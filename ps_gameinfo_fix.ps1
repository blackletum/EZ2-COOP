Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$baseRegPath = 'Software\Valve\Source'

function Get-RegistrySubKeyPathsRecursive {
    param(
        [Microsoft.Win32.RegistryKey]$regKey,
        [string]$currentPath = ''
    )
    $results = @()
    try {
        $subKeyNames = $regKey.GetSubKeyNames()
    } catch {
        return $results
    }
    foreach ($name in $subKeyNames) {
        $fullPath = if ($currentPath -eq '') { $name } else { Join-Path $currentPath $name }

        if ($fullPath -imatch 'EntropyZero2') {
            $results += $fullPath
        }

        $subKey = $null
        try {
            $subKey = $regKey.OpenSubKey($name)
        } catch {}
        if ($subKey) {
            $results += Get-RegistrySubKeyPathsRecursive -regKey $subKey -currentPath $fullPath
            $subKey.Close()
        }
    }
    return $results
}

$baseKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($baseRegPath)
if (-not $baseKey) {
    Write-Error "Registry base key not found: HKCU:\$baseRegPath"
    exit 1
}

$allSubKeys = Get-RegistrySubKeyPathsRecursive -regKey $baseKey

# Keep only those that look like paths (start with drive letter)
$pathRegex = '^[A-Za-z]:\\'
$candidatePaths = $allSubKeys | Where-Object { $_ -match $pathRegex }

if (-not $candidatePaths -or $candidatePaths.Count -eq 0) {
    Write-Error "No valid EntropyZero2 install paths found in registry under HKCU:\$baseRegPath"
    $baseKey.Close()
    exit 1
}

function Remove-SubfolderPaths {
    param([string[]]$paths)

    $sorted = $paths | Sort-Object Length

    $filtered = @()
    foreach ($p in $sorted) {
        $isSubfolder = $false
        foreach ($f in $filtered) {
            if ($p.StartsWith($f.TrimEnd('\') + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
                $isSubfolder = $true
                break
            }
        }
        if (-not $isSubfolder) {
            $filtered += $p
        }
    }
    return $filtered
}

$candidatePaths = Remove-SubfolderPaths -paths $candidatePaths

if ($candidatePaths.Count -gt 1) {
    Write-Host "Multiple possible EntropyZero2 install paths found:`n"
    for ($i=0; $i -lt $candidatePaths.Count; $i++) {
        $num = $i + 1
        Write-Host "[$num] $($candidatePaths[$i])"
    }
    $selection = Read-Host "`nEnter the number for the correct install path"
    if ($selection -notmatch '^\d+$' -or [int]$selection -lt 1 -or [int]$selection -gt $candidatePaths.Count) {
        Write-Error "Invalid selection."
        $baseKey.Close()
        exit 1
    }
    $installPath = $candidatePaths[[int]$selection - 1]
} else {
    $installPath = $candidatePaths[0]
}

$baseKey.Close()

if (-not (Test-Path $installPath)) {
    Write-Error "Resolved install path does not exist on disk: $installPath"
    exit 1
}

$absPath = (Resolve-Path $installPath).ProviderPath -replace '\\','/'
$workshopPath = (Resolve-Path '..').ProviderPath -replace '\\','/'

$gameInfoContent = @"
"GameInfo"
{
    game        "Entropy : Zero 2 Coop Mod"
    gamepadui_title    "E N T R O P Y : Z E R O  2"
    ez2_version    "1.7.1 coop-0.1.1"
    supportsvr    0
    GameData    "bin/EntropyZero2.fgd"
    type    singleplayer_only
    icon    "resource/ez2coop_icon"
    FileSystem
    {
        SteamAppId        1583720
        SearchPaths
        {
            game+mod+addon        "$absPath/entropyzero2/custom/*"
            game+mod+addon        "$absPath/ep2/custom/*"
            game+mod+addon        "$absPath/episodic/custom/*"
            game+mod+addon        "$absPath/hl2/custom/*"
            game+mod+mod_write+default_write_path    |gameinfo_path|.
            gamebin        |gameinfo_path|bin
            game+mod+addon    "$absPath/entropyzero2"
            game+mod        "$absPath/entropyzero2/ez2/*"
            gamebin        "$absPath/mapbase/episodic/bin"
            game+mod        "$absPath/mapbase/episodic/*"
            game+mod        "$absPath/mapbase/hl2/*"
            game+mod        "$absPath/mapbase/css_weapons_in_hl2"
            game+mod        "$absPath/mapbase/css_weapons_in_hl2/content/*"
            game+mod        "$absPath/mapbase/shared/shared_content_v7_0.vpk"
            game_lv        "$absPath/hl2/hl2_lv.vpk"
            game+mod        "$absPath/ep2/ep2_english.vpk"
            game+mod        "$absPath/ep2/ep2_pak.vpk"
            game        "$absPath/episodic/ep1_english.vpk"
            game        "$absPath/episodic/ep1_pak.vpk"
            game        "$absPath/hl2/hl2_english.vpk"
            game        "$absPath/hl2/hl2_pak.vpk"
            game        "$absPath/hl2/hl2_textures.vpk"
            game        "$absPath/hl2/hl2_sound_vo_english.vpk"
            game        "$absPath/hl2/hl2_sound_misc.vpk"
            game        "$absPath/hl2/hl2_misc.vpk"
            platform        "$absPath/platform/platform_misc.vpk"
            game+game_write    "$absPath/ep2"
            gamebin        "$absPath/episodic/bin"
            game        "$absPath/episodic"
            game        "$absPath/hl2"
            platform        "$absPath/platform"
        }
    }
}
"@

Set-Content -Path 'gameinfo.txt' -Value $gameInfoContent -Encoding ASCII

Write-Host "`ngameinfo.txt generated successfully using path:`n$installPath"
exit 0