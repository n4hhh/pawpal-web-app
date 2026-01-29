$ports = @(3000)
foreach($p in $ports){
  $conns = Get-NetTCPConnection -LocalPort $p -ErrorAction SilentlyContinue
  if($conns){
    $pids = $conns | Select-Object -Unique -ExpandProperty OwningProcess
    foreach($pid in $pids){
      try{
        Stop-Process -Id $pid -Force -ErrorAction Stop
        Write-Output ('Stopped PID {0} on port {1}' -f $pid, $p)
      } catch {
        Write-Output ('Could not stop PID {0} on port {1}: {2}' -f $pid, $p, $_.Exception.Message)
      }
    }
  } else {
    Write-Output "No process on port $p"
  }
}
