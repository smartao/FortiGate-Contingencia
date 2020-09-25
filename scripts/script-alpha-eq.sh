#!/bin/bash
ssh -p 2222 admin@10.2.40.200 << EOF
config router static
edit 131
set priority 0
show
next
edit 155
set priority 0
show
next
edit 9
set priority 0
show
next
edit 5
set priority 0
show
next
end
exit
EOF
