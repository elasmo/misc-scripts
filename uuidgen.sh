#!/bin/sh
cat /proc/sys/kernel/random/uuid 2>/dev/null \
    || cat /compat/linux/proc/sys/kernel/random/uuid 2>/dev/null \
    || python -c "import uuid; print uuid.uuid4()" \
    || uuidgen \
    echo "No available method found" && exit 1
