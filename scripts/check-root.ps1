try {
  $r = Invoke-RestMethod -Uri 'http://localhost:3000' -Method GET -ErrorAction Stop
  Write-Output 'ROOT_OK'
  Write-Output $r
} catch {
  Write-Output 'ROOT_ERROR'
  Write-Output $_.Exception.Message
}
