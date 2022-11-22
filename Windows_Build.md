On Windows you need to install wget from here
	https://sourceforge.net/projects/gnuwin32/files/wget/1.11.4-1/wget-1.11.4-1-setup.exe/download?use_mirror=excellmedia

and after then run following commands
```bash
mkdir pmgen
wget -nc -O pmgen.py https://raw.githubusercontent.com/YosysHQ/yosys/master/passes/pmgen/pmgen.py
python3 pmgen.py -o pmgen/rs-dsp-pm.h -p rs_dsp rs_dsp.pmg
python3 pmgen.py -o pmgen/rs-dsp-macc.h -p rs_dsp_macc rs-dsp-macc.pmg
python3 pmgen.py -o pmgen/rs-bram-asymmetric-wider-write.h -p rs_bram_asymmetric_wider_write rs-bram-asymmetric-wider-write.pmg
python3 pmgen.py -o pmgen/rs-bram-asymmetric-wider-read.h -p rs_bram_asymmetric_wider_read rs-bram-asymmetric-wider-read.pmg
```

At the last step install yosys_rs_plagin as a static library
