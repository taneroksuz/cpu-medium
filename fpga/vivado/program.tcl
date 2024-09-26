open_hw_manager

if { [catch {connect_hw_server} ] } {
    disconnect_hw_server
    connect_hw_server
}

if { [info exists ::env(VIVADO_HW_TARGET) ] } {
    set Target $::env(VIVADO_HW_TARGET)
    open_hw_target [get_hw_targets $Target]
} else {
    open_hw_target
}

set Device [lindex [get_hw_devices] 0]
current_hw_device $Device
refresh_hw_device -update_hw_probes false $Device
set_property PROGRAM.FILE "top.bit" $Device
program_hw_devices $Device
refresh_hw_device $Device
disconnect_hw_server