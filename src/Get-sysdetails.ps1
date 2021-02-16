#!/usr/bin/env pwsh
#requires -version 5
#
#   This is a fork created and maintained by Stephen Preston and contributers
#  This was forked from URL: https://github.com/lptstr/winfetch Author: lptstr
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
.VERSION 1.2.3
.GUID 1c26142a-da43-4125-9d70-97555cbb1752
.DESCRIPTION This powershell script is based on Winfetch a command-line system information utility for Windows written in PowerShell. https://github.com/Flipyourbit/winfetch_FYB 
.AUTHOR Stephen Preston
.PROJECTURI https://github.com/Flipyourbit/winfetch_FYB  
.COMPANYNAME
.COPYRIGHT
.TAGS
.LICENSEURI
.ICONURI
.EXTERNALMODULEDEPENDENCIESforked 
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
$hypervdata = Get-ItemProperty -path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters' -ErrorAction SilentlyContinue
$biosdata = Get-CimInstance -ClassName win32_bios -CimSession $cimSession
$microcodedata = Get-ItemProperty -path 'Registry::HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\CentralProcessor\0\' -ErrorAction SilentlyContinue
# ===== CONFIGURATION =====
$config = @(
    "title"
    "dashes"
    "os"
    "platform"
    "kernel"
    "biosver"
    "mrcodeact"
    "mrcodebios"
    "manufacturer"
    "serialnumber"
    "uptime"
    "lastreboot"
    "hypervhost"
    "vmnameonhost"
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
} 170


# ===== COLORBAR =====
function info_colorbar {
    return @{
       #< title   = ""
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


$hypervdata = Get-ItemProperty -path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters' -ErrorAction SilentlyContinue
# ===== platform =====
function info_platform {
    $compsys = Get-CimInstance -ClassName Win32_ComputerSystem -Property Manufacturer,Model -CimSession $cimSession
    return @{
        title   = "Platform"
        content = '{0} {1}' -f $compsys.Manufacturer, $compsys.Model
    }
}




# ===== KERNEL =====
function info_kernel {
    return @{
        title   = "Kernel"
        content = if ($IsWindows -or $PSVersionTable.PSVersion.Major -eq 5) {
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
# this section works by getting  parent processes of the current powershell instance.
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


# ===== CPU/CPU Microcode/GPU =====
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

function info_mrcodebios {


    return @{
        title   = "Microcode Bios"
        content = "0x" +  (-join ( ($microcodedata.'previous update revision')[0..4] | ForEach-Object { $_.ToString("X2") } )).TrimStart('0')
    }
}
function info_mrcodeact {

    return @{
        title   = "Microcode Active"
        content = "0x" + (-join ( ($microcodedata."update revision")[0..4] | ForEach-Object { $_.ToString("X2") } )).TrimStart('0')
    }
}

# ===== SN/BIOS/Manufacturer =====
function info_biosver {
    return @{
        title   = "Bios Version"
        content = $biosdata.SMBIOSBIOSVersion
    }
}

function info_manufacturer {
    return @{
        title   = "Manufacturer"
        content = $biosdata.Manufacturer
    }
}
function info_serialnumber {
    return @{
        title   = "Serial Number"
        content = $biosdata.SerialNumber
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
# ===== last Reboot =====

function info_lastreboot {
    return @{
        title   = "Last Reboot"
        content =  (Get-CimInstance -ClassName Win32_OperatingSystem -Property LastBootUpTime -CimSession $cimSession).LastBootUpTime
    }
}

# ===== Hyper-V host =====
function info_hypervhost {
    #Place logic if not on Hyper-V host
    if($null -ne $hypervdata){
        $vmhostdata =  ($hypervdata).HostName
     }
     else {$vmhostdata = "NA"}
    return @{
        title   = "Hyper-V Host"
        content = $vmhostdata 
    }
}
# ===== VMname on Hyper-V host =====
function info_vmnameonhost {
    #Place logic if not on Hyper-V host
    if($null -ne $hypervdata){
       $hostdata =  ($hypervdata).virtualmachinename
    }
    else {$hostdata = "NA"}
    return @{
        title   = "VMName"
        content = $hostdata 
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
