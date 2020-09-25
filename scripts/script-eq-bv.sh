#!/bin/bash
ssh -p 2222 admin@200.198.178.30 << EOF
config router static
edit 438
set priority 42
show
next
edit 387
set priority 42
show
next
edit 383
set priority 42
show
next
edit 443
set priority 42
show
next
edit 442
set priority 42
show
next
end
exit
EOF
