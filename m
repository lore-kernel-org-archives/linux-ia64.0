From: Thomas Lofgren <tlofgren@cup.hp.com>
Date: Tue, 01 Aug 2000 00:20:34 +0000
Subject: [Linux-ia64] Asm error when building cross-compiler
Message-Id: <marc-linux-ia64-105590678205259@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,

I figure people on this list have experience with compiling
cross-compilers with IA64 as the target.  If there is a more
appropriate place to ask, let me know.

I downloaded the toolchain linked from the ia64linux.org page:
 ftp://ftp.cygnus.com/private/intel/

When building it, I run in to the following:

cp ../../gcc/config/ia64/lib1funcs.asm libgcc1.S
for name in __divdf3 __divsf3 __divdi3 __moddi3 __udivdi3 __umoddi3 __divsi3 __modsi3 __udivsi3 __umodsi3 __save_stack_nonlocal __nonlocal_goto __restore_stack_nonlocal; \
do \
  echo ${name}; \
  /home/lofgren/work/ia64_toolchain/build/gcc/xgcc -B/home/lofgren/work/ia64_toolchain/build/gcc/ -B/usr/local/ia64/ia64-hp-linux-gnu/bin/ -I/usr/local/ia64/ia64-hp-linux-gnu/include -O2  -DCROSS_COMPILE -DIN_GCC    -g -O2  -I./include  -fPIC -g1  -DIN_LIBGCC2 -D__GCC_FLOAT_NOT_NEEDED  -I. -I../../gcc -I../../gcc/config -I../../gcc/../include -c -DL${name} libgcc1.S; \
  if [ $? -eq 0 ] ; then true; else exit 1; fi; \
  mv libgcc1.o ${name}.o; \
  /home/lofgren/work/ia64_toolchain/build/binutils/ar rc tmplibgcc1.a ${name}.o; \
  rm -f ${name}.o; \
done
__divdf3
__divsf3
__divdi3
__moddi3
__udivdi3
__umoddi3
__divsi3
__modsi3
__udivsi3
__umodsi3
__save_stack_nonlocal
__nonlocal_goto
libgcc1.S: Assembler messages:
libgcc1.S:604: Error: Unknown opcode `mov.ret.sptk.few.dc.dc rp=r33,.L0'
make[1]: *** [libgcc1-asm.a] Error 1
make[1]: Leaving directory `/home/lofgren/work/ia64_toolchain/build/gcc'
make: *** [all-gcc] Error 2

As far as I see, the instruction is valid.  I tried removing the
.dc.dc completers, since they're deprecated, but it still fails.  Any
ideas?

All other tools (bfd, binutils, gdb, gas, ld, ...) appeared to have
been built flawlessly.

Thanks,
Tom Lofgren
-- 
T. Lofgren <tlofgren@cup.hp.com>: Wherever I lay my .emacs, that's my ${HOME}
PGP Key ID: DC68D8F6                  Encryption is the envelope for email


