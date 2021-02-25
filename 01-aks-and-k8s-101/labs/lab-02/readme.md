# lab-02 - setting up your shell (bash or PowerShell) for better AKS/kubectl experience

## Estimated completion time - 15 min

When you work with several Kubernetes instances it's important to understand which instance/context you are currently working against. This is especially important when you work with Production cluster. Luckily, it's very easy to configure both bash and PowerShell to display the cluster name of the current context as part of the shell prompt line. 

## Goals

* configure the prompt of shell of your choice to display the current Kubernetes cluster context

If you don't have `oh-my-posh` installed, use `Task #1`. If you already have `oh-my-posh` installed, it's version 2 and you want to keep this version, use `Task #2`

## Task #1 - configure your PowerShell prompt with oh-my-posh v3

Install Posh-Git and Oh-My-Posh

```PowerShell
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
```
If you got a warning telling that you already have `oh-my-posh` installed, you can either upgrade it by using `-Force` flag, or, if you want to keep your version, goto `Task #2`.

Edit your profile by running `code $PROFILE` or `notepad $PROFILE`  and add these lines to the end:

```PowerShell
Import-Module posh-git
Import-Module oh-my-posh
```
save the file and either restart your PowerShell session or reload your profile

```powershell
. $PROFILE
```

Next, set the theme. There are a lot of them. You can preview all themes by running this command 

```powershell
Get-PoshThemes
```

and read about them [here](https://ohmyposh.dev/docs/themes)

I like and use `Material` theme, mainly because it's simple, without any extra noise :)  

First, export theme config so you can customize/extend the blocks and segments.

```powershell
Set-PoshPrompt -Theme Material
Export-PoshTheme -FilePath ~/.oh-my-posh.omp.json
```

Edit `~/.oh-my-posh.omp.json` file and add the following `block` type of [kubectl](https://ohmyposh.dev/docs/kubectl) into the list of `segments`. Checkout detailed [configuration](https://ohmyposh.dev/docs/configure) guide. 

```json
{
    "type": "kubectl",
    "style": "powerline",
    "powerline_symbol": "",
    "invert_powerline": false,
    "foreground": "#66F68F",
    "foreground_templates": null,
    "background": "",
    "background_templates": null,
    "leading_diamond": "",
    "trailing_diamond": "",
    "properties": {
        "template": "[{{.Context}}{{if .Namespace}} :: {{.Namespace}}{{end}}]"
    }
}
```
it's up to you where to place it in the prompt line. I prefer it to be right before the `time` section

![configuration](images/config.png)

Set your custom theme and enjoy.

```powershell
Set-PoshPrompt -Theme  ~/.oh-my-posh.omp.json
```

Edit your profile again by running `code $PROFILE` or `notepad $PROFILE` and new line to the end of this file:

```PowerShell
Import-Module posh-git
Import-Module oh-my-posh
Set-PoshPrompt -Theme  ~/.oh-my-posh.omp.json
```

save the file and either restart your PowerShell session or reload your profile

```powershell
. $PROFILE
```

Now your should have a pretty prompt that shows you you active cluster context.

![ps-k8s](images/ps-k8s.png)

Install a couple of Unix tools using [Chocolatey](https://chocolatey.org/install). We will use them to parse the Kubernetes config file.

```PowerShell
choco install grep
choco install sed
choco install jq
```

Note that as a free bonus, most of the posh themes show you the status of you git repository as well!

For even better experience, you should install the [Cascadia code fonts](https://github.com/microsoft/cascadia-code#installation).

## Task #2 - configure your PowerShell prompt with posh-git v2

Install Posh-Git and Oh-My-Posh

```PowerShell
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
```

Edit your profile by running `code $PROFILE` or `notepad $PROFILE`  and add these lines to the end:

```PowerShell
Import-Module posh-git
Import-Module oh-my-posh
Set-Theme Material
```

save the file and restart your PowerShell session.

Note, here I use `Material` because I like it, but you feel free to use other theme theme that makes you happy and use that theme's name here. Read more over [here](https://ohmyposh.dev/docs/themes).

Install a couple of Unix tools using [Chocolatey](https://chocolatey.org/install). We wil use them to parse the Kubernetes config file.

```PowerShell
choco install grep
choco install sed
choco install jq
```

Restart PowerShell session. Locate the themes settings file by typing:

```PowerShell
PS C:\Users\evgen>$ThemeSettings

CurrentUser          : evgen
CurrentThemeLocation : C:\Users\evgen\Documents\PowerShell\Modules\oh-my-posh\2.0.492\Themes\Material.psm1
CurrentHostname      : DESKTOP-FOOBAR
ErrorCount           : 0
PromptSymbols        : {RootSymbol, UNCSymbol, PromptIndicator, SegmentBackwardSymbol…}
GitSymbols           : {OriginSymbols, AfterStashSymbol, BranchIdenticalStatusToSymbol, BeforeStashSymbol…}
Colors               : {WithForegroundColor, GitDefaultColor, CommandFailedIconForegroundColor, WithBackgroundColor…}
MyThemesLocation     : C:\Users\evgen\Documents\PowerShell\PoshThemes
Options              : {PreserveLastExitCode, OriginSymbols, ConsoleTitle}

```

use the value of `CurrentThemeLocation` variable and edit that file (in my case that was `code C:\Users\evgen\Documents\PowerShell\Modules\oh-my-posh\2.0.496\Themes\Material.psm1`). Add the following lines after line 44 that will retrieve the Kubernetes context and stuff it inside the prompt. Note that it might be a different location inside this file if you use different theme.

```PowerShell
...
$K8sContext=$(Get-Content ~/.kube/config | grep "current-context:" | sed "s/current-context: //")
If ($K8sContext) {
    $prompt += Write-Prompt -Object " [$K8sContext]" -ForegroundColor $sl.Colors.PromptSymbolColor
}
...
```

Save the file and restart Powershell session. Now your should have a pretty prompt that shows you you active cluster context.

![ps-k8s](images/ps-k8s.png)

Note that as a free bonus, most of the posh themes show you the status of you git repository as well!

For even better experience, you should install the [Cascadia code fonts](https://github.com/microsoft/cascadia-code#installation).

## Task #3 - configure your bash prompt

If you are running Linux or mac or [Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/install-win10?WT.mc_id=AZ-MVP-5003837), then here is how you can configure your prompt to display the name of the cluster of your current Kubernetes context. 

Go to your home folder

```bash
cd

#or

cd $HOME
```

Edit `.bashrc` file with editor you normally use and add the following code to the end of the file

```bash

# Kubernetes info
#----------------
generate_kube_info() {
    context=`kubectl config current-context 2>/dev/null`
    if test -n "$context"; then
      namespace=`kubectl config view --template "{{range .contexts}}{{if eq .name \"$context\"}}{{.context.namespace}}{{end}}{{end}}"  2>/dev/null  | grep -v '<no value>'`
      if test -n "$namespace"; then
        context="$context/$namespace"
      fi
    fi
    echo $context
}
# kube info
#---------
kube_info() {
    local BLUE="\[\033[0;36m\]"
    local BLACK="\[\033[0;39m\]"
    if test -f ~/.kube/config; then
        test -d ~/.cache || mkdir ~/.cache
        test -f ~/.cache/kubectx -a ~/.cache/kubectx -nt ~/.kube/config || generate_kube_info >~/.cache/kubectx
        kubectx=`cat ~/.cache/kubectx`
        if test -n "$kubectx"; then
            echo " ${BLUE}[${kubectx}]${BLACK}"
        else
            echo ""
        fi
    else
        echo ""
    fi
}
# Git info
#---------
export GIT_PS1_SHOWDIRTYSTATE=1
gitinfo() {
    if [ "\$(type -t __git_ps1)" ]; then # if we're in a Git repo, show current branch
        BRANCH="\$(__git_ps1 '[ %s ] ')"
        GITEMAIL=`git config user.email`
      __git_ps1 " \[\e[32m\](%s as $GITEMAIL)\[\e[39m\]"
    fi
}
# Set command prompt
#-------------------
prompt_command () {
    local lasterr=$?
    if [ $lasterr -eq 0 ]; then # set an error string for the prompt, if applicable
        ERRPROMPT=""
    else
        ERRPROMPT="\[\033[0;31m\]->($lasterr)\[\033[0;39m\]"
    fi
    export PS1="${debian_chroot:+$debian_chroot:}\w$(gitinfo)$(kube_info)$ERRPROMPT\n\\$ "
}
PROMPT_COMMAND=prompt_command
```

If you already customizing your prompt, you need to adjust/integrate this code into your current profile script.

Save the file and run

```bash
source .bashrc
```

Your prompt should now show both your git repository status (if you are inside git repo folder) and current cluster name

![bash-prompt](images/bash-prompt.png)

## Useful links

* [How to make a pretty prompt in Windows Terminal with Powerline, Nerd Fonts, Cascadia Code, WSL, and oh-my-posh](https://www.hanselman.com/blog/how-to-make-a-pretty-prompt-in-windows-terminal-with-powerline-nerd-fonts-cascadia-code-wsl-and-ohmyposh)
* [oh-my-posh themes](https://github.com/JanDeDobbeleer/oh-my-posh#themes)
* [Powershell prompt: How to display your current Kubernetes context](https://blog.guybarrette.com/powershell-prompt-how-to-display-your-current-kubernetes-context)
* [Oh my Posh home](https://ohmyposh.dev/)

## Next: Containerizing your application

[Go to lab-03](../lab-03/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/3) to comment on this lab. 
