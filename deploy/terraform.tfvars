region          = "eastus"
namespace       = "migratorydata"
additional_tags = {}

address_space = "10.0.0.0/16"

num_instances     = 3
max_num_instances = 5
instance_type     = "Standard_F2s_v2"

ssh_private_key = "~/.ssh/id_rsa"

enable_monitoring = true