# Prettify the PowerShell prompt. You need to run $Profile to figure out where to put this, it varies.

# Credit: https://commandline.ninja/customize-pscmdprompt/ (Changes were made)

# Settings
$global:ShowUserName = 1                    # 0 - off, 1 - on # Show the username
$global:ShowHostName = 1                    # 0 - off, 1 - on # Show the hostname
$global:ShowAdminAlert = 1                  # 0 - off, 1 - on # Show a warning if you're running elevated (note, this only works in new windows) 
$global:ChangeWindowTitles = 1              # 0 - off, 1 - directory only, 2 - entire path # Change the window title to match the working directory
$global:ShowWorkingDir = 2                  # 0 - off, 1 - directory only, 2 - entire path # Change the prompt to match the working directory
$global:ShowLastTime = 1                    # 0 - off, 1 - on # Show the runtime of the last-executed command
$global:ShowDateTime = 0                    # 0 - off, 1 - on # Show the date/time
$global:DateTimeFormat = "dddd hh:mm:ss"    # Format for the date/time # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-date?view=powershell-7.6


# Colors

# Use PowerShell color names WITH quotes # https://stackoverflow.com/questions/20541456/list-of-all-colors-available-for-powershell
# To avoid changing the color for a certain value, set it to "(Get-Host).ui.rawui.BackgroundColor" WITHOUT quotes

$global:BGPromptChar = "DarkBlue"                             # Background color for prompt characters (@,:)
$global:FGPromptChar = "White"                                # Foreground color for prompt characters (@,:)

$global:BGLastTime = (Get-Host).ui.rawui.BackgroundColor      # Background color for last command time
$global:FGLastTime = "Green"                                  # Foreground color for last command time

$global:BGDateTime = "Black"                                  # Background color for date
$global:FGDateTime = "White"                                  # Foreground color for date


$global:BGAdminAlert = "DarkRed"                              # Background color for admin/elevated warning
$global:FGAdminAlert = "White"                                # Foreground color for admin/elevated warning

$global:BGUserName = "DarkBlue"                               # Background color for username
$global:FGUserName = "Green"                                  # Foreground color for username

$global:BGHostName = "DarkBlue"                               # Background color for hostname
$global:FGHostName = "DarkMagenta"                            # Foreground color for hostname

$global:BGDirName = "DarkGray"                                # Background color for directory
$global:FGDirName = "White"                                   # Foregroung color for directory




# Define functions
function Admin-Test {
    # Test for Admin/Elevated
    $global:IsAdmin = (New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Last-Time {
    # Calculate execution time of last cmd and convert to milliseconds, seconds or minutes
    $global:LastCommand = Get-History -Count 1
    if ($LastCommand) { 
        $RunTime = ($LastCommand.EndExecutionTime - $LastCommand.StartExecutionTime).TotalSeconds
        
    }
    if ($RunTime -ge 60) {
        $ts = [timespan]::fromseconds($RunTime)
        $min, $sec = ($ts.ToString("mm\:ss")).Split(":")
        $glboal:ElapsedTime = -join ($min, " min ", $sec, " sec")
    }
    else {
        $global:ElapsedTime = [math]::Round(($RunTime), 2)
        $global:ElapsedTime = -join (($ElapsedTime.ToString()), " sec")
    }
}


# Main function

function prompt {
    # Decorate the CMD Prompt
    # Apparently, this function actually has to be called "prompt"
    # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_prompts?view=powershell-7.6
    Admin-Test
    Last-Time
    # Configure current user
    $global:CmdPromptUser = [Security.Principal.WindowsIdentity]::GetCurrent();
    # Get the current working dir
    $global:WorkingDir = Split-Path -Path $PWD -Leaf
    $global:WorkingRoot = "$(Split-Path -Path $PWD -Qualifier)\"

    if ($ChangeWindowTitles -eq 1) {
        # Assign Windows Title Text, short version
        if ($WorkingDir -eq $WorkingRoot) {
            # Avoid prepending "..\" if already at the drive root
            $host.ui.RawUI.WindowTitle = "$WorkingDir"
        }
        else {
            # If not, do prepend it
            $host.ui.RawUI.WindowTitle = "..\$WorkingDir"
        }
    }
    if ($ChangeWindowTitles -eq 2) {
        # Assign Windows Title Text, long version
        $host.ui.RawUI.WindowTitle = "$PWD"
    }
    if ($ShowDateTime -eq 1) {
        # Show the date
        Write-Host "$(Get-Date -Format $DateTimeFormat)" -NoNewline -BackgroundColor $BGDateTime -ForegroundColor $FGDateTime
        Write-Host " " -NoNewline
    }
    if ($ShowLastTime -eq 1) {
        # Show the time of last command
        Write-Host "[$ElapsedTime]" -NoNewline -BackgroundColor $BGLastTime -ForegroundColor $FGLastTime
    }
    if ($ShowAdminAlert -eq 1) {
        # Show the admin warning
        Write-Host ($(if ($IsAdmin) { 'Elevated' } else { '' })) -BackgroundColor $BGAdminAlert -ForegroundColor $FGAdminAlert -NoNewline
	    Write-Host " " -NoNewline
    }
    if ($ShowUserName -eq 1) {
        # Show the username
        Write-Host "$($CmdPromptUser.Name.split("\")[1])" -NoNewLine -BackgroundColor $BGUserName -ForegroundColor $FGUserName
        if ($ShowHostName -eq 1) {
            # Only print the "@" sign if we want to show the hostname
            Write-Host "@" -BackgroundColor $BGPromptChar -ForegroundColor $FGPromptChar -NoNewline
        }
    }
    if ($ShowHostName -eq 1) {
        # Show the hostname
        Write-Host "$(Hostname)" -BackgroundColor $BGHostName -ForegroundColor $FGHostName -NoNewline
    }

    if ($ShowWorkingDir -eq 1) {
        Write-Host ":" -BackgroundColor $BGPromptChar -ForegroundColor $FGPromptChar -NoNewline
        # Print the directory, short version
        if ($PWD.Path -eq $Home) {
           # Shorten to a ~ if at home, bash-like
            Write-Host "~" -BackgroundColor $BGDirName -ForegroundColor $FGDirName -NoNewline
        }
        else {
            if ($WorkingDir -eq $WorkingRoot) {
                # Avoid printing the "..\" if you're already at the root of a drive
                Write-Host "$WorkingDir" -BackgroundColor $BGDirName -ForegroundColor $FGDirName -NoNewline
            }
            else {
                # Prepend "..\" if you aren't
                Write-Host "..\$WorkingDir"  -BackgroundColor $BGDirName -ForegroundColor $FGDirName -NoNewline
            }
        }
    }
    if ($ShowWorkingDir -eq 2) {
        # Print the directory, long version
        Write-Host ":" -BackgroundColor $BGPromptChar -ForegroundColor $FGPromptChar -NoNewline
        if ($PWD.Path -eq $Home) {
            # Shorten to a ~ if at home, bash-like
            Write-Host "~" -BackgroundColor $BGDirName -ForegroundColor $FGDirName -NoNewline
        }
        else {
            Write-Host "$PWD" -BackgroundColor $BGDirName -ForegroundColor $FGDirName -NoNewline
        }
    }
    return "> " # End with a greater than
}