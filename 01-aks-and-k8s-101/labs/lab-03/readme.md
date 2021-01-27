
# lab-03 - setting up you shell for better AKS/kubectl experience

## Estimated completion time - xx min

In this lab we will implement simple Azure Function API using HTTP trigger that lets you invoke a function with an HTTP request. API will return response, containing value of environment variable `ENVIRONMENT_NAME'. This variable will contain the name of the current environment and will be set at the provisioning time.

## Goals

* Implement simple dotnet Azure Function API with C# using HTTP trigger
* Test Azure function locally

## Useful links

* [How to make a pretty prompt in Windows Terminal with Powerline, Nerd Fonts, Cascadia Code, WSL, and oh-my-posh](https://www.hanselman.com/blog/how-to-make-a-pretty-prompt-in-windows-terminal-with-powerline-nerd-fonts-cascadia-code-wsl-and-ohmyposh)
* [oh-my-posh themes](https://github.com/JanDeDobbeleer/oh-my-posh#themes)
* [Powershell prompt: How to display your current Kubernetes context](https://blog.guybarrette.com/powershell-prompt-how-to-display-your-current-kubernetes-context)

## Task #1 - configure your PowerShell terminal

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

Note, here I use `Material` because I like it, but you feel free to use other theme theme that makes you happy and use that theme's name here. Read more over [here](https://github.com/JanDeDobbeleer/oh-my-posh#themes).

Now, locate the themes settings file by typing:

```PowerShell
$ThemeSettings
```

use the value of `CurrentThemeLocation` variable, edit that file and add the following lines that will retrieve the Kubernetes context and stuff it inside the prompt.
In my case I edited  `code C:\Users\evgen\Documents\PowerShell\Modules\oh-my-posh\2.0.496\Themes\Material.psm1` and insert these code after line 44, but it might different location if you choose different theme.

```PowerShell
...
$K8sContext=$(Get-Content ~/.kube/config | grep "current-context:" | sed "s/current-context: //")
If ($K8sContext) {
    $prompt += Write-Prompt -Object " [$K8sContext]" -ForegroundColor $sl.Colors.PromptSymbolColor
}
...
```

Save the file and restart Powershell session.


## Next: Containerizing your application

[Go to lab-04](../lab-04/readme.md)
