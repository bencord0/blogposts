There's an odd thing with PXE imaging using MAC addresses. You have to specify
them with 7 bytes.

MAC addresses are manufacturer assigned 6 byte numbers. The first 3 are
assigned to identify the manufacturer, the last 3 used for uniqueness. A
manufacturer can be assigned more than one 3 byte sequence of course.

So where does the seventh byte come from? The format of PXE MAC addresses are
01-xx-xx-xx-xx-xx-xx where the 01 stands for the version of ARP being used. It
has never incremented to version 2.

