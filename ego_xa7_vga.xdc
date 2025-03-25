## Clock
set_property PACKAGE_PIN V10 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

## Reset Button
set_property PACKAGE_PIN U19 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

## VGA RGB
set_property PACKAGE_PIN F5 [get_ports vga_r[0]]
set_property PACKAGE_PIN C6 [get_ports vga_r[1]]
set_property PACKAGE_PIN C5 [get_ports vga_r[2]]
set_property PACKAGE_PIN B7 [get_ports vga_r[3]]

set_property PACKAGE_PIN B6 [get_ports vga_g[0]]
set_property PACKAGE_PIN A6 [get_ports vga_g[1]]
set_property PACKAGE_PIN A5 [get_ports vga_g[2]]
set_property PACKAGE_PIN D8 [get_ports vga_g[3]]

set_property PACKAGE_PIN C7 [get_ports vga_b[0]]
set_property PACKAGE_PIN E6 [get_ports vga_b[1]]
set_property PACKAGE_PIN E5 [get_ports vga_b[2]]
set_property PACKAGE_PIN E7 [get_ports vga_b[3]]

## VGA Sync Signals
set_property PACKAGE_PIN D7 [get_ports hsync]
set_property PACKAGE_PIN C4 [get_ports vsync]

## IOSTANDARD
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[*] vga_g[*] vga_b[*] hsync vsync}]