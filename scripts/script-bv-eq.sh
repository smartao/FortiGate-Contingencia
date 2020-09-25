#!/bin/bash
ssh -p 2222 admin@189.125.223.34 << EOF
config router static
edit 468
set priority 42
show
next
edit 467
set priority 42
show
next
edit 454
set priority 42
show
next
edit 456
set priority 42
show
next
end
exit
EOF
