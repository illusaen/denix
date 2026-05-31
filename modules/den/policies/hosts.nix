# Host-level schema wiring.
#
# Fleet host resolution now attaches ACL-selected users directly onto
# host.users, allowing den's built-in host-to-users policy to handle
# host aspect propagation without extra host wiring here.
_: { }
