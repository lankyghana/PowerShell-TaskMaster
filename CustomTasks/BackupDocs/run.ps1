function Invoke-Task {
    param($Params)
    $dest = $Params.Destination
    $src = Join-Path $env:USERPROFILE 'Documents'
    $zip = Join-Path $dest ("DocsBackup_{0:yyyyMMddHHmm}.zip" -f (Get-Date))
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::CreateFromDirectory($src, $zip)
        Write-Output "Backup created: $zip"
    } catch {
        Write-Error "Backup failed: $_"
        throw
    }
}
