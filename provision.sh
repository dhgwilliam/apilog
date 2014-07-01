iptables -F
if ! puppet module list | grep -q alup ; then
  puppet module install alup/rbenv
fi
