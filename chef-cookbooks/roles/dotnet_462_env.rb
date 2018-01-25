name "dotnet_462_env"
description "dot net environment"
run_list "recipe[packer-windows::install_all_vc_runtimes]", "recipe[packer-windows::install_dotnet_462]"