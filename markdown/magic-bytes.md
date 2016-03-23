Hi future me. Just leaving this here as a reminder, but the 4-byte sequence
you want is...

    2a 9d 7b 44  

Which is the little endian way of saying

    printf "\x9d\x2a\x44\x7b"|dd of=/dev/sdX bs=1 count=4 seek=440  

