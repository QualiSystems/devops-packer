name "dotnet_452_env"
description "dot net environment"
run_list "recipe[packer-windows::install_all_vc_runtimes]", "recipe[packer-windows::install_dotnet_452]"