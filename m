From: "MONTGOMERY,BOB (HP-FtCollins,ex1)" <bob.montgomery@hp.com>
Date: Fri, 17 Jan 2003 23:28:51 +0000
Subject: [Linux-ia64] Problem with call across kernel modules
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C2BE80.31463050"
Message-Id: <marc-linux-ia64-105590709805718@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C2BE80.31463050
Content-Type: text/plain;
	charset="iso-8859-1"

The attached files (in a shell archive) illustrate a problem with
calls between kernel modules on ia64 linux.

The problem was verified on two ia64 systems: insmod version 2.4.22
on RedHat's 2.4.18-e.12smp, and insmod version 2.4.21 on a 2.4.21-pre3
kernel.

The Makefile makes two modules: caller.o and helper.o.  The caller module
calls the function helper from its init_module routine.  The helper
function is in the helper module.  Making the call from init_module is a
simplification for the example.  The original problem made the bad call
after the module was successfully loaded.

If you insmod caller.o first, it will fail with an unresolved symbol
for helper, as expected.

After insmod'ing helper, the insmod of caller is expected to succeed,
but the call to helper from init_module causes an Oops.  The oops
message seems to indicate that the procedure call to helper lands at
the wrong address.  The ISR 4294967296 (or 0x1 0000 0000) indicates
the x bit (Execute exception - Interruption is associated with an
instruction fetch).

The ip register is:
   ip  : [<0880210040004000>] 

The two cases that discovered the problem reported 0000058014494800 and
000005800e293010 for their ip registers (same ISR).  My test case does
work on a 2.4.18 ia32 box.

# insmod caller.o
caller.o: unresolved symbol helper
# insmod helper.o
# dmesg
...
helper initialized
# insmod caller.o
Segmentation fault
# dmesg | tail -40
...
helper initialized
caller in init_module, about to call helper...
Unable to handle kernel paging request at virtual address 0880210040004000
insmod[1400]: Oops 4294967296
--> Using_Versions [] 0x40003fff <-- 

Pid: 1400, comm:               insmod
psr : 0000101008026018 ifs : 8000000000000002 ip  : [<0880210040004000>]
Not tainted
unat: 0000000000000000 pfs : 0000000000000185 rsc : 0000000000000003
rnat: e0000040f77c7d50 bsps: e0000040f77c0000 pr  : 000000000000a559
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
b0  : a000000000354110 b6  : 088021004000400a b7  : 0000000000000000
f6  : 1003e000000000000000a f7  : 1003e0a3d70a3d70a3eb8
f8  : 1003ee0000000049f0400 f9  : 10003c000000000000000
r1  : 0004000000420020 r2  : 0000000000000000 r3  : 0000000000000000
r8  : 0000000000000032 r9  : 0000000000000018 r10 : 0000000000000000
r11 : 0000000000000a17 r12 : e0000040f77c7d90 r13 : e0000040f77c0000
r14 : 0000000000004000 r15 : a00000000034c0c8 r16 : 088021004000400a
r17 : e0000040fc790048 r18 : 0000000000080000 r19 : e0000000049f0d30
r20 : e0000040fc790050 r21 : e0000000049f0408 r22 : e0000040f77c0000
r23 : e0000000049f0d28 r24 : e0000040fc790040 r25 : e0000040fc790058
r26 : 200000000029fd58 r27 : ffffffffffffffff r28 : 0000000000000000
r29 : 0000000000000001 r30 : 0000000000000018 r31 : 0000000000000c9e

Call Trace: [<e000000004414870>] sp=0xe0000040f77c7980
bsp=0xe0000040f77c1218
decoded to show_stack [kernel] 0x50 
[<e0000000044150a0>] sp=0xe0000040f77c7b40 bsp=0xe0000040f77c11b8
decoded to show_regs [kernel] 0x7c0 
[<e00000000442e490>] sp=0xe0000040f77c7b60 bsp=0xe0000040f77c1190
decoded to die [kernel] 0x190 
[<e000000004450180>] sp=0xe0000040f77c7b60 bsp=0xe0000040f77c1130
decoded to ia64_do_page_fault [kernel] 0x780 
[<e00000000440dec0>] sp=0xe0000040f77c7bf0 bsp=0xe0000040f77c1130
decoded to ia64_leave_kernel [kernel] 0x0 


------_=_NextPart_000_01C2BE80.31463050
Content-Type: application/octet-stream;
	name="modbug.shar"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="modbug.shar"

#!/bin/sh
# This is a shell archive (produced by GNU sharutils 4.2.1).
# To extract the files from this archive, save it to some FILE, remove
# everything before the `!/bin/sh' line above, then type `sh FILE'.
#
# Made on 2003-01-17 16:09 MST by <bobm@utilica>.
# Source directory was `/home/bobm/Bugs/ModuleBug'.
#
# Existing files will *not* be overwritten unless `-c' is specified.
#
# This shar contains:
# length mode       name
# ------ ---------- ------------------------------------------
#    679 -rw-r--r-- caller.c
#    637 -rw-r--r-- helper.c
#     17 -rw-r--r-- helper.h
#    610 -rw-r--r-- Makefile
#
save_IFS=3D"${IFS}"
IFS=3D"${IFS}:"
gettext_dir=3DFAILED
locale_dir=3DFAILED
first_param=3D"$1"
for dir in $PATH
do
  if test "$gettext_dir" =3D FAILED && test -f $dir/gettext \
     && ($dir/gettext --version >/dev/null 2>&1)
  then
    set `$dir/gettext --version 2>&1`
    if test "$3" =3D GNU
    then
      gettext_dir=3D$dir
    fi
  fi
  if test "$locale_dir" =3D FAILED && test -f $dir/shar \
     && ($dir/shar --print-text-domain-dir >/dev/null 2>&1)
  then
    locale_dir=3D`$dir/shar --print-text-domain-dir`
  fi
done
IFS=3D"$save_IFS"
if test "$locale_dir" =3D FAILED || test "$gettext_dir" =3D FAILED
then
  echo=3Decho
else
  TEXTDOMAINDIR=3D$locale_dir
  export TEXTDOMAINDIR
  TEXTDOMAIN=3Dsharutils
  export TEXTDOMAIN
  echo=3D"$gettext_dir/gettext -s"
fi
if touch -am -t 200112312359.59 $$.touch >/dev/null 2>&1 && test ! -f =
200112312359.59 -a -f $$.touch; then
  shar_touch=3D'touch -am -t $1$2$3$4$5$6.$7 "$8"'
elif touch -am 123123592001.59 $$.touch >/dev/null 2>&1 && test ! -f =
123123592001.59 -a ! -f 123123592001.5 -a -f $$.touch; then
  shar_touch=3D'touch -am $3$4$5$6$1$2.$7 "$8"'
elif touch -am 1231235901 $$.touch >/dev/null 2>&1 && test ! -f =
1231235901 -a -f $$.touch; then
  shar_touch=3D'touch -am $3$4$5$6$2 "$8"'
else
  shar_touch=3D:
  echo
  $echo 'WARNING: not restoring timestamps.  Consider getting and'
  $echo "installing GNU \`touch', distributed in GNU File Utilities..."
  echo
fi
rm -f 200112312359.59 123123592001.59 123123592001.5 1231235901 =
$$.touch
#
if mkdir _sh01528; then
  $echo 'x -' 'creating lock directory'
else
  $echo 'failed to create lock directory'
  exit 1
fi
# =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D caller.c =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
if test -f 'caller.c' && test "$first_param" !=3D -c; then
  $echo 'x -' SKIPPING 'caller.c' '(file already exists)'
else
  $echo 'x -' extracting 'caller.c' '(text)'
  sed 's/^X//' << 'SHAR_EOF' > 'caller.c' &&
/* Necessary header files */
#include <linux/types.h>
#include <linux/kernel.h>
X
#include "helper.h"
X
#include <linux/module.h>
X
MODULE_AUTHOR("Bob Montgomery, HP (bob_montgomery@hp.com)");
MODULE_DESCRIPTION("Module that calls another module");
MODULE_LICENSE("GPL");
X
/* Initialize the module */
int init_module(void)
{
X
X    printk(KERN_ALERT "caller in init_module, about to call =
helper...\n");
X
X    printk("helper(10) returns %d\n", helper(10));
X   =20
X    /* A non 0 return means init_module failed; module can't be =
loaded. */
X    return 0;
}
X        =20
/* Cleanup - undo whatever init_module did */
void cleanup_module(void)
{
X   printk(KERN_ALERT "caller in cleanup\n");
} =20
SHAR_EOF
  (set 20 03 01 17 15 45 29 'caller.c'; eval "$shar_touch") &&
  chmod 0644 'caller.c' ||
  $echo 'restore of' 'caller.c' 'failed'
  if ( md5sum --help 2>&1 | grep 'sage: md5sum \[' ) >/dev/null 2>&1 \
  && ( md5sum --version 2>&1 | grep -v 'textutils 1.12' ) >/dev/null; =
then
    md5sum -c << SHAR_EOF >/dev/null 2>&1 \
    || $echo 'caller.c:' 'MD5 check failed'
0c0ce3ec2a96bba364fb8840442d079c  caller.c
SHAR_EOF
  else
    shar_count=3D"`LC_ALL=3D LC_CTYPE=3D LANG=3D wc -c < 'caller.c'`"
    test 679 -eq "$shar_count" ||
    $echo 'caller.c:' 'original size' '679,' 'current size' =
"$shar_count!"
  fi
fi
# =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D helper.c =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
if test -f 'helper.c' && test "$first_param" !=3D -c; then
  $echo 'x -' SKIPPING 'helper.c' '(file already exists)'
else
  $echo 'x -' extracting 'helper.c' '(text)'
  sed 's/^X//' << 'SHAR_EOF' > 'helper.c' &&
/* Necessary header files */
#include <linux/types.h>
#include <linux/kernel.h>
X
#include "helper.h"
X
#include <linux/module.h>
X
MODULE_AUTHOR("Bob Montgomery, HP (bob_montgomery@hp.com)");
MODULE_DESCRIPTION("Helper module for caller");
MODULE_LICENSE("GPL");
X
X
int helper(int val)
{
X	return ++val;
}
X
/* Initialize the module */
int init_module(void)
{
X
X    printk(KERN_ALERT "helper initialized\n");
X        =20
X    /* A non 0 return means init_module failed; module can't be =
loaded. */
X    return 0;
}
X        =20
/* Cleanup - undo whatever init_module did */
void cleanup_module(void)
{
X   printk(KERN_ALERT "helper in cleanup\n");
} =20
SHAR_EOF
  (set 20 03 01 17 15 45 14 'helper.c'; eval "$shar_touch") &&
  chmod 0644 'helper.c' ||
  $echo 'restore of' 'helper.c' 'failed'
  if ( md5sum --help 2>&1 | grep 'sage: md5sum \[' ) >/dev/null 2>&1 \
  && ( md5sum --version 2>&1 | grep -v 'textutils 1.12' ) >/dev/null; =
then
    md5sum -c << SHAR_EOF >/dev/null 2>&1 \
    || $echo 'helper.c:' 'MD5 check failed'
d939cdb55292168ae1e9a2b3226e2ce8  helper.c
SHAR_EOF
  else
    shar_count=3D"`LC_ALL=3D LC_CTYPE=3D LANG=3D wc -c < 'helper.c'`"
    test 637 -eq "$shar_count" ||
    $echo 'helper.c:' 'original size' '637,' 'current size' =
"$shar_count!"
  fi
fi
# =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D helper.h =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
if test -f 'helper.h' && test "$first_param" !=3D -c; then
  $echo 'x -' SKIPPING 'helper.h' '(file already exists)'
else
  $echo 'x -' extracting 'helper.h' '(text)'
  sed 's/^X//' << 'SHAR_EOF' > 'helper.h' &&
int helper(int);
SHAR_EOF
  (set 20 03 01 17 15 45 47 'helper.h'; eval "$shar_touch") &&
  chmod 0644 'helper.h' ||
  $echo 'restore of' 'helper.h' 'failed'
  if ( md5sum --help 2>&1 | grep 'sage: md5sum \[' ) >/dev/null 2>&1 \
  && ( md5sum --version 2>&1 | grep -v 'textutils 1.12' ) >/dev/null; =
then
    md5sum -c << SHAR_EOF >/dev/null 2>&1 \
    || $echo 'helper.h:' 'MD5 check failed'
32c2e5f4c9b3f63d60cca99d08eba773  helper.h
SHAR_EOF
  else
    shar_count=3D"`LC_ALL=3D LC_CTYPE=3D LANG=3D wc -c < 'helper.h'`"
    test 17 -eq "$shar_count" ||
    $echo 'helper.h:' 'original size' '17,' 'current size' =
"$shar_count!"
  fi
fi
# =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D Makefile =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
if test -f 'Makefile' && test "$first_param" !=3D -c; then
  $echo 'x -' SKIPPING 'Makefile' '(file already exists)'
else
  $echo 'x -' extracting 'Makefile' '(text)'
  sed 's/^X//' << 'SHAR_EOF' > 'Makefile' &&
# Makefile for a basic kernel module
#
all: caller.o helper.o
X        =20
KSRC=3D/lib/modules/`uname -r`/build
CC=3Dgcc
CFLAGS=3D -D__KERNEL__ -Wall -Wstrict-prototypes -Wno-trigraphs -g -O2 =
-fomit-frame-pointer -fno-strict-aliasing -fno-common -pipe  =
-ffixed-r13 -mfixed-range=3Df10-f15,f32-f127 -falign-functions=3D32
IFLAGS=3D -I $(KSRC)/include
MODFLAGS=3D -DMODULE -DMODVERSIONS -include =
$(KSRC)/include/linux/modversions.h
X
caller.o: caller.c helper.h
X	${CC} ${IFLAGS} ${CFLAGS} ${MODFLAGS} -c caller.c
X
helper.o: helper.c helper.h
X	${CC} ${IFLAGS} ${CFLAGS} ${MODFLAGS} -c helper.c
X
clean:
X	-rm caller.o
X	-rm helper.o
X
SHAR_EOF
  (set 20 03 01 17 15 46 27 'Makefile'; eval "$shar_touch") &&
  chmod 0644 'Makefile' ||
  $echo 'restore of' 'Makefile' 'failed'
  if ( md5sum --help 2>&1 | grep 'sage: md5sum \[' ) >/dev/null 2>&1 \
  && ( md5sum --version 2>&1 | grep -v 'textutils 1.12' ) >/dev/null; =
then
    md5sum -c << SHAR_EOF >/dev/null 2>&1 \
    || $echo 'Makefile:' 'MD5 check failed'
0903845f38aea4b2c2dd93afe2e5056a  Makefile
SHAR_EOF
  else
    shar_count=3D"`LC_ALL=3D LC_CTYPE=3D LANG=3D wc -c < 'Makefile'`"
    test 610 -eq "$shar_count" ||
    $echo 'Makefile:' 'original size' '610,' 'current size' =
"$shar_count!"
  fi
fi
rm -fr _sh01528
exit 0

------_=_NextPart_000_01C2BE80.31463050--

