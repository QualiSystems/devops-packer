name "monodevelop_env"
description "MonoDevelop environment"
run_list "role[xfce_desktop]", "recipe[packer-ubuntu::install_mono]", "recipe[packer-ubuntu::build_monodevelop]", "recipe[packer-ubuntu::create_monodevelop_desktop_shortcut]"