From: Francis Galiegue <fg@mandrakesoft.com>
Date: Tue, 21 Nov 2000 15:36:00 +0000
Subject: [Linux-ia64] gcc and glibc: big troubles
Message-Id: <marc-linux-ia64-105590678205756@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm trying to upgrade my glibc and compiler to 001024 snapshot + RCS patches up
to 037 (for gcc) and glibc 2.2 plus patches (not CVS), but it fails on the
whole... Compiler used is 001024 snapshot but with backward compatibility ABI
patch applied.

First, glibc. I obtain this error:

-----
gcc -nostdlib -nostartfiles -o
/usr/src/RPM/BUILD/glibc-2.2/build-ia64-linux/iconv/iconv_prog
-Wl,-dynamic-linker=/lib/ld-linux-ia64.so.2
/usr/src/RPM/BUILD/glibc-2.2/build-ia64-linux/csu/crt1.o
/usr/src/RPM/BUILD/glibc-2.2/build-ia64-linux/csu/crti.o `gcc
--print-file-name=crtbegin.o`
/usr/src/RPM/BUILD/glibc-2.2/build-ia64-linux/iconv/iconv_prog.o
-Wl,-rpath-link=/usr/src/RPM/BUILD/glibc-2.2/build-ia64-linux:/usr/
src/RPM/BUILD/glibc-2.2/build-ia64-linux/math:/usr/src/RPM/BUILD/
glibc-2.2/build-ia64-linux/elf:/usr/src/RPM/BUILD/glibc-2.2/
build-ia64-linux/dlfcn:/usr/src/RPM/BUILD/glibc-2.2/build-ia64-linux/
nss:/usr/src/RPM/BUILD/glibc-2.2/build-ia64-linux/nis:/usr/src/RPM/
BUILD/glibc-2.2/build-ia64-linux/rt:/usr/src/RPM/BUILD/glibc-2.2/
build-ia64-linux/resolv:/usr/src/RPM/BUILD/glibc-2.2/build-ia64-linux/
crypt:/usr/src/RPM/BUILD/glibc-2.2/build-ia64-linux/linuxthreads
/usr/src/RPM/BUILD/glibc-2.2/build-ia64-linux/libc.so.6.1
/usr/src/RPM/BUILD/glibc-2.2/build-ia64-linux/libc_nonshared.a -lgcc `gcc
--print-file-name=crtend.o`
/usr/src/RPM/BUILD/glibc-2.2/build-ia64-linux/csu/crtn.o

/usr/src/RPM/BUILD/glibc-2.2/build-ia64-linux/libc.so.6.1:
undefined reference to `__syscall_getpagesize'
collect2: ld returned 1 exit status
-----

Does CVS glibc cure this? If yes I guess I'll upgrade to the latest toolchain
snapshot too...

Now, trying to recompile the 001024 toolchain, but *without* the ABI patch, I
get the following:

-----
gcc -c -O2   -I../../../tk/unix -I../../../tk/unix/../generic
-I../../../tk/unix/../bitmaps -I/usr/src/RPM/BUILD/src/tcl/generic
-I/usr/X11R6/include -DHAVE_UNISTD_H=1 -DHAVE_LIMITS_H=1 -DSTDC_HEADERS=1
-DHAVE_SYS_TIME_H=1 -DTIME_WITH_SYS_TIME=1
../../../tk/unix/../generic/tkImgPhoto.c
../../../tk/unix/../generic/tkImgPhoto.c: In function `ImgPhotoCmd':
../../../tk/unix/../generic/tkImgPhoto.c:601: warning: passing arg 2 of
`Tcl_GetStringFromObj' from
incompatible pointer type
/tmp/ccalpirm.s: Assembler messages:
/tmp/ccalpirm.s:6579: Internal error, aborting at ../../gas/config/tc-ia64.c
line 5190 in errata_nop_necessary_p
Please report this bug.
-----

Culprit line:

-----
  if (insn_unit = IA64_UNIT_F)
    {
      for (i = 0; i < idesc->num_outputs; i++)
    if (idesc->operands[i] = IA64_OPND_P1
        || idesc->operands[i] = IA64_OPND_P2)
      {
        int regno = slot->opnd[i].X_add_number - REG_P;
        if (regno > 16)
          abort ();		<----- This one
        this_group->p_reg_set[regno] = 1;
      }
    }
-----

One thing I don't get is: why all this in the toolchain? Why make, why bison,
why tk, why tcl? Whats more there's no README at all on how to *avoid* having
them compiled. I tried --without-x, --disable-x but to no avail... Stock bison
for example works perfectly fine here, so does make. Any solution?

-- 
Francis Galiegue, fg@mandrakesoft.com
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook


