From: "Eric Agar" <agar@us.ibm.com>
Date: Wed, 20 Mar 2002 19:08:04 +0000
Subject: [Linux-ia64] Problem with iconv_open() in 32-bit App.
Message-Id: <marc-linux-ia64-105590701905307@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I have some code that has been compiled for x86 that is not working on IA64
--
specifically on Redhat 7.2 running on an IA64 machine.

Are there known problems with 32-bit applications using the iconv()
routines
on IA64?

All the details of what I'm seeing follow.


THE PROBLEM
=====
A 32-bit binary that calls the iconv_open() routine does not appear to work
on
an IA64 system.  When such a program is run on the IA64 system, iconv_open
()
returns an errno value of 22 (EINVAL).  The iconv_open() routine sets that
errno value when the codeset conversion being requested is not supported by
the system.

If the program is re-compiled on the IA64 system, it will run correctly.
That
is, the iconv_open() routine will return an indication of success.

If the codeset conversion modules from /usr/lib/gconv are ftp'ed from an
i686
system onto the IA64 system and the GCONV_PATH environment variable is set
to point to the directory holding the ftp'ed conversion modules, the 32-bit
binary will run.

So the root of the problem appears to be that iconv_open() causes some
shared
objects in /usr/lib/gconv to be loaded into the address space of the
program.
If the program is a 32-bit binary, the loading fails because the shared
objects in /usr/lib/gconv are 64-bit objects.

The following section illustrates the program.  The section after that
contains commentary.


PROBLEM ILLUSTRATION
==========

[01] /tmp/agar # ls -l
total 8
drwxr-xr-x    3 root     root         4096 Mar 19 17:11 ftped32
drwxr-xr-x    2 root     root         4096 Mar 19 17:03 native64

[02] /tmp/agar # cd native64
/tmp/agar/native64 # ls -l
total 20
-rwxr-xr-x    1 root     root        14865 Mar 19 17:03 iconvopen
-rw-r--r--    1 root     root          318 Mar 19 17:02 iconvopen.c

[03] /tmp/agar/native64 # cat iconvopen.c
#include <unistd.h>
#include <stdio.h>
#include <iconv.h>
#include <errno.h>


int main(int argc, char **argv)
{
    iconv_t cd;


    cd = iconv_open("UTF-8", "ISO8859-1");

    if (cd = (iconv_t)-1) {
        printf("iconv_open() failed with errno %d.\n", errno);
    } else {
        printf("iconv_open() worked.\n");
    }

    return 0;
}

[04] /tmp/agar/native64 # objdump -T iconvopen

iconvopen:     file format elf64-ia64-little

DYNAMIC SYMBOL TABLE:
0000000000000000      DF *UND*             00000000000000a0  GLIBC_2.2
printf
0000000000000000      DF *UND*             0000000000000020  GLIBC_2.2
__errno_location
0000000000000000      DF *UND*             00000000000005e0  GLIBC_2.2
iconv_open
0000000000000000      DF *UND*             0000000000000250  GLIBC_2.2
__libc_start_main

[05] /tmp/agar/native64 # ./iconvopen
iconv_open() worked.

[06] /tmp/agar/native64 # cd ../ftped32

[07] /tmp/agar/ftped32 # ls -l
total 28
drwxr-xr-x    2 root     root         4096 Mar 19 17:14 gconv32
-rwxr-xr-x    1 root     root        14066 Mar 19 17:06 iconvopen
-rw-r--r--    1 root     root          318 Mar 19 17:06 iconvopen.c
-rwxr-xr-x    1 root     root           54 Mar 19 17:11 iconvopen.sh

[08] /tmp/agar/ftped32 # objdump -T iconvopen

iconvopen:     file format elf32-little

DYNAMIC SYMBOL TABLE:
000000000804837c  w   DF *UND*             0000000000000081  GLIBC_2.0
__register_frame_info
000000000804838c      DF *UND*             0000000000000216  GLIBC_2.1
iconv_open
000000000804839c      DF *UND*             0000000000000018  GLIBC_2.0
__errno_location
00000000080483ac  w   DF *UND*             00000000000000ac  GLIBC_2.0
__deregister_frame_info
00000000080483bc      DF *UND*             00000000000000ca  GLIBC_2.0
__libc_start_main
00000000080483cc      DF *UND*             0000000000000032  GLIBC_2.0
printf
00000000080483dc  w   DF *UND*             000000000000009d  GLIBC_2.1.3
__cxa_finalize
00000000080485c4 g    DO .rodata           0000000000000004  Base
_IO_stdin_used
0000000000000000  w   D  *UND*             0000000000000000
__gmon_start__

[09] /tmp/agar/ftped32 # ./iconvopen
iconv_open() failed with errno 22.

[10] /tmp/agar/ftped32 # cat iconvopen.sh
#!/bin/ksh

export GCONV_PATH=./gconv32
./iconvopen

[11] /tmp/agar/ftped32 # ls -l ./gconv32
total 4128
-rwxr-xr-x    1 root     root        18360 Mar 19 17:14 ANSI_X3.110.so
-rwxr-xr-x    1 root     root         7960 Mar 19 17:14 ASMO_449.so
-rwxr-xr-x    1 root     root       124660 Mar 19 17:14 BIG5HKSCS.so
-rwxr-xr-x    1 root     root        83992 Mar 19 17:14 BIG5.so
-rwxr-xr-x    1 root     root         8216 Mar 19 17:14 CP1250.so
-rwxr-xr-x    1 root     root         8120 Mar 19 17:14 CP1251.so
-rwxr-xr-x    1 root     root         8120 Mar 19 17:14 CP1252.so
-rwxr-xr-x    1 root     root         8088 Mar 19 17:14 CP1253.so
-rwxr-xr-x    1 root     root         8152 Mar 19 17:14 CP1254.so
-rwxr-xr-x    1 root     root         8120 Mar 19 17:14 CP1255.so
-rwxr-xr-x    1 root     root         8248 Mar 19 17:14 CP1256.so
-rwxr-xr-x    1 root     root         8216 Mar 19 17:14 CP1257.so
-rwxr-xr-x    1 root     root         8184 Mar 19 17:14 CP1258.so
-rwxr-xr-x    1 root     root         8208 Mar 19 17:14 CP737.so
-rwxr-xr-x    1 root     root         8296 Mar 19 17:14 CP775.so
-rwxr-xr-x    1 root     root         8120 Mar 19 17:14 CSN_369103.so
-rwxr-xr-x    1 root     root         8280 Mar 19 17:14 CWI.so
-rwxr-xr-x    1 root     root         8056 Mar 19 17:14 DEC-MCS.so
-rwxr-xr-x    1 root     root         7928 Mar 19 17:14 EBCDIC-AT-DE-A.so
-rwxr-xr-x    1 root     root         7928 Mar 19 17:14 EBCDIC-AT-DE.so
-rwxr-xr-x    1 root     root         7928 Mar 19 17:14 EBCDIC-CA-FR.so
-rwxr-xr-x    1 root     root         7928 Mar 19 17:14 EBCDIC-DK-NO-A.so
-rwxr-xr-x    1 root     root         7928 Mar 19 17:14 EBCDIC-DK-NO.so
-rwxr-xr-x    1 root     root        16024 Mar 19 17:14 EBCDIC-ES-A.so
-rwxr-xr-x    1 root     root        16024 Mar 19 17:14 EBCDIC-ES.so
-rwxr-xr-x    1 root     root         7896 Mar 19 17:14 EBCDIC-ES-S.so
-rwxr-xr-x    1 root     root         7928 Mar 19 17:14 EBCDIC-FI-SE-A.so
-rwxr-xr-x    1 root     root         7928 Mar 19 17:14 EBCDIC-FI-SE.so
-rwxr-xr-x    1 root     root         7928 Mar 19 17:14 EBCDIC-FR.so
-rwxr-xr-x    1 root     root        15896 Mar 19 17:14 EBCDIC-IS-FRISS.so
-rwxr-xr-x    1 root     root         7928 Mar 19 17:14 EBCDIC-IT.so
-rwxr-xr-x    1 root     root         7928 Mar 19 17:14 EBCDIC-PT.so
-rwxr-xr-x    1 root     root        15928 Mar 19 17:14 EBCDIC-UK.so
-rwxr-xr-x    1 root     root         7832 Mar 19 17:14 EBCDIC-US.so
-rwxr-xr-x    1 root     root         7992 Mar 19 17:14 ECMA-CYRILLIC.so
-rwxr-xr-x    1 root     root        13512 Mar 19 17:14 EUC-CN.so
-rwxr-xr-x    1 root     root        12404 Mar 19 17:14 EUC-JP.so
-rwxr-xr-x    1 root     root        10880 Mar 19 17:14 EUC-KR.so
-rwxr-xr-x    1 root     root        17892 Mar 19 17:14 EUC-TW.so
-rwxr-xr-x    1 root     root       187960 Mar 19 17:14 GB18030.so
-rwxr-xr-x    1 root     root        52668 Mar 19 17:14 GBBIG5.so
-rwxr-xr-x    1 root     root         7944 Mar 19 17:14 GBGBK.so
-rwxr-xr-x    1 root     root       109572 Mar 19 17:14 GBK.so
-rwxr-xr-x    1 root     root        38489 Mar 19 17:14 gconv-modules
-rwxr-xr-x    1 root     root         8024 Mar 19 17:14 GOST_19768-74.so
-rwxr-xr-x    1 root     root         7992 Mar 19 17:14 GREEK7-OLD.so
-rwxr-xr-x    1 root     root         7960 Mar 19 17:14 GREEK7.so
-rwxr-xr-x    1 root     root         7960 Mar 19 17:14 GREEK-CCITT.so
-rwxr-xr-x    1 root     root        17304 Mar 19 17:14 HP-ROMAN8.so
-rwxr-xr-x    1 root     root         7928 Mar 19 17:14 IBM037.so
-rwxr-xr-x    1 root     root         7832 Mar 19 17:14 IBM038.so
-rwxr-xr-x    1 root     root         8120 Mar 19 17:14 IBM1004.so
-rwxr-xr-x    1 root     root         8088 Mar 19 17:14 IBM1026.so
-rwxr-xr-x    1 root     root         8440 Mar 19 17:14 IBM1046.so
-rwxr-xr-x    1 root     root         7928 Mar 19 17:14 IBM1047.so
-rwxr-xr-x    1 root     root         8120 Mar 19 17:14 IBM1124.so
-rwxr-xr-x    1 root     root         8152 Mar 19 17:14 IBM1129.so
-rwxr-xr-x    1 root     root         8088 Mar 19 17:14 IBM256.so
-rwxr-xr-x    1 root     root         8056 Mar 19 17:14 IBM273.so
-rwxr-xr-x    1 root     root         7928 Mar 19 17:14 IBM274.so
-rwxr-xr-x    1 root     root         7896 Mar 19 17:14 IBM275.so
-rwxr-xr-x    1 root     root         8056 Mar 19 17:14 IBM277.so
-rwxr-xr-x    1 root     root         8056 Mar 19 17:14 IBM278.so
-rwxr-xr-x    1 root     root         8056 Mar 19 17:14 IBM280.so
-rwxr-xr-x    1 root     root         7960 Mar 19 17:14 IBM281.so
-rwxr-xr-x    1 root     root         8056 Mar 19 17:14 IBM284.so
-rwxr-xr-x    1 root     root         8056 Mar 19 17:14 IBM285.so
-rwxr-xr-x    1 root     root         8056 Mar 19 17:14 IBM290.so
-rwxr-xr-x    1 root     root         8056 Mar 19 17:14 IBM297.so
-rwxr-xr-x    1 root     root         8184 Mar 19 17:14 IBM420.so
-rwxr-xr-x    1 root     root         8632 Mar 19 17:14 IBM423.so
-rwxr-xr-x    1 root     root         8024 Mar 19 17:14 IBM424.so
-rwxr-xr-x    1 root     root         8312 Mar 19 17:14 IBM437.so
-rwxr-xr-x    1 root     root         7928 Mar 19 17:14 IBM500.so
-rwxr-xr-x    1 root     root         8184 Mar 19 17:14 IBM850.so
-rwxr-xr-x    1 root     root         8248 Mar 19 17:14 IBM851.so
-rwxr-xr-x    1 root     root         8280 Mar 19 17:14 IBM852.so
-rwxr-xr-x    1 root     root         8184 Mar 19 17:14 IBM855.so
-rwxr-xr-x    1 root     root         8600 Mar 19 17:14 IBM856.so
-rwxr-xr-x    1 root     root         8184 Mar 19 17:14 IBM857.so
-rwxr-xr-x    1 root     root         8280 Mar 19 17:14 IBM860.so
-rwxr-xr-x    1 root     root         8312 Mar 19 17:14 IBM861.so
-rwxr-xr-x    1 root     root         8312 Mar 19 17:14 IBM862.so
-rwxr-xr-x    1 root     root         8312 Mar 19 17:14 IBM863.so
-rwxr-xr-x    1 root     root         8280 Mar 19 17:14 IBM864.so
-rwxr-xr-x    1 root     root         8312 Mar 19 17:14 IBM865.so
-rwxr-xr-x    1 root     root         8152 Mar 19 17:14 IBM866.so
-rwxr-xr-x    1 root     root         8280 Mar 19 17:14 IBM868.so
-rwxr-xr-x    1 root     root         8184 Mar 19 17:14 IBM869.so
-rwxr-xr-x    1 root     root         8408 Mar 19 17:14 IBM870.so
-rwxr-xr-x    1 root     root         7928 Mar 19 17:14 IBM871.so
-rwxr-xr-x    1 root     root         8056 Mar 19 17:14 IBM874.so
-rwxr-xr-x    1 root     root         8056 Mar 19 17:14 IBM875.so
-rwxr-xr-x    1 root     root         8056 Mar 19 17:14 IBM880.so
-rwxr-xr-x    1 root     root         7800 Mar 19 17:14 IBM891.so
-rwxr-xr-x    1 root     root         7800 Mar 19 17:14 IBM903.so
-rwxr-xr-x    1 root     root         7832 Mar 19 17:14 IBM904.so
-rwxr-xr-x    1 root     root         8408 Mar 19 17:14 IBM905.so
-rwxr-xr-x    1 root     root         8152 Mar 19 17:14 IBM918.so
-rwxr-xr-x    1 root     root         8408 Mar 19 17:14 IBM922.so
-rwxr-xr-x    1 root     root       247604 Mar 19 17:14 IBM930.so
-rwxr-xr-x    1 root     root        66496 Mar 19 17:14 IBM932.so
-rwxr-xr-x    1 root     root       255584 Mar 19 17:14 IBM933.so
-rwxr-xr-x    1 root     root       202432 Mar 19 17:14 IBM935.so
-rwxr-xr-x    1 root     root       256196 Mar 19 17:14 IBM937.so
-rwxr-xr-x    1 root     root       247572 Mar 19 17:14 IBM939.so
-rwxr-xr-x    1 root     root        67496 Mar 19 17:14 IBM943.so
-rwxr-xr-x    1 root     root         8216 Mar 19 17:14 IEC_P27-1.so
-rwxr-xr-x    1 root     root         7960 Mar 19 17:14 INIS-8.so
-rwxr-xr-x    1 root     root         7992 Mar 19 17:14 INIS-CYRILLIC.so
-rwxr-xr-x    1 root     root         7896 Mar 19 17:14 INIS.so
-rwxr-xr-x    1 root     root         8120 Mar 19 17:14 ISIRI-3342.so
-rwxr-xr-x    1 root     root         8088 Mar 19 17:14 ISO_10367-BOX.so
-rwxr-xr-x    1 root     root        38360 Mar 19 17:14 ISO-2022-CN-EXT.so
-rwxr-xr-x    1 root     root        28876 Mar 19 17:14 ISO-2022-CN.so
-rwxr-xr-x    1 root     root        36528 Mar 19 17:14 ISO-2022-JP.so
-rwxr-xr-x    1 root     root        11844 Mar 19 17:14 ISO-2022-KR.so
-rwxr-xr-x    1 root     root         7864 Mar 19 17:14 ISO_2033.so
-rwxr-xr-x    1 root     root         7928 Mar 19 17:14 ISO_5427-EXT.so
-rwxr-xr-x    1 root     root         7928 Mar 19 17:14 ISO_5427.so
-rwxr-xr-x    1 root     root         7992 Mar 19 17:14 ISO_5428.so
-rwxr-xr-x    1 root     root        18048 Mar 19 17:14 ISO646.so
-rwxr-xr-x    1 root     root        17752 Mar 19 17:14 ISO_6937-2.so
-rwxr-xr-x    1 root     root        17496 Mar 19 17:14 ISO_6937.so
-rwxr-xr-x    1 root     root         8120 Mar 19 17:14 ISO8859-10.so
-rwxr-xr-x    1 root     root         8056 Mar 19 17:14 ISO8859-11.so
-rwxr-xr-x    1 root     root         8120 Mar 19 17:14 ISO8859-13.so
-rwxr-xr-x    1 root     root         8088 Mar 19 17:14 ISO8859-14.so
-rwxr-xr-x    1 root     root         8024 Mar 19 17:14 ISO8859-15.so
-rwxr-xr-x    1 root     root        15960 Mar 19 17:14 ISO8859-16.so
-rwxr-xr-x    1 root     root         6416 Mar 19 17:14 ISO8859-1.so
-rwxr-xr-x    1 root     root         8344 Mar 19 17:14 ISO8859-2.so
-rwxr-xr-x    1 root     root         8408 Mar 19 17:14 ISO8859-3.so
-rwxr-xr-x    1 root     root         8344 Mar 19 17:14 ISO8859-4.so
-rwxr-xr-x    1 root     root         7992 Mar 19 17:14 ISO8859-5.so
-rwxr-xr-x    1 root     root         9272 Mar 19 17:14 ISO8859-6.so
-rwxr-xr-x    1 root     root         8056 Mar 19 17:14 ISO8859-7.so
-rwxr-xr-x    1 root     root         8056 Mar 19 17:14 ISO8859-8.so
-rwxr-xr-x    1 root     root         7960 Mar 19 17:14 ISO8859-9.so
-rwxr-xr-x    1 root     root         8184 Mar 19 17:14 ISO-IR-197.so
-rwxr-xr-x    1 root     root        14680 Mar 19 17:14 JOHAB.so
-rwxr-xr-x    1 root     root         8216 Mar 19 17:14 KOI8-R.so
-rwxr-xr-x    1 root     root         8760 Mar 19 17:14 KOI-8.so
-rwxr-xr-x    1 root     root         8184 Mar 19 17:14 KOI8-U.so
-rwxr-xr-x    1 root     root         7960 Mar 19 17:14 LATIN-GREEK-1.so
-rwxr-xr-x    1 root     root         7960 Mar 19 17:14 LATIN-GREEK.so
-rwxr-xr-x    1 root     root       157488 Mar 19 17:14 libCNS.so
-rwxr-xr-x    1 root     root        65240 Mar 19 17:14 libGB.so
-rwxr-xr-x    1 root     root        56220 Mar 19 17:14 libISOIR165.so
-rwxr-xr-x    1 root     root        98632 Mar 19 17:14 libJIS.so
-rwxr-xr-x    1 root     root        44860 Mar 19 17:14 libKSC.so
-rwxr-xr-x    1 root     root         8248 Mar 19 17:14 MACINTOSH.so
-rwxr-xr-x    1 root     root         8248 Mar 19 17:14 MAC-IS.so
-rwxr-xr-x    1 root     root         8088 Mar 19 17:14 MAC-UK.so
-rwxr-xr-x    1 root     root         7992 Mar 19 17:14 NATS-DANO.so
-rwxr-xr-x    1 root     root         7960 Mar 19 17:14 NATS-SEFI.so
-rwxr-xr-x    1 root     root         8184 Mar 19 17:14 SAMI-WS2.so
-rwxr-xr-x    1 root     root        91064 Mar 19 17:14 SJIS.so
-rwxr-xr-x    1 root     root        16536 Mar 19 17:14 T.61.so
-rwxr-xr-x    1 root     root         7992 Mar 19 17:14 TIS-620.so
-rwxr-xr-x    1 root     root        69852 Mar 19 17:14 UHC.so
-rwxr-xr-x    1 root     root         7492 Mar 19 17:14 UNICODE.so
-rwxr-xr-x    1 root     root        10032 Mar 19 17:14 UTF-16.so
-rwxr-xr-x    1 root     root        22400 Mar 19 17:14 UTF-7.so
-rwxr-xr-x    1 root     root        15544 Mar 19 17:14 VISCII.so

[12] /tmp/agar/ftped32 # objdump -T ./gconv32/ISO8859-1.so

./gconv32/ISO8859-1.so:     file format elf32-little

DYNAMIC SYMBOL TABLE:
00000000000000b4 l    d  .note.ABI-tag           0000000000000000

00000000000000d4 l    d  .hash             0000000000000000
0000000000000234 l    d  .dynsym           0000000000000000
0000000000000544 l    d  .dynstr           0000000000000000
0000000000000682 l    d  .gnu.version            0000000000000000

00000000000006e4 l    d  .gnu.version_r          0000000000000000

0000000000000734 l    d  .rel.data         0000000000000000
0000000000000744 l    d  .rel.got          0000000000000000
000000000000076c l    d  .rel.plt          0000000000000000
00000000000007cc l    d  .init             0000000000000000
00000000000007e4 l    d  .plt        0000000000000000
00000000000008c0 l    d  .text             0000000000000000
000000000000134c l    d  .fini             0000000000000000
000000000000136a l    d  .rodata           0000000000000000
0000000000002378 l    d  .data             0000000000000000
0000000000002384 l    d  .eh_frame         0000000000000000
0000000000002388 l    d  .ctors            0000000000000000
0000000000002390 l    d  .dtors            0000000000000000
0000000000002398 l    d  .got        0000000000000000
00000000000023e8 l    d  .dynamic          0000000000000000
0000000000002480 l    d  .sbss             0000000000000000
0000000000002480 l    d  .bss        0000000000000000
0000000000000000 l    d  *ABS*             0000000000000000
0000000000000000 l    d  *ABS*             0000000000000000
0000000000000000 l    d  *ABS*             0000000000000000
0000000000000000 l    d  *ABS*             0000000000000000
00000000000023e8 g    DO *ABS*             0000000000000000  Base
_DYNAMIC
0000000000000000  w   DF *UND*             0000000000000081  GLIBC_2.0
__register_frame_info
0000000000000000      DF *UND*             0000000000000038  GLIBC_2.1
_dl_mcount_wrapper_check
0000000000000000      DF *UND*             0000000000000040  GLIBC_2.1.3
__cxa_atexit
00000000000007cc g    DF .init             0000000000000000  Base
_init
0000000000000000  w   DF *UND*             00000000000000ac  GLIBC_2.0
__deregister_frame_info
0000000000000000      DF *UND*             000000000000032f  GLIBC_2.0
__xstat
0000000000000000      DF *UND*             000000000000032f  GLIBC_2.0
__fxstat
0000000000000000      DF *UND*             000000000000032f  GLIBC_2.0
__lxstat
0000000000000000      DF *UND*             0000000000000197  GLIBC_2.2
__xstat64
0000000000002480 g    DO *ABS*             0000000000000000  Base
__bss_start
000000000000134c g    DF .fini             0000000000000000  Base
_fini
0000000000000000  w   DF *UND*             000000000000009d  GLIBC_2.1.3
__cxa_finalize
00000000000009f4 g    DF .text             00000000000000d3  Base
gconv_init
0000000000000000      DF *UND*             0000000000000197  GLIBC_2.2
__lxstat64
0000000000000ad0 g    DF .text             000000000000068b  Base
gconv
0000000000002480 g    DO *ABS*             0000000000000000  Base
_edata
0000000000002398 g    DO *ABS*             0000000000000000  Base
_GLOBAL_OFFSET_TABLE_
00000000000024a0 g    DO *ABS*             0000000000000000  Base
_end
0000000000000000      DF *UND*             000000000000007c  GLIBC_2.0
__xmknod
0000000000000000      DF *UND*             0000000000000197  GLIBC_2.2
__fxstat64
0000000000000000  w   D  *UND*             0000000000000000
__gmon_start__


[13] /tmp/agar/ftped32 # ./iconvopen.sh
iconv_open() worked.


ILLUSTRATION COMMENTARY
===========
[02]: The directory /tmp/agar/native64 holds the source code and 64-bit
binary
      of the test program.

[03]: The test program simply tries to call iconv_open() specifying some
      common codesets.

[04]: objdump shows the binary is a 64-bit binary.

[05]: The 64-bit binary works.

[07]: The directory /tmp/agar/ftped32 holds the source code and 32-bit
binary
      of the test program that had been ftp'ed from another machine.

[08]: objdump shows the binary is a 32-bit binary.

[09]: The 32-bit binary fails.

[10]: The shell script sets GCONV_PATH and runs the 32-bit binary.

[11]: The directory the shell script references in its setting of
GCONV_PATH
      contains the gconv modules I ftp'ed from an i686 system.

[12]: objdump shows one of the gconv binaries is a 32-bit binary.

[13]: When the 32-bit binary test program is run with the 32-bit binary
gconv
      shared objects, it works.



Eric M. Agar
agar@us.ibm.com


