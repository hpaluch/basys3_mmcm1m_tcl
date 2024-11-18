# 1 MHz cascade MMCM clock base example for Artix-7 Basys3 board

Most trivial example how to use MMCM IP "Clock Wizard" to generate 1 MHz clock
from 100 MHz on-board clock for Artix-7 Digilent Basys3 board and Vivado
2024.1.

Please note that normally only 4.69 Mhz or higher output frequency is permitted on MMCM
output. However using `CLKOUT4_CASCADE = TRUE` new minimum is 0.036 MHz. See [DS181](DS181) for more details

> Work in Progress.
>
> There is warning `HSR_BOUNDARY_TOP`, seen also on: https://adaptivesupport.amd.com/s/question/0D54U00008fEHC9SAO/wrong-fdre-output-during-postimplementation-simulation?language=en_US
> - probably harmless(?)

Status:
- TCL script [aa-gen-project.tcl](aa-gen-project.tcl) now generates project `../basys3_mmcm1m_work/basys3_mmcm1m_work.xpr`
  without error
- Project `../basys3_mmcm1m_work/basys3_mmcm1m_work.xpr` now builds without fatal error - single warning
  about `HSR_BOUNDARY_TOP`

This project is based on "IP Design Example..." code (see
[clk_wiz_0_exdes.v](clk_wiz_0_exdes.v), generated from "Clock Wizard", that
handles properly RESET using several `ASYNC_REG` shift registers - it is serous
stuff where intuition is not enough.

# Setup

Tested Vivado 2024.1 on Linux (Alma Linux 8.7). Command has to be run in this directory:
```shell
bash$ /opt/Xilinx/Vivado/2024.1/bin/vivado -mode tcl
Vivado% ls
Vivado% source aa-gen-project.tcl
Vivado% exit   # exit vivado to avoid project sharing clashes
```

Now open generated project `../basys3_mmcm1m_work/basys3_mmcm1m_work.xpr` in normal `Vivado 2024.1` GUI.
And generate bitstream using Flow Navigator -> Program and Debug -> Generate Bitstream (confirm
that you want to use all previous steps).

# Function

On-board 100 MHz clock is converted to 1 MHz using Artix-7 MMCM module (via
"Clock Wizard" IP) and used for internal counter.  Activity shown on LEDs and
PMOD JA connector (for logic analyzer).

Inputs:
- `btnC` (central button in keypad) - RESET when pressed

Outputs:
- `LD 0`, `PMOD JA1` - copy of RESET button state (Active High)
- `LD 1`, `PMOD JA2` - `safe_reset` - synchronous RESET for safe use with other modules
- `LD 2`, `PMOD JA3` - `locked` - active when MMCM clock output is valid
- `LD 3`, `PMOD JA7` - `COUNT` slow counter output
- `PMOD JA4` - internal 1 MHz clock symmetrized using ODDR (output double rate), but 2nd bit used to get back
   1 MHz (it was that way generated by "IP Design Example...")

# Using proper RESET

There is one serious limitation when using FPGAs with external RESET source (push button `BTNC` in my example)
or RESET signal from different "clock domain" (which is also considered asynchronous):
- asynchronous *assertion*  of RESET is not problem
- but asynchronous *release* of RESET is problem - it may cause non-deterministic behavior

Therefore once asynchronous RESET (including push Button) is used one must generate synchronous
RESET release circuit and use it consistently in design. There are several pointers on this topic:

* https://docs.amd.com/r/en-US/ug906-vivado-design-analysis/Asynchronous-Reset-Synchronizer (or page 207
  in PDF version)
  - please note that you must use *same type* of Flip-Flops in design: (FDCE with FDCE, FDPE with FDPE).
* https://docs.amd.com/r/en-US/ug949-vivado-design-methodology/Synchronous-Reset-vs.-Asynchronous-Reset (page 49
  in PDF version) - more extensive on this topic (mostly about DSP block but not limited to)
* http://www.markharvey.info/art/7clk_19.10.2015/7clk_19.10.2015.html
  section "2. Create a reset circuit based on LOCKED"

I would happily explain this topic in depth, but I have no insight in this case -
above links are all resources I have found on Internet.

# Results

TODO

# Notes

Unlike Vivado 2015.1 (using with AC701) I must admit that Vivado 2024.1 is like
hell. When I used File -> Project -> Write Tcl...  - the results was largely
unusable and I have to change many things including:

- use `import_ip` instead of `add_files` for `.xci` to avoid `[Vivado 12-13650]` that completely
  screws IP generation path (to absolute that is not writable causing Synthesis crash)
- removed all `.dcp` stuff to avoid adding binary files to Git
- and many others smaller changes.

NOTE: All files (but `.xci`) are referenced back to this project - so when you edit them  you can
directly commit changes to git in this project.

But in case of `.xci` you have to manually watch and compare contents
of `../basys3_mmcm1m_work/basys3_mmcm1m_work.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci`,
and  `../basys3_mmcm1m_work/basys3_mmcm1m_work.gen/sources_1/ip/clk_wiz_0/*.*` and manually
merge them back to this repo.

I don't know - why something that worked pretty well in Vivado 2015.1
(generating TCL script to create project) is now screwed...

Some related resources:
- https://adaptivesupport.amd.com/s/question/0D54U00008W1LZzSAN/best-practice-for-xci-add-in-project-creation-tcl?language=en_US
- https://adaptivesupport.amd.com/s/question/0D54U00006VE0bTSAT/outputdir-and-gendirectory-in-xci-json-files?language=en_US
- https://docs.amd.com/r/en-US/ug939-vivado-designing-with-ip-tutorial
- https://docs.amd.com/r/2020.2-English/ug835-vivado-tcl-commands/import_ip

[DS181]: https://docs.amd.com/v/u/en-US/ds181_Artix_7_Data_Sheet
