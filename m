From: Francis Galiegue <fg@mandrakesoft.com>
Date: Wed, 15 Nov 2000 09:30:35 +0000
Subject: [Linux-ia64] Problem compiling latest gcc (001024 snapshot)
Message-Id: <marc-linux-ia64-105590678205721@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I tried to get the latest snapshot of gcc on cygnus to compile... but it fails
with this error:

/usr/src/RPM/BUILD/src/builddir/gcc/xgcc -B/usr/src/RPM/BUILD/src/builddir/gcc/
-B/usr/ia64-mandrake-linux/bin/ -I/usr/ia64-mandrake-linux/include -O2
-DIN_GCC    -O2 -isystem ./include  -fPIC -g1
-DIN_LIBGCC2 -D__GCC_FLOAT_NOT_NEEDED  -I. -I../../gcc -I../../gcc/config
-I../../gcc/../include -DL__nonlocal_goto -xassembler-with-cpp -c
../../gcc/config/ia64/lib1funcs.asm -o libgcc/./__nonlocal_goto.o
../../gcc/config/ia64/lib1funcs.asm: Assembler messages:
../../gcc/config/ia64/lib1funcs.asm:655: Error: Unknown opcode `mov.ret.sptk
rp=in0,.L0'
make[2]: *** [libgcc/./__nonlocal_goto.o] Error 1

Machine is a BigSur, A0 stepping CPU. Glibc is 2.1.3 (and 2.1.3 patch is
applied), gcc is 2.9-ia64-000216-final. Kernel is 2.4.0-test7 with ia64 patch.
I also tried to compile with RCS patches present in the snap directory, up to
031, but to no avail, still the same error. READMEs in the sources don't help.

I'm stuck... Do you see what I did wrong? Would the .032 and .033 patches help?

Oh, and BTW, .033 is unreadable, it's 600 on the FTP site.

-- 
Francis Galiegue, fg@mandrakesoft.com
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook


