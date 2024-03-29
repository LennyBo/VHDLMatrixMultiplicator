# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
create_project -in_memory -part xc7a35tfgg484-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.cache/wt [current_project]
set_property parent.project_path C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property ip_cache_permissions disable [current_project]
read_vhdl -library xil_defaultlib {
  C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/sources_1/imports/nanoProcesseur_src/nanoProcesseur_package.vhd
  C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/sources_1/imports/nanoProcesseur_src/ALU.vhd
  C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/sources_1/imports/nanoProcesseur_src/Accu_Register.vhd
  C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/sources_1/imports/nanoProcesseur_src/Address_Decode.vhd
  C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/sources_1/imports/nanoProcesseur_src/Data_Multiplexer.vhd
  C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/sources_1/imports/nanoProcesseur_src/Instruction_Register.vhd
  C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/sources_1/imports/nanoProcesseur_src/Operandes_Multiplexer.vhd
  C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/sources_1/imports/nanoProcesseur_src/Operandes_Register.vhd
  C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/sources_1/imports/nanoProcesseur_src/Output_Register.vhd
  C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/sources_1/imports/nanoProcesseur_src/Program_Counter.vhd
  C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/sources_1/imports/nanoProcesseur_src/RAM.vhd
  C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/sources_1/imports/nanoProcesseur_src/ROM.vhd
  C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/sources_1/imports/nanoProcesseur_src/Sequenceur.vhd
  C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/sources_1/imports/nanoProcesseur_src/Stack_Register.vhd
  C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/sources_1/imports/nanoProcesseur_src/Status_Register.vhd
  C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/sources_1/imports/nanoProcesseur_src/interrupt_manager.vhd
  C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/sources_1/imports/nanoProcesseur_src/nanoProcesseur.vhd
  C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/sources_1/imports/nanoProcesseur_src/timer.vhd
  C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/sources_1/imports/nanoProcesseur_src/nanoControleur.vhd
}
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/constrs_1/new/nanoControleur.xdc
set_property used_in_implementation false [get_files C:/DEV/sysnum/projet-sysnum-multiplicateur-de-matrice-ll/nano2019v01e_vide/artix7/artix7.srcs/constrs_1/new/nanoControleur.xdc]

set_param ips.enableIPCacheLiteLoad 0
close [open __synthesis_is_running__ w]

synth_design -top nanoControleur -part xc7a35tfgg484-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef nanoControleur.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file nanoControleur_utilization_synth.rpt -pb nanoControleur_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
