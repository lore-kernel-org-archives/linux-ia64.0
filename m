From: "H . J . Lu" <hjl@valinux.com>
Date: Thu, 16 Nov 2000 02:59:45 +0000
Subject: Re: [Linux-ia64] Re: Problem compiling latest gcc (001024 snapshot)
Message-Id: <marc-linux-ia64-105590678205729@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205724@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205724@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 15, 2000 at 09:52:00AM -0500, Bill Nottingham wrote:
> Francis Galiegue (fg@mandrakesoft.com) said: 
> > I tried to get the latest snapshot of gcc on cygnus to compile... but it fails
> > with this error:
> > 
> > /usr/src/RPM/BUILD/src/builddir/gcc/xgcc -B/usr/src/RPM/BUILD/src/builddir/gcc/
> > -B/usr/ia64-mandrake-linux/bin/ -I/usr/ia64-mandrake-linux/include -O2
> > -DIN_GCC    -O2 -isystem ./include  -fPIC -g1
> > -DIN_LIBGCC2 -D__GCC_FLOAT_NOT_NEEDED  -I. -I../../gcc -I../../gcc/config
> > -I../../gcc/../include -DL__nonlocal_goto -xassembler-with-cpp -c
> > ../../gcc/config/ia64/lib1funcs.asm -o libgcc/./__nonlocal_goto.o
> > ../../gcc/config/ia64/lib1funcs.asm: Assembler messages:
> > ../../gcc/config/ia64/lib1funcs.asm:655: Error: Unknown opcode `mov.ret.sptk
> > rp=in0,.L0'
> > make[2]: *** [libgcc/./__nonlocal_goto.o] Error 1
> > 
> > Machine is a BigSur, A0 stepping CPU. Glibc is 2.1.3 (and 2.1.3 patch is
> > applied), gcc is 2.9-ia64-000216-final. Kernel is 2.4.0-test7 with ia64 patch.
> > I also tried to compile with RCS patches present in the snap directory, up to
> > 031, but to no avail, still the same error. READMEs in the sources don't help.
> 
> mv /usr/ia64-mandrake-linux /usr/foo ; rebuild.
> 
> It accidentally started using the wrong assembler.
> 

As Jim mentioned, it is a gcc Makefile bug and has been fixed in the
FSF CVS. I am enclosing a patch I have been using. It seems to work
for me.

-- 
H.J. Lu (hjl@valinux.com)
---
--- Makefile.in.orig	Tue Jul 18 08:20:24 2000
+++ Makefile.in	Wed Aug 16 16:52:45 2000
@@ -227,7 +227,7 @@ CC_FOR_TARGET = ` \
 	  ;; \
       esac \
     else \
-      echo $$r/gcc/xgcc -B$$r/gcc/ -B$(build_tooldir)/bin/; \
+      echo $$r/gcc/xgcc -B$(build_tooldir)/bin/ -B$(build_tooldir)/lib/ -I$(build_tooldir)/include -B$$r/gcc/; \
     fi; \
   else \
     if [ "$(host_canonical)" = "$(target_canonical)" ] ; then \
@@ -241,7 +241,7 @@ CC_FOR_TARGET = ` \
 # variable is passed down to the gcc Makefile, where it is used to
 # build libgcc2.a.  We define it here so that it can itself be
 # overridden on the command line.
-GCC_FOR_TARGET = $$r/gcc/xgcc -B$$r/gcc/ -B$(build_tooldir)/bin/ -I$(build_tooldir)/include
+GCC_FOR_TARGET = $$r/gcc/xgcc -B$(build_tooldir)/bin/ -B$(build_tooldir)/lib/ -I$(build_tooldir)/include -B$$r/gcc/
 
 CHILL_FOR_TARGET = ` \
   if [ -f $$r/gcc/xgcc ] ; then \
@@ -270,7 +270,7 @@ CXX_FOR_TARGET = ` \
 	  ;; \
       esac \
     else \
-      echo $$r/gcc/g++ -B$$r/gcc/ -B$(build_tooldir)/bin/ -L$$r/$(TARGET_SUBDIR)/libstdc++; \
+      echo $$r/gcc/g++ -B$(build_tooldir)/bin/ -B$(build_tooldir)/lib/ -B$$r/gcc/ -L$$r/$(TARGET_SUBDIR)/libstdc++; \
     fi; \
   else \
     if [ "$(host_canonical)" = "$(target_canonical)" ] ; then \
--- gcc/Makefile.in.orig	Mon Jul 31 20:47:43 2000
+++ gcc/Makefile.in	Wed Aug 16 16:54:20 2000
@@ -171,7 +171,7 @@ INSTALL_ASSERT_H = install-assert-h
 # The GCC to use for compiling libgcc.a, enquire, and libgcc1-test.
 # Usually the one we just built.
 # Don't use this as a dependency--use $(GCC_PASSES) or $(GCC_PARTS).
-GCC_FOR_TARGET = ./xgcc -B$(build_tooldir)/bin/ -B./ -isystem $(build_tooldir)/include
+GCC_FOR_TARGET = ./xgcc -B$(build_tooldir)/bin/ -isystem $(build_tooldir)/include -B./
 
 # This is used instead of ALL_CFLAGS when compiling with GCC_FOR_TARGET.
 # It omits XCFLAGS, and specifies -B./.

