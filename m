From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 25 Jul 2000 09:44:21 +0000
Subject: [Linux-ia64] Announce: modutils 2.3.13 is available
Message-Id: <marc-linux-ia64-105590678205228@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Fastest download from kernel.org.
Mirror at ftp://ftp.**.kernel.org/pub/linux/utils/kernel/modutils/v2.3
           replace '**' with your favourite kernel.org mirror.
Mirror at ftp://oss.sgi.com/pub/mirror/modutils/v2.3.
Master at ftp://ftp.ocs.com.au/pub/modutils/v2.3.  (slow)

patch-modutils-2.3.13.gz        Patch from modutils 2.3.12 to 2.3.13
modutils-2.3.13.tar.gz          Source tarball, includes RPM spec file
modutils-2.3.13-1.src.rpm       As above, in SRPM format
modutils-2.3.13-1.i386.rpm      Compiled with egcs-2.91.66, glibc 2.1.2

Changelog extract

        * More gzipped objects changes by Willy Tarreau.
        * Default to no backwards compatibility.  See INSTALL if you want
          modutils to run on 2.0.x kernels, if you want kerneld (died in 2.=
1.91)
          or if your libc does not have create_module(), query_module() etc.
        * IA64, s390 fixes.
        * Redhat 486 patch.
        * Redhat modprobe -k patch.
        * Redhat kallsyms patch.
        * Add mtd directory, aliases from David Woodhouse.
        * Handle unaligned IA64 relocations.
        * Fix for IA64 modules with no cleanup routine, Mike Stephens.
        * Refuse to load modules compiled with -mconstant-gp.

CAUTION: This version changes the defaults on backwards compatibility.
         Previous versions of modutils defaulted to supporting 2.[01]
         kernels and used _syscall() instead of glibc.  The default is
         now no backwards compatibility and to use glibc.  Those
         hopefully few people still using 2.[01] kernels or libc
         without modutils support will have to explicitly select the
         old code, see INSTALL.

IA64 support has had more testing in this release.  If modules are
compiled with "-mconstant-gp" then insmod or the module will oops every
time.  IA64 modules must be compiled without -mconstant-gp, the kernel
can be compiled with or without -mconstant-gp, your choice.  The test
patch below against 2.4.0-test1 should clean up the IA64 make.

insmod attempts to detect modules compiled with -mconstant-gp and will
refuse to load them.  However current gcc for IA64 does not set the
EF_IA_64_CONS_GP (e_flags & 0x00000040) bit in the ELF header so insmod
cannot do its job correctly.

Index: 0-test1.20/arch/ia64/Makefile
--- 0-test1.20/arch/ia64/Makefile Wed, 12 Jul 2000 15:24:58 +1000 kaos (lin=
ux-2.4/c/c/43_Makefile 1.1.1.2 644)
+++ 0-test1.20(w)/arch/ia64/Makefile Tue, 25 Jul 2000 16:52:13 +1000 kaos (=
linux-2.4/c/c/43_Makefile 1.1.1.2 644)
@@ -16,7 +16,8 @@
 EXTRA	=20
 CFLAGS :=3D $(CFLAGS) -pipe $(EXTRA) -Wa,-x -ffixed-r13 -mfixed-range=F10-=
f15,f32-f127 \
-	  -mconstant-gp -funwind-tables
+	  -funwind-tables
+CFLAGS_KERNEL :=3D -mconstant-gp
=20
 ifdef CONFIG_IA64_GENERIC
 	CORE_FILES      :=3D      arch/$(ARCH)/hp/hp.a	\
Index: 0-test1.20/Makefile
--- 0-test1.20/Makefile Wed, 12 Jul 2000 18:06:30 +1000 kaos (linux-2.4/B/c=
/27_Makefile 1.1.3.3 644)
+++ 0-test1.20(w)/Makefile Tue, 25 Jul 2000 19:10:29 +1000 kaos (linux-2.4/=
B/c/27_Makefile 1.1.3.3 644)
@@ -37,11 +37,13 @@
 GENKSYMS	=3D /sbin/genksyms
 KALLSYMS	=3D /sbin/kallsyms
 MODFLAGS	=3D -DMODULE
+CFLAGS_KERNEL	 PERL		=3D perl
=20
 export	VERSION PATCHLEVEL SUBLEVEL EXTRAVERSION KERNELRELEASE ARCH \
 	CONFIG_SHELL TOPDIR HPATH HOSTCC HOSTCFLAGS CROSS_COMPILE AS LD CC \
-	CPP AR NM STRIP OBJCOPY OBJDUMP MAKE MAKEFILES GENKSYMS MODFLAGS PERL
+	CPP AR NM STRIP OBJCOPY OBJDUMP MAKE MAKEFILES GENKSYMS MODFLAGS PERL \
+	CFLAGS_KERNEL
=20
 all:	do-it-all
=20
@@ -197,7 +199,7 @@
 	@rm -f include/linux/compile.h
=20
 boot: vmlinux
-	@$(MAKE) -C arch/$(ARCH)/boot
+	@$(MAKE) CFLAGS=3D"$(CFLAGS) $(CFLAGS_KERNEL)" -C arch/$(ARCH)/boot
=20
 LD_VMLINUX	:=3D $(LD) $(LINKFLAGS) $(HEAD) init/main.o init/version.o \
 			--start-group \
@@ -256,7 +258,7 @@
 linuxsubdirs: $(patsubst %, _dir_%, $(SUBDIRS))
=20
 $(patsubst %, _dir_%, $(SUBDIRS)) : dummy include/config/MARKER
-	$(MAKE) -C $(patsubst _dir_%, %, $@)
+	$(MAKE) CFLAGS=3D"$(CFLAGS) $(CFLAGS_KERNEL)" -C $(patsubst _dir_%, %, $@)
=20
 $(TOPDIR)/include/linux/version.h: include/linux/version.h
 $(TOPDIR)/include/linux/compile.h: include/linux/compile.h
@@ -293,13 +295,13 @@
 	@mv -f .ver $@
=20
 init/version.o: init/version.c include/linux/compile.h include/config/MARK=
ER
-	$(CC) $(CFLAGS) -DUTS_MACHINE=3D'"$(ARCH)"' -c -o init/version.o init/ver=
sion.c
+	$(CC) $(CFLAGS) $(CFLAGS_KERNEL) -DUTS_MACHINE=3D'"$(ARCH)"' -c -o init/v=
ersion.o init/version.c
=20
 init/main.o: init/main.c include/config/MARKER
-	$(CC) $(CFLAGS) $(PROFILING) -c -o $*.o $<
+	$(CC) $(CFLAGS) $(CFLAGS_KERNEL) $(PROFILING) -c -o $*.o $<
=20
 fs lib mm ipc kernel drivers net: dummy
-	$(MAKE) $(subst $@, _dir_$@, $@)
+	$(MAKE) CFLAGS=3D"$(CFLAGS) $(CFLAGS_KERNEL)" $(subst $@, _dir_$@, $@)
=20
 TAGS: dummy
 	etags `find include/asm-$(ARCH) -name '*.h'`



