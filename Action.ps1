Write-Output "	yosys_rs_plugin start  "

mkdir -Force pmgen

$OldPath = $env:PATH
$env:PATH = "c:\cygwin64\bin"
wget -nc -O pmgen.py https://raw.githubusercontent.com/YosysHQ/yosys/master/passes/pmgen/pmgen.py
$env:PATH = $OldPath

Write-Output " Running python3..."

python3 pmgen.py -o pmgen/rs-dsp-pm.h -p rs_dsp rs_dsp.pmg
python3 pmgen.py -o pmgen/rs-dsp-macc.h -p rs_dsp_macc rs-dsp-macc.pmg
python3 pmgen.py -o pmgen/rs-bram-asymmetric-wider-write.h -p rs_bram_asymmetric_wider_write rs-bram-asymmetric-wider-write.pmg
python3 pmgen.py -o pmgen/rs-bram-asymmetric-wider-read.h -p rs_bram_asymmetric_wider_read rs-bram-asymmetric-wider-read.pmg


Write-Output "  yosys_rs_plugin end  "
