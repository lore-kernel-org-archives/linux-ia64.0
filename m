From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 25 Jul 2000 22:57:51 +0000
Subject: [Linux-ia64] 2.4.0-test5-pre4 patch for IA64 make
Message-Id: <marc-linux-ia64-105590678205229@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Linus, please apply.  It has been run past the linux-kbuild group.

The IA64 port needs a compile option (-mconstant-gp) turned on for the
kernel but turned off for modules.  gcc only supports the option, not
its negation, -mno-constant-gp is not valid.

This patch against 2.4.0-test5-pre4 splits CFLAGS into common flags
(CFLAGS), flags for kernel only (CFLAGS_KERNEL) and flags for modules
only (the existing MODFLAGS).  Eventually MODFLAGS should be renamed to
CFLAGS_MODULE for consistency but the kbuild group thinks it is too
close to 2.4 to do that now.

Index: 0-test5-pre4.1/arch/ia64/Makefile
--- 0-test5-pre4.1/arch/ia64/Makefile Tue, 18 Jul 2000 13:40:10 +1000 kaos =
(linux-2.4/c/c/43_Makefile 1.3 644)
+++ 0-test5-pre4.2(w)/arch/ia64/Makefile Wed, 26 Jul 2000 08:52:23 +1000 ka=
os (linux-2.4/c/c/43_Makefile 1.3 644)
@@ -18,7 +18,8 @@
 EXTRA	=20
 CFLAGS :=3D $(CFLAGS) -pipe $(EXTRA) -Wa,-x -ffixed-r13 -mfixed-range=F10-=
f15,f32-f127 \
-	  -mconstant-gp -funwind-tables
+	  -funwind-tables
+CFLAGS_KERNEL :=3D -mconstant-gp
=20
 ifdef CONFIG_IA64_GENERIC
 	CORE_FILES      :=3D      arch/$(ARCH)/hp/hp.a	\
Index: 0-test5-pre4.1/Makefile
--- 0-test5-pre4.1/Makefile Wed, 19 Jul 2000 17:53:13 +1000 kaos (linux-2.4=
/B/c/27_Makefile 1.1.2.2.2.4.1.5 644)
+++ 0-test5-pre4.2(w)/Makefile Wed, 26 Jul 2000 08:53:28 +1000 kaos (linux-=
2.4/B/c/27_Makefile 1.1.2.2.2.6.1.2 644)
@@ -36,6 +36,7 @@
 MAKEFILES	=3D $(TOPDIR)/.config
 GENKSYMS	=3D /sbin/genksyms
 MODFLAGS	=3D -DMODULE
+CFLAGS_KERNEL	 PERL		=3D perl
=20
 export	VERSION PATCHLEVEL SUBLEVEL EXTRAVERSION KERNELRELEASE ARCH \
@@ -190,7 +191,7 @@
 	@rm -f include/linux/compile.h
=20
 boot: vmlinux
-	@$(MAKE) -C arch/$(ARCH)/boot
+	@$(MAKE) CFLAGS=3D"$(CFLAGS) $(CFLAGS_KERNEL)" -C arch/$(ARCH)/boot
=20
 vmlinux: $(CONFIGURATION) init/main.o init/version.o linuxsubdirs
 	$(LD) $(LINKFLAGS) $(HEAD) init/main.o init/version.o \
@@ -231,7 +232,7 @@
 linuxsubdirs: $(patsubst %, _dir_%, $(SUBDIRS))
=20
 $(patsubst %, _dir_%, $(SUBDIRS)) : dummy include/linux/version.h include/=
config/MARKER
-	$(MAKE) -C $(patsubst _dir_%, %, $@)
+	$(MAKE) CFLAGS=3D"$(CFLAGS) $(CFLAGS_KERNEL)" -C $(patsubst _dir_%, %, $@)
=20
 $(TOPDIR)/include/linux/version.h: include/linux/version.h
 $(TOPDIR)/include/linux/compile.h: include/linux/compile.h
@@ -268,13 +269,13 @@
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



