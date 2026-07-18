# Prettify PowerShell prompt. Need to run $PROFILE to figure out where to put this, it varies.
# Credit: https://commandline.ninja/customize-pscmdprompt/ (Some changes were made)

function prompt {

    #Configure current user, current folder and date outputs
    $CmdPromptCurrentFolder = Split-Path -Path $pwd -Leaf
    $CmdPromptUser = [Security.Principal.WindowsIdentity]::GetCurrent();
    $Date = Get-Date -Format 'dddd hh:mm:ss tt'

    #Assign Windows Title Text
    $host.ui.RawUI.WindowTitle = ":.\$CmdPromptCurrentFolder\"

    # Test for Admin / Elevated
    $IsAdmin = (New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

    #Calculate execution time of last cmd and convert to milliseconds, seconds or minutes
    $LastCommand = Get-History -Count 1
    if ($lastCommand) { $RunTime = ($lastCommand.EndExecutionTime - $lastCommand.StartExecutionTime).TotalSeconds }

    if ($RunTime -ge 60) {
        $ts = [timespan]::fromseconds($RunTime)
        $min, $sec = ($ts.ToString("mm\:ss")).Split(":")
        $ElapsedTime = -join ($min, " min ", $sec, " sec")
    }
    else {
        $ElapsedTime = [math]::Round(($RunTime), 2)
        $ElapsedTime = -join (($ElapsedTime.ToString()), " sec")
    }

    #Decorate the CMD Prompt
    Write-Host ""
    Write-Host "[$elapsedTime] " -NoNewline -ForegroundColor Green
    Write-host ($(if ($IsAdmin) { 'Elevated ' } else { '' })) -BackgroundColor DarkRed -ForegroundColor White -NoNewline
    Write-Host "$($CmdPromptUser.Name.split("\")[1])@$(Hostname)" -BackgroundColor DarkBlue -ForegroundColor White -NoNewline
    Write-Host ":" -NoNewLine
    If ($PWD.Path -eq $Home){
        Write-Host "~"  -ForegroundColor White -BackgroundColor DarkGray -NoNewline
        }
        else {
        # Uncomment the below line and comment out the other to show full path in the prompt.
        Write-Host "$PWD"  -ForegroundColor White -BackgroundColor DarkGray -NoNewline
        # Uncomment the below line and comment out the other to show only the current directory in the prompt. Better for systems with a lot of obnoxiously long folder names.
        #Write-Host ".\$CmdPromptCurrentFolder\" -ForegroundColor White -BackgroundColor DarkGray -NoNewline
        }

    #Write-Host " $date " -ForegroundColor White
    return "> "
} #end prompt function
