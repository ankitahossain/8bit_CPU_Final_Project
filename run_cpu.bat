@echo off
REM Mini 8-bit CPU (Set 0). Run from the folder with the .vhd files,
REM with GHDL's bin folder on PATH.
set STD=--std=08

ghdl -a %STD% gates.vhd alu.vhd control_unit.vhd program_rom.vhd pc.vhd acc_z_reg.vhd cpu_top.vhd tb_cpu.vhd || goto :err
ghdl -e %STD% tb_cpu || goto :err
ghdl -r %STD% tb_cpu --wave=cpu.ghw || goto :err

echo.
echo Done. Open cpu.ghw in GTKWave and add: clk, reset, pc, q (ACC), z.
goto :eof

:err
echo Something failed - check the messages above.
