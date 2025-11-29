function Get-LargeFiles {
    param(
        [string]$Path = $env:USERPROFILE,
        [int64]$MinBytes = 100MB
    )
    Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue |
      Where-Object { $_.Length -ge $MinBytes } |
      Sort-Object Length -Descending
}

function Copy-ItemsSafely {
    param([Parameter(Mandatory)][string]$Source, [Parameter(Mandatory)][string]$Destination)
    try {
        Copy-Item -Path $Source -Destination $Destination -Recurse -ErrorAction Stop
        return $true
    } catch {
        Write-Error "Copy failed: $_"
        return $false
    }
}

Export-ModuleMember -Function Get-LargeFiles, Copy-ItemsSafely
