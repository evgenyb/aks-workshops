using Microsoft.Extensions.Primitives;
using System;
using System.Collections.Generic;
using System.IO;
using System.Security.Cryptography;
using System.Threading;
using Timer = System.Threading.Timer;
using Microsoft.Extensions.FileProviders;
using Microsoft.Extensions.FileProviders.Internal;
using Microsoft.Extensions.FileProviders.Physical;
using System.Collections.Concurrent;
using System.Reflection;


// Taken from the article by Francisco Beltrao
// https://medium.com/@fbeltrao/automatically-reload-configuration-changes-based-on-kubernetes-config-maps-in-a-net-d956f8c8399a
// https://raw.githubusercontent.com/fbeltrao/ConfigMapFileProvider/master/src/ConfigMapFileProviderSample/ConfigMapFileProviderChangeToken.cs
//
// Disclaimer: this is a quick implementation, not tested in different environments/configurations. Use at your own risk.
namespace api_a
{

    /// <summary>
    /// Simple <see cref="IFileProvider"/> implementation using config maps as source
    /// Config maps volumes in Linux/Kubernetes are implemented as symlink files.
    /// Once reloaded their Last modified date does not change. This implementation uses a check sum to verify
    /// </summary>
    public class ConfigMapFileProvider : IFileProvider
    {
        ConcurrentDictionary<string, ConfigMapFileProviderChangeToken> watchers;

        public static IFileProvider FromRelativePath(string subPath)
        {
            var executableLocation = Assembly.GetEntryAssembly().Location;
            var executablePath = Path.GetDirectoryName(executableLocation);
            var configPath = Path.Combine(executablePath, subPath);
            if (Directory.Exists(configPath))
            {
                return new ConfigMapFileProvider(configPath);
            }

            return null;
        }

        public ConfigMapFileProvider(string rootPath)
        {
            if (string.IsNullOrWhiteSpace(rootPath))
            {
                throw new System.ArgumentException("Invalid root path", nameof(rootPath));
            }

            RootPath = rootPath;
            watchers = new ConcurrentDictionary<string, ConfigMapFileProviderChangeToken>();
        }

        public string RootPath { get; }

        public IDirectoryContents GetDirectoryContents(string subpath)
        {
            return new PhysicalDirectoryContents(Path.Combine(RootPath, subpath));
        }

        public IFileInfo GetFileInfo(string subpath)
        {
            var fi = new FileInfo(Path.Combine(RootPath, subpath));
            return new PhysicalFileInfo(fi);
        }

        public IChangeToken Watch(string filter)
        {
            var watcher = watchers.AddOrUpdate(filter,
                addValueFactory: (f) =>
                {
                    return new ConfigMapFileProviderChangeToken(RootPath, filter);
                },
                updateValueFactory: (f, e) =>
                {
                    e.Dispose();
                    return new ConfigMapFileProviderChangeToken(RootPath, filter);
                });

            watcher.EnsureStarted();
            return watcher;
        }
    }

    public sealed class ConfigMapFileProviderChangeToken : IChangeToken, IDisposable
    {
        class CallbackRegistration : IDisposable
        {
            Action<object> callback;
            object state;
            Action<CallbackRegistration> unregister;


            public CallbackRegistration(Action<object> callback, object state, Action<CallbackRegistration> unregister)
            {
                this.callback = callback;
                this.state = state;
                this.unregister = unregister;
            }

            public void Notify()
            {
                var localState = this.state;
                var localCallback = this.callback;
                if (localCallback != null)
                {
                    localCallback.Invoke(localState);
                }
            }


            public void Dispose()
            {
                var localUnregister = Interlocked.Exchange(ref unregister, null);
                if (localUnregister != null)
                {
                    localUnregister(this);
                    this.callback = null;
                    this.state = null;
                }
            }
        }

        List<CallbackRegistration> registeredCallbacks;
        private readonly string rootPath;
        private string filter;
        private readonly int detectChangeIntervalMs;
        private Timer timer;
        private bool hasChanged;
        private string lastChecksum;
        object timerLock = new object();

        public ConfigMapFileProviderChangeToken(string rootPath, string filter, int detectChangeIntervalMs = 30_000)
        {
            Console.WriteLine($"new {nameof(ConfigMapFileProviderChangeToken)} for {filter}");
            registeredCallbacks = new List<CallbackRegistration>();
            this.rootPath = rootPath;
            this.filter = filter;
            this.detectChangeIntervalMs = detectChangeIntervalMs;
        }

        internal void EnsureStarted()
        {
            lock (timerLock)
            {
                if (timer == null)
                {
                    var fullPath = Path.Combine(rootPath, filter);
                    if (File.Exists(fullPath))
                    {
                        this.timer = new Timer(CheckForChanges);
                        this.timer.Change(0, detectChangeIntervalMs);
                    }
                }
            }
        }

        private void CheckForChanges(object state)
        {
            var fullPath = Path.Combine(rootPath, filter);

            Console.WriteLine($"Checking for changes in {fullPath}");

            var newCheckSum = GetFileChecksum(fullPath);
            var newHasChangesValue = false;
            if (this.lastChecksum != null && this.lastChecksum != newCheckSum)
            {
                Console.WriteLine($"File {fullPath} was modified!");

                // changed
                NotifyChanges();

                newHasChangesValue = true;
            }

            this.hasChanged = newHasChangesValue;

            this.lastChecksum = newCheckSum;

        }

        private void NotifyChanges()
        {
            var localRegisteredCallbacks = registeredCallbacks;
            if (localRegisteredCallbacks != null)
            {
                var count = localRegisteredCallbacks.Count;
                for (int i = 0; i < count; i++)
                {
                    localRegisteredCallbacks[i].Notify();
                }
            }
        }

        string GetFileChecksum(string filename)
        {
            using (var md5 = MD5.Create())
            {
                using (var stream = File.OpenRead(filename))
                {
                    return BitConverter.ToString(md5.ComputeHash(stream));
                }
            }
        }

        public bool HasChanged => this.hasChanged;

        public bool ActiveChangeCallbacks => true;

        public IDisposable RegisterChangeCallback(Action<object> callback, object state)
        {
            var localRegisteredCallbacks = registeredCallbacks;
            if (localRegisteredCallbacks == null)
                throw new ObjectDisposedException(nameof(registeredCallbacks));

            var cbRegistration = new CallbackRegistration(callback, state, (cb) => localRegisteredCallbacks.Remove(cb));
            localRegisteredCallbacks.Add(cbRegistration);

            return cbRegistration;
        }

        public void Dispose()
        {
            Interlocked.Exchange(ref registeredCallbacks, null);

            Timer localTimer = null;
            lock (timerLock)
            {
                localTimer = Interlocked.Exchange(ref timer, null);
            }

            if (localTimer != null)
            {
                localTimer.Dispose();
            }
        }
    }
}