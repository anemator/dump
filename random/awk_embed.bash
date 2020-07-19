#!/bin/bash

awk -f <(cat - <<-EOF
BEGIN { }
/\#/ { print $1 }
END { }
EOF
) <(cat /etc/passwd)
