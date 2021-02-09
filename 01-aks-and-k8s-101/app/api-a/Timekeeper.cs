
namespace api_a
{
    public static class Timekeeper
    {
        private static System.Diagnostics.Stopwatch Stopwatch = new System.Diagnostics.Stopwatch();

        public static void Start() { Stopwatch.Start(); }
        public static long GetSecondsFromStart() { return Stopwatch.ElapsedMilliseconds / 1000; }
        public static int GetMinutesFromStart() { return (int)(GetSecondsFromStart() / 60); }
    }
}
