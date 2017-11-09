name "xfce_desktop"
description "xfce environment"
run_list "recipe[packer-ubuntu::install_xfce_desktop]", "recipe[packer-ubuntu::configure_x_to_use_xfce]", "recipe[packer-ubuntu::install_xrdp]"