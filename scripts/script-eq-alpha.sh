#!/bin/bash
ssh -p 2222 admin@200.198.178.30 << EOF
config router static
edit 239
set priority 0
show
next
edit 260
set priority 0
show
next
edit 404
set priority 0
show
next
edit 410
set priority 0
show
next
end
exit
EOF
