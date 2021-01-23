#!/usr/bin/env pwsh
#requires -version 5
#
#   This is a fork created and maintained by Stephen Preston and contributers
#
# The MIT License (MIT)
# Copyright (c) 2019 Kied Llaentenn and contributers
#
#
# 
#
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.



<#PSScriptInfo
.VERSION 1.2.1
.GUID 1c26142a-da43-4125-9d70-97555cbb1752
.DESCRIPTION Winfetch is a command-line system information utility for Windows written in PowerShell.
.AUTHOR lptstr
.PROJECTURI https://github.com/lptstr/winfetch
.COMPANYNAME
.COPYRIGHT
.TAGS
.LICENSEURI
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
#>
<#
.SYNOPSIS
    Winfetch - Neofetch for Windows in PowerShell 5+
.DESCRIPTION
    Winfetch is a command-line system information utility for Windows written in PowerShell.
.PARAMETER noimage
    Do not display any image or logo; display information only.
.PARAMETER help
    Display this help message.
.INPUTS
    System.String
.OUTPUTS
    System.String[]
.NOTES
    Run Winfetch without arguments to view core functionality.
#>
[CmdletBinding()]
param(
    [switch][alias('n')]$noimage,
    [switch][alias('h')]$help
)

$e = [char]0x1B

$is_pscore = $PSVersionTable.PSEdition.ToString() -eq 'Core'


# ===== DISPLAY HELP =====
if ($help) {
    if (Get-Command -Name less -ErrorAction Ignore) {
        Get-Help ($MyInvocation.MyCommand.Definition) -Full | less
    } else {
        Get-Help ($MyInvocation.MyCommand.Definition) -Full
    }
    exit 0
}



# ===== VARIABLES =====
$cimSession = New-CimSession


# ===== CONFIGURATION =====
$config = @(
    "title"
    "dashes"
    "os"
    "computer"
    "kernel"
    "uptime"
    "pkgs"
    "pwsh"
    "terminal"
    "cpu"
    "gpu"
    "memory"
    "disk"
    "blank"
    "colorbar"
)

# ===== IMAGE =====
$img = if (-not $image -and -not $noimage) {
    @(
        "${e}[1;32m                    ....,,:;+ccllll${e}[0m"
        "${e}[1;32m      ...,,+:;  cllllllllllllllllll${e}[0m"
        "${e}[1;32m,cclllllllllll  lllllllllllllllllll${e}[0m"
        "${e}[1;32mllllllllllllll  lllllllllllllllllll${e}[0m"
        "${e}[1;32mllllllllllllll  lllllllllllllllllll${e}[0m"
        "${e}[1;32mllllllllllllll  lllllllllllllllllll${e}[0m"
        "${e}[1;32mllllllllllllll  lllllllllllllllllll${e}[0m"
        "${e}[1;32mllllllllllllll  lllllllllllllllllll${e}[0m"
        "${e}[1;32m                                   ${e}[0m"
        "${e}[1;32mllllllllllllll  lllllllllllllllllll${e}[0m"
        "${e}[1;32mllllllllllllll  lllllllllllllllllll${e}[0m"
        "${e}[1;32mllllllllllllll  lllllllllllllllllll${e}[0m"
        "${e}[1;32mllllllllllllll  lllllllllllllllllll${e}[0m"
        "${e}[1;32mllllllllllllll  lllllllllllllllllll${e}[0m"
        "${e}[1;32m``'ccllllllllll  lllllllllllllllllll${e}[0m"
        "${e}[1;32m      ``' \\*::  :ccllllllllllllllll${e}[0m"
        "${e}[1;32m                       ````````''*::cll${e}[0m"
        "${e}[1;32m                                 ````${e}[0m"
    )
}

# ===== BLANK =====
function info_blank {
    return @{}
}


# ===== COLORBAR =====
function info_colorbar {
    return @{
        title   = ""
        content = ('{0}[0;40m{1}{0}[0;41m{1}{0}[0;42m{1}{0}[0;43m{1}' +
            '{0}[0;44m{1}{0}[0;45m{1}{0}[0;46m{1}{0}[0;47m{1}' +
            '{0}[0m') -f $e, '   '
    }
}


# ===== OS =====
function info_os {
    return @{
        title   = "OS"
        content = if ($IsWindows -or $PSVersionTable.PSVersion.Major -eq 5) {
            $os = Get-CimInstance -ClassName Win32_OperatingSystem -Property Caption,OSArchitecture -CimSession $cimSession
            "$($os.Caption.TrimStart('Microsoft ')) [$($os.OSArchitecture)]"
        } else {
            ($PSVersionTable.OS).TrimStart('Microsoft ')
        }
    }
}


# ===== TITLE =====
function info_title {
    return @{
        title   = ""
        content = "${e}[1;32m{0}${e}[0m@${e}[1;32m{1}${e}[0m" -f [Environment]::UserName,$env:COMPUTERNAME
    }
}


# ===== DASHES =====
function info_dashes {
    $length = [Environment]::UserName.Length + $env:COMPUTERNAME.Length + 1
    return @{
        title   = ""
        content = "-" * $length
    }
}


# ===== COMPUTER =====
function info_computer {
    $compsys = Get-CimInstance -ClassName Win32_ComputerSystem -Property Manufacturer,Model -CimSession $cimSession
    return @{
        title   = "Platform"
        content = '{0} {1}' -f $compsys.Manufacturer, $compsys.Model
    }
}


# Stephen to update

# ===== KERNEL =====
function info_kernel {
    return @{
        title   = "Kernel"
        content = if ($IsWindows -or $PSVersionTable.PSVersion.Major -eq 5) {
        #revised code displays revision number b since it was never added to Env variable  or WMI this be pulled from the registery
        "$([System.Environment]::OSVersion.Version.Major)"  + "." + "$([System.Environment]::OSVersion.Version.Minor)"  + "." +  ($(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' CurrentBuild).CurrentBuild) + "." +  ($(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' UBR).UBR)
       
        } else {
            "$(uname -r)"
        }
    }
}


# ===== UPTIME =====
function info_uptime {
    @{
        title   = "Uptime"
        content = $(switch ((Get-Date) - (Get-CimInstance -ClassName Win32_OperatingSystem -Property LastBootUpTime -CimSession $cimSession).LastBootUpTime) {
            ({ $PSItem.Days -eq 1 }) { '1 day' }
            ({ $PSItem.Days -gt 1 }) { "$($PSItem.Days) days" }
            ({ $PSItem.Hours -eq 1 }) { '1 hour' }
            ({ $PSItem.Hours -gt 1 }) { "$($PSItem.Hours) hours" }
            ({ $PSItem.Minutes -eq 1 }) { '1 minute' }
            ({ $PSItem.Minutes -gt 1 }) { "$($PSItem.Minutes) minutes" }
        }) -join ' '
    }
}


# ===== TERMINAL =====
# this section works by getting the parent processes of the current powershell instance.
function info_terminal {
    if (-not $is_pscore) {
        $parent = Get-Process -Id (Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $PID" -Property ParentProcessId -CimSession $cimSession).ParentProcessId
        for () {
            if ($parent.ProcessName -in 'powershell', 'pwsh', 'winpty-agent', 'cmd', 'zsh', 'bash') {
                $parent = Get-Process -Id (Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $($parent.ID)" -Property ParentProcessId -CimSession $cimSession).ParentProcessId
                continue
            }
            break
        }
    } else {
        $parent = (Get-Process -Id $PID).Parent
        for () {
            if ($parent.ProcessName -in 'powershell', 'pwsh', 'winpty-agent', 'cmd', 'zsh', 'bash') {
                $parent = (Get-Process -Id $parent.ID).Parent
                continue
            }
            break
        }
    }
    try {
        $terminal = switch ($parent.ProcessName) {
            'explorer' { 'Windows Console' }
            'Code' { 'Visual Studio Code' }
            default { $PSItem }
        }
    } catch {
        $terminal = $parent.ProcessName
    }

    return @{
        title   = "Terminal"
        content = $terminal
    }
}


# ===== CPU/GPU =====
function info_cpu {
    return @{
        title   = "CPU"
        content = (Get-CimInstance -ClassName Win32_Processor -Property Name -CimSession $cimSession).Name
    }
}

function info_gpu {
    return @{
        title   = "GPU"
        content = (Get-CimInstance -ClassName Win32_VideoController -Property Name -CimSession $cimSession).Name
    }
}


# ===== MEMORY =====
function info_memory {
    $m = Get-CimInstance -ClassName Win32_OperatingSystem -Property TotalVisibleMemorySize,FreePhysicalMemory -CimSession $cimSession
    $total = $m.TotalVisibleMemorySize / 1mb
    $used = ($m.TotalVisibleMemorySize - $m.FreePhysicalMemory) / 1mb
    return @{
        title   = "Memory"
        content = ("{0:f1} GiB / {1:f1} GiB" -f $used,$total)
    }
}


# ===== DISK USAGE =====
function info_disk {
    $disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DeviceID="C:"' -Property Size,FreeSpace -CimSession $cimSession
    $total = [math]::floor(($disk.Size / 1gb))
    $used = [math]::floor((($disk.FreeSpace - $total) / 1gb))
    $usage = [math]::floor(($used / $total * 100))
    return @{
        title   = "Disk (C:)"
        content = ("{0}GiB / {1}GiB ({2}%)" -f $used,$total,$usage)
    }
}


# ===== POWERSHELL VERSION =====
function info_pwsh {
    return @{
        title   = "Shell"
        content = "PowerShell v$($PSVersionTable.PSVersion)"
    }
}


# ===== PACKAGES =====
# find another function
function info_pkgs {
    $chocopkg = if (Get-Command -Name choco -ErrorAction Ignore) {
        (& clist -l)[-1].Split(' ')[0] - 1
    }

    $scooppkg = if (Get-Command -Name scoop -ErrorAction Ignore) {
        $scoop = & scoop which scoop
        $scoopdir = (Resolve-Path "$(Split-Path -Path $scoop)\..\..\..").Path
        (Get-ChildItem -Path $scoopdir -Directory).Count - 1
    }

    $pkgs = $(if ($scooppkg) {
        "$scooppkg (scoop)"
    }
    if ($chocopkg) {
        "$chocopkg (choco)"
    }) -join ', '

    return @{
        title   = "Packages"
        content = $pkgs
    }
}


# reset terminal sequences and display a newline
Write-Host "$e[0m"

# write logo
foreach ($line in $img) {
    Write-Host " $line"
}

# move cursor to top of image and to column 40
if ($img) {
    Write-Host -NoNewLine "$e[$($img.Length)A$e[40G" 
}

# write info
foreach ($item in $config) {
    if (Test-Path Function:"info_$item") {
        $info = & "info_$item"
    } else {
        $info = @{ title = "$e[31mfunction 'info_$item' not found" }
    }

    if (-not $info) {
        continue
    }

    $output = "$e[1;32m$($info.title)$e[0m"

    if ($info.title -and $info.content) {
        $output += ": "
    }

    $output += "$($info.content)`n"

    # move cursor to column 40
    if ($img) {
        $output += "$e[40G"
    }

    Write-Host -NoNewLine $output
}

# move cursor back to the bottom
if ($img) {
    Write-Host -NoNewLine "$e[$($img.Length - $config.Length)B"
}

# print 2 newlines
Write-Host "`n"

#  ___ ___  ___
# | __/ _ \| __|
# | _| (_) | _|
# |___\___/|_|
#
