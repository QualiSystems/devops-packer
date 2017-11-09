name "monodevelop_env"
description "MonoDevelop environment"
run_list "role[xfce_desktop]", "recipe[packer-ubuntu::install_mono]", "recipe[packer-ubuntu::build_monodevelop_6.1.2.44]"