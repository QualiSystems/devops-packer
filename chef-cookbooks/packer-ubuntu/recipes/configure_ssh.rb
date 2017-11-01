sshd = node.default['openssh']['server']
sshd['UseDNS']='no'
sshd['GSSAPIAuthentication']='no'

include_recipe 'openssh'