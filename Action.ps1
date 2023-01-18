Write-Output "	yosys_rs_plugin start  "

mkdir -Force pmgen

$OldPATH = $env:PATH
$env:PATH = (Test-Path -Path "C:\cygwin64\bin") ? "C:\cygwin64\bin\" : "C:\cygwin\bin\"
$env:PATH -split ";"
$Cygwin = $env:PATH + "bash.exe"
$arg = "-c"

& $Cygwin $arg "wget -nc -O pmgen.py https://raw.githubusercontent.com/YosysHQ/yosys/master/passes/pmgen/pmgen.py"

Write-Output " Running python3..."

& $Cygwin $arg "python3 pmgen.py -o pmgen/rs-dsp-pm.h -p rs_dsp rs_dsp.pmg"
& $Cygwin $arg "python3 pmgen.py -o pmgen/rs-dsp-macc.h -p rs_dsp_macc rs-dsp-macc.pmg"
& $Cygwin $arg "python3 pmgen.py -o pmgen/rs-bram-asymmetric-wider-write.h -p rs_bram_asymmetric_wider_write rs-bram-asymmetric-wider-write.pmg"
& $Cygwin $arg "python3 pmgen.py -o pmgen/rs-bram-asymmetric-wider-read.h -p rs_bram_asymmetric_wider_read rs-bram-asymmetric-wider-read.pmg"

$env:PATH = $OldPath

Write-Output "  yosys_rs_plugin end  "
