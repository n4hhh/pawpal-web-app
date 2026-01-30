$body = @{ title='Test Product From Assistant'; price=5.55 } | ConvertTo-Json
try {
  $res = Invoke-RestMethod -Uri 'http://localhost:3000/api/create-product' -Method POST -ContentType 'application/json' -Body $body -ErrorAction Stop
  Write-Output 'RESPONSE_OK'
  $res | ConvertTo-Json -Depth 5 | Write-Output
} catch {
  Write-Output 'RESPONSE_ERROR'
  if ($_.Exception.Response) {
    $sr = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $text = $sr.ReadToEnd()
    Write-Output $text
  } else {
    Write-Output $_.Exception.Message
  }
}
