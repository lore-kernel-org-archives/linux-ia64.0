From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 25 Jan 2003 05:02:32 +0000
Subject: [Linux-ia64] kernel update (relative to 2.5.59)
Message-Id: <marc-linux-ia64-105590709805751@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I just uploaded the latest ia64 patch to the usual location(s).  You
can get it from ftp.kernel.org/pub/linux/ia64/ports/v2.5/ in
file:

	linux-2.5.59-ia64-030124.diff.gz

This is mostly a sync-up with all the changes that happened between
2.5.52 and 2.5.59.  I also added one more light-weight system call:
set_tid_address().  The reason I added this one is because it makes
for a great example that shows how to deal with system call arguments
(explicit testing for NaT is required).  It might also make a (small)
difference in startup overheads for NPTL thread creation.

Stephane, I just realized that I forgot to apply your perfmon patch.
Sorry about tat---I'll fix that in the next patch.

Peter (Chubb): if you have an updated premption-support patch, I'd be
interested in merging it in (I wanted to do that for a while, but just
never got around to it).

This patch works well for me on the platforms I tested (zx6000 and Ski
simulator).  However, there seems to be a problem with running shared
x86 apps.  If someone could look into that, that would be great.

Oh, most importantly: you'll need a new assembler in order to use this
patch.  There was a nasty bug up until Dec 18 last year which
basically made certain place-relative expressions generate bad data.
Fortunately, HJ Lu has fixed that bug and I put a read-for-use, static
binary of a fixed assembler at:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/gas-030124.tar.gz

As a measure of safety, I added a sanity check which will cause "make"
to refuse to build a kernel with a buggy assembler.

As usual, you can get detailed changelogs at:

	http://lia64.bkbits.net:8080/to-linus-2.5

Enjoy,

	--david

diff -Nru a/Documentation/ia64/README b/Documentation/ia64/README
--- a/Documentation/ia64/README	Fri Jan 24 20:41:05 2003
+++ b/Documentation/ia64/README	Fri Jan 24 20:41:05 2003
@@ -4,40 +4,40 @@
    platform.  This document provides information specific to IA-64
    ONLY, to get additional information about the Linux kernel also
    read the original Linux README provided with the kernel.
-=20
+
 INSTALLING the kernel:
=20
  - IA-64 kernel installation is the same as the other platforms, see
    original README for details.
-  =20
-=20
+
+
 SOFTWARE REQUIREMENTS
=20
    Compiling and running this kernel requires an IA-64 compliant GCC
    compiler.  And various software packages also compiled with an
    IA-64 compliant GCC compiler.
-=20
+
=20
 CONFIGURING the kernel:
=20
    Configuration is the same, see original README for details.
- =20
-  =20
+
+
 COMPILING the kernel:
=20
  - Compiling this kernel doesn't differ from other platform so read
    the original README for details BUT make sure you have an IA-64
    compliant GCC compiler.
-=20
+
 IA-64 SPECIFICS
=20
  - General issues:
-=20
+
     o Hardly any performance tuning has been done. Obvious targets
       include the library routines (IP checksum, etc.). Less
       obvious targets include making sure we don't flush the TLB
       needlessly, etc.
-	 =20
+
     o SMP locks cleanup/optimization
-=09
+
     o IA32 support.  Currently experimental.  It mostly works.
diff -Nru a/Documentation/ia64/fsys.txt b/Documentation/ia64/fsys.txt
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/Documentation/ia64/fsys.txt	Fri Jan 24 20:41:06 2003
@@ -0,0 +1,231 @@
+-*-Mode: outline-*-
+
+		Light-weight System Calls for IA-64
+		-----------------------------------
+
+		        Started: 13-Jan-2002
+		    Last update: 24-Jan-2002
+
+	              David Mosberger-Tang
+		      <davidm@hpl.hp.com>
+
+Using the "epc" instruction effectively introduces a new mode of
+execution to the ia64 linux kernel.  We call this mode the
+"fsys-mode".  To recap, the normal states of execution are:
+
+  - kernel mode:
+	Both the register stack and the memory stack have been
+	switched over to kernel memory.  The user-level state is saved
+	in a pt-regs structure at the top of the kernel memory stack.
+
+  - user mode:
+	Both the register stack and the kernel stack are in
+	user memory.  The user-level state is contained in the
+	CPU registers.
+
+  - bank 0 interruption-handling mode:
+	This is the non-interruptible state which all
+	interruption-handlers start execution in.  The user-level
+	state remains in the CPU registers and some kernel state may
+	be stored in bank 0 of registers r16-r31.
+
+In contrast, fsys-mode has the following special properties:
+
+  - execution is at privilege level 0 (most-privileged)
+
+  - CPU registers may contain a mixture of user-level and kernel-level
+    state (it is the responsibility of the kernel to ensure that no
+    security-sensitive kernel-level state is leaked back to
+    user-level)
+
+  - execution is interruptible and preemptible (an fsys-mode handler
+    can disable interrupts and avoid all other interruption-sources
+    to avoid preemption)
+
+  - neither the memory nor the register stack can be trusted while
+    in fsys-mode (they point to the user-level stacks, which may
+    be invalid)
+
+In summary, fsys-mode is much more similar to running in user-mode
+than it is to running in kernel-mode.  Of course, given that the
+privilege level is at level 0, this means that fsys-mode requires some
+care (see below).
+
+
+* How to tell fsys-mode
+
+Linux operates in fsys-mode when (a) the privilege level is 0 (most
+privileged) and (b) the stacks have NOT been switched to kernel memory
+yet.  For convenience, the header file <asm-ia64/ptrace.h> provides
+three macros:
+
+	user_mode(regs)
+	user_stack(task,regs)
+	fsys_mode(task,regs)
+
+The "regs" argument is a pointer to a pt_regs structure.  The "task"
+argument is a pointer to the task structure to which the "regs"
+pointer belongs to.  user_mode() returns TRUE if the CPU state pointed
+to by "regs" was executing in user mode (privilege level 3).
+user_stack() returns TRUE if the state pointed to by "regs" was
+executing on the user-level stack(s).  Finally, fsys_mode() returns
+TRUE if the CPU state pointed to by "regs" was executing in fsys-mode.
+The fsys_mode() macro is equivalent to the expression:
+
+	!user_mode(regs) && user_stack(task,regs)
+
+* How to write an fsyscall handler
+
+The file arch/ia64/kernel/fsys.S contains a table of fsyscall-handlers
+(fsyscall_table).  This table contains one entry for each system call.
+By default, a system call is handled by fsys_fallback_syscall().  This
+routine takes care of entering (full) kernel mode and calling the
+normal Linux system call handler.  For performance-critical system
+calls, it is possible to write a hand-tuned fsyscall_handler.  For
+example, fsys.S contains fsys_getpid(), which is a hand-tuned version
+of the getpid() system call.
+
+The entry and exit-state of an fsyscall handler is as follows:
+
+** Machine state on entry to fsyscall handler:
+
+ - r10	  =3D 0
+ - r11	  =3D saved ar.pfs (a user-level value)
+ - r15	  =3D system call number
+ - r16	  =3D "current" task pointer (in normal kernel-mode, this is in r13)
+ - r32-r39 =3D system call arguments
+ - b6	  =3D return address (a user-level value)
+ - ar.pfs =3D previous frame-state (a user-level value)
+ - PSR.be =3D cleared to zero (i.e., little-endian byte order is in effect)
+ - all other registers may contain values passed in from user-mode
+
+** Required machine state on exit to fsyscall handler:
+
+ - r11	  =3D saved ar.pfs (as passed into the fsyscall handler)
+ - r15	  =3D system call number (as passed into the fsyscall handler)
+ - r32-r39 =3D system call arguments (as passed into the fsyscall handler)
+ - b6	  =3D return address (as passed into the fsyscall handler)
+ - ar.pfs =3D previous frame-state (as passed into the fsyscall handler)
+
+Fsyscall handlers can execute with very little overhead, but with that
+speed comes a set of restrictions:
+
+ o Fsyscall-handlers MUST check for any pending work in the flags
+   member of the thread-info structure and if any of the
+   TIF_ALLWORK_MASK flags are set, the handler needs to fall back on
+   doing a full system call (by calling fsys_fallback_syscall).
+
+ o Fsyscall-handlers MUST preserve incoming arguments (r32-r39, r11,
+   r15, b6, and ar.pfs) because they will be needed in case of a
+   system call restart.  Of course, all "preserved" registers also
+   must be preserved, in accordance to the normal calling conventions.
+
+ o Fsyscall-handlers MUST check argument registers for containing a
+   NaT value before using them in any way that could trigger a
+   NaT-consumption fault.  If a system call argument is found to
+   contain a NaT value, an fsyscall-handler may return immediately
+   with r8=3DEINVAL, r10=3D-1.
+
+ o Fsyscall-handlers MUST NOT use the "alloc" instruction or perform
+   any other operation that would trigger mandatory RSE
+   (register-stack engine) traffic.
+
+ o Fsyscall-handlers MUST NOT write to any stacked registers because
+   it is not safe to assume that user-level called a handler with the
+   proper number of arguments.
+
+ o Fsyscall-handlers need to be careful when accessing per-CPU variables:
+   unless proper safe-guards are taken (e.g., interruptions are avoided),
+   execution may be pre-empted and resumed on another CPU at any given
+   time.
+
+ o Fsyscall-handlers must be careful not to leak sensitive kernel'
+   information back to user-level.  In particular, before returning to
+   user-level, care needs to be taken to clear any scratch registers
+   that could contain sensitive information (note that the current
+   task pointer is not considered sensitive: it's already exposed
+   through ar.k6).
+
+The above restrictions may seem draconian, but remember that it's
+possible to trade off some of the restrictions by paying a slightly
+higher overhead.  For example, if an fsyscall-handler could benefit
+from the shadow register bank, it could temporarily disable PSR.i and
+PSR.ic, switch to bank 0 (bsw.0) and then use the shadow registers as
+needed.  In other words, following the above rules yields extremely
+fast system call execution (while fully preserving system call
+semantics), but there is also a lot of flexibility in handling more
+complicated cases.
+
+* Signal handling
+
+The delivery of (asynchronous) signals must be delayed until fsys-mode
+is exited.  This is acomplished with the help of the lower-privilege
+transfer trap: arch/ia64/kernel/process.c:do_notify_resume_user()
+checks whether the interrupted task was in fsys-mode and, if so, sets
+PSR.lp and returns immediately.  When fsys-mode is exited via the
+"br.ret" instruction that lowers the privilege level, a trap will
+occur.  The trap handler clears PSR.lp again and returns immediately.
+The kernel exit path then checks for and delivers any pending signals.
+
+* PSR Handling
+
+The "epc" instruction doesn't change the contents of PSR at all.  This
+is in contrast to a regular interruption, which clears almost all
+bits.  Because of that, some care needs to be taken to ensure things
+work as expected.  The following discussion describes how each PSR bit
+is handled.
+
+PSR.be	Cleared when entering fsys-mode.  A srlz.d instruction is used
+	to ensure the CPU is in little-endian mode before the first
+	load/store instruction is executed.  PSR.be is normally NOT
+	restored upon return from an fsys-mode handler.  In other
+	words, user-level code must not rely on PSR.be being preserved
+	across a system call.
+PSR.up	Unchanged.
+PSR.ac	Unchanged.
+PSR.mfl Unchanged.  Note: fsys-mode handlers must not write-registers!
+PSR.mfh	Unchanged.  Note: fsys-mode handlers must not write-registers!
+PSR.ic	Unchanged.  Note: fsys-mode handlers can clear the bit, if needed.
+PSR.i	Unchanged.  Note: fsys-mode handlers can clear the bit, if needed.
+PSR.pk	Unchanged.
+PSR.dt	Unchanged.
+PSR.dfl	Unchanged.  Note: fsys-mode handlers must not write-registers!
+PSR.dfh	Unchanged.  Note: fsys-mode handlers must not write-registers!
+PSR.sp	Unchanged.
+PSR.pp	Unchanged.
+PSR.di	Unchanged.
+PSR.si	Unchanged.
+PSR.db	Unchanged.  The kernel prevents user-level from setting a hardware
+	breakpoint that triggers at any privilege level other than 3 (user-mode).
+PSR.lp	Unchanged.
+PSR.tb	Lazy redirect.  If a taken-branch trap occurs while in
+	fsys-mode, the trap-handler modifies the saved machine state
+	such that execution resumes in the gate page at
+	syscall_via_break(), with privilege level 3.  Note: the
+	taken branch would occur on the branch invoking the
+	fsyscall-handler, at which point, by definition, a syscall
+	restart is still safe.  If the system call number is invalid,
+	the fsys-mode handler will return directly to user-level.  This
+	return will trigger a taken-branch trap, but since the trap is
+	taken _after_ restoring the privilege level, the CPU has already
+	left fsys-mode, so no special treatment is needed.
+PSR.rt	Unchanged.
+PSR.cpl	Cleared to 0.
+PSR.is	Unchanged (guaranteed to be 0 on entry to the gate page).
+PSR.mc	Unchanged.
+PSR.it	Unchanged (guaranteed to be 1).
+PSR.id	Unchanged.  Note: the ia64 linux kernel never sets this bit.
+PSR.da	Unchanged.  Note: the ia64 linux kernel never sets this bit.
+PSR.dd	Unchanged.  Note: the ia64 linux kernel never sets this bit.
+PSR.ss	Lazy redirect.  If set, "epc" will cause a Single Step Trap to
+	be taken.  The trap handler then modifies the saved machine
+	state such that execution resumes in the gate page at
+	syscall_via_break(), with privilege level 3.
+PSR.ri	Unchanged.
+PSR.ed	Unchanged.  Note: This bit could only have an effect if an fsys-mode
+	handler performed a speculative load that gets NaTted.  If so, this
+	would be the normal & expected behavior, so no special treatment is
+	needed.
+PSR.bn	Unchanged.  Note: fsys-mode handlers may clear the bit, if needed.
+	Doing so requires clearing PSR.i and PSR.ic as well.
+PSR.ia	Unchanged.  Note: the ia64 linux kernel never sets this bit.
diff -Nru a/Documentation/mmio_barrier.txt b/Documentation/mmio_barrier.txt
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/Documentation/mmio_barrier.txt	Fri Jan 24 20:41:06 2003
@@ -0,0 +1,15 @@
+On some platforms, so-called memory-mapped I/O is weakly ordered.  For
+example, the following might occur:
+
+CPU A writes 0x1 to Device #1
+CPU B writes 0x2 to Device #1
+Device #1 sees 0x2
+Device #1 sees 0x1
+
+On such platforms, driver writers are responsible for ensuring that I/O
+writes to memory-mapped addresses on their device arrive in the order
+intended.  The mmiob() macro is provided for this purpose.  A typical use
+of this macro might be immediately prior to the exit of a critical
+section of code proteced by spinlocks.  This would ensure that subsequent
+writes to I/O space arrived only after all prior writes (much like a
+typical memory barrier op, mb(), only with respect to I/O).
diff -Nru a/Makefile b/Makefile
--- a/Makefile	Fri Jan 24 20:41:05 2003
+++ b/Makefile	Fri Jan 24 20:41:05 2003
@@ -170,7 +170,7 @@
 NOSTDINC_FLAGS  =3D -nostdinc -iwithprefix include
=20
 CPPFLAGS	:=3D -D__KERNEL__ -Iinclude
-CFLAGS 		:=3D $(CPPFLAGS) -Wall -Wstrict-prototypes -Wno-trigraphs -O2 \
+CFLAGS 		:=3D $(CPPFLAGS) -Wall -Wstrict-prototypes -Wno-trigraphs -g -O2 \
 	  	   -fno-strict-aliasing -fno-common
 AFLAGS		:=3D -D__ASSEMBLY__ $(CPPFLAGS)
=20
diff -Nru a/arch/ia64/Kconfig b/arch/ia64/Kconfig
--- a/arch/ia64/Kconfig	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/Kconfig	Fri Jan 24 20:41:05 2003
@@ -768,6 +768,9 @@
=20
 menu "Kernel hacking"
=20
+config FSYS
+	bool "Light-weight system-call support (via epc)"
+
 choice
 	prompt "Physical memory granularity"
 	default IA64_GRANULE_64MB
diff -Nru a/arch/ia64/Makefile b/arch/ia64/Makefile
--- a/arch/ia64/Makefile	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/Makefile	Fri Jan 24 20:41:05 2003
@@ -5,7 +5,7 @@
 # License.  See the file "COPYING" in the main directory of this archive
 # for more details.
 #
-# Copyright (C) 1998-2002 by David Mosberger-Tang <davidm@hpl.hp.com>
+# Copyright (C) 1998-2003 by David Mosberger-Tang <davidm@hpl.hp.com>
 #
=20
 NM :=3D $(CROSS_COMPILE)nm -B
@@ -23,6 +23,16 @@
=20
 GCC_VERSION=3D$(shell $(CC) -v 2>&1 | fgrep 'gcc version' | cut -f3 -d' ' =
| cut -f1 -d'.')
=20
+GAS_STATUS=3D$(shell arch/ia64/scripts/check-gas $(CC))
+
+ifeq ($(GAS_STATUS),buggy)
+$(error Sorry, you need a newer version of the assember, one that is built=
 from	\
+	a source-tree that post-dates 18-Dec-2002.  You can find a pre-compiled	\
+	static binary of such an assembler at:					\
+										\
+		ftp://ftp.hpl.hp.com/pub/linux-ia64/gas-030124.tar.gz)
+endif
+
 ifneq ($(GCC_VERSION),2)
 	cflags-y +=3D -frename-registers --param max-inline-insnsP00
 endif
@@ -48,26 +58,37 @@
 drivers-$(CONFIG_IA64_HP_ZX1)	+=3D arch/ia64/hp/common/ arch/ia64/hp/zx1/
 drivers-$(CONFIG_IA64_SGI_SN)	+=3D arch/ia64/sn/fakeprom/
=20
-makeboot =3D$(Q)$(MAKE) -f scripts/Makefile.build obj=3Darch/ia64/boot $(1)
-maketool =3D$(Q)$(MAKE) -f scripts/Makefile.build obj=3Darch/ia64/tools $(=
1)
+boot :=3D arch/ia64/boot
+tools :=3D arch/ia64/tools
=20
 .PHONY: boot compressed archclean archmrproper include/asm-ia64/offsets.h
=20
-all compressed: vmlinux.gz
+all: vmlinux
+
+compressed: vmlinux.gz
=20
 vmlinux.gz: vmlinux
-	$(call makeboot,vmlinux.gz)
+	$(Q)$(MAKE) $(build)=3D$(boot) vmlinux.gz
+
+check: vmlinux
+	arch/ia64/scripts/unwcheck.sh vmlinux
=20
 archmrproper:
 archclean:
-	$(Q)$(MAKE) -f scripts/Makefile.clean obj=3Darch/ia64/boot
+	$(Q)$(MAKE) $(clean)=3D$(boot)
+	$(Q)$(MAKE) $(clean)=3D$(tools)
=20
 CLEAN_FILES +=3D include/asm-ia64/offsets.h vmlinux.gz bootloader
=20
 prepare: include/asm-ia64/offsets.h
=20
 boot:	lib/lib.a vmlinux
-	$(call makeboot,$@)
+	$(Q)$(MAKE) $(build)=3D$(boot) $@
=20
 include/asm-ia64/offsets.h: include/asm include/linux/version.h include/co=
nfig/MARKER
-	$(call maketool,$@)
+	$(Q)$(MAKE) $(build)=3D$(tools) $@
+
+define archhelp
+  echo '  compressed	- Build compressed kernel image'
+  echo '  boot		- Build vmlinux and bootloader for Ski simulator'
+endef
diff -Nru a/arch/ia64/hp/zx1/hpzx1_misc.c b/arch/ia64/hp/zx1/hpzx1_misc.c
--- a/arch/ia64/hp/zx1/hpzx1_misc.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/hp/zx1/hpzx1_misc.c	Fri Jan 24 20:41:05 2003
@@ -1,9 +1,9 @@
 /*
  * Misc. support for HP zx1 chipset support
  *
- * Copyright (C) 2002 Hewlett-Packard Co
- * Copyright (C) 2002 Alex Williamson <alex_williamson@hp.com>
- * Copyright (C) 2002 Bjorn Helgaas <bjorn_helgaas@hp.com>
+ * Copyright (C) 2002-2003 Hewlett-Packard Co
+ *	Alex Williamson <alex_williamson@hp.com>
+ *	Bjorn Helgaas <bjorn_helgaas@hp.com>
  */
=20
=20
@@ -17,7 +17,7 @@
 #include <asm/dma.h>
 #include <asm/iosapic.h>
=20
-extern acpi_status acpi_evaluate_integer (acpi_handle, acpi_string, acpi_o=
bject_list *,
+extern acpi_status acpi_evaluate_integer (acpi_handle, acpi_string, struct=
 acpi_object_list *,
 					  unsigned long *);
=20
 #define PFX "hpzx1: "
@@ -190,31 +190,31 @@
 	hpzx1_devices++;
 }
=20
-typedef struct {
+struct acpi_hp_vendor_long {
 	u8	guid_id;
 	u8	guid[16];
 	u8	csr_base[8];
 	u8	csr_length[8];
-} acpi_hp_vendor_long;
+};
=20
 #define HP_CCSR_LENGTH	0x21
 #define HP_CCSR_TYPE	0x2
 #define HP_CCSR_GUID	EFI_GUID(0x69e9adf9, 0x924f, 0xab5f,				\
 				 0xf6, 0x4a, 0x24, 0xd2, 0x01, 0x37, 0x0e, 0xad)
=20
-extern acpi_status acpi_get_crs(acpi_handle, acpi_buffer *);
-extern acpi_resource *acpi_get_crs_next(acpi_buffer *, int *);
-extern acpi_resource_data *acpi_get_crs_type(acpi_buffer *, int *, int);
-extern void acpi_dispose_crs(acpi_buffer *);
+extern acpi_status acpi_get_crs(acpi_handle, struct acpi_buffer *);
+extern struct acpi_resource *acpi_get_crs_next(struct acpi_buffer *, int *=
);
+extern union acpi_resource_data *acpi_get_crs_type(struct acpi_buffer *, i=
nt *, int);
+extern void acpi_dispose_crs(struct acpi_buffer *);
=20
 static acpi_status
 hp_csr_space(acpi_handle obj, u64 *csr_base, u64 *csr_length)
 {
 	int i, offset =3D 0;
 	acpi_status status;
-	acpi_buffer buf;
-	acpi_resource_vendor *res;
-	acpi_hp_vendor_long *hp_res;
+	struct acpi_buffer buf;
+	struct acpi_resource_vendor *res;
+	struct acpi_hp_vendor_long *hp_res;
 	efi_guid_t vendor_guid;
=20
 	*csr_base =3D 0;
@@ -226,14 +226,14 @@
 		return status;
 	}
=20
-	res =3D (acpi_resource_vendor *)acpi_get_crs_type(&buf, &offset, ACPI_RST=
YPE_VENDOR);
+	res =3D (struct acpi_resource_vendor *)acpi_get_crs_type(&buf, &offset, A=
CPI_RSTYPE_VENDOR);
 	if (!res) {
 		printk(KERN_ERR PFX "Failed to find config space for device\n");
 		acpi_dispose_crs(&buf);
 		return AE_NOT_FOUND;
 	}
=20
-	hp_res =3D (acpi_hp_vendor_long *)(res->reserved);
+	hp_res =3D (struct acpi_hp_vendor_long *)(res->reserved);
=20
 	if (res->length !=3D HP_CCSR_LENGTH || hp_res->guid_id !=3D HP_CCSR_TYPE)=
 {
 		printk(KERN_ERR PFX "Unknown Vendor data\n");
@@ -288,7 +288,7 @@
 {
 	u64 csr_base =3D 0, csr_length =3D 0;
 	acpi_status status;
-	NATIVE_UINT busnum;
+	acpi_native_uint busnum;
 	char *name =3D context;
 	char fullname[32];
=20
diff -Nru a/arch/ia64/ia32/binfmt_elf32.c b/arch/ia64/ia32/binfmt_elf32.c
--- a/arch/ia64/ia32/binfmt_elf32.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/ia32/binfmt_elf32.c	Fri Jan 24 20:41:05 2003
@@ -44,7 +44,6 @@
=20
 static void elf32_set_personality (void);
=20
-#define ELF_PLAT_INIT(_r)		ia64_elf32_init(_r)
 #define setup_arg_pages(bprm)		ia32_setup_arg_pages(bprm)
 #define elf_map				elf32_map
=20
diff -Nru a/arch/ia64/ia32/ia32_entry.S b/arch/ia64/ia32/ia32_entry.S
--- a/arch/ia64/ia32/ia32_entry.S	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/ia32/ia32_entry.S	Fri Jan 24 20:41:05 2003
@@ -95,12 +95,19 @@
 GLOBAL_ENTRY(ia32_ret_from_clone)
 	PT_REGS_UNWIND_INFO(0)
 #if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
+{	/*
+	 * Some versions of gas generate bad unwind info if the first instruction=
 of a
+	 * procedure doesn't go into the first slot of a bundle.  This is a worka=
round.
+	 */
+	nop.m 0
+	nop.i 0
 	/*
 	 * We need to call schedule_tail() to complete the scheduling process.
 	 * Called by ia64_switch_to after do_fork()->copy_thread().  r8 contains =
the
 	 * address of the previously executing task.
 	 */
 	br.call.sptk.many rp=3Dia64_invoke_schedule_tail
+}
 .ret1:
 #endif
 	adds r2=3DTI_FLAGS+IA64_TASK_SIZE,r13
@@ -264,7 +271,7 @@
 	data8 sys_setreuid	/* 16-bit version */	  /* 70 */
 	data8 sys_setregid	/* 16-bit version */
 	data8 sys32_sigsuspend
-	data8 sys32_sigpending
+	data8 compat_sys_sigpending
 	data8 sys_sethostname
 	data8 sys32_setrlimit	  /* 75 */
 	data8 sys32_old_getrlimit
@@ -290,8 +297,8 @@
 	data8 sys_getpriority
 	data8 sys_setpriority
 	data8 sys32_ni_syscall	  /* old profil syscall holder */
-	data8 sys32_statfs
-	data8 sys32_fstatfs	  /* 100 */
+	data8 compat_sys_statfs
+	data8 compat_sys_fstatfs	  /* 100 */
 	data8 sys32_ioperm
 	data8 sys32_socketcall
 	data8 sys_syslog
@@ -317,7 +324,7 @@
 	data8 sys32_modify_ldt
 	data8 sys32_ni_syscall	/* adjtimex */
 	data8 sys32_mprotect	  /* 125 */
-	data8 sys32_sigprocmask
+	data8 compat_sys_sigprocmask
 	data8 sys32_ni_syscall	/* create_module */
 	data8 sys32_ni_syscall	/* init_module */
 	data8 sys32_ni_syscall	/* delete_module */
diff -Nru a/arch/ia64/ia32/ia32_signal.c b/arch/ia64/ia32/ia32_signal.c
--- a/arch/ia64/ia32/ia32_signal.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/ia32/ia32_signal.c	Fri Jan 24 20:41:05 2003
@@ -56,7 +56,7 @@
        int sig;
        struct sigcontext_ia32 sc;
        struct _fpstate_ia32 fpstate;
-       unsigned int extramask[_IA32_NSIG_WORDS-1];
+       unsigned int extramask[_COMPAT_NSIG_WORDS-1];
        char retcode[8];
 };
=20
@@ -463,7 +463,7 @@
 }
=20
 asmlinkage long
-ia32_rt_sigsuspend (sigset32_t *uset, unsigned int sigsetsize, struct sigs=
cratch *scr)
+ia32_rt_sigsuspend (compat_sigset_t *uset, unsigned int sigsetsize, struct=
 sigscratch *scr)
 {
 	extern long ia64_do_signal (sigset_t *oldset, struct sigscratch *scr, lon=
g in_syscall);
 	sigset_t oldset, set;
@@ -504,7 +504,7 @@
 asmlinkage long
 ia32_sigsuspend (unsigned int mask, struct sigscratch *scr)
 {
-	return ia32_rt_sigsuspend((sigset32_t *)&mask, sizeof(mask), scr);
+	return ia32_rt_sigsuspend((compat_sigset_t *)&mask, sizeof(mask), scr);
 }
=20
 asmlinkage long
@@ -530,14 +530,14 @@
 	int ret;
=20
 	/* XXX: Don't preclude handling different sized sigset_t's.  */
-	if (sigsetsize !=3D sizeof(sigset32_t))
+	if (sigsetsize !=3D sizeof(compat_sigset_t))
 		return -EINVAL;
=20
 	if (act) {
 		ret =3D get_user(handler, &act->sa_handler);
 		ret |=3D get_user(new_ka.sa.sa_flags, &act->sa_flags);
 		ret |=3D get_user(restorer, &act->sa_restorer);
-		ret |=3D copy_from_user(&new_ka.sa.sa_mask, &act->sa_mask, sizeof(sigset=
32_t));
+		ret |=3D copy_from_user(&new_ka.sa.sa_mask, &act->sa_mask, sizeof(compat=
_sigset_t));
 		if (ret)
 			return -EFAULT;
=20
@@ -550,7 +550,7 @@
 		ret =3D put_user(IA32_SA_HANDLER(&old_ka), &oact->sa_handler);
 		ret |=3D put_user(old_ka.sa.sa_flags, &oact->sa_flags);
 		ret |=3D put_user(IA32_SA_RESTORER(&old_ka), &oact->sa_restorer);
-		ret |=3D copy_to_user(&oact->sa_mask, &old_ka.sa.sa_mask, sizeof(sigset3=
2_t));
+		ret |=3D copy_to_user(&oact->sa_mask, &old_ka.sa.sa_mask, sizeof(compat_=
sigset_t));
 	}
 	return ret;
 }
@@ -560,7 +560,7 @@
 					   size_t sigsetsize);
=20
 asmlinkage long
-sys32_rt_sigprocmask (int how, sigset32_t *set, sigset32_t *oset, unsigned=
 int sigsetsize)
+sys32_rt_sigprocmask (int how, compat_sigset_t *set, compat_sigset_t *oset=
, unsigned int sigsetsize)
 {
 	mm_segment_t old_fs =3D get_fs();
 	sigset_t s;
@@ -587,13 +587,7 @@
 }
=20
 asmlinkage long
-sys32_sigprocmask (int how, unsigned int *set, unsigned int *oset)
-{
-	return sys32_rt_sigprocmask(how, (sigset32_t *) set, (sigset32_t *) oset,=
 sizeof(*set));
-}
-
-asmlinkage long
-sys32_rt_sigtimedwait (sigset32_t *uthese, siginfo_t32 *uinfo,
+sys32_rt_sigtimedwait (compat_sigset_t *uthese, siginfo_t32 *uinfo,
 		struct compat_timespec *uts, unsigned int sigsetsize)
 {
 	extern asmlinkage long sys_rt_sigtimedwait (const sigset_t *, siginfo_t *,
@@ -605,16 +599,13 @@
 	sigset_t s;
 	int ret;
=20
-	if (copy_from_user(&s.sig, uthese, sizeof(sigset32_t)))
+	if (copy_from_user(&s.sig, uthese, sizeof(compat_sigset_t)))
+		return -EFAULT;
+	if (uts && get_compat_timespec(&t, uts))
 		return -EFAULT;
-	if (uts) {
-		ret =3D get_user(t.tv_sec, &uts->tv_sec);
-		ret |=3D get_user(t.tv_nsec, &uts->tv_nsec);
-		if (ret)
-			return -EFAULT;
-	}
 	set_fs(KERNEL_DS);
-	ret =3D sys_rt_sigtimedwait(&s, &info, &t, sigsetsize);
+	ret =3D sys_rt_sigtimedwait(&s, uinfo ? &info : NULL, uts ? &t : NULL,
+			sigsetsize);
 	set_fs(old_fs);
 	if (ret >=3D 0 && uinfo) {
 		if (copy_siginfo_to_user32(uinfo, &info))
@@ -648,7 +639,7 @@
 	int ret;
=20
 	if (act) {
-		old_sigset32_t mask;
+		compat_old_sigset_t mask;
=20
 		ret =3D get_user(handler, &act->sa_handler);
 		ret |=3D get_user(new_ka.sa.sa_flags, &act->sa_flags);
@@ -866,7 +857,7 @@
=20
 	err |=3D setup_sigcontext_ia32(&frame->sc, &frame->fpstate, regs, set->si=
g[0]);
=20
-	if (_IA32_NSIG_WORDS > 1)
+	if (_COMPAT_NSIG_WORDS > 1)
 		err |=3D __copy_to_user(frame->extramask, (char *) &set->sig + 4,
 				      sizeof(frame->extramask));
=20
@@ -1011,7 +1002,7 @@
 		goto badframe;
=20
 	if (__get_user(set.sig[0], &frame->sc.oldmask)
-	    || (_IA32_NSIG_WORDS > 1 && __copy_from_user((char *) &set.sig + 4, &=
frame->extramask,
+	    || (_COMPAT_NSIG_WORDS > 1 && __copy_from_user((char *) &set.sig + 4,=
 &frame->extramask,
 							 sizeof(frame->extramask))))
 		goto badframe;
=20
diff -Nru a/arch/ia64/ia32/ia32_support.c b/arch/ia64/ia32/ia32_support.c
--- a/arch/ia64/ia32/ia32_support.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/ia32/ia32_support.c	Fri Jan 24 20:41:05 2003
@@ -95,8 +95,6 @@
 	struct pt_regs *regs =3D ia64_task_regs(t);
 	int nr =3D smp_processor_id();	/* LDT and TSS depend on CPU number: */
=20
-	nr =3D smp_processor_id();
-
 	eflag =3D t->thread.eflag;
 	fsr =3D t->thread.fsr;
 	fcr =3D t->thread.fcr;
diff -Nru a/arch/ia64/ia32/sys_ia32.c b/arch/ia64/ia32/sys_ia32.c
--- a/arch/ia64/ia32/sys_ia32.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/ia32/sys_ia32.c	Fri Jan 24 20:41:05 2003
@@ -6,7 +6,7 @@
  * Copyright (C) 1999		Arun Sharma <arun.sharma@intel.com>
  * Copyright (C) 1997,1998	Jakub Jelinek (jj@sunsite.mff.cuni.cz)
  * Copyright (C) 1997		David S. Miller (davem@caip.rutgers.edu)
- * Copyright (C) 2000-2002 Hewlett-Packard Co
+ * Copyright (C) 2000-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * These routines maintain argument size conversion between 32bit and 64bit
@@ -609,61 +609,6 @@
 	return retval;
 }
=20
-static inline int
-put_statfs (struct statfs32 *ubuf, struct statfs *kbuf)
-{
-	int err;
-
-	if (!access_ok(VERIFY_WRITE, ubuf, sizeof(*ubuf)))
-		return -EFAULT;
-
-	err =3D __put_user(kbuf->f_type, &ubuf->f_type);
-	err |=3D __put_user(kbuf->f_bsize, &ubuf->f_bsize);
-	err |=3D __put_user(kbuf->f_blocks, &ubuf->f_blocks);
-	err |=3D __put_user(kbuf->f_bfree, &ubuf->f_bfree);
-	err |=3D __put_user(kbuf->f_bavail, &ubuf->f_bavail);
-	err |=3D __put_user(kbuf->f_files, &ubuf->f_files);
-	err |=3D __put_user(kbuf->f_ffree, &ubuf->f_ffree);
-	err |=3D __put_user(kbuf->f_namelen, &ubuf->f_namelen);
-	err |=3D __put_user(kbuf->f_fsid.val[0], &ubuf->f_fsid.val[0]);
-	err |=3D __put_user(kbuf->f_fsid.val[1], &ubuf->f_fsid.val[1]);
-	return err;
-}
-
-extern asmlinkage long sys_statfs(const char * path, struct statfs * buf);
-
-asmlinkage long
-sys32_statfs (const char *path, struct statfs32 *buf)
-{
-	int ret;
-	struct statfs s;
-	mm_segment_t old_fs =3D get_fs();
-
-	set_fs(KERNEL_DS);
-	ret =3D sys_statfs(path, &s);
-	set_fs(old_fs);
-	if (put_statfs(buf, &s))
-		return -EFAULT;
-	return ret;
-}
-
-extern asmlinkage long sys_fstatfs(unsigned int fd, struct statfs * buf);
-
-asmlinkage long
-sys32_fstatfs (unsigned int fd, struct statfs32 *buf)
-{
-	int ret;
-	struct statfs s;
-	mm_segment_t old_fs =3D get_fs();
-
-	set_fs(KERNEL_DS);
-	ret =3D sys_fstatfs(fd, &s);
-	set_fs(old_fs);
-	if (put_statfs(buf, &s))
-		return -EFAULT;
-	return ret;
-}
-
 static inline long
 get_tv32 (struct timeval *o, struct compat_timeval *i)
 {
@@ -1849,10 +1794,10 @@
=20
 struct ipc64_perm32 {
 	key_t key;
-	__kernel_uid32_t32 uid;
-	__kernel_gid32_t32 gid;
-	__kernel_uid32_t32 cuid;
-	__kernel_gid32_t32 cgid;
+	compat_uid32_t uid;
+	compat_gid32_t gid;
+	compat_uid32_t cuid;
+	compat_gid32_t cgid;
 	compat_mode_t mode;
 	unsigned short __pad1;
 	unsigned short seq;
@@ -1895,8 +1840,8 @@
 	unsigned short msg_cbytes;
 	unsigned short msg_qnum;
 	unsigned short msg_qbytes;
-	__kernel_ipc_pid_t32 msg_lspid;
-	__kernel_ipc_pid_t32 msg_lrpid;
+	compat_ipc_pid_t msg_lspid;
+	compat_ipc_pid_t msg_lrpid;
 };
=20
 struct msqid64_ds32 {
@@ -1922,8 +1867,8 @@
 	compat_time_t   shm_atime;
 	compat_time_t   shm_dtime;
 	compat_time_t   shm_ctime;
-	__kernel_ipc_pid_t32 shm_cpid;
-	__kernel_ipc_pid_t32 shm_lpid;
+	compat_ipc_pid_t shm_cpid;
+	compat_ipc_pid_t shm_lpid;
 	unsigned short shm_nattch;
 };
=20
@@ -2011,6 +1956,10 @@
 	else
 		fourth.__pad =3D (void *)A(pad);
 	switch (third) {
+	      default:
+		err =3D -EINVAL;
+		break;
+
 	      case IPC_INFO:
 	      case IPC_RMID:
 	      case IPC_SET:
@@ -2399,7 +2348,7 @@
=20
 static long
 semtimedop32(int semid, struct sembuf *tsems, int nsems,
-	     const struct timespec32 *timeout32)
+	     const struct compat_timespec *timeout32)
 {
 	struct timespec t;
 	if (get_user (t.tv_sec, &timeout32->tv_sec) ||
@@ -2422,7 +2371,7 @@
 		return sys_semtimedop(first, (struct sembuf *)AA(ptr), second, NULL);
 	      case SEMTIMEDOP:
 		return semtimedop32(first, (struct sembuf *)AA(ptr), second,
-				    (const struct timespec32 *)AA(fifth));
+				    (const struct compat_timespec *)AA(fifth));
 	      case SEMGET:
 		return sys_semget(first, second, third);
 	      case SEMCTL:
@@ -3475,12 +3424,6 @@
 	return ret;
 }
=20
-asmlinkage long
-sys32_sigpending (unsigned int *set)
-{
-	return do_sigpending(set, sizeof(*set));
-}
-
 struct sysinfo32 {
 	s32 uptime;
 	u32 loads[3];
@@ -3536,7 +3479,7 @@
 	set_fs(KERNEL_DS);
 	ret =3D sys_sched_rr_get_interval(pid, &t);
 	set_fs(old_fs);
-	if (put_user (t.tv_sec, &interval->tv_sec) || put_user (t.tv_nsec, &inter=
val->tv_nsec))
+	if (put_compat_timespec(&t, interval))
 		return -EFAULT;
 	return ret;
 }
diff -Nru a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
--- a/arch/ia64/kernel/Makefile	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/Makefile	Fri Jan 24 20:41:05 2003
@@ -12,6 +12,7 @@
 	 semaphore.o setup.o	\
 	 signal.o sys_ia64.o traps.o time.o unaligned.o unwind.o
=20
+obj-$(CONFIG_FSYS) +=3D fsys.o
 obj-$(CONFIG_IOSAPIC) +=3D iosapic.o
 obj-$(CONFIG_IA64_PALINFO) +=3D palinfo.o
 obj-$(CONFIG_EFI_VARS) +=3D efivars.o
diff -Nru a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
--- a/arch/ia64/kernel/acpi.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/acpi.c	Fri Jan 24 20:41:05 2003
@@ -128,7 +128,7 @@
  * with a list of acpi_resource structures.
  */
 acpi_status
-acpi_get_crs (acpi_handle obj, acpi_buffer *buf)
+acpi_get_crs (acpi_handle obj, struct acpi_buffer *buf)
 {
 	acpi_status result;
 	buf->length =3D 0;
@@ -144,10 +144,10 @@
 	return acpi_get_current_resources(obj, buf);
 }
=20
-acpi_resource *
-acpi_get_crs_next (acpi_buffer *buf, int *offset)
+struct acpi_resource *
+acpi_get_crs_next (struct acpi_buffer *buf, int *offset)
 {
-	acpi_resource *res;
+	struct acpi_resource *res;
=20
 	if (*offset >=3D buf->length)
 		return NULL;
@@ -157,11 +157,11 @@
 	return res;
 }
=20
-acpi_resource_data *
-acpi_get_crs_type (acpi_buffer *buf, int *offset, int type)
+union acpi_resource_data *
+acpi_get_crs_type (struct acpi_buffer *buf, int *offset, int type)
 {
 	for (;;) {
-		acpi_resource *res =3D acpi_get_crs_next(buf, offset);
+		struct acpi_resource *res =3D acpi_get_crs_next(buf, offset);
 		if (!res)
 			return NULL;
 		if (res->id =3D type)
@@ -170,7 +170,7 @@
 }
=20
 void
-acpi_dispose_crs (acpi_buffer *buf)
+acpi_dispose_crs (struct acpi_buffer *buf)
 {
 	kfree(buf->pointer);
 }
@@ -638,7 +638,7 @@
 acpi_parse_fadt (unsigned long phys_addr, unsigned long size)
 {
 	struct acpi_table_header *fadt_header;
-	fadt_descriptor_rev2 *fadt;
+	struct fadt_descriptor_rev2 *fadt;
 	u32 sci_irq, gsi_base;
 	char *iosapic_address;
=20
@@ -649,7 +649,7 @@
 	if (fadt_header->revision !=3D 3)
 		return -ENODEV;		/* Only deal with ACPI 2.0 FADT */
=20
-	fadt =3D (fadt_descriptor_rev2 *) fadt_header;
+	fadt =3D (struct fadt_descriptor_rev2 *) fadt_header;
=20
 	if (!(fadt->iapc_boot_arch & BAF_8042_KEYBOARD_CONTROLLER))
 		acpi_kbd_controller_present =3D 0;
@@ -886,6 +886,28 @@
 		return isa_irq_to_vector(irq);
=20
 	return gsi_to_vector(irq);
+}
+
+int __init
+acpi_register_irq (u32 gsi, u32 polarity, u32 trigger)
+{
+	int vector =3D 0;
+	u32 irq_base;
+	char *iosapic_address;
+
+	if (acpi_madt->flags.pcat_compat && (gsi < 16))
+		return isa_irq_to_vector(gsi);
+
+	if (!iosapic_register_intr)
+		return 0;
+
+	/* Find the IOSAPIC */
+	if (!acpi_find_iosapic(gsi, &irq_base, &iosapic_address)) {
+		/* Turn it on */
+		vector =3D iosapic_register_intr (gsi, polarity, trigger,
+						irq_base, iosapic_address);
+	}
+	return vector;
 }
=20
 #endif /* CONFIG_ACPI_BOOT */
diff -Nru a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/efi.c	Fri Jan 24 20:41:05 2003
@@ -33,15 +33,6 @@
=20
 #define EFI_DEBUG	0
=20
-#ifdef CONFIG_HUGETLB_PAGE
-
-/* By default at total of 512MB is reserved huge pages. */
-#define HTLBZONE_SIZE_DEFAULT  0x20000000
-
-unsigned long htlbzone_pages =3D (HTLBZONE_SIZE_DEFAULT >> HPAGE_SHIFT);
-
-#endif
-
 extern efi_status_t efi_call_phys (void *, ...);
=20
 struct efi efi;
@@ -497,25 +488,6 @@
 				++cp;
 		}
 	}
-#ifdef CONFIG_HUGETLB_PAGE
-	/* Just duplicating the above algo for lpzone start */
-	for (cp =3D saved_command_line; *cp; ) {
-		if (memcmp(cp, "lpmem=3D", 6) =3D 0) {
-			cp +=3D 6;
-			htlbzone_pages =3D memparse(cp, &end);
-			htlbzone_pages =3D (htlbzone_pages >> HPAGE_SHIFT);
-			if (end !=3D cp)
-				break;
-			cp =3D end;
-		} else {
-			while (*cp !=3D ' ' && *cp)
-				++cp;
-			while (*cp =3D ' ')
-				++cp;
-		}
-	}
-	printk("Total HugeTLB_Page memory pages requested  0x%lx \n", htlbzone_pa=
ges);
-#endif
 	if (mem_limit !=3D ~0UL)
 		printk("Ignoring memory above %luMB\n", mem_limit >> 20);
=20
diff -Nru a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/entry.S	Fri Jan 24 20:41:05 2003
@@ -3,7 +3,7 @@
  *
  * Kernel entry points.
  *
- * Copyright (C) 1998-2002 Hewlett-Packard Co
+ * Copyright (C) 1998-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
@@ -22,8 +22,8 @@
 /*
  * Global (preserved) predicate usage on syscall entry/exit path:
  *
- *	pKern:		See entry.h.
- *	pUser:		See entry.h.
+ *	pKStk:		See entry.h.
+ *	pUStk:		See entry.h.
  *	pSys:		See entry.h.
  *	pNonSys:	!pSys
  */
@@ -63,7 +63,7 @@
 	sxt4 r8=3Dr8			// return 64-bit result
 	;;
 	stf.spill [sp]=F0
-(p6)	cmp.ne pKern,pUser=3Dr0,r0	// a successful execve() lands us in user-=
mode...
+(p6)	cmp.ne pKStk,pUStk=3Dr0,r0	// a successful execve() lands us in user-=
mode...
 	mov rp=3Dloc0
 (p6)	mov ar.pfs=3Dr0			// clear ar.pfs on success
 (p7)	br.ret.sptk.many rp
@@ -193,7 +193,7 @@
 	;;
 (p6)	srlz.d
 	ld8 sp=3D[r21]			// load kernel stack pointer of new task
-	mov IA64_KR(CURRENT)=3Dr20	// update "current" application register
+	mov IA64_KR(CURRENT)=3Din0	// update "current" application register
 	mov r8=3Dr13			// return pointer to previously running task
 	mov r13=3Din0			// set "current" pointer
 	;;
@@ -507,7 +507,14 @@
=20
 GLOBAL_ENTRY(ia64_trace_syscall)
 	PT_REGS_UNWIND_INFO(0)
+{	/*
+	 * Some versions of gas generate bad unwind info if the first instruction=
 of a
+	 * procedure doesn't go into the first slot of a bundle.  This is a worka=
round.
+	 */
+	nop.m 0
+	nop.i 0
 	br.call.sptk.many rp=3Dinvoke_syscall_trace // give parent a chance to ca=
tch syscall args
+}
 .ret6:	br.call.sptk.many rp=B6			// do the syscall
 strace_check_retval:
 	cmp.lt p6,p0=3Dr8,r0			// syscall failed?
@@ -537,12 +544,19 @@
=20
 GLOBAL_ENTRY(ia64_ret_from_clone)
 	PT_REGS_UNWIND_INFO(0)
+{	/*
+	 * Some versions of gas generate bad unwind info if the first instruction=
 of a
+	 * procedure doesn't go into the first slot of a bundle.  This is a worka=
round.
+	 */
+	nop.m 0
+	nop.i 0
 	/*
 	 * We need to call schedule_tail() to complete the scheduling process.
 	 * Called by ia64_switch_to() after do_fork()->copy_thread().  r8 contain=
s the
 	 * address of the previously executing task.
 	 */
 	br.call.sptk.many rp=3Dia64_invoke_schedule_tail
+}
 .ret8:
 	adds r2=3DTI_FLAGS+IA64_TASK_SIZE,r13
 	;;
@@ -569,11 +583,12 @@
 	// fall through
 GLOBAL_ENTRY(ia64_leave_kernel)
 	PT_REGS_UNWIND_INFO(0)
-	// work.need_resched etc. mustn't get changed by this CPU before it retur=
ns to userspace:
-(pUser)	cmp.eq.unc p6,p0=3Dr0,r0			// p6 <- pUser
-(pUser)	rsm psr.i
+	// work.need_resched etc. mustn't get changed by this CPU before it retur=
ns to
+	// user- or fsys-mode:
+(pUStk)	cmp.eq.unc p6,p0=3Dr0,r0			// p6 <- pUStk
+(pUStk)	rsm psr.i
 	;;
-(pUser)	adds r17=3DTI_FLAGS+IA64_TASK_SIZE,r13
+(pUStk)	adds r17=3DTI_FLAGS+IA64_TASK_SIZE,r13
 	;;
 .work_processed:
 (p6)	ld4 r18=3D[r17]				// load current_thread_info()->flags
@@ -635,9 +650,9 @@
 	;;
 	srlz.i			// ensure interruption collection is off
 	mov b7=3Dr15
+	bsw.0			// switch back to bank 0 (no stop bit required beforehand...)
 	;;
-	bsw.0			// switch back to bank 0
-	;;
+(pUStk)	mov r18=3DIA64_KR(CURRENT)	// Itanium 2: 12 cycle read latency
 	adds r16=16,r12
 	adds r17$,r12
 	;;
@@ -665,16 +680,21 @@
 	;;
 	ld8.fill r12=3D[r16],16
 	ld8.fill r13=3D[r17],16
+(pUStk)	adds r18=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r18
 	;;
 	ld8.fill r14=3D[r16]
 	ld8.fill r15=3D[r17]
+(pUStk)	mov r17=3D1
+	;;
+(pUStk)	st1 [r18]=3Dr17		// restore current->thread.on_ustack
 	shr.u r18=3Dr19,16	// get byte size of existing "dirty" partition
 	;;
 	mov r16=3Dar.bsp		// get existing backing store pointer
 	movl r17=3DTHIS_CPU(ia64_phys_stacked_size_p8)
 	;;
 	ld4 r17=3D[r17]		// r17 =3D cpu_data->phys_stacked_size_p8
-(pKern)	br.cond.dpnt skip_rbs_switch
+(pKStk)	br.cond.dpnt skip_rbs_switch
+
 	/*
 	 * Restore user backing store.
 	 *
@@ -710,21 +730,9 @@
 	shr.u loc1=3Dr18,9		// RNaTslots <=3D dirtySize / (64*8) + 1
 	sub r17=3Dr17,r18			// r17 =3D (physStackedSize + 8) - dirtySize
 	;;
-#if 1
-	.align 32		// see comment below about gas bug...
-#endif
 	mov ar.rsc=3Dr19			// load ar.rsc to be used for "loadrs"
 	shladd in0=3Dloc1,3,r17
 	mov in1=3D0
-#if 0
-	// gas-2.12.90 is unable to generate a stop bit after .align, which is ba=
d,
-	// because alloc must be at the beginning of an insn-group.
-	.align 32
-#else
-	nop 0
-	nop 0
-	nop 0
-#endif
 	;;
 rse_clear_invalid:
 #ifdef CONFIG_ITANIUM
@@ -788,12 +796,12 @@
 skip_rbs_switch:
 	mov b6=3DrB6
 	mov ar.pfs=3DrARPFS
-(pUser)	mov ar.bspstore=3DrARBSPSTORE
+(pUStk)	mov ar.bspstore=3DrARBSPSTORE
 (p9)	mov cr.ifs=3DrCRIFS
 	mov cr.ipsr=3DrCRIPSR
 	mov cr.iip=3DrCRIIP
 	;;
-(pUser)	mov ar.rnat=3DrARRNAT	// must happen with RSE in lazy mode
+(pUStk)	mov ar.rnat=3DrARRNAT	// must happen with RSE in lazy mode
 	mov ar.rsc=3DrARRSC
 	mov ar.unat=3DrARUNAT
 	mov pr=3DrARPR,-1
@@ -963,17 +971,16 @@
 END(sys_rt_sigreturn)
=20
 GLOBAL_ENTRY(ia64_prepare_handle_unaligned)
-	//
-	// r16 =3D fake ar.pfs, we simply need to make sure
-	// privilege is still 0
-	//
-	mov r16=3Dr0
 	.prologue
+	/*
+	 * r16 =3D fake ar.pfs, we simply need to make sure privilege is still 0
+	 */
+	mov r16=3Dr0
 	DO_SAVE_SWITCH_STACK
-	br.call.sptk.many rp=3Dia64_handle_unaligned // stack frame setup in ivt
+	br.call.sptk.many rp=3Dia64_handle_unaligned	// stack frame setup in ivt
 .ret21:	.body
 	DO_LOAD_SWITCH_STACK
-	br.cond.sptk.many rp			  // goes to ia64_leave_kernel
+	br.cond.sptk.many rp				// goes to ia64_leave_kernel
 END(ia64_prepare_handle_unaligned)
=20
 	//
@@ -1235,8 +1242,8 @@
 	data8 sys_sched_setaffinity
 	data8 sys_sched_getaffinity
 	data8 sys_set_tid_address
-	data8 ia64_ni_syscall 		// available. (was sys_alloc_hugepages)
-	data8 ia64_ni_syscall		// available (was sys_free_hugepages)
+	data8 ia64_ni_syscall
+	data8 ia64_ni_syscall 			// 1235
 	data8 sys_exit_group
 	data8 sys_lookup_dcookie
 	data8 sys_io_setup
diff -Nru a/arch/ia64/kernel/entry.h b/arch/ia64/kernel/entry.h
--- a/arch/ia64/kernel/entry.h	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/entry.h	Fri Jan 24 20:41:05 2003
@@ -4,8 +4,8 @@
  * Preserved registers that are shared between code in ivt.S and entry.S. =
 Be
  * careful not to step on these!
  */
-#define pKern		p2	/* will leave_kernel return to kernel-mode? */
-#define pUser		p3	/* will leave_kernel return to user-mode? */
+#define pKStk		p2	/* will leave_kernel return to kernel-stacks? */
+#define pUStk		p3	/* will leave_kernel return to user-stacks? */
 #define pSys		p4	/* are we processing a (synchronous) system call? */
 #define pNonSys		p5	/* complement of pSys */
=20
diff -Nru a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/ia64/kernel/fsys.S	Fri Jan 24 20:41:06 2003
@@ -0,0 +1,339 @@
+/*
+ * This file contains the light-weight system call handlers (fsyscall-hand=
lers).
+ *
+ * Copyright (C) 2003 Hewlett-Packard Co
+ * 	David Mosberger-Tang <davidm@hpl.hp.com>
+ */
+
+#include <asm/asmmacro.h>
+#include <asm/errno.h>
+#include <asm/offsets.h>
+#include <asm/thread_info.h>
+
+/*
+ * See Documentation/ia64/fsys.txt for details on fsyscalls.
+ *
+ * On entry to an fsyscall handler:
+ *   r10	=3D 0 (i.e., defaults to "successful syscall return")
+ *   r11	=3D saved ar.pfs (a user-level value)
+ *   r15	=3D system call number
+ *   r16	=3D "current" task pointer (in normal kernel-mode, this is in r13)
+ *   r32-r39	=3D system call arguments
+ *   b6		=3D return address (a user-level value)
+ *   ar.pfs	=3D previous frame-state (a user-level value)
+ *   PSR.be	=3D cleared to zero (i.e., little-endian byte order is in effe=
ct)
+ *   all other registers may contain values passed in from user-mode
+ *
+ * On return from an fsyscall handler:
+ *   r11	=3D saved ar.pfs (as passed into the fsyscall handler)
+ *   r15	=3D system call number (as passed into the fsyscall handler)
+ *   r32-r39	=3D system call arguments (as passed into the fsyscall handle=
r)
+ *   b6		=3D return address (as passed into the fsyscall handler)
+ *   ar.pfs	=3D previous frame-state (as passed into the fsyscall handler)
+ */
+
+ENTRY(fsys_ni_syscall)
+	mov r8=3DENOSYS
+	mov r10=3D-1
+	MCKINLEY_E9_WORKAROUND
+	br.ret.sptk.many b6
+END(fsys_ni_syscall)
+
+ENTRY(fsys_getpid)
+	add r9=3DTI_FLAGS+IA64_TASK_SIZE,r16
+	;;
+	ld4 r9=3D[r9]
+	add r8=3DIA64_TASK_TGID_OFFSET,r16
+	;;
+	and r9=3DTIF_ALLWORK_MASK,r9
+	ld4 r8=3D[r8]
+	;;
+	cmp.ne p8,p0=3D0,r9
+(p8)	br.spnt.many fsys_fallback_syscall
+	MCKINLEY_E9_WORKAROUND
+	br.ret.sptk.many b6
+END(fsys_getpid)
+
+ENTRY(fsys_set_tid_address)
+	add r9=3DTI_FLAGS+IA64_TASK_SIZE,r16
+	;;
+	ld4 r9=3D[r9]
+	tnat.z p6,p7=3Dr32		// check argument register for being NaT
+	;;
+	and r9=3DTIF_ALLWORK_MASK,r9
+	add r8=3DIA64_TASK_PID_OFFSET,r16
+	add r18=3DIA64_TASK_CLEAR_CHILD_TID_OFFSET,r16
+	;;
+	ld4 r8=3D[r8]
+	cmp.ne p8,p0=3D0,r9
+	mov r17=3D-1
+	;;
+(p6)	st8 [r18]=3Dr32
+(p7)	st8 [r18]=3Dr17
+(p8)	br.spnt.many fsys_fallback_syscall
+	;;
+	mov r17=3D0			// don't leak kernel bits...
+	mov r18=3D0			// don't leak kernel bits...
+	MCKINLEY_E9_WORKAROUND
+	br.ret.sptk.many b6
+END(fsys_set_tid_address)
+
+	.rodata
+	.align 8
+	.globl fsyscall_table
+fsyscall_table:
+	data8 fsys_ni_syscall
+	data8 fsys_fallback_syscall	// exit			// 1025
+	data8 fsys_fallback_syscall	// read
+	data8 fsys_fallback_syscall	// write
+	data8 fsys_fallback_syscall	// open
+	data8 fsys_fallback_syscall	// close
+	data8 fsys_fallback_syscall	// creat		// 1030
+	data8 fsys_fallback_syscall	// link
+	data8 fsys_fallback_syscall	// unlink
+	data8 fsys_fallback_syscall	// execve
+	data8 fsys_fallback_syscall	// chdir
+	data8 fsys_fallback_syscall	// fchdir		// 1035
+	data8 fsys_fallback_syscall	// utimes
+	data8 fsys_fallback_syscall	// mknod
+	data8 fsys_fallback_syscall	// chmod
+	data8 fsys_fallback_syscall	// chown
+	data8 fsys_fallback_syscall	// lseek		// 1040
+	data8 fsys_getpid
+	data8 fsys_fallback_syscall	// getppid
+	data8 fsys_fallback_syscall	// mount
+	data8 fsys_fallback_syscall	// umount
+	data8 fsys_fallback_syscall	// setuid		// 1045
+	data8 fsys_fallback_syscall	// getuid
+	data8 fsys_fallback_syscall	// geteuid
+	data8 fsys_fallback_syscall	// ptrace
+	data8 fsys_fallback_syscall	// access
+	data8 fsys_fallback_syscall	// sync			// 1050
+	data8 fsys_fallback_syscall	// fsync
+	data8 fsys_fallback_syscall	// fdatasync
+	data8 fsys_fallback_syscall	// kill
+	data8 fsys_fallback_syscall	// rename
+	data8 fsys_fallback_syscall	// mkdir		// 1055
+	data8 fsys_fallback_syscall	// rmdir
+	data8 fsys_fallback_syscall	// dup
+	data8 fsys_fallback_syscall	// pipe
+	data8 fsys_fallback_syscall	// times
+	data8 fsys_fallback_syscall	// brk			// 1060
+	data8 fsys_fallback_syscall	// setgid
+	data8 fsys_fallback_syscall	// getgid
+	data8 fsys_fallback_syscall	// getegid
+	data8 fsys_fallback_syscall	// acct
+	data8 fsys_fallback_syscall	// ioctl		// 1065
+	data8 fsys_fallback_syscall	// fcntl
+	data8 fsys_fallback_syscall	// umask
+	data8 fsys_fallback_syscall	// chroot
+	data8 fsys_fallback_syscall	// ustat
+	data8 fsys_fallback_syscall	// dup2			// 1070
+	data8 fsys_fallback_syscall	// setreuid
+	data8 fsys_fallback_syscall	// setregid
+	data8 fsys_fallback_syscall	// getresuid
+	data8 fsys_fallback_syscall	// setresuid
+	data8 fsys_fallback_syscall	// getresgid		// 1075
+	data8 fsys_fallback_syscall	// setresgid
+	data8 fsys_fallback_syscall	// getgroups
+	data8 fsys_fallback_syscall	// setgroups
+	data8 fsys_fallback_syscall	// getpgid
+	data8 fsys_fallback_syscall	// setpgid		// 1080
+	data8 fsys_fallback_syscall	// setsid
+	data8 fsys_fallback_syscall	// getsid
+	data8 fsys_fallback_syscall	// sethostname
+	data8 fsys_fallback_syscall	// setrlimit
+	data8 fsys_fallback_syscall	// getrlimit		// 1085
+	data8 fsys_fallback_syscall	// getrusage
+	data8 fsys_fallback_syscall	// gettimeofday
+	data8 fsys_fallback_syscall	// settimeofday
+	data8 fsys_fallback_syscall	// select
+	data8 fsys_fallback_syscall	// poll			// 1090
+	data8 fsys_fallback_syscall	// symlink
+	data8 fsys_fallback_syscall	// readlink
+	data8 fsys_fallback_syscall	// uselib
+	data8 fsys_fallback_syscall	// swapon
+	data8 fsys_fallback_syscall	// swapoff		// 1095
+	data8 fsys_fallback_syscall	// reboot
+	data8 fsys_fallback_syscall	// truncate
+	data8 fsys_fallback_syscall	// ftruncate
+	data8 fsys_fallback_syscall	// fchmod
+	data8 fsys_fallback_syscall	// fchown		// 1100
+	data8 fsys_fallback_syscall	// getpriority
+	data8 fsys_fallback_syscall	// setpriority
+	data8 fsys_fallback_syscall	// statfs
+	data8 fsys_fallback_syscall	// fstatfs
+	data8 fsys_fallback_syscall	// gettid		// 1105
+	data8 fsys_fallback_syscall	// semget
+	data8 fsys_fallback_syscall	// semop
+	data8 fsys_fallback_syscall	// semctl
+	data8 fsys_fallback_syscall	// msgget
+	data8 fsys_fallback_syscall	// msgsnd		// 1110
+	data8 fsys_fallback_syscall	// msgrcv
+	data8 fsys_fallback_syscall	// msgctl
+	data8 fsys_fallback_syscall	// shmget
+	data8 fsys_fallback_syscall	// shmat
+	data8 fsys_fallback_syscall	// shmdt		// 1115
+	data8 fsys_fallback_syscall	// shmctl
+	data8 fsys_fallback_syscall	// syslog
+	data8 fsys_fallback_syscall	// setitimer
+	data8 fsys_fallback_syscall	// getitimer
+	data8 fsys_fallback_syscall		 		// 1120
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall	// vhangup
+	data8 fsys_fallback_syscall	// lchown
+	data8 fsys_fallback_syscall	// remap_file_pages	// 1125
+	data8 fsys_fallback_syscall	// wait4
+	data8 fsys_fallback_syscall	// sysinfo
+	data8 fsys_fallback_syscall	// clone
+	data8 fsys_fallback_syscall	// setdomainname
+	data8 fsys_fallback_syscall	// newuname		// 1130
+	data8 fsys_fallback_syscall	// adjtimex
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall	// init_module
+	data8 fsys_fallback_syscall	// delete_module
+	data8 fsys_fallback_syscall				// 1135
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall	// quotactl
+	data8 fsys_fallback_syscall	// bdflush
+	data8 fsys_fallback_syscall	// sysfs
+	data8 fsys_fallback_syscall	// personality		// 1140
+	data8 fsys_fallback_syscall	// afs_syscall
+	data8 fsys_fallback_syscall	// setfsuid
+	data8 fsys_fallback_syscall	// setfsgid
+	data8 fsys_fallback_syscall	// getdents
+	data8 fsys_fallback_syscall	// flock		// 1145
+	data8 fsys_fallback_syscall	// readv
+	data8 fsys_fallback_syscall	// writev
+	data8 fsys_fallback_syscall	// pread64
+	data8 fsys_fallback_syscall	// pwrite64
+	data8 fsys_fallback_syscall	// sysctl		// 1150
+	data8 fsys_fallback_syscall	// mmap
+	data8 fsys_fallback_syscall	// munmap
+	data8 fsys_fallback_syscall	// mlock
+	data8 fsys_fallback_syscall	// mlockall
+	data8 fsys_fallback_syscall	// mprotect		// 1155
+	data8 fsys_fallback_syscall	// mremap
+	data8 fsys_fallback_syscall	// msync
+	data8 fsys_fallback_syscall	// munlock
+	data8 fsys_fallback_syscall	// munlockall
+	data8 fsys_fallback_syscall	// sched_getparam	// 1160
+	data8 fsys_fallback_syscall	// sched_setparam
+	data8 fsys_fallback_syscall	// sched_getscheduler
+	data8 fsys_fallback_syscall	// sched_setscheduler
+	data8 fsys_fallback_syscall	// sched_yield
+	data8 fsys_fallback_syscall	// sched_get_priority_max	// 1165
+	data8 fsys_fallback_syscall	// sched_get_priority_min
+	data8 fsys_fallback_syscall	// sched_rr_get_interval
+	data8 fsys_fallback_syscall	// nanosleep
+	data8 fsys_fallback_syscall	// nfsservctl
+	data8 fsys_fallback_syscall	// prctl		// 1170
+	data8 fsys_fallback_syscall	// getpagesize
+	data8 fsys_fallback_syscall	// mmap2
+	data8 fsys_fallback_syscall	// pciconfig_read
+	data8 fsys_fallback_syscall	// pciconfig_write
+	data8 fsys_fallback_syscall	// perfmonctl		// 1175
+	data8 fsys_fallback_syscall	// sigaltstack
+	data8 fsys_fallback_syscall	// rt_sigaction
+	data8 fsys_fallback_syscall	// rt_sigpending
+	data8 fsys_fallback_syscall	// rt_sigprocmask
+	data8 fsys_fallback_syscall	// rt_sigqueueinfo	// 1180
+	data8 fsys_fallback_syscall	// rt_sigreturn
+	data8 fsys_fallback_syscall	// rt_sigsuspend
+	data8 fsys_fallback_syscall	// rt_sigtimedwait
+	data8 fsys_fallback_syscall	// getcwd
+	data8 fsys_fallback_syscall	// capget		// 1185
+	data8 fsys_fallback_syscall	// capset
+	data8 fsys_fallback_syscall	// sendfile
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall	// socket		// 1190
+	data8 fsys_fallback_syscall	// bind
+	data8 fsys_fallback_syscall	// connect
+	data8 fsys_fallback_syscall	// listen
+	data8 fsys_fallback_syscall	// accept
+	data8 fsys_fallback_syscall	// getsockname		// 1195
+	data8 fsys_fallback_syscall	// getpeername
+	data8 fsys_fallback_syscall	// socketpair
+	data8 fsys_fallback_syscall	// send
+	data8 fsys_fallback_syscall	// sendto
+	data8 fsys_fallback_syscall	// recv			// 1200
+	data8 fsys_fallback_syscall	// recvfrom
+	data8 fsys_fallback_syscall	// shutdown
+	data8 fsys_fallback_syscall	// setsockopt
+	data8 fsys_fallback_syscall	// getsockopt
+	data8 fsys_fallback_syscall	// sendmsg		// 1205
+	data8 fsys_fallback_syscall	// recvmsg
+	data8 fsys_fallback_syscall	// pivot_root
+	data8 fsys_fallback_syscall	// mincore
+	data8 fsys_fallback_syscall	// madvise
+	data8 fsys_fallback_syscall	// newstat		// 1210
+	data8 fsys_fallback_syscall	// newlstat
+	data8 fsys_fallback_syscall	// newfstat
+	data8 fsys_fallback_syscall	// clone2
+	data8 fsys_fallback_syscall	// getdents64
+	data8 fsys_fallback_syscall	// getunwind		// 1215
+	data8 fsys_fallback_syscall	// readahead
+	data8 fsys_fallback_syscall	// setxattr
+	data8 fsys_fallback_syscall	// lsetxattr
+	data8 fsys_fallback_syscall	// fsetxattr
+	data8 fsys_fallback_syscall	// getxattr		// 1220
+	data8 fsys_fallback_syscall	// lgetxattr
+	data8 fsys_fallback_syscall	// fgetxattr
+	data8 fsys_fallback_syscall	// listxattr
+	data8 fsys_fallback_syscall	// llistxattr
+	data8 fsys_fallback_syscall	// flistxattr		// 1225
+	data8 fsys_fallback_syscall	// removexattr
+	data8 fsys_fallback_syscall	// lremovexattr
+	data8 fsys_fallback_syscall	// fremovexattr
+	data8 fsys_fallback_syscall	// tkill
+	data8 fsys_fallback_syscall	// futex		// 1230
+	data8 fsys_fallback_syscall	// sched_setaffinity
+	data8 fsys_fallback_syscall	// sched_getaffinity
+	data8 fsys_set_tid_address	// set_tid_address
+	data8 fsys_fallback_syscall	// unused
+	data8 fsys_fallback_syscall	// unused		// 1235
+	data8 fsys_fallback_syscall	// exit_group
+	data8 fsys_fallback_syscall	// lookup_dcookie
+	data8 fsys_fallback_syscall	// io_setup
+	data8 fsys_fallback_syscall	// io_destroy
+	data8 fsys_fallback_syscall	// io_getevents		// 1240
+	data8 fsys_fallback_syscall	// io_submit
+	data8 fsys_fallback_syscall	// io_cancel
+	data8 fsys_fallback_syscall	// epoll_create
+	data8 fsys_fallback_syscall	// epoll_ctl
+	data8 fsys_fallback_syscall	// epoll_wait		// 1245
+	data8 fsys_fallback_syscall	// restart_syscall
+	data8 fsys_fallback_syscall	// semtimedop
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall				// 1250
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall				// 1255
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall				// 1260
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall				// 1265
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall				// 1270
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall				// 1275
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
+	data8 fsys_fallback_syscall
diff -Nru a/arch/ia64/kernel/gate.S b/arch/ia64/kernel/gate.S
--- a/arch/ia64/kernel/gate.S	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/gate.S	Fri Jan 24 20:41:05 2003
@@ -2,7 +2,7 @@
  * This file contains the code that gets mapped at the upper end of each t=
ask's text
  * region.  For now, it contains the signal trampoline code only.
  *
- * Copyright (C) 1999-2002 Hewlett-Packard Co
+ * Copyright (C) 1999-2003 Hewlett-Packard Co
  * 	David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
@@ -14,6 +14,87 @@
 #include <asm/page.h>
=20
 	.section .text.gate, "ax"
+.start_gate:
+
+
+#if CONFIG_FSYS
+
+#include <asm/errno.h>
+
+/*
+ * On entry:
+ *	r11 =3D saved ar.pfs
+ *	r15 =3D system call #
+ *	b0  =3D saved return address
+ *	b6  =3D return address
+ * On exit:
+ *	r11 =3D saved ar.pfs
+ *	r15 =3D system call #
+ *	b0  =3D saved return address
+ *	all other "scratch" registers:	undefined
+ *	all "preserved" registers:	same as on entry
+ */
+GLOBAL_ENTRY(syscall_via_epc)
+	.prologue
+	.altrp b6
+	.body
+{
+	/*
+	 * Note: the kernel cannot assume that the first two instructions in this
+	 * bundle get executed.  The remaining code must be safe even if
+	 * they do not get executed.
+	 */
+	adds r17=3D-1024,r15
+	mov r10=3D0				// default to successful syscall execution
+	epc
+}
+	;;
+	rsm psr.be
+	movl r18=3Dfsyscall_table
+
+	mov r16=3DIA64_KR(CURRENT)
+	mov r19%5
+	;;
+	shladd r18=3Dr17,3,r18
+	cmp.geu p6,p0=3Dr19,r17			// (syscall > 0 && syscall <=3D 1024+255)?
+	;;
+	srlz.d					// ensure little-endian byteorder is in effect
+(p6)	ld8 r18=3D[r18]
+	;;
+(p6)	mov b7=3Dr18
+(p6)	br.sptk.many b7
+
+	mov r10=3D-1
+	mov r8=3DENOSYS
+	MCKINLEY_E9_WORKAROUND
+	br.ret.sptk.many b6
+END(syscall_via_epc)
+
+GLOBAL_ENTRY(syscall_via_break)
+	.prologue
+	.altrp b6
+	.body
+	break 0x100000
+	br.ret.sptk.many b6
+END(syscall_via_break)
+
+GLOBAL_ENTRY(fsys_fallback_syscall)
+	/*
+	 * It would be better/fsyser to do the SAVE_MIN magic directly here, but =
for now
+	 * we simply fall back on doing a system-call via break.  Good enough
+	 * to get started.  (Note: we have to do this through the gate page again=
, since
+	 * the br.ret will switch us back to user-level privilege.)
+	 *
+	 * XXX Move this back to fsys.S after changing it over to avoid break 0x1=
00000.
+	 */
+	movl r2=3D(syscall_via_break - .start_gate) + GATE_ADDR
+	;;
+	MCKINLEY_E9_WORKAROUND
+	mov b7=3Dr2
+	br.ret.sptk.many b7
+END(fsys_fallback_syscall)
+
+#endif /* CONFIG_FSYS */
=20
 #	define ARG0_OFF		(16 + IA64_SIGFRAME_ARG0_OFFSET)
 #	define ARG1_OFF		(16 + IA64_SIGFRAME_ARG1_OFFSET)
@@ -63,15 +144,18 @@
 	 * call stack.
 	 */
=20
+#define SIGTRAMP_SAVES										\
+	.unwabi @svr4, 's'		// mark this as a sigtramp handler (saves scratch reg=
s)	\
+	.savesp ar.unat, UNAT_OFF+SIGCONTEXT_OFF						\
+	.savesp ar.fpsr, FPSR_OFF+SIGCONTEXT_OFF						\
+	.savesp pr, PR_OFF+SIGCONTEXT_OFF							\
+	.savesp rp, RP_OFF+SIGCONTEXT_OFF							\
+	.vframesp SP_OFF+SIGCONTEXT_OFF
+
 GLOBAL_ENTRY(ia64_sigtramp)
 	// describe the state that is active when we get here:
 	.prologue
-	.unwabi @svr4, 's'		// mark this as a sigtramp handler (saves scratch reg=
s)
-	.savesp ar.unat, UNAT_OFF+SIGCONTEXT_OFF
-	.savesp ar.fpsr, FPSR_OFF+SIGCONTEXT_OFF
-	.savesp pr, PR_OFF+SIGCONTEXT_OFF
-	.savesp rp, RP_OFF+SIGCONTEXT_OFF
-	.vframesp SP_OFF+SIGCONTEXT_OFF
+	SIGTRAMP_SAVES
 	.body
=20
 	.label_state 1
@@ -156,10 +240,11 @@
 	ldf.fill f14=3D[base0],32
 	ldf.fill f15=3D[base1],32
 	mov r15=3D__NR_rt_sigreturn
+	.restore sp				// pop .prologue
 	break __BREAK_SYSCALL
=20
-	.body
-	.copy_state 1
+	.prologue
+	SIGTRAMP_SAVES
 setup_rbs:
 	mov ar.rsc=3D0				// put RSE into enforced lazy mode
 	;;
@@ -171,6 +256,7 @@
 	;;
 	.spillsp ar.rnat, RNAT_OFF+SIGCONTEXT_OFF
 	st8 [r14]=3Dr16				// save sc_ar_rnat
+	.body
 	adds r14=3D(LOADRS_OFF+SIGCONTEXT_OFF),sp
=20
 	mov.m r16=3Dar.bsp			// sc_loadrs <- (new bsp - new bspstore) << 16
@@ -182,10 +268,11 @@
 	;;
 	st8 [r14]=3Dr15				// save sc_loadrs
 	mov ar.rsc=3D0xf				// set RSE into eager mode, pl 3
+	.restore sp				// pop .prologue
 	br.cond.sptk back_from_setup_rbs
=20
 	.prologue
-	.copy_state 1
+	SIGTRAMP_SAVES
 	.spillsp ar.rnat, RNAT_OFF+SIGCONTEXT_OFF
 	.body
 restore_rbs:
diff -Nru a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
--- a/arch/ia64/kernel/head.S	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/head.S	Fri Jan 24 20:41:05 2003
@@ -5,7 +5,7 @@
  * to set up the kernel's global pointer and jump to the kernel
  * entry point.
  *
- * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001, 2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *	Stephane Eranian <eranian@hpl.hp.com>
  * Copyright (C) 1999 VA Linux Systems
@@ -143,17 +143,14 @@
 	movl r2=3Dinit_thread_union
 	cmp.eq isBP,isAP=3Dr0,r0
 #endif
-	;;
-	extr r3=3Dr2,0,61		// r3 =3D phys addr of task struct
 	mov r16=3DKERNEL_TR_PAGE_NUM
 	;;
=20
 	// load the "current" pointer (r13) and ar.k6 with the current task
-	mov r13=3Dr2
-	mov IA64_KR(CURRENT)=3Dr3		// Physical address
-
+	mov IA64_KR(CURRENT)=3Dr2		// virtual address
 	// initialize k4 to a safe value (64-128MB is mapped by TR_KERNEL)
 	mov IA64_KR(CURRENT_STACK)=3Dr16
+	mov r13=3Dr2
 	/*
 	 * Reserve space at the top of the stack for "struct pt_regs".  Kernel th=
reads
 	 * don't store interesting values in that structure, but the space still =
needs
diff -Nru a/arch/ia64/kernel/ia64_ksyms.c b/arch/ia64/kernel/ia64_ksyms.c
--- a/arch/ia64/kernel/ia64_ksyms.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/ia64_ksyms.c	Fri Jan 24 20:41:05 2003
@@ -56,6 +56,12 @@
 #include <asm/page.h>
 EXPORT_SYMBOL(clear_page);
=20
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+#include <asm/pgtable.h>
+EXPORT_SYMBOL(vmalloc_end);
+EXPORT_SYMBOL(ia64_pfn_valid);
+#endif
+
 #include <asm/processor.h>
 # ifndef CONFIG_NUMA
 EXPORT_SYMBOL(cpu_info__per_cpu);
@@ -142,4 +148,8 @@
 EXPORT_SYMBOL(ia64_mv);
 #endif
 EXPORT_SYMBOL(machvec_noop);
-
+#ifdef CONFIG_PERFMON
+#include <asm/perfmon.h>
+EXPORT_SYMBOL(pfm_install_alternate_syswide_subsystem);
+EXPORT_SYMBOL(pfm_remove_alternate_syswide_subsystem);
+#endif
diff -Nru a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
--- a/arch/ia64/kernel/iosapic.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/iosapic.c	Fri Jan 24 20:41:05 2003
@@ -752,7 +752,7 @@
=20
 			if (index < 0) {
 				printk(KERN_WARNING"IOSAPIC: GSI 0x%x has no IOSAPIC!\n", gsi);
-				return;
+				continue;
 			}
 			addr =3D iosapic_lists[index].addr;
 			gsi_base =3D iosapic_lists[index].gsi_base;
diff -Nru a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
--- a/arch/ia64/kernel/irq_ia64.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/irq_ia64.c	Fri Jan 24 20:41:05 2003
@@ -178,7 +178,7 @@
 	register_percpu_irq(IA64_IPI_VECTOR, &ipi_irqaction);
 #endif
 #ifdef CONFIG_PERFMON
-	perfmon_init_percpu();
+	pfm_init_percpu();
 #endif
 	platform_irq_init();
 }
diff -Nru a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
--- a/arch/ia64/kernel/ivt.S	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/ivt.S	Fri Jan 24 20:41:05 2003
@@ -192,7 +192,7 @@
 	rfi
 END(vhpt_miss)
=20
-	.align 1024
+	.org ia64_ivt+0x400
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x0400 Entry 1 (size 64 bundles) ITLB (21)
 ENTRY(itlb_miss)
@@ -206,7 +206,7 @@
 	mov r16=3Dcr.ifa				// get virtual address
 	mov r29=B0				// save b0
 	mov r31=3Dpr				// save predicates
-itlb_fault:
+.itlb_fault:
 	mov r17=3Dcr.iha				// get virtual address of L3 PTE
 	movl r30=1F				// load nested fault continuation point
 	;;
@@ -230,7 +230,7 @@
 	rfi
 END(itlb_miss)
=20
-	.align 1024
+	.org ia64_ivt+0x0800
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x0800 Entry 2 (size 64 bundles) DTLB (9,48)
 ENTRY(dtlb_miss)
@@ -268,7 +268,7 @@
 	rfi
 END(dtlb_miss)
=20
-	.align 1024
+	.org ia64_ivt+0x0c00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x0c00 Entry 3 (size 64 bundles) Alt ITLB (19)
 ENTRY(alt_itlb_miss)
@@ -288,7 +288,7 @@
 	;;
 (p8)	mov cr.iha=3Dr17
 (p8)	mov r29=B0				// save b0
-(p8)	br.cond.dptk itlb_fault
+(p8)	br.cond.dptk .itlb_fault
 #endif
 	extr.u r23=3Dr21,IA64_PSR_CPL0_BIT,2	// extract psr.cpl
 	and r19=3Dr19,r16		// clear ed, reserved bits, and PTE control bits
@@ -306,7 +306,7 @@
 	rfi
 END(alt_itlb_miss)
=20
-	.align 1024
+	.org ia64_ivt+0x1000
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x1000 Entry 4 (size 64 bundles) Alt DTLB (7,46)
 ENTRY(alt_dtlb_miss)
@@ -379,7 +379,7 @@
 	br.call.sptk.many b6=3Dia64_do_page_fault	// ignore return address
 END(page_fault)
=20
-	.align 1024
+	.org ia64_ivt+0x1400
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x1400 Entry 5 (size 64 bundles) Data nested TLB (6,45)
 ENTRY(nested_dtlb_miss)
@@ -440,7 +440,7 @@
 	br.sptk.many b0				// return to continuation point
 END(nested_dtlb_miss)
=20
-	.align 1024
+	.org ia64_ivt+0x1800
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x1800 Entry 6 (size 64 bundles) Instruction Key Miss (24)
 ENTRY(ikey_miss)
@@ -448,7 +448,7 @@
 	FAULT(6)
 END(ikey_miss)
=20
-	.align 1024
+	.org ia64_ivt+0x1c00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x1c00 Entry 7 (size 64 bundles) Data Key Miss (12,51)
 ENTRY(dkey_miss)
@@ -456,7 +456,7 @@
 	FAULT(7)
 END(dkey_miss)
=20
-	.align 1024
+	.org ia64_ivt+0x2000
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x2000 Entry 8 (size 64 bundles) Dirty-bit (54)
 ENTRY(dirty_bit)
@@ -512,7 +512,7 @@
 	rfi
 END(idirty_bit)
=20
-	.align 1024
+	.org ia64_ivt+0x2400
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x2400 Entry 9 (size 64 bundles) Instruction Access-bit (27)
 ENTRY(iaccess_bit)
@@ -571,7 +571,7 @@
 	rfi
 END(iaccess_bit)
=20
-	.align 1024
+	.org ia64_ivt+0x2800
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x2800 Entry 10 (size 64 bundles) Data Access-bit (15,55)
 ENTRY(daccess_bit)
@@ -618,7 +618,7 @@
 	rfi
 END(daccess_bit)
=20
-	.align 1024
+	.org ia64_ivt+0x2c00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x2c00 Entry 11 (size 64 bundles) Break instruction (33)
 ENTRY(break_fault)
@@ -690,7 +690,7 @@
 	// NOT REACHED
 END(break_fault)
=20
-ENTRY(demine_args)
+ENTRY_MIN_ALIGN(demine_args)
 	alloc r2=3Dar.pfs,8,0,0,0
 	tnat.nz p8,p0=3Din0
 	tnat.nz p9,p0=3Din1
@@ -719,7 +719,7 @@
 	br.ret.sptk.many rp
 END(demine_args)
=20
-	.align 1024
+	.org ia64_ivt+0x3000
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x3000 Entry 12 (size 64 bundles) External Interrupt (4)
 ENTRY(interrupt)
@@ -746,19 +746,19 @@
 	br.call.sptk.many b6=3Dia64_handle_irq
 END(interrupt)
=20
-	.align 1024
+	.org ia64_ivt+0x3400
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x3400 Entry 13 (size 64 bundles) Reserved
 	DBG_FAULT(13)
 	FAULT(13)
=20
-	.align 1024
+	.org ia64_ivt+0x3800
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x3800 Entry 14 (size 64 bundles) Reserved
 	DBG_FAULT(14)
 	FAULT(14)
=20
-	.align 1024
+	.org ia64_ivt+0x3c00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x3c00 Entry 15 (size 64 bundles) Reserved
 	DBG_FAULT(15)
@@ -803,7 +803,7 @@
 	br.sptk.many ia64_leave_kernel
 END(dispatch_illegal_op_fault)
=20
-	.align 1024
+	.org ia64_ivt+0x4000
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x4000 Entry 16 (size 64 bundles) Reserved
 	DBG_FAULT(16)
@@ -893,7 +893,7 @@
=20
 #endif /* CONFIG_IA32_SUPPORT */
=20
-	.align 1024
+	.org ia64_ivt+0x4400
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x4400 Entry 17 (size 64 bundles) Reserved
 	DBG_FAULT(17)
@@ -925,7 +925,7 @@
 	br.call.sptk.many b6=3Dia64_bad_break	// avoid WAW on CFM and ignore retu=
rn addr
 END(non_syscall)
=20
-	.align 1024
+	.org ia64_ivt+0x4800
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x4800 Entry 18 (size 64 bundles) Reserved
 	DBG_FAULT(18)
@@ -959,7 +959,7 @@
 	br.sptk.many ia64_prepare_handle_unaligned
 END(dispatch_unaligned_handler)
=20
-	.align 1024
+	.org ia64_ivt+0x4c00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x4c00 Entry 19 (size 64 bundles) Reserved
 	DBG_FAULT(19)
@@ -1005,7 +1005,7 @@
 // --- End of long entries, Beginning of short entries
 //
=20
-	.align 1024
+	.org ia64_ivt+0x5000
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5000 Entry 20 (size 16 bundles) Page Not Present (10,22,49)
 ENTRY(page_not_present)
@@ -1025,7 +1025,7 @@
 	br.sptk.many page_fault
 END(page_not_present)
=20
-	.align 256
+	.org ia64_ivt+0x5100
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5100 Entry 21 (size 16 bundles) Key Permission (13,25,52)
 ENTRY(key_permission)
@@ -1038,7 +1038,7 @@
 	br.sptk.many page_fault
 END(key_permission)
=20
-	.align 256
+	.org ia64_ivt+0x5200
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5200 Entry 22 (size 16 bundles) Instruction Access Rights (26)
 ENTRY(iaccess_rights)
@@ -1051,7 +1051,7 @@
 	br.sptk.many page_fault
 END(iaccess_rights)
=20
-	.align 256
+	.org ia64_ivt+0x5300
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5300 Entry 23 (size 16 bundles) Data Access Rights (14,53)
 ENTRY(daccess_rights)
@@ -1064,7 +1064,7 @@
 	br.sptk.many page_fault
 END(daccess_rights)
=20
-	.align 256
+	.org ia64_ivt+0x5400
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5400 Entry 24 (size 16 bundles) General Exception (5,32,34,36,38,39)
 ENTRY(general_exception)
@@ -1079,7 +1079,7 @@
 	br.sptk.many dispatch_to_fault_handler
 END(general_exception)
=20
-	.align 256
+	.org ia64_ivt+0x5500
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5500 Entry 25 (size 16 bundles) Disabled FP-Register (35)
 ENTRY(disabled_fp_reg)
@@ -1092,7 +1092,7 @@
 	br.sptk.many dispatch_to_fault_handler
 END(disabled_fp_reg)
=20
-	.align 256
+	.org ia64_ivt+0x5600
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5600 Entry 26 (size 16 bundles) Nat Consumption (11,23,37,50)
 ENTRY(nat_consumption)
@@ -1100,7 +1100,7 @@
 	FAULT(26)
 END(nat_consumption)
=20
-	.align 256
+	.org ia64_ivt+0x5700
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5700 Entry 27 (size 16 bundles) Speculation (40)
 ENTRY(speculation_vector)
@@ -1137,13 +1137,13 @@
 	rfi				// and go back
 END(speculation_vector)
=20
-	.align 256
+	.org ia64_ivt+0x5800
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5800 Entry 28 (size 16 bundles) Reserved
 	DBG_FAULT(28)
 	FAULT(28)
=20
-	.align 256
+	.org ia64_ivt+0x5900
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5900 Entry 29 (size 16 bundles) Debug (16,28,56)
 ENTRY(debug_vector)
@@ -1151,7 +1151,7 @@
 	FAULT(29)
 END(debug_vector)
=20
-	.align 256
+	.org ia64_ivt+0x5a00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5a00 Entry 30 (size 16 bundles) Unaligned Reference (57)
 ENTRY(unaligned_access)
@@ -1162,91 +1162,103 @@
 	br.sptk.many dispatch_unaligned_handler
 END(unaligned_access)
=20
-	.align 256
+	.org ia64_ivt+0x5b00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5b00 Entry 31 (size 16 bundles) Unsupported Data Reference (57)
+ENTRY(unsupported_data_reference)
 	DBG_FAULT(31)
 	FAULT(31)
+END(unsupported_data_reference)
=20
-	.align 256
+	.org ia64_ivt+0x5c00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5c00 Entry 32 (size 16 bundles) Floating-Point Fault (64)
+ENTRY(floating_point_fault)
 	DBG_FAULT(32)
 	FAULT(32)
+END(floating_point_fault)
=20
-	.align 256
+	.org ia64_ivt+0x5d00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5d00 Entry 33 (size 16 bundles) Floating Point Trap (66)
+ENTRY(floating_point_trap)
 	DBG_FAULT(33)
 	FAULT(33)
+END(floating_point_trap)
=20
-	.align 256
+	.org ia64_ivt+0x5e00
 //////////////////////////////////////////////////////////////////////////=
///////////////
-// 0x5e00 Entry 34 (size 16 bundles) Lower Privilege Tranfer Trap (66)
+// 0x5e00 Entry 34 (size 16 bundles) Lower Privilege Transfer Trap (66)
+ENTRY(lower_privilege_trap)
 	DBG_FAULT(34)
 	FAULT(34)
+END(lower_privilege_trap)
=20
-	.align 256
+	.org ia64_ivt+0x5f00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5f00 Entry 35 (size 16 bundles) Taken Branch Trap (68)
+ENTRY(taken_branch_trap)
 	DBG_FAULT(35)
 	FAULT(35)
+END(taken_branch_trap)
=20
-	.align 256
+	.org ia64_ivt+0x6000
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6000 Entry 36 (size 16 bundles) Single Step Trap (69)
+ENTRY(single_step_trap)
 	DBG_FAULT(36)
 	FAULT(36)
+END(single_step_trap)
=20
-	.align 256
+	.org ia64_ivt+0x6100
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6100 Entry 37 (size 16 bundles) Reserved
 	DBG_FAULT(37)
 	FAULT(37)
=20
-	.align 256
+	.org ia64_ivt+0x6200
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6200 Entry 38 (size 16 bundles) Reserved
 	DBG_FAULT(38)
 	FAULT(38)
=20
-	.align 256
+	.org ia64_ivt+0x6300
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6300 Entry 39 (size 16 bundles) Reserved
 	DBG_FAULT(39)
 	FAULT(39)
=20
-	.align 256
+	.org ia64_ivt+0x6400
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6400 Entry 40 (size 16 bundles) Reserved
 	DBG_FAULT(40)
 	FAULT(40)
=20
-	.align 256
+	.org ia64_ivt+0x6500
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6500 Entry 41 (size 16 bundles) Reserved
 	DBG_FAULT(41)
 	FAULT(41)
=20
-	.align 256
+	.org ia64_ivt+0x6600
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6600 Entry 42 (size 16 bundles) Reserved
 	DBG_FAULT(42)
 	FAULT(42)
=20
-	.align 256
+	.org ia64_ivt+0x6700
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6700 Entry 43 (size 16 bundles) Reserved
 	DBG_FAULT(43)
 	FAULT(43)
=20
-	.align 256
+	.org ia64_ivt+0x6800
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6800 Entry 44 (size 16 bundles) Reserved
 	DBG_FAULT(44)
 	FAULT(44)
=20
-	.align 256
+	.org ia64_ivt+0x6900
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6900 Entry 45 (size 16 bundles) IA-32 Exeception (17,18,29,41,42,43,4=
4,58,60,61,62,72,73,75,76,77)
 ENTRY(ia32_exception)
@@ -1254,7 +1266,7 @@
 	FAULT(45)
 END(ia32_exception)
=20
-	.align 256
+	.org ia64_ivt+0x6a00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6a00 Entry 46 (size 16 bundles) IA-32 Intercept  (30,31,59,70,71)
 ENTRY(ia32_intercept)
@@ -1284,7 +1296,7 @@
 	FAULT(46)
 END(ia32_intercept)
=20
-	.align 256
+	.org ia64_ivt+0x6b00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6b00 Entry 47 (size 16 bundles) IA-32 Interrupt  (74)
 ENTRY(ia32_interrupt)
@@ -1297,121 +1309,121 @@
 #endif
 END(ia32_interrupt)
=20
-	.align 256
+	.org ia64_ivt+0x6c00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6c00 Entry 48 (size 16 bundles) Reserved
 	DBG_FAULT(48)
 	FAULT(48)
=20
-	.align 256
+	.org ia64_ivt+0x6d00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6d00 Entry 49 (size 16 bundles) Reserved
 	DBG_FAULT(49)
 	FAULT(49)
=20
-	.align 256
+	.org ia64_ivt+0x6e00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6e00 Entry 50 (size 16 bundles) Reserved
 	DBG_FAULT(50)
 	FAULT(50)
=20
-	.align 256
+	.org ia64_ivt+0x6f00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6f00 Entry 51 (size 16 bundles) Reserved
 	DBG_FAULT(51)
 	FAULT(51)
=20
-	.align 256
+	.org ia64_ivt+0x7000
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7000 Entry 52 (size 16 bundles) Reserved
 	DBG_FAULT(52)
 	FAULT(52)
=20
-	.align 256
+	.org ia64_ivt+0x7100
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7100 Entry 53 (size 16 bundles) Reserved
 	DBG_FAULT(53)
 	FAULT(53)
=20
-	.align 256
+	.org ia64_ivt+0x7200
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7200 Entry 54 (size 16 bundles) Reserved
 	DBG_FAULT(54)
 	FAULT(54)
=20
-	.align 256
+	.org ia64_ivt+0x7300
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7300 Entry 55 (size 16 bundles) Reserved
 	DBG_FAULT(55)
 	FAULT(55)
=20
-	.align 256
+	.org ia64_ivt+0x7400
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7400 Entry 56 (size 16 bundles) Reserved
 	DBG_FAULT(56)
 	FAULT(56)
=20
-	.align 256
+	.org ia64_ivt+0x7500
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7500 Entry 57 (size 16 bundles) Reserved
 	DBG_FAULT(57)
 	FAULT(57)
=20
-	.align 256
+	.org ia64_ivt+0x7600
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7600 Entry 58 (size 16 bundles) Reserved
 	DBG_FAULT(58)
 	FAULT(58)
=20
-	.align 256
+	.org ia64_ivt+0x7700
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7700 Entry 59 (size 16 bundles) Reserved
 	DBG_FAULT(59)
 	FAULT(59)
=20
-	.align 256
+	.org ia64_ivt+0x7800
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7800 Entry 60 (size 16 bundles) Reserved
 	DBG_FAULT(60)
 	FAULT(60)
=20
-	.align 256
+	.org ia64_ivt+0x7900
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7900 Entry 61 (size 16 bundles) Reserved
 	DBG_FAULT(61)
 	FAULT(61)
=20
-	.align 256
+	.org ia64_ivt+0x7a00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7a00 Entry 62 (size 16 bundles) Reserved
 	DBG_FAULT(62)
 	FAULT(62)
=20
-	.align 256
+	.org ia64_ivt+0x7b00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7b00 Entry 63 (size 16 bundles) Reserved
 	DBG_FAULT(63)
 	FAULT(63)
=20
-	.align 256
+	.org ia64_ivt+0x7c00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7c00 Entry 64 (size 16 bundles) Reserved
 	DBG_FAULT(64)
 	FAULT(64)
=20
-	.align 256
+	.org ia64_ivt+0x7d00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7d00 Entry 65 (size 16 bundles) Reserved
 	DBG_FAULT(65)
 	FAULT(65)
=20
-	.align 256
+	.org ia64_ivt+0x7e00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7e00 Entry 66 (size 16 bundles) Reserved
 	DBG_FAULT(66)
 	FAULT(66)
=20
-	.align 256
+	.org ia64_ivt+0x7f00
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x7f00 Entry 67 (size 16 bundles) Reserved
 	DBG_FAULT(67)
diff -Nru a/arch/ia64/kernel/minstate.h b/arch/ia64/kernel/minstate.h
--- a/arch/ia64/kernel/minstate.h	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/minstate.h	Fri Jan 24 20:41:05 2003
@@ -30,25 +30,23 @@
  * on interrupts.
  */
 #define MINSTATE_START_SAVE_MIN_VIRT								\
-(pUser)	mov ar.rsc=3D0;		/* set enforced lazy mode, pl 0, little-endian, l=
oadrs=3D0 */	\
-	dep r1=3D-1,r1,61,3;				/* r1 =3D current (virtual) */		\
+(pUStk)	mov ar.rsc=3D0;		/* set enforced lazy mode, pl 0, little-endian, l=
oadrs=3D0 */	\
 	;;											\
-(pUser)	mov.m rARRNAT=3Dar.rnat;									\
-(pUser)	addl rKRBS=3DIA64_RBS_OFFSET,r1;			/* compute base of RBS */		\
-(pKern) mov r1=3Dsp;					/* get sp  */				\
-	;;											\
-(pUser) lfetch.fault.excl.nt1 [rKRBS];								\
-(pUser)	mov rARBSPSTORE=3Dar.bspstore;			/* save ar.bspstore */			\
-(pUser)	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of=
 memory stack */	\
+(pUStk)	mov.m rARRNAT=3Dar.rnat;									\
+(pUStk)	addl rKRBS=3DIA64_RBS_OFFSET,r1;			/* compute base of RBS */		\
+(pKStk) mov r1=3Dsp;					/* get sp  */				\
 	;;											\
-(pUser)	mov ar.bspstore=3DrKRBS;				/* switch to kernel RBS */		\
-(pKern) addl r1=3D-IA64_PT_REGS_SIZE,r1;			/* if in kernel mode, use sp (r=
12) */	\
+(pUStk) lfetch.fault.excl.nt1 [rKRBS];								\
+(pUStk)	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of=
 memory stack */	\
+(pUStk)	mov rARBSPSTORE=3Dar.bspstore;			/* save ar.bspstore */			\
 	;;											\
-(pUser)	mov r18=3Dar.bsp;										\
-(pUser)	mov ar.rsc=3D0x3;		/* set eager mode, pl 0, little-endian, loadrs=
=3D0 */		\
+(pUStk)	mov ar.bspstore=3DrKRBS;				/* switch to kernel RBS */		\
+(pKStk) addl r1=3D-IA64_PT_REGS_SIZE,r1;			/* if in kernel mode, use sp (r=
12) */	\
+	;;											\
+(pUStk)	mov r18=3Dar.bsp;										\
+(pUStk)	mov ar.rsc=3D0x3;		/* set eager mode, pl 0, little-endian, loadrs=
=3D0 */		\
=20
 #define MINSTATE_END_SAVE_MIN_VIRT								\
-	or r13=3Dr13,r14;		/* make `current' a kernel virtual address */			\
 	bsw.1;			/* switch back to bank 1 (must be last in insn group) */	\
 	;;
=20
@@ -57,21 +55,21 @@
  * go virtual and dont want to destroy the iip or ipsr.
  */
 #define MINSTATE_START_SAVE_MIN_PHYS								\
-(pKern) movl sp=3Dia64_init_stack+IA64_STK_OFFSET-IA64_PT_REGS_SIZE;				\
-(pUser)	mov ar.rsc=3D0;		/* set enforced lazy mode, pl 0, little-endian, l=
oadrs=3D0 */	\
-(pUser)	addl rKRBS=3DIA64_RBS_OFFSET,r1;		/* compute base of register back=
ing store */	\
-	;;											\
-(pUser)	mov rARRNAT=3Dar.rnat;									\
-(pKern) dep r1=3D0,sp,61,3;				/* compute physical addr of sp	*/	\
-(pUser)	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of=
 memory stack */	\
-(pUser)	mov rARBSPSTORE=3Dar.bspstore;			/* save ar.bspstore */			\
-(pUser)	dep rKRBS=3D-1,rKRBS,61,3;			/* compute kernel virtual addr of RBS=
 */\
+(pKStk) movl sp=3Dia64_init_stack+IA64_STK_OFFSET-IA64_PT_REGS_SIZE;				\
+(pUStk)	mov ar.rsc=3D0;		/* set enforced lazy mode, pl 0, little-endian, l=
oadrs=3D0 */	\
+(pUStk)	addl rKRBS=3DIA64_RBS_OFFSET,r1;		/* compute base of register back=
ing store */	\
+	;;											\
+(pUStk)	mov rARRNAT=3Dar.rnat;									\
+(pKStk) dep r1=3D0,sp,61,3;				/* compute physical addr of sp	*/	\
+(pUStk)	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of=
 memory stack */	\
+(pUStk)	mov rARBSPSTORE=3Dar.bspstore;			/* save ar.bspstore */			\
+(pUStk)	dep rKRBS=3D-1,rKRBS,61,3;			/* compute kernel virtual addr of RBS=
 */\
 	;;											\
-(pKern) addl r1=3D-IA64_PT_REGS_SIZE,r1;		/* if in kernel mode, use sp (r1=
2) */		\
-(pUser)	mov ar.bspstore=3DrKRBS;			/* switch to kernel RBS */			\
+(pKStk) addl r1=3D-IA64_PT_REGS_SIZE,r1;		/* if in kernel mode, use sp (r1=
2) */		\
+(pUStk)	mov ar.bspstore=3DrKRBS;			/* switch to kernel RBS */			\
 	;;											\
-(pUser)	mov r18=3Dar.bsp;										\
-(pUser)	mov ar.rsc=3D0x3;		/* set eager mode, pl 0, little-endian, loadrs=
=3D0 */		\
+(pUStk)	mov r18=3Dar.bsp;										\
+(pUStk)	mov ar.rsc=3D0x3;		/* set eager mode, pl 0, little-endian, loadrs=
=3D0 */		\
=20
 #define MINSTATE_END_SAVE_MIN_PHYS								\
 	or r12=3Dr12,r14;		/* make sp a kernel virtual address */				\
@@ -79,11 +77,13 @@
 	;;
=20
 #ifdef MINSTATE_VIRT
+# define MINSTATE_GET_CURRENT(reg)	mov reg=3DIA64_KR(CURRENT)
 # define MINSTATE_START_SAVE_MIN	MINSTATE_START_SAVE_MIN_VIRT
 # define MINSTATE_END_SAVE_MIN		MINSTATE_END_SAVE_MIN_VIRT
 #endif
=20
 #ifdef MINSTATE_PHYS
+# define MINSTATE_GET_CURRENT(reg)	mov reg=3DIA64_KR(CURRENT);; dep reg=3D=
0,reg,61,3
 # define MINSTATE_START_SAVE_MIN	MINSTATE_START_SAVE_MIN_PHYS
 # define MINSTATE_END_SAVE_MIN		MINSTATE_END_SAVE_MIN_PHYS
 #endif
@@ -110,23 +110,26 @@
  * we can pass interruption state as arguments to a handler.
  */
 #define DO_SAVE_MIN(COVER,SAVE_IFS,EXTRA)							  \
-	mov rARRSC=3Dar.rsc;									  \
-	mov rARPFS=3Dar.pfs;									  \
-	mov rR1=3Dr1;										  \
-	mov rARUNAT=3Dar.unat;									  \
-	mov rCRIPSR=3Dcr.ipsr;									  \
-	mov rB6=B6;				/* rB6 =3D branch reg 6 */			  \
-	mov rCRIIP=3Dcr.iip;									  \
-	mov r1=3DIA64_KR(CURRENT);		/* r1 =3D current (physical) */			  \
-	COVER;											  \
+	mov rARRSC=3Dar.rsc;		/* M */							  \
+	mov rARUNAT=3Dar.unat;		/* M */							  \
+	mov rR1=3Dr1;			/* A */							  \
+	MINSTATE_GET_CURRENT(r1);	/* M (or M;;I) */					  \
+	mov rCRIPSR=3Dcr.ipsr;		/* M */							  \
+	mov rARPFS=3Dar.pfs;		/* I */							  \
+	mov rCRIIP=3Dcr.iip;		/* M */							  \
+	mov rB6=B6;			/* I */	/* rB6 =3D branch reg 6 */			  \
+	COVER;				/* B;; (or nothing) */					  \
 	;;											  \
-	invala;											  \
-	extr.u r16=3DrCRIPSR,32,2;		/* extract psr.cpl */				  \
+	adds r16=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r1;						  \
 	;;											  \
-	cmp.eq pKern,pUser=3Dr0,r16;		/* are we in kernel mode already? (psr.cpl=
=3D0) */ \
+	ld1 r17=3D[r16];				/* load current->thread.on_ustack flag */	  \
+	st1 [r16]=3Dr0;				/* clear current->thread.on_ustack flag */	  \
 	/* switch from user to kernel RBS: */							  \
 	;;											  \
+	invala;				/* M */							  \
 	SAVE_IFS;										  \
+	cmp.eq pKStk,pUStk=3Dr0,r17;		/* are we in kernel mode already? (psr.cpl=
=3D0) */ \
+	;;											  \
 	MINSTATE_START_SAVE_MIN									  \
 	add r17=3DL1_CACHE_BYTES,r1			/* really: biggest cache-line size */	  \
 	;;											  \
@@ -138,23 +141,23 @@
 	;;											  \
 	lfetch.fault.excl.nt1 [r17];								  \
 	adds r17=3D8,r1;					/* initialize second base pointer */	  \
-(pKern)	mov r18=3Dr0;		/* make sure r18 isn't NaT */					  \
+(pKStk)	mov r18=3Dr0;		/* make sure r18 isn't NaT */					  \
 	;;											  \
 	st8 [r17]=3DrCRIIP,16;	/* save cr.iip */						  \
 	st8 [r16]=3DrCRIFS,16;	/* save cr.ifs */						  \
-(pUser)	sub r18=3Dr18,rKRBS;	/* r18=3DRSE.ndirty*8 */						  \
+(pUStk)	sub r18=3Dr18,rKRBS;	/* r18=3DRSE.ndirty*8 */						  \
 	;;											  \
 	st8 [r17]=3DrARUNAT,16;	/* save ar.unat */						  \
 	st8 [r16]=3DrARPFS,16;	/* save ar.pfs */						  \
 	shl r18=3Dr18,16;		/* compute ar.rsc to be used for "loadrs" */			  \
 	;;											  \
 	st8 [r17]=3DrARRSC,16;	/* save ar.rsc */						  \
-(pUser)	st8 [r16]=3DrARRNAT,16;	/* save ar.rnat */						  \
-(pKern)	adds r16=16,r16;	/* skip over ar_rnat field */					  \
+(pUStk)	st8 [r16]=3DrARRNAT,16;	/* save ar.rnat */						  \
+(pKStk)	adds r16=16,r16;	/* skip over ar_rnat field */					  \
 	;;			/* avoid RAW on r16 & r17 */					  \
-(pUser)	st8 [r17]=3DrARBSPSTORE,16;	/* save ar.bspstore */					  \
+(pUStk)	st8 [r17]=3DrARBSPSTORE,16;	/* save ar.bspstore */					  \
 	st8 [r16]=3DrARPR,16;	/* save predicates */						  \
-(pKern)	adds r17=16,r17;	/* skip over ar_bspstore field */				  \
+(pKStk)	adds r17=16,r17;	/* skip over ar_bspstore field */				  \
 	;;											  \
 	st8 [r17]=3DrB6,16;	/* save b6 */							  \
 	st8 [r16]=3Dr18,16;	/* save ar.rsc value for "loadrs" */				  \
diff -Nru a/arch/ia64/kernel/pal.S b/arch/ia64/kernel/pal.S
--- a/arch/ia64/kernel/pal.S	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/pal.S	Fri Jan 24 20:41:05 2003
@@ -4,7 +4,7 @@
  *
  * Copyright (C) 1999 Don Dugger <don.dugger@intel.com>
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
- * Copyright (C) 1999-2001 Hewlett-Packard Co
+ * Copyright (C) 1999-2001, 2003 Hewlett-Packard Co
  *	David Mosberger <davidm@hpl.hp.com>
  *	Stephane Eranian <eranian@hpl.hp.com>
  *
@@ -114,7 +114,7 @@
 	;;
 	rsm psr.i
 	mov b7 =3D loc2
-	;;=20
+	;;
 	br.call.sptk.many rp=B7		// now make the call
 .ret0:	mov psr.l  =3D loc3
 	mov ar.pfs =3D loc1
@@ -131,15 +131,15 @@
  * 	in0         Index of PAL service
  * 	in2 - in3   Remaning PAL arguments
  *
- * PSR_DB, PSR_LP, PSR_TB, PSR_ID, PSR_DA are never set by the kernel.
+ * PSR_LP, PSR_TB, PSR_ID, PSR_DA are never set by the kernel.
  * So we don't need to clear them.
  */
-#define PAL_PSR_BITS_TO_CLEAR						\
-	(IA64_PSR_I | IA64_PSR_IT | IA64_PSR_DT | IA64_PSR_RT |		\
-	 IA64_PSR_DD | IA64_PSR_SS | IA64_PSR_RI | IA64_PSR_ED |	\
+#define PAL_PSR_BITS_TO_CLEAR							\
+	(IA64_PSR_I | IA64_PSR_IT | IA64_PSR_DT  | IA64_PSR_DB | IA64_PSR_RT |	\
+	 IA64_PSR_DD | IA64_PSR_SS | IA64_PSR_RI | IA64_PSR_ED |		\
 	 IA64_PSR_DFL | IA64_PSR_DFH)
=20
-#define PAL_PSR_BITS_TO_SET						\
+#define PAL_PSR_BITS_TO_SET							\
 	(IA64_PSR_BN)
=20
=20
@@ -161,7 +161,7 @@
 	;;
 	mov loc3 =3D psr			// save psr
 	adds r8  =3D 1f-1b,r8		// calculate return address for call
-	;;=20
+	;;
 	mov loc4=3Dar.rsc			// save RSE configuration
 	dep.z loc2=3Dloc2,0,61		// convert pal entry point to physical
 	dep.z r8=3Dr8,0,61		// convert rp to physical
@@ -275,7 +275,6 @@
  * Inputs:
  *      in0	Address of stack storage for fp regs
  */
-
 GLOBAL_ENTRY(ia64_load_scratch_fpregs)
 	alloc r3=3Dar.pfs,1,0,0,0
 	add r2=16,in0
diff -Nru a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
--- a/arch/ia64/kernel/perfmon.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/perfmon.c	Fri Jan 24 20:41:05 2003
@@ -28,7 +28,6 @@
 #include <asm/bitops.h>
 #include <asm/errno.h>
 #include <asm/page.h>
-#include <asm/pal.h>
 #include <asm/perfmon.h>
 #include <asm/processor.h>
 #include <asm/signal.h>
@@ -56,8 +55,8 @@
 /*
  * Reset register flags
  */
-#define PFM_RELOAD_LONG_RESET	1
-#define PFM_RELOAD_SHORT_RESET	2
+#define PFM_PMD_LONG_RESET	1
+#define PFM_PMD_SHORT_RESET	2
=20
 /*
  * Misc macros and definitions
@@ -83,8 +82,10 @@
 #define	PFM_REG_CONFIG		(0x4<<4|PFM_REG_IMPL) /* refine configuration */
 #define PFM_REG_BUFFER	 	(0x5<<4|PFM_REG_IMPL) /* PMD used as buffer */
=20
+#define PMC_IS_LAST(i)	(pmu_conf.pmc_desc[i].type & PFM_REG_END)
+#define PMD_IS_LAST(i)	(pmu_conf.pmd_desc[i].type & PFM_REG_END)
=20
-#define PFM_IS_DISABLED() pmu_conf.pfm_is_disabled
+#define PFM_IS_DISABLED() pmu_conf.disabled
=20
 #define PMC_OVFL_NOTIFY(ctx, i)	((ctx)->ctx_soft_pmds[i].flags &  PFM_REGF=
L_OVFL_NOTIFY)
 #define PFM_FL_INHERIT_MASK	(PFM_FL_INHERIT_NONE|PFM_FL_INHERIT_ONCE|PFM_F=
L_INHERIT_ALL)
@@ -102,7 +103,6 @@
 #define PMD_PMD_DEP(i)	   pmu_conf.pmd_desc[i].dep_pmd[0]
 #define PMC_PMD_DEP(i)	   pmu_conf.pmc_desc[i].dep_pmd[0]
=20
-
 /* k assume unsigned */
 #define IBR_IS_IMPL(k)	  (k<pmu_conf.num_ibrs)
 #define DBR_IS_IMPL(k)	  (k<pmu_conf.num_dbrs)
@@ -131,6 +131,9 @@
=20
 #define PFM_REG_RETFLAG_SET(flags, val)	do { flags &=3D ~PFM_REG_RETFL_MAS=
K; flags |=3D (val); } while(0)
=20
+#define PFM_CPUINFO_CLEAR(v)	__get_cpu_var(pfm_syst_info) &=3D ~(v)
+#define PFM_CPUINFO_SET(v)	__get_cpu_var(pfm_syst_info) |=3D (v)
+
 #ifdef CONFIG_SMP
 #define cpu_is_online(i) (cpu_online_map & (1UL << i))
 #else
@@ -211,7 +214,7 @@
 	u64 reset_pmds[4]; /* which other pmds to reset when this counter overflo=
ws */
 	u64 seed;	/* seed for random-number generator */
 	u64 mask;	/* mask for random-number generator */
-	int flags;	/* notify/do not notify */
+	unsigned int flags; /* notify/do not notify */
 } pfm_counter_t;
=20
 /*
@@ -226,7 +229,8 @@
 	unsigned int frozen:1;		/* pmu must be kept frozen on ctxsw in */
 	unsigned int protected:1;	/* allow access to creator of context only */
 	unsigned int using_dbreg:1;	/* using range restrictions (debug registers)=
 */
-	unsigned int reserved:24;
+	unsigned int excl_idle:1;	/* exclude idle task in system wide session */
+	unsigned int reserved:23;
 } pfm_context_flags_t;
=20
 /*
@@ -261,7 +265,7 @@
=20
 	u64			ctx_saved_psr;		/* copy of psr used for lazy ctxsw */
 	unsigned long		ctx_saved_cpus_allowed;	/* copy of the task cpus_allowed (=
system wide) */
-	unsigned long		ctx_cpu;		/* cpu to which perfmon is applied (system wide)=
 */
+	unsigned int		ctx_cpu;		/* CPU used by system wide session */
=20
 	atomic_t		ctx_saving_in_progress;	/* flag indicating actual save in progr=
ess */
 	atomic_t		ctx_is_busy;		/* context accessed by overflow handler */
@@ -274,6 +278,7 @@
 #define ctx_fl_frozen		ctx_flags.frozen
 #define ctx_fl_protected	ctx_flags.protected
 #define ctx_fl_using_dbreg	ctx_flags.using_dbreg
+#define ctx_fl_excl_idle	ctx_flags.excl_idle
=20
 /*
  * global information about all sessions
@@ -282,10 +287,10 @@
 typedef struct {
 	spinlock_t		pfs_lock;		   /* lock the structure */
=20
-	unsigned long		pfs_task_sessions;	   /* number of per task sessions */
-	unsigned long		pfs_sys_sessions;	   /* number of per system wide sessions=
 */
-	unsigned long   	pfs_sys_use_dbregs;	   /* incremented when a system wide=
 session uses debug regs */
-	unsigned long   	pfs_ptrace_use_dbregs;	   /* incremented when a process =
uses debug regs */
+	unsigned int 		pfs_task_sessions;	   /* number of per task sessions */
+	unsigned int		pfs_sys_sessions;	   /* number of per system wide sessions =
*/
+	unsigned int		pfs_sys_use_dbregs;	   /* incremented when a system wide se=
ssion uses debug regs */
+	unsigned int		pfs_ptrace_use_dbregs;	   /* incremented when a process use=
s debug regs */
 	struct task_struct	*pfs_sys_session[NR_CPUS]; /* point to task owning a s=
ystem-wide session */
 } pfm_session_t;
=20
@@ -313,23 +318,22 @@
=20
 /*
  * This structure is initialized at boot time and contains
- * a description of the PMU main characteristic as indicated
- * by PAL along with a list of inter-registers dependencies and configurat=
ions.
+ * a description of the PMU main characteristics.
  */
 typedef struct {
-	unsigned long pfm_is_disabled;	/* indicates if perfmon is working properl=
y */
-	unsigned long perf_ovfl_val;	/* overflow value for generic counters   */
-	unsigned long max_counters;	/* upper limit on counter pair (PMC/PMD) */
-	unsigned long num_pmcs ;	/* highest PMC implemented (may have holes) */
-	unsigned long num_pmds;		/* highest PMD implemented (may have holes) */
-	unsigned long impl_regs[16];	/* buffer used to hold implememted PMC/PMD m=
ask */
-	unsigned long num_ibrs;		/* number of instruction debug registers */
-	unsigned long num_dbrs;		/* number of data debug registers */
-	pfm_reg_desc_t *pmc_desc;	/* detailed PMC register descriptions */
-	pfm_reg_desc_t *pmd_desc;	/* detailed PMD register descriptions */
+	unsigned int  disabled;		/* indicates if perfmon is working properly */
+	unsigned long ovfl_val;		/* overflow value for generic counters   */
+	unsigned long impl_pmcs[4];	/* bitmask of implemented PMCS */
+	unsigned long impl_pmds[4];	/* bitmask of implemented PMDS */
+	unsigned int  num_pmcs;		/* number of implemented PMCS */
+	unsigned int  num_pmds;		/* number of implemented PMDS */
+	unsigned int  num_ibrs;		/* number of implemented IBRS */
+	unsigned int  num_dbrs;		/* number of implemented DBRS */
+	unsigned int  num_counters;	/* number of PMD/PMC counters */
+	pfm_reg_desc_t *pmc_desc;	/* detailed PMC register dependencies descripti=
ons */
+	pfm_reg_desc_t *pmd_desc;	/* detailed PMD register dependencies descripti=
ons */
 } pmu_config_t;
=20
-
 /*
  * structure used to pass argument to/from remote CPU=20
  * using IPI to check and possibly save the PMU context on SMP systems.
@@ -389,13 +393,12 @@
 /*
  * perfmon internal variables
  */
-static pmu_config_t	pmu_conf; 	/* PMU configuration */
 static pfm_session_t	pfm_sessions;	/* global sessions information */
 static struct proc_dir_entry *perfmon_dir; /* for debug only */
 static pfm_stats_t	pfm_stats[NR_CPUS];
+static pfm_intr_handler_desc_t	*pfm_alternate_intr_handler;
=20
-DEFINE_PER_CPU(int, pfm_syst_wide);
-static DEFINE_PER_CPU(int, pfm_dcr_pp);
+DEFINE_PER_CPU(unsigned long, pfm_syst_info);
=20
 /* sysctl() controls */
 static pfm_sysctl_t pfm_sysctl;
@@ -449,42 +452,62 @@
 #include "perfmon_generic.h"
 #endif
=20
+static inline void
+pfm_clear_psr_pp(void)
+{
+	__asm__ __volatile__ ("rsm psr.pp;; srlz.i;;"::: "memory");
+}
+
+static inline void
+pfm_set_psr_pp(void)
+{
+	__asm__ __volatile__ ("ssm psr.pp;; srlz.i;;"::: "memory");
+}
+
+static inline void
+pfm_clear_psr_up(void)
+{
+	__asm__ __volatile__ ("rum psr.up;; srlz.i;;"::: "memory");
+}
+
+static inline void
+pfm_set_psr_up(void)
+{
+	__asm__ __volatile__ ("sum psr.up;; srlz.i;;"::: "memory");
+}
+
+static inline unsigned long
+pfm_get_psr(void)
+{
+	unsigned long tmp;
+	__asm__ __volatile__ ("mov %0=3Dpsr;;": "=3Dr"(tmp) :: "memory");
+	return tmp;
+}
+
+static inline void
+pfm_set_psr_l(unsigned long val)
+{
+	__asm__ __volatile__ ("mov psr.l=3D%0;; srlz.i;;"::"r"(val): "memory");
+}
+
+
 static inline unsigned long
 pfm_read_soft_counter(pfm_context_t *ctx, int i)
 {
-	return ctx->ctx_soft_pmds[i].val + (ia64_get_pmd(i) & pmu_conf.perf_ovfl_=
val);
+	return ctx->ctx_soft_pmds[i].val + (ia64_get_pmd(i) & pmu_conf.ovfl_val);
 }
=20
 static inline void
 pfm_write_soft_counter(pfm_context_t *ctx, int i, unsigned long val)
 {
-	ctx->ctx_soft_pmds[i].val =3D val  & ~pmu_conf.perf_ovfl_val;
+	ctx->ctx_soft_pmds[i].val =3D val  & ~pmu_conf.ovfl_val;
 	/*
 	 * writing to unimplemented part is ignore, so we do not need to
 	 * mask off top part
 	 */
-	ia64_set_pmd(i, val & pmu_conf.perf_ovfl_val);
-}
-
-/*
- * finds the number of PM(C|D) registers given
- * the bitvector returned by PAL
- */
-static unsigned long __init
-find_num_pm_regs(long *buffer)
-{
-	int i=3D3; /* 4 words/per bitvector */
-
-	/* start from the most significant word */
-	while (i>=3D0 && buffer[i] =3D 0 ) i--;
-	if (i< 0) {
-		printk(KERN_ERR "perfmon: No bit set in pm_buffer\n");
-		return 0;
-	}
-	return 1+ ia64_fls(buffer[i]) + 64 * i;
+	ia64_set_pmd(i, val & pmu_conf.ovfl_val);
 }
=20
-
 /*
  * Generates a unique (per CPU) timestamp
  */
@@ -875,6 +898,120 @@
 	return -ENOMEM;
 }
=20
+static int
+pfm_reserve_session(struct task_struct *task, int is_syswide, unsigned lon=
g cpu_mask)
+{
+	unsigned long m, undo_mask;
+	unsigned int n, i;
+
+	/*
+	 * validy checks on cpu_mask have been done upstream
+	 */
+	LOCK_PFS();
+
+	if (is_syswide) {
+		/*=20
+		 * cannot mix system wide and per-task sessions
+		 */
+		if (pfm_sessions.pfs_task_sessions > 0UL) {
+			DBprintk(("system wide not possible, %u conflicting task_sessions\n",=20
+			  	pfm_sessions.pfs_task_sessions));
+			goto abort;
+		}
+
+		m =3D cpu_mask; undo_mask =3D 0UL; n =3D 0;
+		DBprintk(("cpu_mask=3D0x%lx\n", cpu_mask));
+		for(i=3D0; m; i++, m>>=3D1) {
+
+			if ((m & 0x1) =3D 0UL) continue;
+
+			if (pfm_sessions.pfs_sys_session[i]) goto undo;
+
+			DBprintk(("reserving CPU%d currently on CPU%d\n", i, smp_processor_id()=
));
+
+			pfm_sessions.pfs_sys_session[i] =3D task;
+			undo_mask |=3D 1UL << i;
+			n++;
+		}
+		pfm_sessions.pfs_sys_sessions +=3D n;
+	} else {
+		if (pfm_sessions.pfs_sys_sessions) goto abort;
+		pfm_sessions.pfs_task_sessions++;
+	}
+	DBprintk(("task_sessions=3D%u sys_session[%d]=3D%d",=20
+		  pfm_sessions.pfs_task_sessions,=20
+		  smp_processor_id(), pfm_sessions.pfs_sys_session[smp_processor_id()] ?=
 1 : 0));
+	UNLOCK_PFS();
+	return 0;
+undo:
+	DBprintk(("system wide not possible, conflicting session [%d] on CPU%d\n",
+  		pfm_sessions.pfs_sys_session[i]->pid, i));
+
+	for(i=3D0; undo_mask; i++, undo_mask >>=3D1) {
+		pfm_sessions.pfs_sys_session[i] =3D NULL;
+	}
+abort:
+	UNLOCK_PFS();
+
+	return -EBUSY;
+
+}
+
+static int
+pfm_unreserve_session(struct task_struct *task, int is_syswide, unsigned l=
ong cpu_mask)
+{
+	pfm_context_t *ctx;
+	unsigned long m;
+	unsigned int n, i;
+
+	ctx =3D task ? task->thread.pfm_context : NULL;
+
+	/*
+	 * validy checks on cpu_mask have been done upstream
+	 */
+	LOCK_PFS();
+
+	DBprintk(("[%d] sys_sessions=3D%u task_sessions=3D%u dbregs=3D%u syswide=
=3D%d cpu_mask=3D0x%lx\n",
+		task->pid,
+		pfm_sessions.pfs_sys_sessions,
+		pfm_sessions.pfs_task_sessions,
+		pfm_sessions.pfs_sys_use_dbregs,
+		is_syswide,
+		cpu_mask));
+	=09
+
+	if (is_syswide) {
+		m =3D cpu_mask; n =3D 0;
+		for(i=3D0; m; i++, m>>=3D1) {
+			if ((m & 0x1) =3D 0UL) continue;
+			pfm_sessions.pfs_sys_session[i] =3D NULL;
+			n++;
+		}
+		/*=20
+		 * would not work with perfmon+more than one bit in cpu_mask
+		 */
+		if (ctx && ctx->ctx_fl_using_dbreg) {
+			if (pfm_sessions.pfs_sys_use_dbregs =3D 0) {
+				printk("perfmon: invalid release for [%d] sys_use_dbregs=3D0\n", task-=
>pid);
+			} else {
+				pfm_sessions.pfs_sys_use_dbregs--;
+			}
+		}
+		pfm_sessions.pfs_sys_sessions -=3D n;
+
+		DBprintk(("CPU%d sys_sessions=3D%u\n",=20
+			smp_processor_id(), pfm_sessions.pfs_sys_sessions));
+	} else {
+		pfm_sessions.pfs_task_sessions--;
+		DBprintk(("[%d] task_sessions=3D%u\n",=20
+			task->pid, pfm_sessions.pfs_task_sessions));
+	}
+
+	UNLOCK_PFS();
+
+	return 0;
+}
+
 /*
  * XXX: do something better here
  */
@@ -891,6 +1028,7 @@
 static int
 pfx_is_sane(struct task_struct *task, pfarg_context_t *pfx)
 {
+	unsigned long smpl_pmds =3D pfx->ctx_smpl_regs[0];
 	int ctx_flags;
 	int cpu;
=20
@@ -957,6 +1095,11 @@
 		}
 #endif
 	}
+	/* verify validity of smpl_regs */
+	if ((smpl_pmds & pmu_conf.impl_pmds[0]) !=3D smpl_pmds) {
+		DBprintk(("invalid smpl_regs 0x%lx\n", smpl_pmds));
+		return -EINVAL;
+	}
 	/* probably more to add here */
=20
 	return 0;
@@ -968,7 +1111,7 @@
 {
 	pfarg_context_t tmp;
 	void *uaddr =3D NULL;
-	int ret, cpu =3D 0;
+	int ret;
 	int ctx_flags;
 	pid_t notify_pid;
=20
@@ -987,40 +1130,8 @@
=20
 	ctx_flags =3D tmp.ctx_flags;
=20
-	ret =3D  -EBUSY;
-
-	LOCK_PFS();
-
-	if (ctx_flags & PFM_FL_SYSTEM_WIDE) {
-
-		/* at this point, we know there is at least one bit set */
-		cpu =3D ffz(~tmp.ctx_cpu_mask);
-
-		DBprintk(("requesting CPU%d currently on CPU%d\n",cpu, smp_processor_id(=
)));
-
-		if (pfm_sessions.pfs_task_sessions > 0) {
-			DBprintk(("system wide not possible, task_sessions=3D%ld\n", pfm_sessio=
ns.pfs_task_sessions));
-			goto abort;
-		}
-
-		if (pfm_sessions.pfs_sys_session[cpu]) {
-			DBprintk(("system wide not possible, conflicting session [%d] on CPU%d\=
n",pfm_sessions.pfs_sys_session[cpu]->pid, cpu));
-			goto abort;
-		}
-		pfm_sessions.pfs_sys_session[cpu] =3D task;
-		/*
-		 * count the number of system wide sessions
-		 */
-		pfm_sessions.pfs_sys_sessions++;
-
-	} else if (pfm_sessions.pfs_sys_sessions =3D 0) {
-		pfm_sessions.pfs_task_sessions++;
-	} else {
-		/* no per-process monitoring while there is a system wide session */
-		goto abort;
-	}
-
-	UNLOCK_PFS();
+	ret =3D pfm_reserve_session(task, ctx_flags & PFM_FL_SYSTEM_WIDE, tmp.ctx=
_cpu_mask);
+	if (ret) goto abort;
=20
 	ret =3D -ENOMEM;
=20
@@ -1103,6 +1214,7 @@
 	ctx->ctx_fl_inherit   =3D ctx_flags & PFM_FL_INHERIT_MASK;
 	ctx->ctx_fl_block     =3D (ctx_flags & PFM_FL_NOTIFY_BLOCK) ? 1 : 0;
 	ctx->ctx_fl_system    =3D (ctx_flags & PFM_FL_SYSTEM_WIDE) ? 1: 0;
+	ctx->ctx_fl_excl_idle =3D (ctx_flags & PFM_FL_EXCL_IDLE) ? 1: 0;
 	ctx->ctx_fl_frozen    =3D 0;
 	/*
 	 * setting this flag to 0 here means, that the creator or the task that t=
he
@@ -1113,7 +1225,7 @@
 	ctx->ctx_fl_protected =3D 0;
=20
 	/* for system wide mode only (only 1 bit set) */
-	ctx->ctx_cpu         =3D cpu;
+	ctx->ctx_cpu =3D ffz(~tmp.ctx_cpu_mask);
=20
 	atomic_set(&ctx->ctx_last_cpu,-1); /* SMP only, means no CPU */
=20
@@ -1131,9 +1243,9 @@
 	DBprintk(("context=3D%p, pid=3D%d notify_task=3D%p\n",
 			(void *)ctx, task->pid, ctx->ctx_notify_task));
=20
-	DBprintk(("context=3D%p, pid=3D%d flags=3D0x%x inherit=3D%d block=3D%d sy=
stem=3D%d\n",=20
+	DBprintk(("context=3D%p, pid=3D%d flags=3D0x%x inherit=3D%d block=3D%d sy=
stem=3D%d excl_idle=3D%d\n",=20
 			(void *)ctx, task->pid, ctx_flags, ctx->ctx_fl_inherit,=20
-			ctx->ctx_fl_block, ctx->ctx_fl_system));
+			ctx->ctx_fl_block, ctx->ctx_fl_system, ctx->ctx_fl_excl_idle));
=20
 	/*
 	 * when no notification is required, we can make this visible at the last=
 moment
@@ -1146,8 +1258,8 @@
 	 */
 	if (ctx->ctx_fl_system) {
 		ctx->ctx_saved_cpus_allowed =3D task->cpus_allowed;
-		set_cpus_allowed(task, 1UL << cpu);
-		DBprintk(("[%d] rescheduled allowed=3D0x%lx\n", task->pid,task->cpus_all=
owed));
+		set_cpus_allowed(task, tmp.ctx_cpu_mask);
+		DBprintk(("[%d] rescheduled allowed=3D0x%lx\n", task->pid, task->cpus_al=
lowed));
 	}
=20
 	return 0;
@@ -1155,20 +1267,8 @@
 buffer_error:
 	pfm_context_free(ctx);
 error:
-	/*
-	 * undo session reservation
-	 */
-	LOCK_PFS();
-
-	if (ctx_flags & PFM_FL_SYSTEM_WIDE) {
-		pfm_sessions.pfs_sys_session[cpu] =3D NULL;
-		pfm_sessions.pfs_sys_sessions--;
-	} else {
-		pfm_sessions.pfs_task_sessions--;
-	}
+	pfm_unreserve_session(task, ctx_flags & PFM_FL_SYSTEM_WIDE , tmp.ctx_cpu_=
mask);
 abort:
-	UNLOCK_PFS();
-
 	/* make sure we don't leave anything behind */
 	task->thread.pfm_context =3D NULL;
=20
@@ -1200,9 +1300,7 @@
 	unsigned long mask =3D ovfl_regs[0];
 	unsigned long reset_others =3D 0UL;
 	unsigned long val;
-	int i, is_long_reset =3D (flag & PFM_RELOAD_LONG_RESET);
-
-	DBprintk(("masks=3D0x%lx\n", mask));
+	int i, is_long_reset =3D (flag =3D PFM_PMD_LONG_RESET);
=20
 	/*
 	 * now restore reset value on sampling overflowed counters
@@ -1213,7 +1311,7 @@
 			val =3D pfm_new_counter_value(ctx->ctx_soft_pmds + i, is_long_reset);
 			reset_others |=3D ctx->ctx_soft_pmds[i].reset_pmds[0];
=20
-			DBprintk(("[%d] %s reset soft_pmd[%d]=3D%lx\n", current->pid,
+			DBprintk_ovfl(("[%d] %s reset soft_pmd[%d]=3D%lx\n", current->pid,
 				  is_long_reset ? "long" : "short", i, val));
=20
 			/* upper part is ignored on rval */
@@ -1235,7 +1333,7 @@
 		} else {
 			ia64_set_pmd(i, val);
 		}
-		DBprintk(("[%d] %s reset_others pmd[%d]=3D%lx\n", current->pid,
+		DBprintk_ovfl(("[%d] %s reset_others pmd[%d]=3D%lx\n", current->pid,
 			  is_long_reset ? "long" : "short", i, val));
 	}
 	ia64_srlz_d();
@@ -1246,7 +1344,7 @@
 {
 	struct thread_struct *th =3D &task->thread;
 	pfarg_reg_t tmp, *req =3D (pfarg_reg_t *)arg;
-	unsigned long value;
+	unsigned long value, reset_pmds;
 	unsigned int cnum, reg_flags, flags;
 	int i;
 	int ret =3D -EINVAL;
@@ -1262,10 +1360,11 @@
=20
 		if (__copy_from_user(&tmp, req, sizeof(tmp))) return -EFAULT;
=20
-		cnum      =3D tmp.reg_num;
-		reg_flags =3D tmp.reg_flags;
-		value     =3D tmp.reg_value;
-		flags     =3D 0;
+		cnum       =3D tmp.reg_num;
+		reg_flags  =3D tmp.reg_flags;
+		value      =3D tmp.reg_value;
+		reset_pmds =3D tmp.reg_reset_pmds[0];
+		flags      =3D 0;
=20
 		/*=20
 		 * we reject all non implemented PMC as well
@@ -1283,6 +1382,8 @@
 		 * any other configuration is rejected.
 		 */
 		if (PMC_IS_MONITOR(cnum) || PMC_IS_COUNTING(cnum)) {
+			DBprintk(("pmc[%u].pm=3D%ld\n", cnum, PMC_PM(cnum, value)));=20
+
 			if (ctx->ctx_fl_system ^ PMC_PM(cnum, value)) {
 				DBprintk(("pmc_pm=3D%ld fl_system=3D%d\n", PMC_PM(cnum, value), ctx->c=
tx_fl_system));
 				goto error;
@@ -1310,6 +1411,11 @@
=20
 			if (reg_flags & PFM_REGFL_RANDOM) flags |=3D PFM_REGFL_RANDOM;
=20
+			/* verify validity of reset_pmds */
+			if ((reset_pmds & pmu_conf.impl_pmds[0]) !=3D reset_pmds) {
+				DBprintk(("invalid reset_pmds 0x%lx for pmc%u\n", reset_pmds, cnum));
+				goto error;
+			}
 		} else if (reg_flags & (PFM_REGFL_OVFL_NOTIFY|PFM_REGFL_RANDOM)) {
 				DBprintk(("cannot set ovfl_notify or random on pmc%u\n", cnum));
 				goto error;
@@ -1348,13 +1454,10 @@
 		ctx->ctx_soft_pmds[cnum].flags =3D flags;
=20
 		if (PMC_IS_COUNTING(cnum)) {
-			/*
-			 * copy reset vector
-			 */
-			ctx->ctx_soft_pmds[cnum].reset_pmds[0] =3D tmp.reg_reset_pmds[0];
-			ctx->ctx_soft_pmds[cnum].reset_pmds[1] =3D tmp.reg_reset_pmds[1];
-			ctx->ctx_soft_pmds[cnum].reset_pmds[2] =3D tmp.reg_reset_pmds[2];
-			ctx->ctx_soft_pmds[cnum].reset_pmds[3] =3D tmp.reg_reset_pmds[3];
+			ctx->ctx_soft_pmds[cnum].reset_pmds[0] =3D reset_pmds;
+
+			/* mark all PMDS to be accessed as used */
+			CTX_USED_PMD(ctx, reset_pmds);
 		}
=20
 		/*
@@ -1397,7 +1500,7 @@
 	unsigned long value, hw_value;
 	unsigned int cnum;
 	int i;
-	int ret;
+	int ret =3D 0;
=20
 	/* we don't quite support this right now */
 	if (task !=3D current) return -EINVAL;
@@ -1448,9 +1551,9 @@
 		/* update virtualized (64bits) counter */
 		if (PMD_IS_COUNTING(cnum)) {
 			ctx->ctx_soft_pmds[cnum].lval =3D value;
-			ctx->ctx_soft_pmds[cnum].val  =3D value & ~pmu_conf.perf_ovfl_val;
+			ctx->ctx_soft_pmds[cnum].val  =3D value & ~pmu_conf.ovfl_val;
=20
-			hw_value =3D value & pmu_conf.perf_ovfl_val;=20
+			hw_value =3D value & pmu_conf.ovfl_val;
=20
 			ctx->ctx_soft_pmds[cnum].long_reset  =3D tmp.reg_long_reset;
 			ctx->ctx_soft_pmds[cnum].short_reset =3D tmp.reg_short_reset;
@@ -1478,7 +1581,7 @@
 				ctx->ctx_soft_pmds[cnum].val,
 				ctx->ctx_soft_pmds[cnum].short_reset,
 				ctx->ctx_soft_pmds[cnum].long_reset,
-				ia64_get_pmd(cnum) & pmu_conf.perf_ovfl_val,
+				ia64_get_pmd(cnum) & pmu_conf.ovfl_val,
 				PMC_OVFL_NOTIFY(ctx, cnum) ? 'Y':'N',
 				ctx->ctx_used_pmds[0],
 				ctx->ctx_soft_pmds[cnum].reset_pmds[0]));
@@ -1504,15 +1607,18 @@
 	return ret;
 }
=20
-
 static int
 pfm_read_pmds(struct task_struct *task, pfm_context_t *ctx, void *arg, int=
 count, struct pt_regs *regs)
 {
 	struct thread_struct *th =3D &task->thread;
-	unsigned long val =3D 0UL;
+	unsigned long val, lval;
 	pfarg_reg_t *req =3D (pfarg_reg_t *)arg;
 	unsigned int cnum, reg_flags =3D 0;
-	int i, ret =3D -EINVAL;
+	int i, ret =3D 0;
+
+#if __GNUC__ < 3
+	int foo;
+#endif
=20
 	if (!CTX_IS_ENABLED(ctx)) return -EINVAL;
=20
@@ -1528,9 +1634,16 @@
 	DBprintk(("ctx_last_cpu=3D%d for [%d]\n", atomic_read(&ctx->ctx_last_cpu)=
, task->pid));
=20
 	for (i =3D 0; i < count; i++, req++) {
-
+#if __GNUC__ < 3
+		foo =3D __get_user(cnum, &req->reg_num);
+		if (foo) return -EFAULT;
+		foo =3D __get_user(reg_flags, &req->reg_flags);
+		if (foo) return -EFAULT;
+#else
 		if (__get_user(cnum, &req->reg_num)) return -EFAULT;
 		if (__get_user(reg_flags, &req->reg_flags)) return -EFAULT;
+#endif
+		lval =3D 0UL;
=20
 		if (!PMD_IS_IMPL(cnum)) goto abort_mission;
 		/*
@@ -1578,9 +1691,10 @@
 			/*
 			 * XXX: need to check for overflow
 			 */
-
-			val &=3D pmu_conf.perf_ovfl_val;
+			val &=3D pmu_conf.ovfl_val;
 			val +=3D ctx->ctx_soft_pmds[cnum].val;
+
+			lval =3D ctx->ctx_soft_pmds[cnum].lval;
 		}=20
=20
 		/*
@@ -1592,10 +1706,11 @@
 			val =3D v;
 		}
=20
-		PFM_REG_RETFLAG_SET(reg_flags, 0);
+		PFM_REG_RETFLAG_SET(reg_flags, ret);
=20
 		DBprintk(("read pmd[%u] ret=3D%d value=3D0x%lx pmc=3D0x%lx\n",=20
-			cnum, ret, val, ia64_get_pmc(cnum)));
+					cnum, ret, val, ia64_get_pmc(cnum)));
+
 		/*
 		 * update register return value, abort all if problem during copy.
 		 * we only modify the reg_flags field. no check mode is fine because
@@ -1604,16 +1719,19 @@
 		if (__put_user(cnum, &req->reg_num)) return -EFAULT;
 		if (__put_user(val, &req->reg_value)) return -EFAULT;
 		if (__put_user(reg_flags, &req->reg_flags)) return -EFAULT;
+		if (__put_user(lval, &req->reg_last_reset_value)) return -EFAULT;
 	}
=20
 	return 0;
=20
 abort_mission:
 	PFM_REG_RETFLAG_SET(reg_flags, PFM_REG_RETFL_EINVAL);
+	/*=20
+	 * XXX: if this fails, we stick with the original failure, flag not updat=
ed!
+	 */
+	__put_user(reg_flags, &req->reg_flags);
=20
-	if (__put_user(reg_flags, &req->reg_flags)) ret =3D -EFAULT;
-
-	return ret;
+	return -EINVAL;
 }
=20
 #ifdef PFM_PMU_USES_DBR
@@ -1655,7 +1773,7 @@
 	else
 		pfm_sessions.pfs_ptrace_use_dbregs++;
=20
-	DBprintk(("ptrace_use_dbregs=3D%lu  sys_use_dbregs=3D%lu by [%d] ret =3D =
%d\n",=20
+	DBprintk(("ptrace_use_dbregs=3D%u  sys_use_dbregs=3D%u by [%d] ret =3D %d=
\n",=20
 		  pfm_sessions.pfs_ptrace_use_dbregs,=20
 		  pfm_sessions.pfs_sys_use_dbregs,=20
 		  task->pid, ret));
@@ -1673,7 +1791,6 @@
  * perfmormance monitoring, so we only decrement the number
  * of "ptraced" debug register users to keep the count up to date
  */
-
 int
 pfm_release_debug_registers(struct task_struct *task)
 {
@@ -1702,6 +1819,7 @@
 {
 	return 0;
 }
+
 int
 pfm_release_debug_registers(struct task_struct *task)
 {
@@ -1721,9 +1839,12 @@
 	if (!CTX_IS_ENABLED(ctx)) return -EINVAL;
=20
 	if (task =3D current) {
-		DBprintk(("restarting self %d frozen=3D%d \n", current->pid, ctx->ctx_fl=
_frozen));
+		DBprintk(("restarting self %d frozen=3D%d ovfl_regs=3D0x%lx\n",=20
+			task->pid,=20
+			ctx->ctx_fl_frozen,
+			ctx->ctx_ovfl_regs[0]));
=20
-		pfm_reset_regs(ctx, ctx->ctx_ovfl_regs, PFM_RELOAD_LONG_RESET);
+		pfm_reset_regs(ctx, ctx->ctx_ovfl_regs, PFM_PMD_LONG_RESET);
=20
 		ctx->ctx_ovfl_regs[0] =3D 0UL;
=20
@@ -1806,18 +1927,18 @@
 		ia64_set_dcr(ia64_get_dcr() & ~IA64_DCR_PP);
=20
 		/* stop monitoring */
-		__asm__ __volatile__ ("rsm psr.pp;;"::: "memory");
+		pfm_clear_psr_pp();
=20
 		ia64_srlz_i();
=20
-		__get_cpu_var(pfm_dcr_pp)  =3D 0;
+		PFM_CPUINFO_CLEAR(PFM_CPUINFO_DCR_PP);
=20
 		ia64_psr(regs)->pp =3D 0;
=20
 	} else {
=20
 		/* stop monitoring */
-		__asm__ __volatile__ ("rum psr.up;;"::: "memory");
+		pfm_clear_psr_up();
=20
 		ia64_srlz_i();
=20
@@ -1979,14 +2100,9 @@
 	int i, ret =3D 0;
=20
 	/*
-	 * for range restriction: psr.db must be cleared or the
-	 * the PMU will ignore the debug registers.
-	 *
-	 * XXX: may need more in system wide mode,
-	 * no task can have this bit set?
+	 * we do not need to check for ipsr.db because we do clear ibr.x, dbr.r, =
and dbr.w
+	 * ensuring that no real breakpoint can be installed via this call.
 	 */
-	if (ia64_psr(regs)->db =3D 1) return -EINVAL;
-
=20
 	first_time =3D ctx->ctx_fl_using_dbreg =3D 0;
=20
@@ -2055,7 +2171,6 @@
 	 * Now install the values into the registers
 	 */
 	for (i =3D 0; i < count; i++, req++) {
-
 	=09
 		if (__copy_from_user(&tmp, req, sizeof(tmp))) goto abort_mission;
 	=09
@@ -2145,7 +2260,7 @@
 		 * XXX: for now we can only come here on EINVAL
 		 */
 		PFM_REG_RETFLAG_SET(tmp.dbreg_flags, PFM_REG_RETFL_EINVAL);
-		__put_user(tmp.dbreg_flags, &req->dbreg_flags);
+		if (__put_user(tmp.dbreg_flags, &req->dbreg_flags)) ret =3D -EFAULT;
 	}
 	return ret;
 }
@@ -2215,13 +2330,13 @@
=20
 	if (ctx->ctx_fl_system) {
 	=09
-		__get_cpu_var(pfm_dcr_pp)  =3D 1;
+		PFM_CPUINFO_SET(PFM_CPUINFO_DCR_PP);
=20
 		/* set user level psr.pp */
 		ia64_psr(regs)->pp =3D 1;
=20
 		/* start monitoring at kernel level */
-		__asm__ __volatile__ ("ssm psr.pp;;"::: "memory");
+		pfm_set_psr_pp();
=20
 		/* enable dcr pp */
 		ia64_set_dcr(ia64_get_dcr()|IA64_DCR_PP);
@@ -2237,7 +2352,7 @@
 		ia64_psr(regs)->up =3D 1;
=20
 		/* start monitoring at kernel level */
-		__asm__ __volatile__ ("sum psr.up;;"::: "memory");
+		pfm_set_psr_up();
=20
 		ia64_srlz_i();
 	}
@@ -2264,11 +2379,12 @@
 		ia64_psr(regs)->up =3D 0; /* just to make sure! */
=20
 		/* make sure monitoring is stopped */
-		__asm__ __volatile__ ("rsm psr.pp;;"::: "memory");
+		pfm_clear_psr_pp();
 		ia64_srlz_i();
=20
-		__get_cpu_var(pfm_dcr_pp)    =3D 0;
-		__get_cpu_var(pfm_syst_wide) =3D 1;
+		PFM_CPUINFO_CLEAR(PFM_CPUINFO_DCR_PP);
+		PFM_CPUINFO_SET(PFM_CPUINFO_SYST_WIDE);
+		if (ctx->ctx_fl_excl_idle) PFM_CPUINFO_SET(PFM_CPUINFO_EXCL_IDLE);
 	} else {
 		/*
 		 * needed in case the task was a passive task during
@@ -2279,7 +2395,7 @@
 		ia64_psr(regs)->up =3D 0;
=20
 		/* make sure monitoring is stopped */
-		__asm__ __volatile__ ("rum psr.up;;"::: "memory");
+		pfm_clear_psr_up();
 		ia64_srlz_i();
=20
 		DBprintk(("clearing psr.sp for [%d]\n", current->pid));
@@ -2331,6 +2447,7 @@
 abort_mission:
 	PFM_REG_RETFLAG_SET(tmp.reg_flags, PFM_REG_RETFL_EINVAL);
 	if (__copy_to_user(req, &tmp, sizeof(tmp))) ret =3D -EFAULT;
+
 	return ret;
 }
=20
@@ -2532,7 +2649,7 @@
 		 * use the local reference
 		 */
=20
-		pfm_reset_regs(ctx, ctx->ctx_ovfl_regs, PFM_RELOAD_LONG_RESET);
+		pfm_reset_regs(ctx, ctx->ctx_ovfl_regs, PFM_PMD_LONG_RESET);
=20
 		ctx->ctx_ovfl_regs[0] =3D 0UL;
=20
@@ -2591,19 +2708,11 @@
 	h->pid  =3D current->pid;
 	h->cpu  =3D smp_processor_id();
 	h->last_reset_value =3D ovfl_mask ? ctx->ctx_soft_pmds[ffz(~ovfl_mask)].l=
val : 0UL;
-	/*=20
-	 * where did the fault happen
-	 */
-	h->ip   =3D regs ? regs->cr_iip | ((regs->cr_ipsr >> 41) & 0x3): 0x0UL;=09
-
-	/*=20
-	 * which registers overflowed
-	 */
-	h->regs =3D ovfl_mask;
+	h->ip   =3D regs ? regs->cr_iip | ((regs->cr_ipsr >> 41) & 0x3): 0x0UL;
+	h->regs =3D ovfl_mask; 			/* which registers overflowed */
=20
 	/* guaranteed to monotonically increase on each cpu */
 	h->stamp  =3D pfm_get_stamp();
-	h->period =3D 0UL; /* not yet used */
=20
 	/* position for first pmd */
 	e =3D (unsigned long *)(h+1);
@@ -2724,7 +2833,7 @@
 		 * pfm_read_pmds().
 		 */
 		old_val =3D ctx->ctx_soft_pmds[i].val;
-		ctx->ctx_soft_pmds[i].val +=3D 1 + pmu_conf.perf_ovfl_val;
+		ctx->ctx_soft_pmds[i].val +=3D 1 + pmu_conf.ovfl_val;
=20
 		/*
 		 * check for overflow condition
@@ -2739,9 +2848,7 @@
 		}
 		DBprintk_ovfl(("soft_pmd[%d].val=3D0x%lx old_val=3D0x%lx pmd=3D0x%lx ovf=
l_pmds=3D0x%lx ovfl_notify=3D0x%lx\n",=20
 			  i, ctx->ctx_soft_pmds[i].val, old_val,=20
-			  ia64_get_pmd(i) & pmu_conf.perf_ovfl_val, ovfl_pmds, ovfl_notify));
-
-
+			  ia64_get_pmd(i) & pmu_conf.ovfl_val, ovfl_pmds, ovfl_notify));
 	}
=20
 	/*
@@ -2776,7 +2883,7 @@
 	 */
 	if (ovfl_notify =3D 0UL) {
 		if (ovfl_pmds)=20
-			pfm_reset_regs(ctx, &ovfl_pmds, PFM_RELOAD_SHORT_RESET);
+			pfm_reset_regs(ctx, &ovfl_pmds, PFM_PMD_SHORT_RESET);
 		return 0x0;
 	}
=20
@@ -2924,7 +3031,7 @@
 }
=20
 static void
-perfmon_interrupt (int irq, void *arg, struct pt_regs *regs)
+pfm_interrupt_handler(int irq, void *arg, struct pt_regs *regs)
 {
 	u64 pmc0;
 	struct task_struct *task;
@@ -2932,6 +3039,14 @@
=20
 	pfm_stats[smp_processor_id()].pfm_ovfl_intr_count++;
=20
+	/*
+	 * if an alternate handler is registered, just bypass the default one
+	 */
+	if (pfm_alternate_intr_handler) {
+		(*pfm_alternate_intr_handler->handler)(irq, arg, regs);
+		return;
+	}
+
 	/*=20
 	 * srlz.d done before arriving here
 	 *
@@ -2994,14 +3109,13 @@
=20
 /* for debug only */
 static int
-perfmon_proc_info(char *page)
+pfm_proc_info(char *page)
 {
 	char *p =3D page;
 	int i;
=20
-	p +=3D sprintf(p, "enabled                : %s\n", pmu_conf.pfm_is_disabl=
ed ? "No": "Yes");
 	p +=3D sprintf(p, "fastctxsw              : %s\n", pfm_sysctl.fastctxsw >=
 0 ? "Yes": "No");
-	p +=3D sprintf(p, "ovfl_mask              : 0x%lx\n", pmu_conf.perf_ovfl_=
val);
+	p +=3D sprintf(p, "ovfl_mask              : 0x%lx\n", pmu_conf.ovfl_val);
=20
 	for(i=3D0; i < NR_CPUS; i++) {
 		if (cpu_is_online(i) =3D 0) continue;
@@ -3009,16 +3123,18 @@
 		p +=3D sprintf(p, "CPU%-2d spurious intrs   : %lu\n", i, pfm_stats[i].pf=
m_spurious_ovfl_intr_count);
 		p +=3D sprintf(p, "CPU%-2d recorded samples : %lu\n", i, pfm_stats[i].pf=
m_recorded_samples_count);
 		p +=3D sprintf(p, "CPU%-2d smpl buffer full : %lu\n", i, pfm_stats[i].pf=
m_full_smpl_buffer_count);
+		p +=3D sprintf(p, "CPU%-2d syst_wide        : %d\n", i, per_cpu(pfm_syst=
_info, i) & PFM_CPUINFO_SYST_WIDE ? 1 : 0);
+		p +=3D sprintf(p, "CPU%-2d dcr_pp           : %d\n", i, per_cpu(pfm_syst=
_info, i) & PFM_CPUINFO_DCR_PP ? 1 : 0);
+		p +=3D sprintf(p, "CPU%-2d exclude idle     : %d\n", i, per_cpu(pfm_syst=
_info, i) & PFM_CPUINFO_EXCL_IDLE ? 1 : 0);
 		p +=3D sprintf(p, "CPU%-2d owner            : %d\n", i, pmu_owners[i].ow=
ner ? pmu_owners[i].owner->pid: -1);
-		p +=3D sprintf(p, "CPU%-2d syst_wide        : %d\n", i, per_cpu(pfm_syst=
_wide, i));
-		p +=3D sprintf(p, "CPU%-2d dcr_pp           : %d\n", i, per_cpu(pfm_dcr_=
pp, i));
 	}
=20
 	LOCK_PFS();
-	p +=3D sprintf(p, "proc_sessions          : %lu\n"
-			"sys_sessions           : %lu\n"
-			"sys_use_dbregs         : %lu\n"
-			"ptrace_use_dbregs      : %lu\n",=20
+
+	p +=3D sprintf(p, "proc_sessions          : %u\n"
+			"sys_sessions           : %u\n"
+			"sys_use_dbregs         : %u\n"
+			"ptrace_use_dbregs      : %u\n",=20
 			pfm_sessions.pfs_task_sessions,=20
 			pfm_sessions.pfs_sys_sessions,
 			pfm_sessions.pfs_sys_use_dbregs,
@@ -3033,7 +3149,7 @@
 static int
 perfmon_read_entry(char *page, char **start, off_t off, int count, int *eo=
f, void *data)
 {
-	int len =3D perfmon_proc_info(page);
+	int len =3D pfm_proc_info(page);
=20
 	if (len <=3D off+count) *eof =3D 1;
=20
@@ -3046,17 +3162,57 @@
 	return len;
 }
=20
+/*
+ * we come here as soon as PFM_CPUINFO_SYST_WIDE is set. This happens
+ * during pfm_enable() hence before pfm_start(). We cannot assume monitori=
ng
+ * is active or inactive based on mode. We must rely on the value in=20
+ * cpu_data(i)->pfm_syst_info
+ */
 void
-pfm_syst_wide_update_task(struct task_struct *task, int mode)
+pfm_syst_wide_update_task(struct task_struct *task, unsigned long info, in=
t is_ctxswin)
 {
-	struct pt_regs *regs =3D (struct pt_regs *)((unsigned long) task + IA64_S=
TK_OFFSET);
+	struct pt_regs *regs;
+	unsigned long dcr;
+	unsigned long dcr_pp;
=20
-	regs--;
+	dcr_pp =3D info & PFM_CPUINFO_DCR_PP ? 1 : 0;
=20
 	/*
-	 * propagate the value of the dcr_pp bit to the psr
+	 * pid 0 is guaranteed to be the idle task. There is one such task with p=
id 0=20
+	 * on every CPU, so we can rely on the pid to identify the idle task.
+	 */
+	if ((info & PFM_CPUINFO_EXCL_IDLE) =3D 0 || task->pid) {
+		regs =3D (struct pt_regs *)((unsigned long) task + IA64_STK_OFFSET);
+		regs--;
+		ia64_psr(regs)->pp =3D is_ctxswin ? dcr_pp : 0;
+		return;
+	}
+	/*
+	 * if monitoring has started
 	 */
-	ia64_psr(regs)->pp =3D mode ? __get_cpu_var(pfm_dcr_pp) : 0;
+	if (dcr_pp) {
+		dcr =3D ia64_get_dcr();
+		/*=20
+		 * context switching in?=20
+		 */
+		if (is_ctxswin) {
+			/* mask monitoring for the idle task */
+			ia64_set_dcr(dcr & ~IA64_DCR_PP);
+			pfm_clear_psr_pp();
+			ia64_srlz_i();
+			return;
+		}
+		/*=20
+		 * context switching out
+		 * restore monitoring for next task=20
+		 *
+		 * Due to inlining this odd if-then-else construction generates=20
+		 * better code.
+		 */
+		ia64_set_dcr(dcr |IA64_DCR_PP);
+		pfm_set_psr_pp();
+		ia64_srlz_i();
+	}
 }
=20
 void
@@ -3067,11 +3223,10 @@
=20
 	ctx =3D task->thread.pfm_context;
=20
-
 	/*
 	 * save current PSR: needed because we modify it
 	 */
-	__asm__ __volatile__ ("mov %0=3Dpsr;;": "=3Dr"(psr) :: "memory");
+	psr =3D pfm_get_psr();
=20
 	/*
 	 * stop monitoring:
@@ -3369,7 +3524,7 @@
 	 */
 	mask =3D pfm_sysctl.fastctxsw || ctx->ctx_fl_protected ?  ctx->ctx_used_p=
mds[0] : ctx->ctx_reload_pmds[0];
 	for (i=3D0; mask; i++, mask>>=3D1) {
-		if (mask & 0x1) ia64_set_pmd(i, t->pmd[i] & pmu_conf.perf_ovfl_val);
+		if (mask & 0x1) ia64_set_pmd(i, t->pmd[i] & pmu_conf.ovfl_val);
 	}
=20
 	/*=20
@@ -3419,7 +3574,7 @@
 	int i;
=20
 	if (task !=3D current) {
-		printk("perfmon: invalid task in ia64_reset_pmu()\n");
+		printk("perfmon: invalid task in pfm_reset_pmu()\n");
 		return;
 	}
=20
@@ -3428,6 +3583,7 @@
=20
 	/*
 	 * install reset values for PMC. We skip PMC0 (done above)
+	 * XX: good up to 64 PMCS
 	 */
 	for (i=3D1; (pmu_conf.pmc_desc[i].type & PFM_REG_END) =3D 0; i++) {
 		if ((pmu_conf.pmc_desc[i].type & PFM_REG_IMPL) =3D 0) continue;
@@ -3444,7 +3600,7 @@
=20
 	/*
 	 * clear reset values for PMD.=20
-	 * XXX: good up to 64 PMDS. Suppose that zero is a valid value.
+	 * XXX: good up to 64 PMDS.
 	 */
 	for (i=3D0; (pmu_conf.pmd_desc[i].type & PFM_REG_END) =3D 0; i++) {
 		if ((pmu_conf.pmd_desc[i].type & PFM_REG_IMPL) =3D 0) continue;
@@ -3477,13 +3633,13 @@
 	  *
 	  * We never directly restore PMC0 so we do not include it in the mask.
 	  */
-	ctx->ctx_reload_pmcs[0] =3D pmu_conf.impl_regs[0] & ~0x1;
+	ctx->ctx_reload_pmcs[0] =3D pmu_conf.impl_pmcs[0] & ~0x1;
 	/*
 	 * We must include all the PMD in this mask to avoid picking
 	 * up stale value and leak information, especially directly
 	 * at the user level when psr.sp=3D0
 	 */
-	ctx->ctx_reload_pmds[0] =3D pmu_conf.impl_regs[4];
+	ctx->ctx_reload_pmds[0] =3D pmu_conf.impl_pmds[0];
=20
 	/*=20
 	 * Keep track of the pmds we want to sample
@@ -3493,7 +3649,7 @@
 	 *
 	 * We ignore the unimplemented pmds specified by the user
 	 */
-	ctx->ctx_used_pmds[0] =3D ctx->ctx_smpl_regs[0] & pmu_conf.impl_regs[4];
+	ctx->ctx_used_pmds[0] =3D ctx->ctx_smpl_regs[0];
 	ctx->ctx_used_pmcs[0] =3D 1; /* always save/restore PMC[0] */
=20
 	/*
@@ -3547,16 +3703,17 @@
 		ia64_set_dcr(ia64_get_dcr() & ~IA64_DCR_PP);
=20
 		/* stop monitoring */
-		__asm__ __volatile__ ("rsm psr.pp;;"::: "memory");
+		pfm_clear_psr_pp();
=20
 		ia64_srlz_i();
=20
-		__get_cpu_var(pfm_syst_wide) =3D 0;
-		__get_cpu_var(pfm_dcr_pp)    =3D 0;
+		PFM_CPUINFO_CLEAR(PFM_CPUINFO_SYST_WIDE);
+		PFM_CPUINFO_CLEAR(PFM_CPUINFO_DCR_PP);
+		PFM_CPUINFO_CLEAR(PFM_CPUINFO_EXCL_IDLE);
 	} else  {
=20
 		/* stop monitoring */
-		__asm__ __volatile__ ("rum psr.up;;"::: "memory");
+		pfm_clear_psr_up();
=20
 		ia64_srlz_i();
=20
@@ -3622,10 +3779,14 @@
 		val =3D ia64_get_pmd(i);
=20
 		if (PMD_IS_COUNTING(i)) {
-			DBprintk(("[%d] pmd[%d] soft_pmd=3D0x%lx hw_pmd=3D0x%lx\n", task->pid, =
i, ctx->ctx_soft_pmds[i].val, val & pmu_conf.perf_ovfl_val));
+			DBprintk(("[%d] pmd[%d] soft_pmd=3D0x%lx hw_pmd=3D0x%lx\n",=20
+				task->pid,=20
+				i,=20
+				ctx->ctx_soft_pmds[i].val,=20
+				val & pmu_conf.ovfl_val));
=20
 			/* collect latest results */
-			ctx->ctx_soft_pmds[i].val +=3D val & pmu_conf.perf_ovfl_val;
+			ctx->ctx_soft_pmds[i].val +=3D val & pmu_conf.ovfl_val;
=20
 			/*
 			 * now everything is in ctx_soft_pmds[] and we need
@@ -3638,7 +3799,7 @@
 			 * take care of overflow inline
 			 */
 			if (pmc0 & (1UL << i)) {
-				ctx->ctx_soft_pmds[i].val +=3D 1 + pmu_conf.perf_ovfl_val;
+				ctx->ctx_soft_pmds[i].val +=3D 1 + pmu_conf.ovfl_val;
 				DBprintk(("[%d] pmd[%d] overflowed soft_pmd=3D0x%lx\n",
 					task->pid, i, ctx->ctx_soft_pmds[i].val));
 			}
@@ -3771,8 +3932,8 @@
 	m =3D nctx->ctx_used_pmds[0] >> PMU_FIRST_COUNTER;
 	for(i =3D PMU_FIRST_COUNTER ; m ; m>>=3D1, i++) {
 		if ((m & 0x1) && pmu_conf.pmd_desc[i].type =3D PFM_REG_COUNTING) {
-			nctx->ctx_soft_pmds[i].val =3D nctx->ctx_soft_pmds[i].lval & ~pmu_conf.=
perf_ovfl_val;
-			thread->pmd[i]	      	   =3D nctx->ctx_soft_pmds[i].lval & pmu_conf.per=
f_ovfl_val;
+			nctx->ctx_soft_pmds[i].val =3D nctx->ctx_soft_pmds[i].lval & ~pmu_conf.=
ovfl_val;
+			thread->pmd[i]	      	   =3D nctx->ctx_soft_pmds[i].lval & pmu_conf.ovf=
l_val;
 		} else {
 			thread->pmd[i]	      	   =3D 0UL; /* reset to initial state */
 		}
@@ -3939,30 +4100,14 @@
=20
 	UNLOCK_CTX(ctx);
=20
-	LOCK_PFS();
+	pfm_unreserve_session(task, ctx->ctx_fl_system, 1UL << ctx->ctx_cpu);
=20
 	if (ctx->ctx_fl_system) {
-
-		pfm_sessions.pfs_sys_session[ctx->ctx_cpu] =3D NULL;
-		pfm_sessions.pfs_sys_sessions--;
-		DBprintk(("freeing syswide session on CPU%ld\n", ctx->ctx_cpu));
-
-		/* update perfmon debug register usage counter */
-		if (ctx->ctx_fl_using_dbreg) {
-			if (pfm_sessions.pfs_sys_use_dbregs =3D 0) {
-				printk("perfmon: invalid release for [%d] sys_use_dbregs=3D0\n", task-=
>pid);
-			} else
-				pfm_sessions.pfs_sys_use_dbregs--;
-		}
-
 		/*
 	 	 * remove any CPU pinning
 	 	 */
 		set_cpus_allowed(task, ctx->ctx_saved_cpus_allowed);
-	} else {
-		pfm_sessions.pfs_task_sessions--;
-	}
-	UNLOCK_PFS();
+	}=20
=20
 	pfm_context_free(ctx);
 	/*=20
@@ -3990,8 +4135,7 @@
 	 * Walk through the list and free the sampling buffer and psb
 	 */
 	while (psb) {
-		DBprintk(("[%d] freeing smpl @%p size %ld\n",=20
-			current->pid, psb->psb_hdr, psb->psb_size));
+		DBprintk(("[%d] freeing smpl @%p size %ld\n", current->pid, psb->psb_hdr=
, psb->psb_size));
=20
 		pfm_rvfree(psb->psb_hdr, psb->psb_size);
 		tmp =3D psb->psb_next;
@@ -4095,16 +4239,16 @@
 		if (ctx && ctx->ctx_notify_task =3D task) {
 			DBprintk(("trying for notifier [%d] in [%d]\n", task->pid, p->pid));
 			/*
-			 * the spinlock is required to take care of a race condition with
-			 * the send_sig_info() call. We must make sure that either the
-			 * send_sig_info() completes using a valid task, or the
-			 * notify_task is cleared before the send_sig_info() can pick up a
-			 * stale value. Note that by the time this function is executed
-			 * the 'task' is already detached from the tasklist. The problem
-			 * is that the notifiers have a direct pointer to it. It is okay
-			 * to send a signal to a task in this stage, it simply will have
-			 * no effect. But it is better than sending to a completely
-			 * destroyed task or worse to a new task using the same
+			 * the spinlock is required to take care of a race condition
+			 * with the send_sig_info() call. We must make sure that=20
+			 * either the send_sig_info() completes using a valid task,
+			 * or the notify_task is cleared before the send_sig_info()
+			 * can pick up a stale value. Note that by the time this
+			 * function is executed the 'task' is already detached from the
+			 * tasklist. The problem is that the notifiers have a direct
+			 * pointer to it. It is okay to send a signal to a task in this
+			 * stage, it simply will have no effect. But it is better than sending
+			 * to a completely destroyed task or worse to a new task using the same
 			 * task_struct address.
 			 */
 			LOCK_CTX(ctx);
@@ -4123,87 +4267,131 @@
 }
=20
 static struct irqaction perfmon_irqaction =3D {
-	.handler =3D	perfmon_interrupt,
+	.handler =3D	pfm_interrupt_handler,
 	.flags =3D	SA_INTERRUPT,
 	.name =3D		"perfmon"
 };
=20
+int
+pfm_install_alternate_syswide_subsystem(pfm_intr_handler_desc_t *hdl)
+{
+	int ret;
+
+	/* some sanity checks */
+	if (hdl =3D NULL || hdl->handler =3D NULL) return -EINVAL;
+
+	/* do the easy test first */
+	if (pfm_alternate_intr_handler) return -EBUSY;
+
+	/* reserve our session */
+	ret =3D pfm_reserve_session(NULL, 1, cpu_online_map);
+	if (ret) return ret;
+
+	if (pfm_alternate_intr_handler) {
+		printk("perfmon: install_alternate, intr_handler not NULL after reserve\=
n");
+		return -EINVAL;
+	}
+
+	pfm_alternate_intr_handler =3D hdl;
+
+	return 0;
+}
+
+int
+pfm_remove_alternate_syswide_subsystem(pfm_intr_handler_desc_t *hdl)
+{
+	if (hdl =3D NULL) return -EINVAL;
+
+	/* cannot remove someone else's handler! */
+	if (pfm_alternate_intr_handler !=3D hdl) return -EINVAL;
+
+	pfm_alternate_intr_handler =3D NULL;
+
+	/*=20
+	 * XXX: assume cpu_online_map has not changed since reservation=20
+	 */
+	pfm_unreserve_session(NULL, 1, cpu_online_map);
+
+	return 0;
+}
=20
 /*
  * perfmon initialization routine, called from the initcall() table
  */
 int __init
-perfmon_init (void)
+pfm_init(void)
 {
-	pal_perf_mon_info_u_t pm_info;
-	s64 status;
+	unsigned int n, n_counters, i;
=20
-	pmu_conf.pfm_is_disabled =3D 1;
+	pmu_conf.disabled =3D 1;
=20
-	printk("perfmon: version %u.%u (sampling format v%u.%u) IRQ %u\n",=20
+	printk("perfmon: version %u.%u IRQ %u\n",=20
 		PFM_VERSION_MAJ,=20
 		PFM_VERSION_MIN,=20
-		PFM_SMPL_VERSION_MAJ,=20
-		PFM_SMPL_VERSION_MIN,=20
 		IA64_PERFMON_VECTOR);
=20
-	if ((status=3Dia64_pal_perf_mon_info(pmu_conf.impl_regs, &pm_info)) !=3D =
0) {
-		printk("perfmon: PAL call failed (%ld), perfmon disabled\n", status);
-		return -1;
-	}
-
-	pmu_conf.perf_ovfl_val =3D (1UL << pm_info.pal_perf_mon_info_s.width) - 1;
 	/*
-	 * XXX: use the pfm_*_desc tables instead and simply verify with PAL
+	 * compute the number of implemented PMD/PMC from the
+	 * description tables
 	 */
-	pmu_conf.max_counters  =3D pm_info.pal_perf_mon_info_s.generic;
-	pmu_conf.num_pmcs      =3D find_num_pm_regs(pmu_conf.impl_regs);
-	pmu_conf.num_pmds      =3D find_num_pm_regs(&pmu_conf.impl_regs[4]);
-
-	printk("perfmon: %u bits counters\n", pm_info.pal_perf_mon_info_s.width);
-
-	printk("perfmon: %lu PMC/PMD pairs, %lu PMCs, %lu PMDs\n",=20
-	       pmu_conf.max_counters, pmu_conf.num_pmcs, pmu_conf.num_pmds);
+	n =3D 0;
+	for (i=3D0; PMC_IS_LAST(i) =3D 0;  i++) {
+		if (PMC_IS_IMPL(i) =3D 0) continue;
+		pmu_conf.impl_pmcs[i>>6] |=3D 1UL << (i&63);
+		n++;
+	}
+	pmu_conf.num_pmcs =3D n;
+
+	n =3D 0; n_counters =3D 0;
+	for (i=3D0; PMD_IS_LAST(i) =3D 0;  i++) {
+		if (PMD_IS_IMPL(i) =3D 0) continue;
+		pmu_conf.impl_pmds[i>>6] |=3D 1UL << (i&63);
+		n++;
+		if (PMD_IS_COUNTING(i)) n_counters++;
+	}
+	pmu_conf.num_pmds      =3D n;
+	pmu_conf.num_counters  =3D n_counters;
+
+	printk("perfmon: %u PMCs, %u PMDs, %u counters (%lu bits)\n",=20
+	       pmu_conf.num_pmcs,=20
+	       pmu_conf.num_pmds,
+	       pmu_conf.num_counters,
+	       ffz(pmu_conf.ovfl_val));
=20
 	/* sanity check */
 	if (pmu_conf.num_pmds >=3D IA64_NUM_PMD_REGS || pmu_conf.num_pmcs >=3D IA=
64_NUM_PMC_REGS) {
-		printk(KERN_ERR "perfmon: not enough pmc/pmd, perfmon is DISABLED\n");
-		return -1; /* no need to continue anyway */
-	}
-
-	if (ia64_pal_debug_info(&pmu_conf.num_ibrs, &pmu_conf.num_dbrs)) {
-		printk(KERN_WARNING "perfmon: unable to get number of debug registers\n"=
);
-		pmu_conf.num_ibrs =3D pmu_conf.num_dbrs =3D 0;
+		printk(KERN_ERR "perfmon: not enough pmc/pmd, perfmon disabled\n");
+		return -1;
 	}
-	/* PAL reports the number of pairs */
-	pmu_conf.num_ibrs <<=3D1;
-	pmu_conf.num_dbrs <<=3D1;
-
-	/*
-	 * setup the register configuration descriptions for the CPU
-	 */
-	pmu_conf.pmc_desc =3D pfm_pmc_desc;
-	pmu_conf.pmd_desc =3D pfm_pmd_desc;
-
-	/* we are all set */
-	pmu_conf.pfm_is_disabled =3D 0;
=20
 	/*
 	 * for now here for debug purposes
 	 */
 	perfmon_dir =3D create_proc_read_entry ("perfmon", 0, 0, perfmon_read_ent=
ry, NULL);
+	if (perfmon_dir =3D NULL) {
+		printk(KERN_ERR "perfmon: cannot create /proc entry, perfmon disabled\n"=
);
+		return -1;=20
+	}
=20
+	/*
+	 * create /proc/perfmon
+	 */
 	pfm_sysctl_header =3D register_sysctl_table(pfm_sysctl_root, 0);
=20
+	/*
+	 * initialize all our spinlocks
+	 */
 	spin_lock_init(&pfm_sessions.pfs_lock);
=20
+	/* we are all set */
+	pmu_conf.disabled =3D 0;
+
 	return 0;
 }
-
-__initcall(perfmon_init);
+__initcall(pfm_init);
=20
 void
-perfmon_init_percpu (void)
+pfm_init_percpu(void)
 {
 	int i;
=20
@@ -4222,17 +4410,17 @@
 	 *
 	 * On McKinley, this code is ineffective until PMC4 is initialized.
 	 */
-	for (i=3D1; (pfm_pmc_desc[i].type & PFM_REG_END) =3D 0;  i++) {
-		if ((pfm_pmc_desc[i].type & PFM_REG_IMPL) =3D 0) continue;
-		ia64_set_pmc(i, pfm_pmc_desc[i].default_value);
+	for (i=3D1; PMC_IS_LAST(i) =3D 0;  i++) {
+		if (PMC_IS_IMPL(i) =3D 0) continue;
+		ia64_set_pmc(i, PMC_DFL_VAL(i));
 	}
-	for (i=3D0; (pfm_pmd_desc[i].type & PFM_REG_END) =3D 0; i++) {
-		if ((pfm_pmd_desc[i].type & PFM_REG_IMPL) =3D 0) continue;
+
+	for (i=3D0; PMD_IS_LAST(i); i++) {
+		if (PMD_IS_IMPL(i) =3D 0) continue;
 		ia64_set_pmd(i, 0UL);
 	}
 	ia64_set_pmc(0,1UL);
 	ia64_srlz_d();
-
 }
=20
 #else /* !CONFIG_PERFMON */
diff -Nru a/arch/ia64/kernel/perfmon_generic.h b/arch/ia64/kernel/perfmon_g=
eneric.h
--- a/arch/ia64/kernel/perfmon_generic.h	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/perfmon_generic.h	Fri Jan 24 20:41:05 2003
@@ -1,10 +1,17 @@
+/*
+ * This file contains the architected PMU register description tables
+ * and pmc checker used by perfmon.c.
+ *
+ * Copyright (C) 2002  Hewlett Packard Co
+ *               Stephane Eranian <eranian@hpl.hp.com>
+ */
 #define RDEP(x)	(1UL<<(x))
=20
-#if defined(CONFIG_ITANIUM) || defined(CONFIG_MCKINLEY)
-#error "This file should only be used when CONFIG_ITANIUM and CONFIG_MCKIN=
LEY are not defined"
+#if defined(CONFIG_ITANIUM) || defined (CONFIG_MCKINLEY)
+#error "This file should not be used when CONFIG_ITANIUM or CONFIG_MCKINLE=
Y is defined"
 #endif
=20
-static pfm_reg_desc_t pmc_desc[PMU_MAX_PMCS]=3D{
+static pfm_reg_desc_t pmc_gen_desc[PMU_MAX_PMCS]=3D{
 /* pmc0  */ { PFM_REG_CONTROL , 0, 0x1UL, -1UL, NULL, NULL, {0UL,0UL, 0UL,=
 0UL}, {0UL,0UL, 0UL, 0UL}},
 /* pmc1  */ { PFM_REG_CONTROL , 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL,=
 0UL}, {0UL,0UL, 0UL, 0UL}},
 /* pmc2  */ { PFM_REG_CONTROL , 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL,=
 0UL}, {0UL,0UL, 0UL, 0UL}},
@@ -13,10 +20,10 @@
 /* pmc5  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {RDEP(5),0UL, =
0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
 /* pmc6  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {RDEP(6),0UL, =
0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
 /* pmc7  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {RDEP(7),0UL, =
0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
-	     { PFM_REG_END     , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}}, /* end =
marker */
+	    { PFM_REG_END     , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}}, /* end m=
arker */
 };
=20
-static pfm_reg_desc_t pmd_desc[PMU_MAX_PMDS]=3D{
+static pfm_reg_desc_t pmd_gen_desc[PMU_MAX_PMDS]=3D{
 /* pmd0  */ { PFM_REG_NOTIMPL , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}},
 /* pmd1  */ { PFM_REG_NOTIMPL , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}},
 /* pmd2  */ { PFM_REG_NOTIMPL , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}},
@@ -25,5 +32,17 @@
 /* pmd5  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL,=
 0UL}, {RDEP(5),0UL, 0UL, 0UL}},
 /* pmd6  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL,=
 0UL}, {RDEP(6),0UL, 0UL, 0UL}},
 /* pmd7  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL,=
 0UL}, {RDEP(7),0UL, 0UL, 0UL}},
-	     { PFM_REG_END     , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}}, /* end =
marker */
+	    { PFM_REG_END     , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}}, /* end m=
arker */
+};
+
+/*
+ * impl_pmcs, impl_pmds are computed at runtime to minimize errors!
+ */
+static pmu_config_t pmu_conf=3D{
+	disabled:	1,
+	ovfl_val:	(1UL << 32) - 1,
+	num_ibrs:	8,
+	num_dbrs:	8,
+	pmd_desc:	pfm_gen_pmd_desc,
+	pmc_desc:	pfm_gen_pmc_desc
 };
diff -Nru a/arch/ia64/kernel/perfmon_itanium.h b/arch/ia64/kernel/perfmon_i=
tanium.h
--- a/arch/ia64/kernel/perfmon_itanium.h	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/perfmon_itanium.h	Fri Jan 24 20:41:05 2003
@@ -15,7 +15,7 @@
 static int pfm_ita_pmc_check(struct task_struct *task, unsigned int cnum, =
unsigned long *val, struct pt_regs *regs);
 static int pfm_write_ibr_dbr(int mode, struct task_struct *task, void *arg=
, int count, struct pt_regs *regs);
=20
-static pfm_reg_desc_t pfm_pmc_desc[PMU_MAX_PMCS]=3D{
+static pfm_reg_desc_t pfm_ita_pmc_desc[PMU_MAX_PMCS]=3D{
 /* pmc0  */ { PFM_REG_CONTROL , 0, 0x1UL, -1UL, NULL, NULL, {0UL,0UL, 0UL,=
 0UL}, {0UL,0UL, 0UL, 0UL}},
 /* pmc1  */ { PFM_REG_CONTROL , 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL,=
 0UL}, {0UL,0UL, 0UL, 0UL}},
 /* pmc2  */ { PFM_REG_CONTROL , 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL,=
 0UL}, {0UL,0UL, 0UL, 0UL}},
@@ -33,7 +33,7 @@
 	    { PFM_REG_END     , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}}, /* end m=
arker */
 };
=20
-static pfm_reg_desc_t pfm_pmd_desc[PMU_MAX_PMDS]=3D{
+static pfm_reg_desc_t pfm_ita_pmd_desc[PMU_MAX_PMDS]=3D{
 /* pmd0  */ { PFM_REG_BUFFER  , 0, 0UL, -1UL, NULL, NULL, {RDEP(1),0UL, 0U=
L, 0UL}, {RDEP(10),0UL, 0UL, 0UL}},
 /* pmd1  */ { PFM_REG_BUFFER  , 0, 0UL, -1UL, NULL, NULL, {RDEP(0),0UL, 0U=
L, 0UL}, {RDEP(10),0UL, 0UL, 0UL}},
 /* pmd2  */ { PFM_REG_BUFFER  , 0, 0UL, -1UL, NULL, NULL, {RDEP(3)|RDEP(17=
),0UL, 0UL, 0UL}, {RDEP(11),0UL, 0UL, 0UL}},
@@ -54,6 +54,19 @@
 /* pmd17 */ { PFM_REG_BUFFER  , 0, 0UL, -1UL, NULL, NULL, {RDEP(2)|RDEP(3)=
,0UL, 0UL, 0UL}, {RDEP(11),0UL, 0UL, 0UL}},
 	    { PFM_REG_END     , 0, 0UL, -1UL, NULL, NULL, {0,}, {0,}}, /* end mar=
ker */
 };
+
+/*
+ * impl_pmcs, impl_pmds are computed at runtime to minimize errors!
+ */
+static pmu_config_t pmu_conf=3D{
+	disabled:	1,
+	ovfl_val:	(1UL << 32) - 1,
+	num_ibrs:	8,
+	num_dbrs:	8,
+	pmd_desc:	pfm_ita_pmd_desc,
+	pmc_desc:	pfm_ita_pmc_desc
+};
+
=20
 static int
 pfm_ita_pmc_check(struct task_struct *task, unsigned int cnum, unsigned lo=
ng *val, struct pt_regs *regs)
diff -Nru a/arch/ia64/kernel/perfmon_mckinley.h b/arch/ia64/kernel/perfmon_=
mckinley.h
--- a/arch/ia64/kernel/perfmon_mckinley.h	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/perfmon_mckinley.h	Fri Jan 24 20:41:05 2003
@@ -16,7 +16,7 @@
 static int pfm_mck_pmc_check(struct task_struct *task, unsigned int cnum, =
unsigned long *val, struct pt_regs *regs);
 static int pfm_write_ibr_dbr(int mode, struct task_struct *task, void *arg=
, int count, struct pt_regs *regs);
=20
-static pfm_reg_desc_t pfm_pmc_desc[PMU_MAX_PMCS]=3D{
+static pfm_reg_desc_t pfm_mck_pmc_desc[PMU_MAX_PMCS]=3D{
 /* pmc0  */ { PFM_REG_CONTROL , 0, 0x1UL, -1UL, NULL, NULL, {0UL,0UL, 0UL,=
 0UL}, {0UL,0UL, 0UL, 0UL}},
 /* pmc1  */ { PFM_REG_CONTROL , 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL,=
 0UL}, {0UL,0UL, 0UL, 0UL}},
 /* pmc2  */ { PFM_REG_CONTROL , 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL,=
 0UL}, {0UL,0UL, 0UL, 0UL}},
@@ -36,7 +36,7 @@
 	    { PFM_REG_END     , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}}, /* end m=
arker */
 };
=20
-static pfm_reg_desc_t pfm_pmd_desc[PMU_MAX_PMDS]=3D{
+static pfm_reg_desc_t pfm_mck_pmd_desc[PMU_MAX_PMDS]=3D{
 /* pmd0  */ { PFM_REG_BUFFER  , 0, 0x0UL, -1UL, NULL, NULL, {RDEP(1),0UL, =
0UL, 0UL}, {RDEP(10),0UL, 0UL, 0UL}},
 /* pmd1  */ { PFM_REG_BUFFER  , 0, 0x0UL, -1UL, NULL, NULL, {RDEP(0),0UL, =
0UL, 0UL}, {RDEP(10),0UL, 0UL, 0UL}},
 /* pmd2  */ { PFM_REG_BUFFER  , 0, 0x0UL, -1UL, NULL, NULL, {RDEP(3)|RDEP(=
17),0UL, 0UL, 0UL}, {RDEP(11),0UL, 0UL, 0UL}},
@@ -57,6 +57,19 @@
 /* pmd17 */ { PFM_REG_BUFFER  , 0, 0x0UL, -1UL, NULL, NULL, {RDEP(2)|RDEP(=
3),0UL, 0UL, 0UL}, {RDEP(11),0UL, 0UL, 0UL}},
 	    { PFM_REG_END     , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}}, /* end m=
arker */
 };
+
+/*
+ * impl_pmcs, impl_pmds are computed at runtime to minimize errors!
+ */
+static pmu_config_t pmu_conf=3D{
+	disabled:	1,
+	ovfl_val:	(1UL << 47) - 1,
+	num_ibrs:	8,
+	num_dbrs:	8,
+	pmd_desc:	pfm_mck_pmd_desc,
+	pmc_desc:	pfm_mck_pmc_desc
+};
+
=20
 /*
  * PMC reserved fields must have their power-up values preserved
diff -Nru a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
--- a/arch/ia64/kernel/process.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/process.c	Fri Jan 24 20:41:05 2003
@@ -1,7 +1,7 @@
 /*
  * Architecture-specific setup.
  *
- * Copyright (C) 1998-2002 Hewlett-Packard Co
+ * Copyright (C) 1998-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #define __KERNEL_SYSCALLS__	/* see <asm/unistd.h> */
@@ -96,7 +96,7 @@
 {
 	unsigned long ip =3D regs->cr_iip + ia64_psr(regs)->ri;
=20
-	printk("\nPid: %d, comm: %20s\n", current->pid, current->comm);
+	printk("\nPid: %d, CPU %d, comm: %20s\n", current->pid, smp_processor_id(=
), current->comm);
 	printk("psr : %016lx ifs : %016lx ip  : [<%016lx>]    %s\n",
 	       regs->cr_ipsr, regs->cr_ifs, ip, print_tainted());
 	print_symbol("ip is at %s\n", ip);
@@ -144,6 +144,15 @@
 void
 do_notify_resume_user (sigset_t *oldset, struct sigscratch *scr, long in_s=
yscall)
 {
+#ifdef CONFIG_FSYS
+	if (fsys_mode(current, &scr->pt)) {
+		/* defer signal-handling etc. until we return to privilege-level 0.  */
+		if (!ia64_psr(&scr->pt)->lp)
+			ia64_psr(&scr->pt)->lp =3D 1;
+		return;
+	}
+#endif
+
 #ifdef CONFIG_PERFMON
 	if (current->thread.pfm_ovfl_block_reset)
 		pfm_ovfl_block_reset();
@@ -198,6 +207,10 @@
 void
 ia64_save_extra (struct task_struct *task)
 {
+#ifdef CONFIG_PERFMON
+	unsigned long info;
+#endif
+
 	if ((task->thread.flags & IA64_THREAD_DBG_VALID) !=3D 0)
 		ia64_save_debug_regs(&task->thread.dbr[0]);
=20
@@ -205,8 +218,9 @@
 	if ((task->thread.flags & IA64_THREAD_PM_VALID) !=3D 0)
 		pfm_save_regs(task);
=20
-	if (__get_cpu_var(pfm_syst_wide))
-		pfm_syst_wide_update_task(task, 0);
+	info =3D __get_cpu_var(pfm_syst_info);
+	if (info & PFM_CPUINFO_SYST_WIDE)
+		pfm_syst_wide_update_task(task, info, 0);
 #endif
=20
 #ifdef CONFIG_IA32_SUPPORT
@@ -218,6 +232,10 @@
 void
 ia64_load_extra (struct task_struct *task)
 {
+#ifdef CONFIG_PERFMON
+	unsigned long info;
+#endif
+
 	if ((task->thread.flags & IA64_THREAD_DBG_VALID) !=3D 0)
 		ia64_load_debug_regs(&task->thread.dbr[0]);
=20
@@ -225,8 +243,9 @@
 	if ((task->thread.flags & IA64_THREAD_PM_VALID) !=3D 0)
 		pfm_load_regs(task);
=20
-	if (__get_cpu_var(pfm_syst_wide))=20
-		pfm_syst_wide_update_task(task, 1);
+	info =3D __get_cpu_var(pfm_syst_info);
+	if (info & PFM_CPUINFO_SYST_WIDE)=20
+		pfm_syst_wide_update_task(task, info, 1);
 #endif
=20
 #ifdef CONFIG_IA32_SUPPORT
diff -Nru a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
--- a/arch/ia64/kernel/ptrace.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/ptrace.c	Fri Jan 24 20:41:05 2003
@@ -833,21 +833,19 @@
 			return -1;
 		}
 #ifdef CONFIG_PERFMON
-		/*=20
-		 * Check if debug registers are used=20
-		 * by perfmon. This test must be done once we know that we can
-		 * do the operation, i.e. the arguments are all valid, but before
-		 * we start modifying the state.
+		/*
+		 * Check if debug registers are used by perfmon. This test must be done
+		 * once we know that we can do the operation, i.e. the arguments are all
+		 * valid, but before we start modifying the state.
 		 *
-		 * Perfmon needs to keep a count of how many processes are
-		 * trying to modify the debug registers for system wide monitoring
-		 * sessions.
+		 * Perfmon needs to keep a count of how many processes are trying to
+		 * modify the debug registers for system wide monitoring sessions.
 		 *
-		 * We also include read access here, because they may cause=20
-		 * the PMU-installed debug register state (dbr[], ibr[]) to
-		 * be reset. The two arrays are also used by perfmon, but
-		 * we do not use IA64_THREAD_DBG_VALID. The registers are restored
-		 * by the PMU context switch code.
+		 * We also include read access here, because they may cause the
+		 * PMU-installed debug register state (dbr[], ibr[]) to be reset. The two
+		 * arrays are also used by perfmon, but we do not use
+		 * IA64_THREAD_DBG_VALID. The registers are restored by the PMU context
+		 * switch code.
 		 */
 		if (pfm_use_debug_registers(child)) return -1;
 #endif
diff -Nru a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/setup.c	Fri Jan 24 20:41:05 2003
@@ -423,7 +423,7 @@
 #ifdef CONFIG_ACPI_BOOT
 	acpi_boot_init(*cmdline_p);
 #endif
-#ifdef CONFIG_SERIAL_HCDP
+#ifdef CONFIG_SERIAL_8250_HCDP
 	if (efi.hcdp) {
 		void setup_serial_hcdp(void *);
=20
diff -Nru a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
--- a/arch/ia64/kernel/smpboot.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/smpboot.c	Fri Jan 24 20:41:05 2003
@@ -265,7 +265,7 @@
 	extern void ia64_init_itm(void);
=20
 #ifdef CONFIG_PERFMON
-	extern void perfmon_init_percpu(void);
+	extern void pfm_init_percpu(void);
 #endif
=20
 	cpuid =3D smp_processor_id();
@@ -300,7 +300,7 @@
 #endif
=20
 #ifdef CONFIG_PERFMON
-	perfmon_init_percpu();
+	pfm_init_percpu();
 #endif
=20
 	local_irq_enable();
diff -Nru a/arch/ia64/kernel/sys_ia64.c b/arch/ia64/kernel/sys_ia64.c
--- a/arch/ia64/kernel/sys_ia64.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/sys_ia64.c	Fri Jan 24 20:41:05 2003
@@ -20,7 +20,6 @@
 #include <asm/shmparam.h>
 #include <asm/uaccess.h>
=20
-
 unsigned long
 arch_get_unmapped_area (struct file *filp, unsigned long addr, unsigned lo=
ng len,
 			unsigned long pgoff, unsigned long flags)
@@ -31,6 +30,20 @@
=20
 	if (len > RGN_MAP_LIMIT)
 		return -ENOMEM;
+
+#ifdef CONFIG_HUGETLB_PAGE
+#define COLOR_HALIGN(addr) ((addr + HPAGE_SIZE - 1) & ~(HPAGE_SIZE - 1))
+#define TASK_HPAGE_BASE ((REGION_HPAGE << REGION_SHIFT) | HPAGE_SIZE)
+	if (filp && is_file_hugepages(filp)) {
+		if ((REGION_NUMBER(addr) !=3D REGION_HPAGE) || (addr & (HPAGE_SIZE -1)))
+			addr =3D TASK_HPAGE_BASE;
+		addr =3D COLOR_HALIGN(addr);
+	}
+	else {
+		if (REGION_NUMBER(addr) =3D REGION_HPAGE)
+			addr =3D 0;
+	}
+#endif
 	if (!addr)
 		addr =3D TASK_UNMAPPED_BASE;
=20
diff -Nru a/arch/ia64/kernel/traps.c b/arch/ia64/kernel/traps.c
--- a/arch/ia64/kernel/traps.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/traps.c	Fri Jan 24 20:41:05 2003
@@ -1,7 +1,7 @@
 /*
  * Architecture-specific trap handling.
  *
- * Copyright (C) 1998-2002 Hewlett-Packard Co
+ * Copyright (C) 1998-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * 05/12/00 grao <goutham.rao@intel.com> : added isr in siginfo for SIGFPE
@@ -142,7 +142,7 @@
=20
 	switch (break_num) {
 	      case 0: /* unknown error (used by GCC for __builtin_abort()) */
-		die_if_kernel("bad break", regs, break_num);
+		die_if_kernel("bugcheck!", regs, break_num);
 		sig =3D SIGILL; code =3D ILL_ILLOPC;
 		break;
=20
@@ -524,6 +524,25 @@
 	      case 29: /* Debug */
 	      case 35: /* Taken Branch Trap */
 	      case 36: /* Single Step Trap */
+#ifdef CONFIG_FSYS
+		if (fsys_mode(current, regs)) {
+			extern char syscall_via_break[], __start_gate_section[];
+			/*
+			 * Got a trap in fsys-mode: Taken Branch Trap and Single Step trap
+			 * need special handling; Debug trap is not supposed to happen.
+			 */
+			if (unlikely(vector =3D 29)) {
+				die("Got debug trap in fsys-mode---not supposed to happen!",
+				    regs, 0);
+				return;
+			}
+			/* re-do the system call via break 0x100000: */
+			regs->cr_iip =3D GATE_ADDR + (syscall_via_break - __start_gate_section);
+			ia64_psr(regs)->ri =3D 0;
+			ia64_psr(regs)->cpl =3D 3;
+			return;
+		}
+#endif
 		switch (vector) {
 		      case 29:
 			siginfo.si_code =3D TRAP_HWBKPT;
@@ -563,19 +582,31 @@
 		}
 		return;
=20
-	      case 34:		/* Unimplemented Instruction Address Trap */
-		if (user_mode(regs)) {
-			siginfo.si_signo =3D SIGILL;
-			siginfo.si_code =3D ILL_BADIADDR;
-			siginfo.si_errno =3D 0;
-			siginfo.si_flags =3D 0;
-			siginfo.si_isr =3D 0;
-			siginfo.si_imm =3D 0;
-			siginfo.si_addr =3D (void *) (regs->cr_iip + ia64_psr(regs)->ri);
-			force_sig_info(SIGILL, &siginfo, current);
+	      case 34:
+		if (isr & 0x2) {
+			/* Lower-Privilege Transfer Trap */
+			/*
+			 * Just clear PSR.lp and then return immediately: all the
+			 * interesting work (e.g., signal delivery is done in the kernel
+			 * exit path).
+			 */
+			ia64_psr(regs)->lp =3D 0;
 			return;
+		} else {
+			/* Unimplemented Instr. Address Trap */
+			if (user_mode(regs)) {
+				siginfo.si_signo =3D SIGILL;
+				siginfo.si_code =3D ILL_BADIADDR;
+				siginfo.si_errno =3D 0;
+				siginfo.si_flags =3D 0;
+				siginfo.si_isr =3D 0;
+				siginfo.si_imm =3D 0;
+				siginfo.si_addr =3D (void *) (regs->cr_iip + ia64_psr(regs)->ri);
+				force_sig_info(SIGILL, &siginfo, current);
+				return;
+			}
+			sprintf(buf, "Unimplemented Instruction Address fault");
 		}
-		sprintf(buf, "Unimplemented Instruction Address fault");
 		break;
=20
 	      case 45:
diff -Nru a/arch/ia64/kernel/unaligned.c b/arch/ia64/kernel/unaligned.c
--- a/arch/ia64/kernel/unaligned.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/unaligned.c	Fri Jan 24 20:41:05 2003
@@ -331,12 +331,8 @@
 		return;
 	}
=20
-	/*
-	 * Avoid using user_mode() here: with "epc", we cannot use the privilege =
level to
-	 * infer whether the interrupt task was running on the kernel backing sto=
re.
-	 */
-	if (regs->r12 >=3D TASK_SIZE) {
-		DPRINT("ignoring kernel write to r%lu; register isn't on the RBS!", r1);
+	if (!user_stack(current, regs)) {
+		DPRINT("ignoring kernel write to r%lu; register isn't on the kernel RBS!=
", r1);
 		return;
 	}
=20
@@ -406,11 +402,7 @@
 		return;
 	}
=20
-	/*
-	 * Avoid using user_mode() here: with "epc", we cannot use the privilege =
level to
-	 * infer whether the interrupt task was running on the kernel backing sto=
re.
-	 */
-	if (regs->r12 >=3D TASK_SIZE) {
+	if (!user_stack(current, regs)) {
 		DPRINT("ignoring kernel read of r%lu; register isn't on the RBS!", r1);
 		goto fail;
 	}
@@ -1302,12 +1294,12 @@
 void
 ia64_handle_unaligned (unsigned long ifa, struct pt_regs *regs)
 {
-	struct exception_fixup fix =3D { 0 };
 	struct ia64_psr *ipsr =3D ia64_psr(regs);
 	mm_segment_t old_fs =3D get_fs();
 	unsigned long bundle[2];
 	unsigned long opcode;
 	struct siginfo si;
+	const struct exception_table_entry *eh =3D NULL;
 	union {
 		unsigned long l;
 		load_store_t insn;
@@ -1325,10 +1317,9 @@
 	 * user-level unaligned accesses.  Otherwise, a clever program could tric=
k this
 	 * handler into reading an arbitrary kernel addresses...
 	 */
-	if (!user_mode(regs)) {
-		fix =3D SEARCH_EXCEPTION_TABLE(regs);
-	}
-	if (user_mode(regs) || fix.cont) {
+	if (!user_mode(regs))
+		eh =3D SEARCH_EXCEPTION_TABLE(regs);
+	if (user_mode(regs) || eh) {
 		if ((current->thread.flags & IA64_THREAD_UAC_SIGBUS) !=3D 0)
 			goto force_sigbus;
=20
@@ -1494,8 +1485,8 @@
   failure:
 	/* something went wrong... */
 	if (!user_mode(regs)) {
-		if (fix.cont) {
-			handle_exception(regs, fix);
+		if (eh) {
+			handle_exception(regs, eh);
 			goto done;
 		}
 		die_if_kernel("error during unaligned kernel access\n", regs, ret);
diff -Nru a/arch/ia64/kernel/unwind.c b/arch/ia64/kernel/unwind.c
--- a/arch/ia64/kernel/unwind.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/kernel/unwind.c	Fri Jan 24 20:41:06 2003
@@ -1997,16 +1997,18 @@
 {
 	extern char __start_gate_section[], __stop_gate_section[];
 	unsigned long *lp, start, end, segbase =3D unw.kernel_table.segment_base;
-	const struct unw_table_entry *entry, *first;
+	const struct unw_table_entry *entry, *first, *unw_table_end;
+	extern int ia64_unw_end;
 	size_t info_size, size;
 	char *info;
=20
 	start =3D (unsigned long) __start_gate_section - segbase;
 	end   =3D (unsigned long) __stop_gate_section - segbase;
+	unw_table_end =3D (struct unw_table_entry *) &ia64_unw_end;
 	size  =3D 0;
 	first =3D lookup(&unw.kernel_table, start);
=20
-	for (entry =3D first; entry->start_offset < end; ++entry)
+	for (entry =3D first; entry < unw_table_end && entry->start_offset < end;=
 ++entry)
 		size +=3D 3*8 + 8 + 8*UNW_LENGTH(*(u64 *) (segbase + entry->info_offset)=
);
 	size +=3D 8;	/* reserve space for "end of table" marker */
=20
@@ -2021,7 +2023,7 @@
 	lp =3D unw.gate_table;
 	info =3D (char *) unw.gate_table + size;
=20
-	for (entry =3D first; entry->start_offset < end; ++entry, lp +=3D 3) {
+	for (entry =3D first; entry < unw_table_end && entry->start_offset < end;=
 ++entry, lp +=3D 3) {
 		info_size =3D 8 + 8*UNW_LENGTH(*(u64 *) (segbase + entry->info_offset));
 		info -=3D info_size;
 		memcpy(info, (char *) segbase + entry->info_offset, info_size);
diff -Nru a/arch/ia64/lib/memcpy_mck.S b/arch/ia64/lib/memcpy_mck.S
--- a/arch/ia64/lib/memcpy_mck.S	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/lib/memcpy_mck.S	Fri Jan 24 20:41:05 2003
@@ -159,7 +159,7 @@
 	mov	ar.ec=3D2
 (p10)	br.dpnt.few .aligned_src_tail
 	;;
-	.align 32
+//	.align 32
 1:
 EX(.ex_handler, (p16)	ld8	r34=3D[src0],16)
 EK(.ex_handler, (p16)	ld8	r38=3D[src1],16)
@@ -316,7 +316,7 @@
 (p7)	mov	ar.lc =3D r21
 (p8)	mov	ar.lc =3D r0
 	;;
-	.align 32
+//	.align 32
 1:	lfetch.fault	  [src_pre_mem], 128
 	lfetch.fault.excl [dst_pre_mem], 128
 	br.cloop.dptk.few 1b
@@ -522,7 +522,7 @@
 		 shrp	r21=3Dr22,r38,shift;	/* speculative work */			\
 		 br.sptk.few .unaligned_src_tail /* branch out of jump table */		\
 		 ;;
-	.align 32
+//	.align 32
 .jump_table:
 	COPYU(8)	// unaligned cases
 .jmp1:
diff -Nru a/arch/ia64/lib/memset.S b/arch/ia64/lib/memset.S
--- a/arch/ia64/lib/memset.S	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/lib/memset.S	Fri Jan 24 20:41:05 2003
@@ -125,7 +125,7 @@
 (p_zr)	br.cond.dptk.many .l1b			// Jump to use stf.spill
 ;; }
=20
-	.align 32 // -------------------------- //  L1A: store ahead into cache l=
ines; fill later
+//	.align 32 // -------------------------- //  L1A: store ahead into cache=
 lines; fill later
 { .mmi
 	and	tmp =3D -(LINE_SIZE), cnt		// compute end of range
 	mov	ptr9 =3D ptr1			// used for prefetching
@@ -194,7 +194,7 @@
 	br.cond.dpnt.many  .move_bytes_from_alignment	// Branch no. 3
 ;; }
=20
-	.align 32
+//	.align 32
 .l1b:	// ------------------------------------ //  L1B: store ahead into ca=
che lines; fill later
 { .mmi
 	and	tmp =3D -(LINE_SIZE), cnt		// compute end of range
@@ -261,7 +261,7 @@
 	and	cnt =3D 0x1f, cnt			// compute the remaining cnt
 	mov.i   ar.lc =3D loopcnt
 ;; }
-	.align 32
+//	.align 32
 .l2:	// ------------------------------------ //  L2A:  store 32B in 2 cycl=
es
 { .mmb
 	stf8	[ptr1] =3D fvalue, 8
diff -Nru a/arch/ia64/mm/extable.c b/arch/ia64/mm/extable.c
--- a/arch/ia64/mm/extable.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/mm/extable.c	Fri Jan 24 20:41:05 2003
@@ -10,20 +10,19 @@
 #include <asm/uaccess.h>
 #include <asm/module.h>
=20
-extern const struct exception_table_entry __start___ex_table[];
-extern const struct exception_table_entry __stop___ex_table[];
-
-static inline const struct exception_table_entry *
-search_one_table (const struct exception_table_entry *first,
-		  const struct exception_table_entry *last,
-		  unsigned long ip, unsigned long gp)
+const struct exception_table_entry *
+search_extable (const struct exception_table_entry *first,
+		const struct exception_table_entry *last,
+		unsigned long ip)
 {
-        while (first <=3D last) {
-		const struct exception_table_entry *mid;
-		long diff;
+	const struct exception_table_entry *mid;
+	unsigned long mid_ip;
+	long diff;
=20
+        while (first <=3D last) {
 		mid =3D &first[(last - first)/2];
-		diff =3D (mid->addr + gp) - ip;
+		mid_ip =3D (u64) &mid->addr + mid->addr;
+		diff =3D mid_ip - ip;
                 if (diff =3D 0)
                         return mid;
                 else if (diff < 0)
@@ -34,50 +33,14 @@
         return 0;
 }
=20
-#ifndef CONFIG_MODULES
-register unsigned long main_gp __asm__("gp");
-#endif
-
-struct exception_fixup
-search_exception_table (unsigned long addr)
-{
-	const struct exception_table_entry *entry;
-	struct exception_fixup fix =3D { 0 };
-
-#ifndef CONFIG_MODULES
-	/* There is only the kernel to search.  */
-	entry =3D search_one_table(__start___ex_table, __stop___ex_table - 1, add=
r, main_gp);
-	if (entry)
-		fix.cont =3D entry->cont + main_gp;
-	return fix;
-#else
-	struct archdata *archdata;
-	struct module *mp;
-
-	/* The kernel is the last "module" -- no need to treat it special. */
-	for (mp =3D module_list; mp; mp =3D mp->next) {
-		if (!mp->ex_table_start)
-			continue;
-		archdata =3D (struct archdata *) mp->archdata_start;
-		if (!archdata)
-			continue;
-		entry =3D search_one_table(mp->ex_table_start, mp->ex_table_end - 1,
-					 addr, (unsigned long) archdata->gp);
-		if (entry) {
-			fix.cont =3D entry->cont + (unsigned long) archdata->gp;
-			return fix;
-		}
-	}
-#endif
-	return fix;
-}
-
 void
-handle_exception (struct pt_regs *regs, struct exception_fixup fix)
+handle_exception (struct pt_regs *regs, const struct exception_table_entry=
 *e)
 {
+	long fix =3D (u64) &e->cont + e->cont;
+
 	regs->r8 =3D -EFAULT;
-	if (fix.cont & 4)
+	if (fix & 4)
 		regs->r9 =3D 0;
-	regs->cr_iip =3D (long) fix.cont & ~0xf;
-	ia64_psr(regs)->ri =3D fix.cont & 0x3;		/* set continuation slot number */
+	regs->cr_iip =3D fix & ~0xf;
+	ia64_psr(regs)->ri =3D fix & 0x3;		/* set continuation slot number */
 }
diff -Nru a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
--- a/arch/ia64/mm/fault.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/mm/fault.c	Fri Jan 24 20:41:05 2003
@@ -58,6 +58,18 @@
 	if (in_interrupt() || !mm)
 		goto no_context;
=20
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+	/*
+	 * If fault is in region 5 and we are in the kernel, we may already
+	 * have the mmap_sem (pfn_valid macro is called during mmap). There
+	 * is no vma for region 5 addr's anyway, so skip getting the semaphore
+	 * and go directly to the exception handling code.
+	 */
+
+	if ((REGION_NUMBER(address) =3D 5) && !user_mode(regs))
+		goto bad_area_no_up;
+#endif
+
 	down_read(&mm->mmap_sem);
=20
 	vma =3D find_vma_prev(mm, address, &prev_vma);
@@ -139,6 +151,9 @@
=20
   bad_area:
 	up_read(&mm->mmap_sem);
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+  bad_area_no_up:
+#endif
 	if ((isr & IA64_ISR_SP)
 	    || ((isr & IA64_ISR_NA) && (isr & IA64_ISR_CODE_MASK) =3D IA64_ISR_CO=
DE_LFETCH))
 	{
diff -Nru a/arch/ia64/mm/hugetlbpage.c b/arch/ia64/mm/hugetlbpage.c
--- a/arch/ia64/mm/hugetlbpage.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/mm/hugetlbpage.c	Fri Jan 24 20:41:05 2003
@@ -12,71 +12,42 @@
 #include <linux/pagemap.h>
 #include <linux/smp_lock.h>
 #include <linux/slab.h>
-
 #include <asm/mman.h>
 #include <asm/pgalloc.h>
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
=20
-static struct vm_operations_struct hugetlb_vm_ops;
-struct list_head htlbpage_freelist;
-spinlock_t htlbpage_lock =3D SPIN_LOCK_UNLOCKED;
-extern long htlbpagemem;
+#include <linux/sysctl.h>
+
+static long    htlbpagemem;
+int     htlbpage_max;
+static long    htlbzone_pages;
=20
-static void zap_hugetlb_resources (struct vm_area_struct *);
+struct vm_operations_struct hugetlb_vm_ops;
+static LIST_HEAD(htlbpage_freelist);
+static spinlock_t htlbpage_lock =3D SPIN_LOCK_UNLOCKED;
=20
-static struct page *
-alloc_hugetlb_page (void)
+static struct page *alloc_hugetlb_page(void)
 {
-	struct list_head *curr, *head;
+	int i;
 	struct page *page;
=20
 	spin_lock(&htlbpage_lock);
-
-	head =3D &htlbpage_freelist;
-	curr =3D head->next;
-
-	if (curr =3D head) {
+	if (list_empty(&htlbpage_freelist)) {
 		spin_unlock(&htlbpage_lock);
 		return NULL;
 	}
-	page =3D list_entry(curr, struct page, list);
-	list_del(curr);
+
+	page =3D list_entry(htlbpage_freelist.next, struct page, list);
+	list_del(&page->list);
 	htlbpagemem--;
 	spin_unlock(&htlbpage_lock);
 	set_page_count(page, 1);
-	memset(page_address(page), 0, HPAGE_SIZE);
+	for (i =3D 0; i < (HPAGE_SIZE/PAGE_SIZE); ++i)
+		clear_highpage(&page[i]);
 	return page;
 }
=20
-static void
-free_hugetlb_page (struct page *page)
-{
-	spin_lock(&htlbpage_lock);
-	if ((page->mapping !=3D NULL) && (page_count(page) =3D 2)) {
-		struct inode *inode =3D page->mapping->host;
-		int i;
-
-		ClearPageDirty(page);
-		remove_from_page_cache(page);
-		set_page_count(page, 1);
-		if ((inode->i_size -=3D HPAGE_SIZE) =3D 0) {
-			for (i =3D 0; i < MAX_ID; i++)
-				if (htlbpagek[i].key =3D inode->i_ino) {
-					htlbpagek[i].key =3D 0;
-					htlbpagek[i].in =3D NULL;
-					break;
-				}
-			kfree(inode);
-		}
-	}
-	if (put_page_testzero(page)) {
-		list_add(&page->list, &htlbpage_freelist);
-		htlbpagemem++;
-	}
-	spin_unlock(&htlbpage_lock);
-}
-
 static pte_t *
 huge_pte_alloc (struct mm_struct *mm, unsigned long addr)
 {
@@ -126,63 +97,8 @@
 	return;
 }
=20
-static int
-anon_get_hugetlb_page (struct mm_struct *mm, struct vm_area_struct *vma,
-		       int write_access, pte_t * page_table)
-{
-	struct page *page;
-
-	page =3D alloc_hugetlb_page();
-	if (page =3D NULL)
-		return -1;
-	set_huge_pte(mm, vma, page, page_table, write_access);
-	return 1;
-}
-
-static int
-make_hugetlb_pages_present (unsigned long addr, unsigned long end, int fla=
gs)
-{
-	int write;
-	struct mm_struct *mm =3D current->mm;
-	struct vm_area_struct *vma;
-	pte_t *pte;
-
-	vma =3D find_vma(mm, addr);
-	if (!vma)
-		goto out_error1;
-
-	write =3D (vma->vm_flags & VM_WRITE) !=3D 0;
-	if ((vma->vm_end - vma->vm_start) & (HPAGE_SIZE - 1))
-		goto out_error1;
-	spin_lock(&mm->page_table_lock);
-	do {
-		pte =3D huge_pte_alloc(mm, addr);
-		if ((pte) && (pte_none(*pte))) {
-			if (anon_get_hugetlb_page(mm, vma, write ? VM_WRITE : VM_READ, pte) =3D=
 -1)
-				goto out_error;
-		} else
-			goto out_error;
-		addr +=3D HPAGE_SIZE;
-	} while (addr < end);
-	spin_unlock(&mm->page_table_lock);
-	vma->vm_flags |=3D (VM_HUGETLB | VM_RESERVED);
-	if (flags & MAP_PRIVATE)
-		vma->vm_flags |=3D VM_DONTCOPY;
-	vma->vm_ops =3D &hugetlb_vm_ops;
-	return 0;
-out_error:
-	if (addr > vma->vm_start) {
-		vma->vm_end =3D addr;
-		zap_hugetlb_resources(vma);
-		vma->vm_end =3D end;
-	}
-	spin_unlock(&mm->page_table_lock);
-out_error1:
-	return -1;
-}
-
-int
-copy_hugetlb_page_range (struct mm_struct *dst, struct mm_struct *src, str=
uct vm_area_struct *vma)
+int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
+			struct vm_area_struct *vma)
 {
 	pte_t *src_pte, *dst_pte, entry;
 	struct page *ptepage;
@@ -202,15 +118,14 @@
 		addr +=3D HPAGE_SIZE;
 	}
 	return 0;
-
-      nomem:
+nomem:
 	return -ENOMEM;
 }
=20
 int
-follow_hugetlb_page (struct mm_struct *mm, struct vm_area_struct *vma,
-		     struct page **pages, struct vm_area_struct **vmas,
-		     unsigned long *st, int *length, int i)
+follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
+		    struct page **pages, struct vm_area_struct **vmas,
+		    unsigned long *st, int *length, int i)
 {
 	pte_t *ptep, pte;
 	unsigned long start =3D *st;
@@ -234,8 +149,8 @@
 		i++;
 		len--;
 		start +=3D PAGE_SIZE;
-		if (((start & HPAGE_MASK) =3D pstart) && len
-		    && (start < vma->vm_end))
+		if (((start & HPAGE_MASK) =3D pstart) && len &&
+				(start < vma->vm_end))
 			goto back1;
 	} while (len && start < vma->vm_end);
 	*length =3D len;
@@ -243,51 +158,149 @@
 	return i;
 }
=20
-static void
-zap_hugetlb_resources (struct vm_area_struct *mpnt)
+void free_huge_page(struct page *page)
+{
+	BUG_ON(page_count(page));
+	BUG_ON(page->mapping);
+
+	INIT_LIST_HEAD(&page->list);
+
+	spin_lock(&htlbpage_lock);
+	list_add(&page->list, &htlbpage_freelist);
+	htlbpagemem++;
+	spin_unlock(&htlbpage_lock);
+}
+
+void huge_page_release(struct page *page)
 {
-	struct mm_struct *mm =3D mpnt->vm_mm;
-	unsigned long len, addr, end;
-	pte_t *ptep;
+	if (!put_page_testzero(page))
+		return;
+
+	free_huge_page(page);
+}
+
+void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,=
 unsigned long end)
+{
+	struct mm_struct *mm =3D vma->vm_mm;
+	unsigned long address;
+	pte_t *pte;
 	struct page *page;
=20
-	addr =3D mpnt->vm_start;
-	end =3D mpnt->vm_end;
-	len =3D end - addr;
-	do {
-		ptep =3D huge_pte_offset(mm, addr);
-		page =3D pte_page(*ptep);
-		pte_clear(ptep);
-		free_hugetlb_page(page);
-		addr +=3D HPAGE_SIZE;
-	} while (addr < end);
-	mm->rss -=3D (len >> PAGE_SHIFT);
-	mpnt->vm_ops =3D NULL;
-	flush_tlb_range(mpnt, end - len, end);
+	BUG_ON(start & (HPAGE_SIZE - 1));
+	BUG_ON(end & (HPAGE_SIZE - 1));
+
+	spin_lock(&htlbpage_lock);
+	spin_unlock(&htlbpage_lock);
+	for (address =3D start; address < end; address +=3D HPAGE_SIZE) {
+		pte =3D huge_pte_offset(mm, address);
+		if (pte_none(*pte))
+			continue;
+		page =3D pte_page(*pte);
+		huge_page_release(page);
+		pte_clear(pte);
+	}
+	mm->rss -=3D (end - start) >> PAGE_SHIFT;
+	flush_tlb_range(vma, start, end);
 }
=20
-static void
-unlink_vma (struct vm_area_struct *mpnt)
+void zap_hugepage_range(struct vm_area_struct *vma, unsigned long start, u=
nsigned long length)
+{
+	struct mm_struct *mm =3D vma->vm_mm;
+	spin_lock(&mm->page_table_lock);
+	unmap_hugepage_range(vma, start, start + length);
+	spin_unlock(&mm->page_table_lock);
+}
+
+int hugetlb_prefault(struct address_space *mapping, struct vm_area_struct =
*vma)
 {
 	struct mm_struct *mm =3D current->mm;
-	struct vm_area_struct *vma;
+	unsigned long addr;
+	int ret =3D 0;
+
+	BUG_ON(vma->vm_start & ~HPAGE_MASK);
+	BUG_ON(vma->vm_end & ~HPAGE_MASK);
=20
-	vma =3D mm->mmap;
-	if (vma =3D mpnt) {
-		mm->mmap =3D vma->vm_next;
-	} else {
-		while (vma->vm_next !=3D mpnt) {
-			vma =3D vma->vm_next;
+	spin_lock(&mm->page_table_lock);
+	for (addr =3D vma->vm_start; addr < vma->vm_end; addr +=3D HPAGE_SIZE) {
+		unsigned long idx;
+		pte_t *pte =3D huge_pte_alloc(mm, addr);
+		struct page *page;
+
+		if (!pte) {
+			ret =3D -ENOMEM;
+			goto out;
+		}
+		if (!pte_none(*pte))
+			continue;
+
+		idx =3D ((addr - vma->vm_start) >> HPAGE_SHIFT)
+			+ (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
+		page =3D find_get_page(mapping, idx);
+		if (!page) {
+			page =3D alloc_hugetlb_page();
+			if (!page) {
+				ret =3D -ENOMEM;
+				goto out;
+			}
+			add_to_page_cache(page, mapping, idx);
+			unlock_page(page);
 		}
-		vma->vm_next =3D mpnt->vm_next;
+		set_huge_pte(mm, vma, page, pte, vma->vm_flags & VM_WRITE);
 	}
-	rb_erase(&mpnt->vm_rb, &mm->mm_rb);
-	mm->mmap_cache =3D NULL;
-	mm->map_count--;
+out:
+	spin_unlock(&mm->page_table_lock);
+	return ret;
 }
=20
-int
-set_hugetlb_mem_size (int count)
+void update_and_free_page(struct page *page)
+{
+	int j;
+	struct page *map;
+
+	map =3D page;
+	htlbzone_pages--;
+	for (j =3D 0; j < (HPAGE_SIZE / PAGE_SIZE); j++) {
+		map->flags &=3D ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
+				1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
+				1 << PG_private | 1<< PG_writeback);
+		set_page_count(map, 0);
+		map++;
+	}
+	set_page_count(page, 1);
+	__free_pages(page, HUGETLB_PAGE_ORDER);
+}
+
+int try_to_free_low(int count)
+{
+	struct list_head *p;
+	struct page *page, *map;
+
+	map =3D NULL;
+	spin_lock(&htlbpage_lock);
+	list_for_each(p, &htlbpage_freelist) {
+		if (map) {
+			list_del(&map->list);
+			update_and_free_page(map);
+			htlbpagemem--;
+			map =3D NULL;
+			if (++count =3D 0)
+				break;
+		}
+		page =3D list_entry(p, struct page, list);
+		if ((page_zone(page))->name[0] !=3D 'H') // Look for non-Highmem
+				map =3D page;
+	}
+	if (map) {
+		list_del(&map->list);
+		update_and_free_page(map);
+		htlbpagemem--;
+		count++;
+	}
+	spin_unlock(&htlbpage_lock);
+	return count;
+}
+
+int set_hugetlb_mem_size(int count)
 {
 	int j, lcount;
 	struct page *page, *map;
@@ -298,7 +311,10 @@
 		lcount =3D count;
 	else
 		lcount =3D count - htlbzone_pages;
-	if (lcount > 0) {	/*Increase the mem size. */
+
+	if (lcount =3D 0)
+		return (int)htlbzone_pages;
+	if (lcount > 0) {	/* Increase the mem size. */
 		while (lcount--) {
 			page =3D alloc_pages(__GFP_HIGHMEM, HUGETLB_PAGE_ORDER);
 			if (page =3D NULL)
@@ -316,27 +332,79 @@
 		}
 		return (int) htlbzone_pages;
 	}
-	/*Shrink the memory size. */
+	/* Shrink the memory size. */
+	lcount =3D try_to_free_low(lcount);
 	while (lcount++) {
 		page =3D alloc_hugetlb_page();
 		if (page =3D NULL)
 			break;
 		spin_lock(&htlbpage_lock);
-		htlbzone_pages--;
+		update_and_free_page(page);
 		spin_unlock(&htlbpage_lock);
-		map =3D page;
-		for (j =3D 0; j < (HPAGE_SIZE / PAGE_SIZE); j++) {
-			map->flags &=3D ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
-					1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
-					1 << PG_private | 1<< PG_writeback);
-			map++;
-		}
-		set_page_count(page, 1);
-		__free_pages(page, HUGETLB_PAGE_ORDER);
 	}
 	return (int) htlbzone_pages;
 }
=20
-static struct vm_operations_struct hugetlb_vm_ops =3D {
-	.close =3D	zap_hugetlb_resources
+int hugetlb_sysctl_handler(ctl_table *table, int write, struct file *file,=
 void *buffer, size_t *length)
+{
+	proc_dointvec(table, write, file, buffer, length);
+	htlbpage_max =3D set_hugetlb_mem_size(htlbpage_max);
+	return 0;
+}
+
+static int __init hugetlb_setup(char *s)
+{
+	if (sscanf(s, "%d", &htlbpage_max) <=3D 0)
+		htlbpage_max =3D 0;
+	return 1;
+}
+__setup("hugepages=3D", hugetlb_setup);
+
+static int __init hugetlb_init(void)
+{
+	int i, j;
+	struct page *page;
+
+	for (i =3D 0; i < htlbpage_max; ++i) {
+		page =3D alloc_pages(__GFP_HIGHMEM, HUGETLB_PAGE_ORDER);
+		if (!page)
+			break;
+		for (j =3D 0; j < HPAGE_SIZE/PAGE_SIZE; ++j)
+			SetPageReserved(&page[j]);
+		spin_lock(&htlbpage_lock);
+		list_add(&page->list, &htlbpage_freelist);
+		spin_unlock(&htlbpage_lock);
+	}
+	htlbpage_max =3D htlbpagemem =3D htlbzone_pages =3D i;
+	printk("Total HugeTLB memory allocated, %ld\n", htlbpagemem);
+	return 0;
+}
+module_init(hugetlb_init);
+
+int hugetlb_report_meminfo(char *buf)
+{
+	return sprintf(buf,
+			"HugePages_Total: %5lu\n"
+			"HugePages_Free:  %5lu\n"
+			"Hugepagesize:    %5lu kB\n",
+			htlbzone_pages,
+			htlbpagemem,
+			HPAGE_SIZE/1024);
+}
+
+int is_hugepage_mem_enough(size_t size)
+{
+	if (size > (htlbpagemem << HPAGE_SHIFT))
+		return 0;
+	return 1;
+}
+
+static struct page *hugetlb_nopage(struct vm_area_struct * area, unsigned =
long address, int unused)
+{
+	BUG();
+	return NULL;
+}
+
+struct vm_operations_struct hugetlb_vm_ops =3D {
+	.nopage =3D hugetlb_nopage,
 };
diff -Nru a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
--- a/arch/ia64/mm/init.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/mm/init.c	Fri Jan 24 20:41:05 2003
@@ -38,6 +38,13 @@
=20
 unsigned long MAX_DMA_ADDRESS =3D PAGE_OFFSET + 0x100000000UL;
=20
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+# define LARGE_GAP	0x40000000	/* Use virtual mem map if hole is > than thi=
s */
+  unsigned long vmalloc_end =3D VMALLOC_END_INIT;
+  static struct page *vmem_map;
+  static unsigned long num_dma_physpages;
+#endif
+
 static int pgt_cache_water[2] =3D { 25, 50 };
=20
 void
@@ -338,17 +345,148 @@
 	ia64_tlb_init();
 }
=20
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+
+static int
+create_mem_map_page_table (u64 start, u64 end, void *arg)
+{
+	unsigned long address, start_page, end_page;
+	struct page *map_start, *map_end;
+	pgd_t *pgd;
+	pmd_t *pmd;
+	pte_t *pte;
+
+	map_start =3D vmem_map + (__pa(start) >> PAGE_SHIFT);
+	map_end   =3D vmem_map + (__pa(end) >> PAGE_SHIFT);
+
+	start_page =3D (unsigned long) map_start & PAGE_MASK;
+	end_page =3D PAGE_ALIGN((unsigned long) map_end);
+
+	for (address =3D start_page; address < end_page; address +=3D PAGE_SIZE) {
+		pgd =3D pgd_offset_k(address);
+		if (pgd_none(*pgd))
+			pgd_populate(&init_mm, pgd, alloc_bootmem_pages(PAGE_SIZE));
+		pmd =3D pmd_offset(pgd, address);
+
+		if (pmd_none(*pmd))
+			pmd_populate_kernel(&init_mm, pmd, alloc_bootmem_pages(PAGE_SIZE));
+		pte =3D pte_offset_kernel(pmd, address);
+
+		if (pte_none(*pte))
+			set_pte(pte, pfn_pte(__pa(alloc_bootmem_pages(PAGE_SIZE)) >> PAGE_SHIFT,
+					     PAGE_KERNEL));
+	}
+	return 0;
+}
+
+struct memmap_init_callback_data {
+	memmap_init_callback_t *memmap_init;
+	struct page *start;
+	struct page *end;
+	int nid;
+	unsigned long zone;
+};
+
+static int
+virtual_memmap_init (u64 start, u64 end, void *arg)
+{
+	struct memmap_init_callback_data *args;
+	struct page *map_start, *map_end;
+
+	args =3D (struct memmap_init_callback_data *) arg;
+
+	map_start =3D vmem_map + (__pa(start) >> PAGE_SHIFT);
+	map_end   =3D vmem_map + (__pa(end) >> PAGE_SHIFT);
+
+	if (map_start < args->start)
+		map_start =3D args->start;
+	if (map_end > args->end)
+		map_end =3D args->end;
+
+	/*
+	 * We have to initialize "out of bounds" struct page elements
+	 * that fit completely on the same pages that were allocated
+	 * for the "in bounds" elements because they may be referenced
+	 * later (and found to be "reserved").
+	 */
+
+	map_start -=3D ((unsigned long) map_start & (PAGE_SIZE - 1)) / sizeof(str=
uct page);
+	map_end +=3D ((PAGE_ALIGN((unsigned long) map_end) - (unsigned long) map_=
end)
+		    / sizeof(struct page));
+
+	if (map_start < map_end)
+		(*args->memmap_init)(map_start, (unsigned long)(map_end - map_start),
+				     args->nid,args->zone,page_to_pfn(map_start));
+	return 0;
+}
+
+void
+arch_memmap_init (memmap_init_callback_t *memmap_init,
+	struct page *start, unsigned long size, int nid,
+	unsigned long zone, unsigned long start_pfn)
+{
+	if (!vmem_map)
+		memmap_init(start,size,nid,zone,start_pfn);
+	else {
+		struct memmap_init_callback_data args;
+
+		args.memmap_init =3D memmap_init;
+		args.start =3D start;
+		args.end =3D start + size;
+		args.nid =3D nid;
+		args.zone =3D zone;
+
+		efi_memmap_walk(virtual_memmap_init, &args);
+	}
+}
+
+int
+ia64_pfn_valid (unsigned long pfn)
+{
+	char byte;
+
+	return __get_user(byte, (char *) pfn_to_page(pfn)) =3D 0;
+}
+
+static int
+count_dma_pages (u64 start, u64 end, void *arg)
+{
+	unsigned long *count =3D arg;
+
+	if (end <=3D MAX_DMA_ADDRESS)
+		*count +=3D (end - start) >> PAGE_SHIFT;
+	return 0;
+}
+
+static int
+find_largest_hole (u64 start, u64 end, void *arg)
+{
+	u64 *max_gap =3D arg;
+
+	static u64 last_end =3D PAGE_OFFSET;
+
+	/* NOTE: this algorithm assumes efi memmap table is ordered */
+
+	if (*max_gap < (start - last_end))
+		*max_gap =3D start - last_end;
+	last_end =3D end;
+	return 0;
+}
+#endif /* CONFIG_VIRTUAL_MEM_MAP */
+
+static int
+count_pages (u64 start, u64 end, void *arg)
+{
+	unsigned long *count =3D arg;
+
+	*count +=3D (end - start) >> PAGE_SHIFT;
+	return 0;
+}
+
 /*
  * Set up the page tables.
  */
=20
-#ifdef CONFIG_HUGETLB_PAGE
-long htlbpagemem;
-int htlbpage_max;
-extern long htlbzone_pages;
-extern struct list_head htlbpage_freelist;
-#endif
-
 #ifdef CONFIG_DISCONTIGMEM
 void
 paging_init (void)
@@ -356,18 +494,71 @@
 	extern void discontig_paging_init(void);
=20
 	discontig_paging_init();
+	efi_memmap_walk(count_pages, &num_physpages);
 }
 #else /* !CONFIG_DISCONTIGMEM */
 void
 paging_init (void)
 {
-	unsigned long max_dma, zones_size[MAX_NR_ZONES];
+	unsigned long max_dma;
+	unsigned long zones_size[MAX_NR_ZONES];
+#  ifdef CONFIG_VIRTUAL_MEM_MAP
+	unsigned long zholes_size[MAX_NR_ZONES];
+	unsigned long max_gap;
+#  endif
=20
 	/* initialize mem_map[] */
=20
 	memset(zones_size, 0, sizeof(zones_size));
=20
+	num_physpages =3D 0;
+	efi_memmap_walk(count_pages, &num_physpages);
+
 	max_dma =3D virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
+
+#  ifdef CONFIG_VIRTUAL_MEM_MAP
+	memset(zholes_size, 0, sizeof(zholes_size));
+
+	num_dma_physpages =3D 0;
+	efi_memmap_walk(count_dma_pages, &num_dma_physpages);
+
+	if (max_low_pfn < max_dma) {
+		zones_size[ZONE_DMA] =3D max_low_pfn;
+		zholes_size[ZONE_DMA] =3D max_low_pfn - num_dma_physpages;
+	}
+	else {
+		zones_size[ZONE_DMA] =3D max_dma;
+		zholes_size[ZONE_DMA] =3D max_dma - num_dma_physpages;
+		if (num_physpages > num_dma_physpages) {
+			zones_size[ZONE_NORMAL] =3D max_low_pfn - max_dma;
+			zholes_size[ZONE_NORMAL] =3D ((max_low_pfn - max_dma)
+						    - (num_physpages - num_dma_physpages));
+		}
+	}
+
+	max_gap =3D 0;
+	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
+	if (max_gap < LARGE_GAP) {
+		vmem_map =3D (struct page *) 0;
+		free_area_init_node(0, &contig_page_data, NULL, zones_size, 0, zholes_si=
ze);
+		mem_map =3D contig_page_data.node_mem_map;
+	}
+	else {
+		unsigned long map_size;
+
+		/* allocate virtual_mem_map */
+
+		map_size =3D PAGE_ALIGN(max_low_pfn * sizeof(struct page));
+		vmalloc_end -=3D map_size;
+		vmem_map =3D (struct page *) vmalloc_end;
+		efi_memmap_walk(create_mem_map_page_table, 0);
+
+		free_area_init_node(0, &contig_page_data, vmem_map, zones_size, 0, zhole=
s_size);
+
+		mem_map =3D contig_page_data.node_mem_map;
+		printk("Virtual mem_map starts at 0x%p\n", mem_map);
+	}
+#  else /* !CONFIG_VIRTUAL_MEM_MAP */
 	if (max_low_pfn < max_dma)
 		zones_size[ZONE_DMA] =3D max_low_pfn;
 	else {
@@ -375,19 +566,11 @@
 		zones_size[ZONE_NORMAL] =3D max_low_pfn - max_dma;
 	}
 	free_area_init(zones_size);
+#  endif /* !CONFIG_VIRTUAL_MEM_MAP */
 }
 #endif /* !CONFIG_DISCONTIGMEM */
=20
 static int
-count_pages (u64 start, u64 end, void *arg)
-{
-	unsigned long *count =3D arg;
-
-	*count +=3D (end - start) >> PAGE_SHIFT;
-	return 0;
-}
-
-static int
 count_reserved_pages (u64 start, u64 end, void *arg)
 {
 	unsigned long num_reserved =3D 0;
@@ -423,9 +606,6 @@
 	max_mapnr =3D max_low_pfn;
 #endif
=20
-	num_physpages =3D 0;
-	efi_memmap_walk(count_pages, &num_physpages);
-
 	high_memory =3D __va(max_low_pfn * PAGE_SIZE);
=20
 	for_each_pgdat(pgdat)
@@ -461,30 +641,5 @@
=20
 #ifdef CONFIG_IA32_SUPPORT
 	ia32_gdt_init();
-#endif
-#ifdef CONFIG_HUGETLB_PAGE
-	{
-		long i;
-		int j;
-		struct page *page, *map;
-
-		if ((htlbzone_pages << (HPAGE_SHIFT - PAGE_SHIFT)) >=3D max_low_pfn)
-			htlbzone_pages =3D (max_low_pfn >> ((HPAGE_SHIFT - PAGE_SHIFT) + 1));
-		INIT_LIST_HEAD(&htlbpage_freelist);
-		for (i =3D 0; i < htlbzone_pages; i++) {
-			page =3D alloc_pages(__GFP_HIGHMEM, HUGETLB_PAGE_ORDER);
-			if (!page)
-				break;
-			map =3D page;
-			for (j =3D 0; j < (HPAGE_SIZE/PAGE_SIZE); j++) {
-				SetPageReserved(map);
-				map++;
-			}
-			list_add(&page->list, &htlbpage_freelist);
-		}
-		printk("Total Huge_TLB_Page memory pages allocated %ld \n", i);
-		htlbzone_pages =3D htlbpagemem =3D i;
-		htlbpage_max =3D (int)i;
-	}
 #endif
 }
diff -Nru a/arch/ia64/scripts/check-gas b/arch/ia64/scripts/check-gas
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/ia64/scripts/check-gas	Fri Jan 24 20:41:06 2003
@@ -0,0 +1,11 @@
+#!/bin/sh
+dir=3D$(dirname $0)
+CC=3D$1
+$CC -c $dir/check-gas-asm.S
+res=3D$(objdump -r --section .data check-gas-asm.o | fgrep 00004 | tr -s '=
 ' |cut -f3 -d' ')
+if [ $res !=3D ".text" ]; then
+	echo buggy
+else
+	echo good
+fi
+exit 0
diff -Nru a/arch/ia64/scripts/check-gas-asm.S b/arch/ia64/scripts/check-gas=
-asm.S
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/ia64/scripts/check-gas-asm.S	Fri Jan 24 20:41:06 2003
@@ -0,0 +1,2 @@
+[1:]	nop 0
+	.xdata4 ".data", 0, 1b-.
diff -Nru a/arch/ia64/scripts/unwcheck.sh b/arch/ia64/scripts/unwcheck.sh
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/ia64/scripts/unwcheck.sh	Fri Jan 24 20:41:06 2003
@@ -0,0 +1,109 @@
+#!/bin/sh
+#   Usage: unwcheck.sh <executable_file_name>
+#   Pre-requisite: readelf [from Gnu binutils package]
+#   Purpose: Check the following invariant
+#       For each code range in the input binary:
+#          Sum[ lengths of unwind regions] =3D Number of slots in code ran=
ge.
+#   Author : Harish Patil
+#   First version: January 2002
+#   Modified : 2/13/2002
+#   Modified : 3/15/2002: duplicate detection
+readelf -u $1 | gawk '\
+ function todec(hexstr){
+    dec =3D 0;
+    l =3D length(hexstr);
+    for (i =3D 1; i <=3D l; i++)
+    {
+        c =3D substr(hexstr, i, 1);
+        if (c =3D "A")
+            dec =3D dec*16 + 10;
+        else if (c =3D "B")
+            dec =3D dec*16 + 11;
+        else if (c =3D "C")
+            dec =3D dec*16 + 12;
+        else if (c =3D "D")
+            dec =3D dec*16 + 13;
+        else if (c =3D "E")
+            dec =3D dec*16 + 14;
+        else if (c =3D "F")
+            dec =3D dec*16 + 15;
+        else
+            dec =3D dec*16 + c;
+    }
+    return dec;
+ }
+ BEGIN { first =3D 1; sum_rlen =3D 0; no_slots =3D 0; errors=3D0; no_code_=
ranges=3D0; }
+ {
+   if (NF=3D5 && $3=3D"info")
+   {
+      no_code_ranges +=3D 1;
+      if (first =3D 0)
+      {
+         if (sum_rlen !=3D no_slots)
+         {
+            print full_code_range;
+            print "       ", "lo =3D ", lo, " hi =3D", hi;
+            print "       ", "sum_rlen =3D ", sum_rlen, "no_slots =3D " no=
_slots;
+            print "       ","   ", "*******ERROR ***********";
+            print "       ","   ", "sum_rlen:", sum_rlen, " !=3D no_slots:=
" no_slots;
+            errors +=3D 1;
+         }
+         sum_rlen =3D 0;
+      }
+      full_code_range =3D  $0;
+      code_range =3D  $2;
+      gsub("..$", "", code_range);
+      gsub("^.", "", code_range);
+      split(code_range, addr, "-");
+      lo =3D toupper(addr[1]);
+
+      code_range_lo[no_code_ranges] =3D addr[1];
+      occurs[addr[1]] +=3D 1;
+      full_range[addr[1]] =3D $0;
+
+      gsub("0X.[0]*", "", lo);
+      hi =3D toupper(addr[2]);
+      gsub("0X.[0]*", "", hi);
+      no_slots =3D (todec(hi) - todec(lo))/ 16*3
+      first =3D 0;
+   }
+   if (index($0,"rlen") > 0 )
+   {
+    rlen_str =3D  substr($0, index($0,"rlen"));
+    rlen =3D rlen_str;
+    gsub("rlen=3D", "", rlen);
+    gsub(")", "", rlen);
+    sum_rlen =3D sum_rlen +  rlen;
+   }
+  }
+  END {
+      if (first =3D 0)
+      {
+         if (sum_rlen !=3D no_slots)
+         {
+            print "code_range=3D", code_range;
+            print "       ", "lo =3D ", lo, " hi =3D", hi;
+            print "       ", "sum_rlen =3D ", sum_rlen, "no_slots =3D " no=
_slots;
+            print "       ","   ", "*******ERROR ***********";
+            print "       ","   ", "sum_rlen:", sum_rlen, " !=3D no_slots:=
" no_slots;
+            errors +=3D 1;
+         }
+      }
+    no_duplicates =3D 0;
+    for (i=3D1; i<=3Dno_code_ranges; i++)
+    {
+        cr =3D code_range_lo[i];
+        if (reported_cr[cr]=3D1) continue;
+        if ( occurs[cr] > 1)
+        {
+            reported_cr[cr] =3D 1;
+            print "Code range low ", code_range_lo[i], ":", full_range[cr]=
, " occurs: ", occurs[cr], " times.";
+            print " ";
+            no_duplicates++;
+        }
+    }
+    print "=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D"
+    print "Total errors:", errors, "/", no_code_ranges, " duplicates:", no=
_duplicates;
+    print "=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D"
+  }
+  '
diff -Nru a/arch/ia64/tools/Makefile b/arch/ia64/tools/Makefile
--- a/arch/ia64/tools/Makefile	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/tools/Makefile	Fri Jan 24 20:41:05 2003
@@ -4,14 +4,7 @@
=20
 src =3D $(obj)
=20
-all:
-
-fastdep:
-
-mrproper: clean
-
-clean:
-	rm -f $(obj)/print_offsets.s $(obj)/print_offsets $(obj)/offsets.h
+clean-files :=3D print_offsets.s print_offsets offsets.h
=20
 $(TARGET): $(obj)/offsets.h
 	@if ! cmp -s $(obj)/offsets.h ${TARGET}; then	\
diff -Nru a/arch/ia64/tools/print_offsets.c b/arch/ia64/tools/print_offsets=
.c
--- a/arch/ia64/tools/print_offsets.c	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/tools/print_offsets.c	Fri Jan 24 20:41:05 2003
@@ -1,7 +1,7 @@
 /*
  * Utility to generate asm-ia64/offsets.h.
  *
- * Copyright (C) 1999-2002 Hewlett-Packard Co
+ * Copyright (C) 1999-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * Note that this file has dual use: when building the kernel
@@ -53,7 +53,10 @@
     { "UNW_FRAME_INFO_SIZE",		sizeof (struct unw_frame_info) },
     { "", 0 },			/* spacer */
     { "IA64_TASK_THREAD_KSP_OFFSET",	offsetof (struct task_struct, thread.=
ksp) },
+    { "IA64_TASK_THREAD_ON_USTACK_OFFSET", offsetof (struct task_struct, t=
hread.on_ustack) },
     { "IA64_TASK_PID_OFFSET",		offsetof (struct task_struct, pid) },
+    { "IA64_TASK_TGID_OFFSET",		offsetof (struct task_struct, tgid) },
+    { "IA64_TASK_CLEAR_CHILD_TID_OFFSET",offsetof (struct task_struct, cle=
ar_child_tid) },
     { "IA64_PT_REGS_CR_IPSR_OFFSET",	offsetof (struct pt_regs, cr_ipsr) },
     { "IA64_PT_REGS_CR_IIP_OFFSET",	offsetof (struct pt_regs, cr_iip) },
     { "IA64_PT_REGS_CR_IFS_OFFSET",	offsetof (struct pt_regs, cr_ifs) },
diff -Nru a/arch/ia64/vmlinux.lds.S b/arch/ia64/vmlinux.lds.S
--- a/arch/ia64/vmlinux.lds.S	Fri Jan 24 20:41:05 2003
+++ b/arch/ia64/vmlinux.lds.S	Fri Jan 24 20:41:05 2003
@@ -6,7 +6,7 @@
=20
 #define LOAD_OFFSET PAGE_OFFSET
 #include <asm-generic/vmlinux.lds.h>
-=09
+
 OUTPUT_FORMAT("elf64-ia64-little")
 OUTPUT_ARCH(ia64)
 ENTRY(phys_start)
@@ -29,6 +29,7 @@
=20
   _text =3D .;
   _stext =3D .;
+
   .text : AT(ADDR(.text) - PAGE_OFFSET)
     {
 	*(.text.ivt)
@@ -44,33 +45,39 @@
=20
   /* Read-only data */
=20
-  /* Global data */
-  _data =3D .;
-
   /* Exception table */
   . =3D ALIGN(16);
-  __start___ex_table =3D .;
   __ex_table : AT(ADDR(__ex_table) - PAGE_OFFSET)
-	{ *(__ex_table) }
-  __stop___ex_table =3D .;
+	{
+	  __start___ex_table =3D .;
+	  *(__ex_table)
+	  __stop___ex_table =3D .;
+	}
+
+  /* Global data */
+  _data =3D .;
=20
 #if defined(CONFIG_IA64_GENERIC)
   /* Machine Vector */
   . =3D ALIGN(16);
-  machvec_start =3D .;
   .machvec : AT(ADDR(.machvec) - PAGE_OFFSET)
-	{ *(.machvec) }
-  machvec_end =3D .;
+	{
+	  machvec_start =3D .;
+	  *(.machvec)
+	  machvec_end =3D .;
+	}
 #endif
=20
   /* Unwind info & table: */
   . =3D ALIGN(8);
   .IA_64.unwind_info : AT(ADDR(.IA_64.unwind_info) - PAGE_OFFSET)
 	{ *(.IA_64.unwind_info*) }
-  ia64_unw_start =3D .;
   .IA_64.unwind : AT(ADDR(.IA_64.unwind) - PAGE_OFFSET)
-	{ *(.IA_64.unwind*) }
-  ia64_unw_end =3D .;
+	{
+	  ia64_unw_start =3D .;
+	  *(.IA_64.unwind*)
+	  ia64_unw_end =3D .;
+	}
=20
   RODATA
=20
@@ -87,32 +94,38 @@
   .init.data : AT(ADDR(.init.data) - PAGE_OFFSET)
 	{ *(.init.data) }
=20
-  __initramfs_start =3D .;
   .init.ramfs : AT(ADDR(.init.ramfs) - PAGE_OFFSET)
-	{ *(.init.ramfs) }
-  __initramfs_end =3D .;
+	{
+	  __initramfs_start =3D .;
+	  *(.init.ramfs)
+	  __initramfs_end =3D .;
+	}
=20
    . =3D ALIGN(16);
-  __setup_start =3D .;
   .init.setup : AT(ADDR(.init.setup) - PAGE_OFFSET)
-        { *(.init.setup) }
-  __setup_end =3D .;
-  __start___param =3D .;
+        {
+	  __setup_start =3D .;
+	  *(.init.setup)
+	  __setup_end =3D .;
+	}
   __param : AT(ADDR(__param) - PAGE_OFFSET)
-        { *(__param) }
-  __stop___param =3D .;
-  __initcall_start =3D .;
+        {
+	  __start___param =3D .;
+	  *(__param)
+	  __stop___param =3D .;
+	}
   .initcall.init : AT(ADDR(.initcall.init) - PAGE_OFFSET)
 	{
-		*(.initcall1.init)
-		*(.initcall2.init)
-		*(.initcall3.init)
-		*(.initcall4.init)
-		*(.initcall5.init)
-		*(.initcall6.init)
-		*(.initcall7.init)
+	  __initcall_start =3D .;
+	  *(.initcall1.init)
+	  *(.initcall2.init)
+	  *(.initcall3.init)
+	  *(.initcall4.init)
+	  *(.initcall5.init)
+	  *(.initcall6.init)
+	  *(.initcall7.init)
+	  __initcall_end =3D .;
 	}
-  __initcall_end =3D .;
   . =3D ALIGN(PAGE_SIZE);
   __init_end =3D .;
=20
@@ -130,10 +143,6 @@
   . =3D ALIGN(SMP_CACHE_BYTES);
   .data.cacheline_aligned : AT(ADDR(.data.cacheline_aligned) - PAGE_OFFSET)
         { *(.data.cacheline_aligned) }
-
-  /* Kernel symbol names for modules: */
-  .kstrtab : AT(ADDR(.kstrtab) - PAGE_OFFSET)
-	{ *(.kstrtab) }
=20
   /* Per-cpu data: */
   . =3D ALIGN(PERCPU_PAGE_SIZE);
diff -Nru a/drivers/acpi/osl.c b/drivers/acpi/osl.c
--- a/drivers/acpi/osl.c	Fri Jan 24 20:41:05 2003
+++ b/drivers/acpi/osl.c	Fri Jan 24 20:41:05 2003
@@ -143,9 +143,9 @@
 #ifdef CONFIG_ACPI_EFI
 	addr->pointer_type =3D ACPI_PHYSICAL_POINTER;
 	if (efi.acpi20)
-		addr->pointer.physical =3D (ACPI_PHYSICAL_ADDRESS) virt_to_phys(efi.acpi=
20);
+		addr->pointer.physical =3D (acpi_physical_address) virt_to_phys(efi.acpi=
20);
 	else if (efi.acpi)
-		addr->pointer.physical =3D (ACPI_PHYSICAL_ADDRESS) virt_to_phys(efi.acpi=
);
+		addr->pointer.physical =3D (acpi_physical_address) virt_to_phys(efi.acpi=
);
 	else {
 		printk(KERN_ERR PREFIX "System description tables not found\n");
 		return AE_NOT_FOUND;
@@ -224,7 +224,14 @@
 acpi_os_install_interrupt_handler(u32 irq, OSD_HANDLER handler, void *cont=
ext)
 {
 #ifdef CONFIG_IA64
-	irq =3D gsi_to_vector(irq);
+	int vector;
+
+	vector =3D acpi_irq_to_vector(irq);
+	if (vector < 0) {
+		printk(KERN_ERR PREFIX "SCI (IRQ%d) not registerd\n", irq);
+		return AE_OK;
+	}
+	irq =3D vector;
 #endif
 	acpi_irq_irq =3D irq;
 	acpi_irq_handler =3D handler;
@@ -242,7 +249,7 @@
 {
 	if (acpi_irq_handler) {
 #ifdef CONFIG_IA64
-		irq =3D gsi_to_vector(irq);
+		irq =3D acpi_irq_to_vector(irq);
 #endif
 		free_irq(irq, acpi_irq);
 		acpi_irq_handler =3D NULL;
diff -Nru a/drivers/acpi/pci_irq.c b/drivers/acpi/pci_irq.c
--- a/drivers/acpi/pci_irq.c	Fri Jan 24 20:41:05 2003
+++ b/drivers/acpi/pci_irq.c	Fri Jan 24 20:41:05 2003
@@ -36,6 +36,9 @@
 #ifdef CONFIG_X86_IO_APIC
 #include <asm/mpspec.h>
 #endif
+#ifdef CONFIG_IOSAPIC
+# include <asm/iosapic.h>
+#endif
 #include "acpi_bus.h"
 #include "acpi_drivers.h"
=20
@@ -250,6 +253,8 @@
 		return_VALUE(0);
 	}
=20
+	entry->irq =3D entry->link.index;
+
 	if (!entry->irq && entry->link.handle) {
 		entry->irq =3D acpi_pci_link_get_irq(entry->link.handle, entry->link.ind=
ex);
 		if (!entry->irq) {
@@ -355,7 +360,7 @@
 			return_VALUE(0);
  	}
=20
-	dev->irq =3D irq;
+	dev->irq =3D gsi_to_irq(irq);
=20
 	ACPI_DEBUG_PRINT((ACPI_DB_INFO, "Device %s using IRQ %d\n", dev->slot_nam=
e, dev->irq));
=20
diff -Nru a/drivers/char/agp/agp.h b/drivers/char/agp/agp.h
--- a/drivers/char/agp/agp.h	Fri Jan 24 20:41:05 2003
+++ b/drivers/char/agp/agp.h	Fri Jan 24 20:41:05 2003
@@ -47,7 +47,7 @@
 	flush_agp_cache();
 }
 #else
-static void global_cache_flush(void)
+static void __attribute__((unused)) global_cache_flush(void)
 {
 	flush_agp_cache();
 }
diff -Nru a/drivers/char/agp/backend.c b/drivers/char/agp/backend.c
--- a/drivers/char/agp/backend.c	Fri Jan 24 20:41:05 2003
+++ b/drivers/char/agp/backend.c	Fri Jan 24 20:41:05 2003
@@ -26,6 +26,7 @@
  * TODO:=20
  * - Allocate more than order 0 pages to avoid too much linear map splitti=
ng.
  */
+
 #include <linux/config.h>
 #include <linux/module.h>
 #include <linux/pci.h>
diff -Nru a/drivers/char/agp/hp-agp.c b/drivers/char/agp/hp-agp.c
--- a/drivers/char/agp/hp-agp.c	Fri Jan 24 20:41:05 2003
+++ b/drivers/char/agp/hp-agp.c	Fri Jan 24 20:41:05 2003
@@ -369,7 +369,7 @@
 }
=20
 static struct agp_driver hp_agp_driver =3D {
-	.owner =3D THIS_MODULE;
+	.owner =3D THIS_MODULE,
 };
=20
 static int __init agp_hp_probe (struct pci_dev *dev, const struct pci_devi=
ce_id *ent)
diff -Nru a/drivers/char/drm/drmP.h b/drivers/char/drm/drmP.h
--- a/drivers/char/drm/drmP.h	Fri Jan 24 20:41:05 2003
+++ b/drivers/char/drm/drmP.h	Fri Jan 24 20:41:05 2003
@@ -230,16 +230,16 @@
    if (len > DRM_PROC_LIMIT) { ret; *eof =3D 1; return len - offset; }
=20
 				/* Mapping helper macros */
-#define DRM_IOREMAP(map)						\
-	(map)->handle =3D DRM(ioremap)( (map)->offset, (map)->size )
+#define DRM_IOREMAP(map, dev)							\
+	(map)->handle =3D DRM(ioremap)( (map)->offset, (map)->size, (dev) )
=20
-#define DRM_IOREMAP_NOCACHE(map)					\
-	(map)->handle =3D DRM(ioremap_nocache)((map)->offset, (map)->size)
+#define DRM_IOREMAP_NOCACHE(map, dev)						\
+	(map)->handle =3D DRM(ioremap_nocache)((map)->offset, (map)->size, (dev))
=20
-#define DRM_IOREMAPFREE(map)						\
-	do {								\
-		if ( (map)->handle && (map)->size )			\
-			DRM(ioremapfree)( (map)->handle, (map)->size );	\
+#define DRM_IOREMAPFREE(map, dev)							\
+	do {									\
+		if ( (map)->handle && (map)->size )				\
+			DRM(ioremapfree)( (map)->handle, (map)->size, (dev) );	\
 	} while (0)
=20
 #define DRM_FIND_MAP(_map, _o)						\
@@ -693,9 +693,10 @@
 extern unsigned long DRM(alloc_pages)(int order, int area);
 extern void	     DRM(free_pages)(unsigned long address, int order,
 				     int area);
-extern void	     *DRM(ioremap)(unsigned long offset, unsigned long size);
-extern void	     *DRM(ioremap_nocache)(unsigned long offset, unsigned long=
 size);
-extern void	     DRM(ioremapfree)(void *pt, unsigned long size);
+extern void	     *DRM(ioremap)(unsigned long offset, unsigned long size, d=
rm_device_t *dev);
+extern void	     *DRM(ioremap_nocache)(unsigned long offset, unsigned long=
 size,
+					   drm_device_t *dev);
+extern void	     DRM(ioremapfree)(void *pt, unsigned long size, drm_device=
_t *dev);
=20
 #if __REALLY_HAVE_AGP
 extern agp_memory    *DRM(alloc_agp)(int pages, u32 type);
diff -Nru a/drivers/char/drm/drm_bufs.h b/drivers/char/drm/drm_bufs.h
--- a/drivers/char/drm/drm_bufs.h	Fri Jan 24 20:41:05 2003
+++ b/drivers/char/drm/drm_bufs.h	Fri Jan 24 20:41:05 2003
@@ -107,7 +107,7 @@
 	switch ( map->type ) {
 	case _DRM_REGISTERS:
 	case _DRM_FRAME_BUFFER:
-#if !defined(__sparc__) && !defined(__alpha__)
+#if !defined(__sparc__) && !defined(__alpha__) && !defined(__ia64__)
 		if ( map->offset + map->size < map->offset ||
 		     map->offset < virt_to_phys(high_memory) ) {
 			DRM(free)( map, sizeof(*map), DRM_MEM_MAPS );
@@ -124,7 +124,7 @@
 					      MTRR_TYPE_WRCOMB, 1 );
 		}
 #endif
-		map->handle =3D DRM(ioremap)( map->offset, map->size );
+		map->handle =3D DRM(ioremap)( map->offset, map->size, dev );
 		break;
=20
 	case _DRM_SHM:
@@ -246,7 +246,7 @@
 				DRM_DEBUG("mtrr_del =3D %d\n", retcode);
 			}
 #endif
-			DRM(ioremapfree)(map->handle, map->size);
+			DRM(ioremapfree)(map->handle, map->size, dev);
 			break;
 		case _DRM_SHM:
 			vfree(map->handle);
diff -Nru a/drivers/char/drm/drm_drv.h b/drivers/char/drm/drm_drv.h
--- a/drivers/char/drm/drm_drv.h	Fri Jan 24 20:41:05 2003
+++ b/drivers/char/drm/drm_drv.h	Fri Jan 24 20:41:05 2003
@@ -443,7 +443,7 @@
 					DRM_DEBUG( "mtrr_del=3D%d\n", retcode );
 				}
 #endif
-				DRM(ioremapfree)( map->handle, map->size );
+				DRM(ioremapfree)( map->handle, map->size, dev );
 				break;
 			case _DRM_SHM:
 				vfree(map->handle);
diff -Nru a/drivers/char/drm/drm_memory.h b/drivers/char/drm/drm_memory.h
--- a/drivers/char/drm/drm_memory.h	Fri Jan 24 20:41:05 2003
+++ b/drivers/char/drm/drm_memory.h	Fri Jan 24 20:41:05 2003
@@ -33,6 +33,10 @@
 #include <linux/config.h>
 #include "drmP.h"
 #include <linux/wrapper.h>
+#include <linux/vmalloc.h>
+
+#include <asm/agp.h>
+#include <asm/tlbflush.h>
=20
 typedef struct drm_mem_stats {
 	const char	  *name;
@@ -291,17 +295,122 @@
 	}
 }
=20
-void *DRM(ioremap)(unsigned long offset, unsigned long size)
+#if __REALLY_HAVE_AGP
+
+/*
+ * Find the drm_map that covers the range [offset, offset+size).
+ */
+static inline drm_map_t *
+drm_lookup_map (unsigned long offset, unsigned long size, drm_device_t *de=
v)
 {
+	struct list_head *list;
+	drm_map_list_t *r_list;
+	drm_map_t *map;
+
+	list_for_each(list, &dev->maplist->head) {
+		r_list =3D (drm_map_list_t *) list;
+		map =3D r_list->map;
+		if (!map)
+			continue;
+		if (map->offset <=3D offset && (offset + size) <=3D (map->offset + map->=
size))
+			return map;
+	}
+	return NULL;
+}
+
+static inline void *
+agp_remap (unsigned long offset, unsigned long size, drm_device_t *dev)
+{
+	unsigned long *phys_addr_map, i, num_pages =3D PAGE_ALIGN(size) / PAGE_SI=
ZE;
+	struct page **page_map, **page_map_ptr;
+	struct drm_agp_mem *agpmem;
+	struct vm_struct *area;
+
+
+	size =3D PAGE_ALIGN(size);
+
+	for (agpmem =3D dev->agp->memory; agpmem; agpmem =3D agpmem->next)
+		if (agpmem->bound <=3D offset
+		    && (agpmem->bound + (agpmem->pages << PAGE_SHIFT)) >=3D (offset + si=
ze))
+			break;
+	if (!agpmem)
+		return NULL;
+
+	/*
+	 * OK, we're mapping AGP space on a chipset/platform on which memory acce=
sses by
+	 * the CPU do not get remapped by the GART.  We fix this by using the ker=
nel's
+	 * page-table instead (that's probably faster anyhow...).
+	 */
+	area =3D get_vm_area(size, VM_IOREMAP);
+	if (!area)
+		return NULL;
+
+	flush_cache_all();
+
+	/* note: use vmalloc() because num_pages could be large... */
+	page_map =3D vmalloc(num_pages * sizeof(struct page *));
+	if (!page_map)
+		return NULL;
+
+	phys_addr_map =3D agpmem->memory->memory + (offset - agpmem->bound) / PAG=
E_SIZE;
+	for (i =3D 0; i < num_pages; ++i)
+		page_map[i] =3D pfn_to_page(phys_addr_map[i] >> PAGE_SHIFT);
+	page_map_ptr =3D page_map;
+	if (map_vm_area(area, PAGE_AGP, &page_map_ptr) < 0) {
+		vunmap(area->addr);
+		vfree(page_map);
+		return NULL;
+	}
+	vfree(page_map);
+
+	flush_tlb_kernel_range(area->addr, area->addr + size);
+	return area->addr;
+}
+
+static inline unsigned long
+drm_follow_page (void *vaddr)
+{
+printk("drm_follow_page: vaddr=3D%p\n", vaddr);
+	pgd_t *pgd =3D pgd_offset_k((unsigned long) vaddr);
+printk("  pgd=3D%p\n", pgd);
+	pmd_t *pmd =3D pmd_offset(pgd, (unsigned long) vaddr);
+printk("  pmd=3D%p\n", pmd);
+	pte_t *ptep =3D pte_offset_kernel(pmd, (unsigned long) vaddr);
+printk("  ptep=3D%p\n", ptep);
+printk("  page=3D0x%lx\n", pte_pfn(*ptep) << PAGE_SHIFT);
+	return pte_pfn(*ptep) << PAGE_SHIFT;
+}
+
+#else /* !__REALLY_HAVE_AGP */
+
+static inline void *
+agp_remap (unsigned long offset, unsigned long size, drm_device_t *dev) { =
return NULL; }
+
+#endif /* !__REALLY_HAVE_AGP */
+
+void *DRM(ioremap)(unsigned long offset, unsigned long size, drm_device_t =
*dev)
+{
+	int remap_aperture =3D 0;
 	void *pt;
=20
 	if (!size) {
-		DRM_MEM_ERROR(DRM_MEM_MAPPINGS,
-			      "Mapping 0 bytes at 0x%08lx\n", offset);
+		DRM_MEM_ERROR(DRM_MEM_MAPPINGS, "Mapping 0 bytes at 0x%08lx\n", offset);
 		return NULL;
 	}
=20
-	if (!(pt =3D ioremap(offset, size))) {
+#if __REALLY_HAVE_AGP
+	if (dev->agp->cant_use_aperture) {
+		drm_map_t *map =3D drm_lookup_map(offset, size, dev);
+
+		if (map && map->type =3D _DRM_AGP)
+			remap_aperture =3D 1;
+	}
+#endif
+	if (remap_aperture)
+		pt =3D agp_remap(offset, size, dev);
+ 	else
+		pt =3D ioremap(offset, size);
+	if (!pt) {
 		spin_lock(&DRM(mem_lock));
 		++DRM(mem_stats)[DRM_MEM_MAPPINGS].fail_count;
 		spin_unlock(&DRM(mem_lock));
@@ -314,8 +423,9 @@
 	return pt;
 }
=20
-void *DRM(ioremap_nocache)(unsigned long offset, unsigned long size)
+void *DRM(ioremap_nocache)(unsigned long offset, unsigned long size, drm_d=
evice_t *dev)
 {
+	int remap_aperture =3D 0;
 	void *pt;
=20
 	if (!size) {
@@ -324,7 +434,19 @@
 		return NULL;
 	}
=20
-	if (!(pt =3D ioremap_nocache(offset, size))) {
+#if __REALLY_HAVE_AGP
+	if (dev->agp->cant_use_aperture) {
+		drm_map_t *map =3D drm_lookup_map(offset, size, dev);
+
+		if (map && map->type =3D _DRM_AGP)
+			remap_aperture =3D 1;
+	}
+#endif
+	if (remap_aperture)
+		pt =3D agp_remap(offset, size, dev);
+	else
+		pt =3D ioremap_nocache(offset, size);
+	if (!pt) {
 		spin_lock(&DRM(mem_lock));
 		++DRM(mem_stats)[DRM_MEM_MAPPINGS].fail_count;
 		spin_unlock(&DRM(mem_lock));
@@ -337,16 +459,40 @@
 	return pt;
 }
=20
-void DRM(ioremapfree)(void *pt, unsigned long size)
+void DRM(ioremapfree)(void *pt, unsigned long size, drm_device_t *dev)
 {
 	int alloc_count;
 	int free_count;
=20
+printk("ioremapfree(pt=3D%p)\n", pt);
 	if (!pt)
 		DRM_MEM_ERROR(DRM_MEM_MAPPINGS,
 			      "Attempt to free NULL pointer\n");
-	else
-		iounmap(pt);
+	else {
+		int unmap_aperture =3D 0;
+#if __REALLY_HAVE_AGP
+		/*
+		 * This is rather ugly.  It would be much cleaner if the DRM API would u=
se
+		 * separate routines for handling mappings in the AGP space.  Hopefully =
this
+		 * can be done in a future revision of the interface...
+		 */
+		if (dev->agp->cant_use_aperture
+		    && ((unsigned long) pt >=3D VMALLOC_START && (unsigned long) pt < VM=
ALLOC_END))
+		{
+			unsigned long offset =3D (drm_follow_page(pt)
+						| ((unsigned long) pt & ~PAGE_MASK));
+printk("offset=3D0x%lx\n", offset);
+			drm_map_t *map =3D drm_lookup_map(offset, size, dev);
+printk("map=3D%p\n", map);
+			if (map && map->type =3D _DRM_AGP)
+				unmap_aperture =3D 1;
+		}
+#endif
+		if (unmap_aperture)
+			vunmap(pt);
+		else
+			iounmap(pt);
+	}
=20
 	spin_lock(&DRM(mem_lock));
 	DRM(mem_stats)[DRM_MEM_MAPPINGS].bytes_freed +=3D size;
diff -Nru a/drivers/char/drm/drm_vm.h b/drivers/char/drm/drm_vm.h
--- a/drivers/char/drm/drm_vm.h	Fri Jan 24 20:41:05 2003
+++ b/drivers/char/drm/drm_vm.h	Fri Jan 24 20:41:05 2003
@@ -108,12 +108,12 @@
                  * Get the page, inc the use count, and return it
                  */
 		offset =3D (baddr - agpmem->bound) >> PAGE_SHIFT;
-		agpmem->memory->memory[offset] &=3D dev->agp->page_mask;
 		page =3D virt_to_page(__va(agpmem->memory->memory[offset]));
 		get_page(page);
=20
-		DRM_DEBUG("baddr =3D 0x%lx page =3D 0x%p, offset =3D 0x%lx\n",
-			  baddr, __va(agpmem->memory->memory[offset]), offset);
+		DRM_DEBUG("baddr =3D 0x%lx page =3D 0x%p, offset =3D 0x%lx, count=3D%d\n=
",
+			  baddr, __va(agpmem->memory->memory[offset]), offset,
+			  atomic_read(&page->count));
=20
 		return page;
         }
@@ -207,7 +207,7 @@
 					DRM_DEBUG("mtrr_del =3D %d\n", retcode);
 				}
 #endif
-				DRM(ioremapfree)(map->handle, map->size);
+				DRM(ioremapfree)(map->handle, map->size, dev);
 				break;
 			case _DRM_SHM:
 				vfree(map->handle);
@@ -421,15 +421,16 @@
=20
 	switch (map->type) {
         case _DRM_AGP:
-#if defined(__alpha__)
+#if __REALLY_HAVE_AGP
+	  if (dev->agp->cant_use_aperture) {
                 /*
-                 * On Alpha we can't talk to bus dma address from the
-                 * CPU, so for memory of type DRM_AGP, we'll deal with
-                 * sorting out the real physical pages and mappings
-                 * in nopage()
+                 * On some platforms we can't talk to bus dma address from=
 the CPU, so for
+                 * memory of type DRM_AGP, we'll deal with sorting out the=
 real physical
+                 * pages and mappings in nopage()
                  */
                 vma->vm_ops =3D &DRM(vm_ops);
                 break;
+	  }
 #endif
                 /* fall through to _DRM_FRAME_BUFFER... */       =20
 	case _DRM_FRAME_BUFFER:
@@ -440,15 +441,15 @@
 				pgprot_val(vma->vm_page_prot) |=3D _PAGE_PCD;
 				pgprot_val(vma->vm_page_prot) &=3D ~_PAGE_PWT;
 			}
-#elif defined(__ia64__)
-			if (map->type !=3D _DRM_AGP)
-				vma->vm_page_prot -					pgprot_writecombine(vma->vm_page_prot);
 #elif defined(__powerpc__)
 			pgprot_val(vma->vm_page_prot) |=3D _PAGE_NO_CACHE | _PAGE_GUARDED;
 #endif
 			vma->vm_flags |=3D VM_IO;	/* not in core dump */
 		}
+#if defined(__ia64__)
+		if (map->type !=3D _DRM_AGP)
+			vma->vm_page_prot =3D pgprot_writecombine(vma->vm_page_prot);
+#endif
 		offset =3D DRIVER_GET_REG_OFS();
 #ifdef __sparc__
 		if (io_remap_page_range(DRM_RPR_ARG(vma) vma->vm_start,
diff -Nru a/drivers/char/drm/gamma_dma.c b/drivers/char/drm/gamma_dma.c
--- a/drivers/char/drm/gamma_dma.c	Fri Jan 24 20:41:05 2003
+++ b/drivers/char/drm/gamma_dma.c	Fri Jan 24 20:41:05 2003
@@ -637,7 +637,7 @@
 	} else {
 		DRM_FIND_MAP( dev_priv->buffers, init->buffers_offset );
=20
-		DRM_IOREMAP( dev_priv->buffers );
+		DRM_IOREMAP( dev_priv->buffers, dev );
=20
 		buf =3D dma->buflist[GLINT_DRI_BUF_COUNT];
 		pgt =3D buf->address;
@@ -667,7 +667,7 @@
 	if ( dev->dev_private ) {
 		drm_gamma_private_t *dev_priv =3D dev->dev_private;
=20
-		DRM_IOREMAPFREE( dev_priv->buffers );
+		DRM_IOREMAPFREE( dev_priv->buffers, dev );
=20
 		DRM(free)( dev->dev_private, sizeof(drm_gamma_private_t),
 			   DRM_MEM_DRIVER );
diff -Nru a/drivers/char/drm/i810_dma.c b/drivers/char/drm/i810_dma.c
--- a/drivers/char/drm/i810_dma.c	Fri Jan 24 20:41:05 2003
+++ b/drivers/char/drm/i810_dma.c	Fri Jan 24 20:41:05 2003
@@ -275,7 +275,7 @@
=20
 	   	if(dev_priv->ring.virtual_start) {
 		   	DRM(ioremapfree)((void *) dev_priv->ring.virtual_start,
-					 dev_priv->ring.Size);
+					 dev_priv->ring.Size, dev);
 		}
 	   	if(dev_priv->hw_status_page !=3D 0UL) {
 		   	pci_free_consistent(dev->pdev, PAGE_SIZE,
@@ -291,7 +291,7 @@
 		for (i =3D 0; i < dma->buf_count; i++) {
 			drm_buf_t *buf =3D dma->buflist[ i ];
 			drm_i810_buf_priv_t *buf_priv =3D buf->dev_private;
-			DRM(ioremapfree)(buf_priv->kernel_virtual, buf->total);
+			DRM(ioremapfree)(buf_priv->kernel_virtual, buf->total, dev);
 		}
 	}
    	return 0;
@@ -361,7 +361,7 @@
 	   	*buf_priv->in_use =3D I810_BUF_FREE;
=20
 		buf_priv->kernel_virtual =3D DRM(ioremap)(buf->bus_address,
-							buf->total);
+							buf->total, dev);
 	}
 	return 0;
 }
@@ -414,7 +414,7 @@
=20
    	dev_priv->ring.virtual_start =3D DRM(ioremap)(dev->agp->base +
 						    init->ring_start,
-						    init->ring_size);
+						    init->ring_size, dev);
=20
    	if (dev_priv->ring.virtual_start =3D NULL) {
 		dev->dev_private =3D (void *) dev_priv;
diff -Nru a/drivers/char/drm/i830_dma.c b/drivers/char/drm/i830_dma.c
--- a/drivers/char/drm/i830_dma.c	Fri Jan 24 20:41:05 2003
+++ b/drivers/char/drm/i830_dma.c	Fri Jan 24 20:41:05 2003
@@ -283,7 +283,7 @@
 	  =20
 	   	if(dev_priv->ring.virtual_start) {
 		   	DRM(ioremapfree)((void *) dev_priv->ring.virtual_start,
-					 dev_priv->ring.Size);
+					 dev_priv->ring.Size, dev);
 		}
 	   	if(dev_priv->hw_status_page !=3D 0UL) {
 		   	pci_free_consistent(dev->pdev, PAGE_SIZE,
@@ -299,7 +299,7 @@
 		for (i =3D 0; i < dma->buf_count; i++) {
 			drm_buf_t *buf =3D dma->buflist[ i ];
 			drm_i830_buf_priv_t *buf_priv =3D buf->dev_private;
-			DRM(ioremapfree)(buf_priv->kernel_virtual, buf->total);
+			DRM(ioremapfree)(buf_priv->kernel_virtual, buf->total, dev);
 		}
 	}
    	return 0;
@@ -371,7 +371,7 @@
 	   	*buf_priv->in_use =3D I830_BUF_FREE;
=20
 		buf_priv->kernel_virtual =3D DRM(ioremap)(buf->bus_address,=20
-							buf->total);
+							buf->total, dev);
 	}
 	return 0;
 }
@@ -425,7 +425,7 @@
=20
    	dev_priv->ring.virtual_start =3D DRM(ioremap)(dev->agp->base +=20
 						    init->ring_start,=20
-						    init->ring_size);
+						    init->ring_size, dev);
=20
    	if (dev_priv->ring.virtual_start =3D NULL) {
 		dev->dev_private =3D (void *) dev_priv;
diff -Nru a/drivers/char/drm/mga_dma.c b/drivers/char/drm/mga_dma.c
--- a/drivers/char/drm/mga_dma.c	Fri Jan 24 20:41:05 2003
+++ b/drivers/char/drm/mga_dma.c	Fri Jan 24 20:41:05 2003
@@ -554,9 +554,9 @@
 		(drm_mga_sarea_t *)((u8 *)dev_priv->sarea->handle +
 				    init->sarea_priv_offset);
=20
-	DRM_IOREMAP( dev_priv->warp );
-	DRM_IOREMAP( dev_priv->primary );
-	DRM_IOREMAP( dev_priv->buffers );
+	DRM_IOREMAP( dev_priv->warp, dev );
+	DRM_IOREMAP( dev_priv->primary, dev );
+	DRM_IOREMAP( dev_priv->buffers, dev );
=20
 	if(!dev_priv->warp->handle ||
 	   !dev_priv->primary->handle ||
@@ -642,9 +642,9 @@
 	if ( dev->dev_private ) {
 		drm_mga_private_t *dev_priv =3D dev->dev_private;
=20
-		DRM_IOREMAPFREE( dev_priv->warp );
-		DRM_IOREMAPFREE( dev_priv->primary );
-		DRM_IOREMAPFREE( dev_priv->buffers );
+		DRM_IOREMAPFREE( dev_priv->warp, dev );
+		DRM_IOREMAPFREE( dev_priv->primary, dev );
+		DRM_IOREMAPFREE( dev_priv->buffers, dev );
=20
 		if ( dev_priv->head !=3D NULL ) {
 			mga_freelist_cleanup( dev );
diff -Nru a/drivers/char/drm/mga_drv.h b/drivers/char/drm/mga_drv.h
--- a/drivers/char/drm/mga_drv.h	Fri Jan 24 20:41:05 2003
+++ b/drivers/char/drm/mga_drv.h	Fri Jan 24 20:41:05 2003
@@ -238,7 +238,7 @@
 	if ( MGA_VERBOSE ) {						\
 		DRM_INFO( "BEGIN_DMA( %d ) in %s\n",			\
 			  (n), __FUNCTION__ );				\
-		DRM_INFO( "   space=3D0x%x req=3D0x%x\n",			\
+		DRM_INFO( "   space=3D0x%x req=3D0x%Zx\n",			\
 			  dev_priv->prim.space, (n) * DMA_BLOCK_SIZE );	\
 	}								\
 	prim =3D dev_priv->prim.start;					\
@@ -288,7 +288,7 @@
 #define DMA_WRITE( offset, val )					\
 do {									\
 	if ( MGA_VERBOSE ) {						\
-		DRM_INFO( "   DMA_WRITE( 0x%08x ) at 0x%04x\n",		\
+		DRM_INFO( "   DMA_WRITE( 0x%08x ) at 0x%04Zx\n",	\
 			  (u32)(val), write + (offset) * sizeof(u32) );	\
 	}								\
 	*(volatile u32 *)(prim + write + (offset) * sizeof(u32)) =3D val;	\
diff -Nru a/drivers/char/drm/r128_cce.c b/drivers/char/drm/r128_cce.c
--- a/drivers/char/drm/r128_cce.c	Fri Jan 24 20:41:05 2003
+++ b/drivers/char/drm/r128_cce.c	Fri Jan 24 20:41:05 2003
@@ -350,8 +350,8 @@
=20
 		R128_WRITE( R128_PM4_BUFFER_DL_RPTR_ADDR,
      			    entry->busaddr[page_ofs]);
-		DRM_DEBUG( "ring rptr: offset=3D0x%08x handle=3D0x%08lx\n",
-			   entry->busaddr[page_ofs],
+		DRM_DEBUG( "ring rptr: offset=3D0x%08lx handle=3D0x%08lx\n",
+			   (unsigned long) entry->busaddr[page_ofs],
      			   entry->handle + tmp_ofs );
 	}
=20
@@ -540,9 +540,9 @@
 				     init->sarea_priv_offset);
=20
 	if ( !dev_priv->is_pci ) {
-		DRM_IOREMAP( dev_priv->cce_ring );
-		DRM_IOREMAP( dev_priv->ring_rptr );
-		DRM_IOREMAP( dev_priv->buffers );
+		DRM_IOREMAP( dev_priv->cce_ring, dev );
+		DRM_IOREMAP( dev_priv->ring_rptr, dev );
+		DRM_IOREMAP( dev_priv->buffers, dev );
 		if(!dev_priv->cce_ring->handle ||
 		   !dev_priv->ring_rptr->handle ||
 		   !dev_priv->buffers->handle) {
@@ -618,9 +618,9 @@
 #if __REALLY_HAVE_SG
 		if ( !dev_priv->is_pci ) {
 #endif
-			DRM_IOREMAPFREE( dev_priv->cce_ring );
-			DRM_IOREMAPFREE( dev_priv->ring_rptr );
-			DRM_IOREMAPFREE( dev_priv->buffers );
+			DRM_IOREMAPFREE( dev_priv->cce_ring, dev );
+			DRM_IOREMAPFREE( dev_priv->ring_rptr, dev );
+			DRM_IOREMAPFREE( dev_priv->buffers, dev );
 #if __REALLY_HAVE_SG
 		} else {
 			if (!DRM(ati_pcigart_cleanup)( dev,
diff -Nru a/drivers/char/drm/radeon_cp.c b/drivers/char/drm/radeon_cp.c
--- a/drivers/char/drm/radeon_cp.c	Fri Jan 24 20:41:05 2003
+++ b/drivers/char/drm/radeon_cp.c	Fri Jan 24 20:41:05 2003
@@ -904,8 +904,8 @@
=20
 		RADEON_WRITE( RADEON_CP_RB_RPTR_ADDR,
 			     entry->busaddr[page_ofs]);
-		DRM_DEBUG( "ring rptr: offset=3D0x%08x handle=3D0x%08lx\n",
-			   entry->busaddr[page_ofs],
+		DRM_DEBUG( "ring rptr: offset=3D0x%08lx handle=3D0x%08lx\n",
+			   (unsigned long) entry->busaddr[page_ofs],
 			   entry->handle + tmp_ofs );
 	}
=20
@@ -1157,9 +1157,9 @@
 				       init->sarea_priv_offset);
=20
 	if ( !dev_priv->is_pci ) {
-		DRM_IOREMAP( dev_priv->cp_ring );
-		DRM_IOREMAP( dev_priv->ring_rptr );
-		DRM_IOREMAP( dev_priv->buffers );
+		DRM_IOREMAP( dev_priv->cp_ring, dev );
+		DRM_IOREMAP( dev_priv->ring_rptr, dev );
+		DRM_IOREMAP( dev_priv->buffers, dev );
 		if(!dev_priv->cp_ring->handle ||
 		   !dev_priv->ring_rptr->handle ||
 		   !dev_priv->buffers->handle) {
@@ -1278,9 +1278,9 @@
 		drm_radeon_private_t *dev_priv =3D dev->dev_private;
=20
 		if ( !dev_priv->is_pci ) {
-			DRM_IOREMAPFREE( dev_priv->cp_ring );
-			DRM_IOREMAPFREE( dev_priv->ring_rptr );
-			DRM_IOREMAPFREE( dev_priv->buffers );
+			DRM_IOREMAPFREE( dev_priv->cp_ring, dev );
+			DRM_IOREMAPFREE( dev_priv->ring_rptr, dev );
+			DRM_IOREMAPFREE( dev_priv->buffers, dev );
 		} else {
 #if __REALLY_HAVE_SG
 			if (!DRM(ati_pcigart_cleanup)( dev,
diff -Nru a/drivers/char/mem.c b/drivers/char/mem.c
--- a/drivers/char/mem.c	Fri Jan 24 20:41:05 2003
+++ b/drivers/char/mem.c	Fri Jan 24 20:41:05 2003
@@ -528,10 +528,12 @@
 		case 0:
 			file->f_pos =3D offset;
 			ret =3D file->f_pos;
+			force_successful_syscall_return();
 			break;
 		case 1:
 			file->f_pos +=3D offset;
 			ret =3D file->f_pos;
+			force_successful_syscall_return();
 			break;
 		default:
 			ret =3D -EINVAL;
diff -Nru a/drivers/media/radio/Makefile b/drivers/media/radio/Makefile
--- a/drivers/media/radio/Makefile	Fri Jan 24 20:41:05 2003
+++ b/drivers/media/radio/Makefile	Fri Jan 24 20:41:05 2003
@@ -5,6 +5,8 @@
 # All of the (potential) objects that export symbols.
 # This list comes from 'grep -l EXPORT_SYMBOL *.[hc]'.
=20
+obj-y		:=3D dummy.o
+
 export-objs     :=3D miropcm20-rds-core.o
=20
 miropcm20-objs	:=3D miropcm20-rds-core.o miropcm20-radio.o
diff -Nru a/drivers/media/radio/dummy.c b/drivers/media/radio/dummy.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/drivers/media/radio/dummy.c	Fri Jan 24 20:41:06 2003
@@ -0,0 +1 @@
+/* just so the linker knows what kind of object files it's deadling with..=
. */
diff -Nru a/drivers/media/video/Makefile b/drivers/media/video/Makefile
--- a/drivers/media/video/Makefile	Fri Jan 24 20:41:05 2003
+++ b/drivers/media/video/Makefile	Fri Jan 24 20:41:05 2003
@@ -12,6 +12,8 @@
 			bttv-risc.o bttv-vbi.o
 zoran-objs      :=3D	zr36120.o zr36120_i2c.o zr36120_mem.o
=20
+obj-y		:=3D	dummy.o
+
 obj-$(CONFIG_VIDEO_DEV) +=3D videodev.o v4l2-common.o v4l1-compat.o
=20
 obj-$(CONFIG_VIDEO_BT848) +=3D bttv.o msp3400.o tvaudio.o \
diff -Nru a/drivers/media/video/dummy.c b/drivers/media/video/dummy.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/drivers/media/video/dummy.c	Fri Jan 24 20:41:06 2003
@@ -0,0 +1 @@
+/* just so the linker knows what kind of object files it's deadling with..=
. */
diff -Nru a/drivers/net/tulip/media.c b/drivers/net/tulip/media.c
--- a/drivers/net/tulip/media.c	Fri Jan 24 20:41:05 2003
+++ b/drivers/net/tulip/media.c	Fri Jan 24 20:41:05 2003
@@ -278,6 +278,10 @@
 				for (i =3D 0; i < init_length; i++)
 					outl(init_sequence[i], ioaddr + CSR12);
 			}
+
+			(void) inl(ioaddr + CSR6); /* flush CSR12 writes */
+			udelay(500);		/* Give MII time to recover */
+
 			tmp_info =3D get_u16(&misc_info[1]);
 			if (tmp_info)
 				tp->advertising[phy_num] =3D tmp_info | 1;
diff -Nru a/drivers/scsi/megaraid.c b/drivers/scsi/megaraid.c
--- a/drivers/scsi/megaraid.c	Fri Jan 24 20:41:05 2003
+++ b/drivers/scsi/megaraid.c	Fri Jan 24 20:41:05 2003
@@ -2045,7 +2045,7 @@
 		return;
=20
 	mbox =3D (mega_mailbox *) pScb->mboxData;
-	printk ("%u cmd:%x id:%x #scts:%x lba:%x addr:%x logdrv:%x #sg:%x\n",
+	printk ("%lu cmd:%x id:%x #scts:%x lba:%x addr:%x logdrv:%x #sg:%x\n",
 		pScb->SCpnt->pid,
 		mbox->cmd, mbox->cmdid, mbox->numsectors,
 		mbox->lba, mbox->xferaddr, mbox->logdrv, mbox->numsgelements);
@@ -3351,9 +3351,13 @@
 	mbox[0] =3D IS_BIOS_ENABLED;
 	mbox[2] =3D GET_BIOS;
=20
-	mboxpnt->xferaddr =3D virt_to_bus ((void *) megacfg->mega_buffer);
+	mboxpnt->xferaddr =3D pci_map_single(megacfg->dev,
+				(void *) megacfg->mega_buffer, (2 * 1024L),
+				PCI_DMA_FROMDEVICE);
=20
 	ret =3D megaIssueCmd (megacfg, mbox, NULL, 0);
+
+	pci_unmap_single(megacfg->dev, mboxpnt->xferaddr, 2 * 1024L, PCI_DMA_FROM=
DEVICE);
=20
 	return (*(char *) megacfg->mega_buffer);
 }
diff -Nru a/drivers/scsi/scsi_ioctl.c b/drivers/scsi/scsi_ioctl.c
--- a/drivers/scsi/scsi_ioctl.c	Fri Jan 24 20:41:05 2003
+++ b/drivers/scsi/scsi_ioctl.c	Fri Jan 24 20:41:05 2003
@@ -219,6 +219,9 @@
 	unsigned int needed, buf_needed;
 	int timeout, retries, result;
 	int data_direction, gfp_mask =3D GFP_KERNEL;
+#if __GNUC__ < 3
+	int foo;
+#endif
=20
 	if (!sic)
 		return -EINVAL;
@@ -232,11 +235,21 @@
 	if (verify_area(VERIFY_READ, sic, sizeof(Scsi_Ioctl_Command)))
 		return -EFAULT;
=20
+#if __GNUC__ < 3
+	foo =3D __get_user(inlen, &sic->inlen);
+	if (foo)
+		return -EFAULT;
+
+	foo =3D __get_user(outlen, &sic->outlen);
+	if (foo)
+		return -EFAULT;
+#else
 	if(__get_user(inlen, &sic->inlen))
 		return -EFAULT;
 	=09
 	if(__get_user(outlen, &sic->outlen))
 		return -EFAULT;
+#endif
=20
 	/*
 	 * We do not transfer more than MAX_BUF with this interface.
diff -Nru a/drivers/scsi/sym53c8xx_2/sym_glue.c b/drivers/scsi/sym53c8xx_2/=
sym_glue.c
--- a/drivers/scsi/sym53c8xx_2/sym_glue.c	Fri Jan 24 20:41:06 2003
+++ b/drivers/scsi/sym53c8xx_2/sym_glue.c	Fri Jan 24 20:41:06 2003
@@ -295,11 +295,7 @@
 #ifndef SYM_LINUX_DYNAMIC_DMA_MAPPING
 typedef u_long		bus_addr_t;
 #else
-#if	SYM_CONF_DMA_ADDRESSING_MODE > 0
-typedef dma64_addr_t	bus_addr_t;
-#else
 typedef dma_addr_t	bus_addr_t;
-#endif
 #endif
=20
 /*
diff -Nru a/drivers/scsi/sym53c8xx_2/sym_malloc.c b/drivers/scsi/sym53c8xx_=
2/sym_malloc.c
--- a/drivers/scsi/sym53c8xx_2/sym_malloc.c	Fri Jan 24 20:41:05 2003
+++ b/drivers/scsi/sym53c8xx_2/sym_malloc.c	Fri Jan 24 20:41:05 2003
@@ -143,12 +143,14 @@
 	a =3D (m_addr_t) ptr;
=20
 	while (1) {
-#ifdef SYM_MEM_FREE_UNUSED
 		if (s =3D SYM_MEM_CLUSTER_SIZE) {
+#ifdef SYM_MEM_FREE_UNUSED
 			M_FREE_MEM_CLUSTER(a);
-			break;
-		}
+#else
+			((m_link_p) a)->next =3D h[i].next;
+			h[i].next =3D (m_link_p) a;
 #endif
+		}
 		b =3D a ^ s;
 		q =3D &h[i];
 		while (q->next && q->next !=3D (m_link_p) b) {
diff -Nru a/drivers/serial/8250.c b/drivers/serial/8250.c
--- a/drivers/serial/8250.c	Fri Jan 24 20:41:05 2003
+++ b/drivers/serial/8250.c	Fri Jan 24 20:41:05 2003
@@ -1999,9 +1999,11 @@
 	return __register_serial(req, -1);
 }
=20
-int __init early_serial_setup(struct serial_struct *req)
+int __init early_serial_setup(struct uart_port *port)
 {
-	__register_serial(req, req->line);
+	serial8250_isa_init_ports();
+	serial8250_ports[port->line].port	=3D *port;
+	serial8250_ports[port->line].port.ops	=3D &serial8250_pops;
 	return 0;
 }
=20
diff -Nru a/drivers/serial/8250_acpi.c b/drivers/serial/8250_acpi.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/drivers/serial/8250_acpi.c	Fri Jan 24 20:41:06 2003
@@ -0,0 +1,178 @@
+/*
+ * linux/drivers/char/acpi_serial.c
+ *
+ * Copyright (C) 2000, 2002 Hewlett-Packard Co.
+ *	Khalid Aziz <khalid_aziz@hp.com>
+ *
+ * Detect and initialize the headless console serial port defined in SPCR =
table and debug
+ * serial port defined in DBGP table.
+ *
+ * 2002/08/29 davidm	Adjust it to new 2.5 serial driver infrastructure.
+ */
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/acpi.h>
+#include <linux/init.h>
+#include <linux/tty.h>
+#include <linux/serial.h>
+#include <linux/serial_core.h>
+#include <linux/acpi_serial.h>
+
+#include <asm/io.h>
+#include <asm/serial.h>
+
+#undef SERIAL_DEBUG_ACPI
+
+#define ACPI_SERIAL_CONSOLE_PORT	0
+#define ACPI_SERIAL_DEBUG_PORT		5
+
+/*
+ * Query ACPI tables for a debug and a headless console serial port. If fo=
und, add them to
+ * rs_table[]. A pointer to either SPCR or DBGP table is passed as paramet=
er. This
+ * function should be called before serial_console_init() is called to mak=
e sure the SPCR
+ * serial console will be available for use. IA-64 kernel calls this funct=
ion from within
+ * acpi.c when it encounters SPCR or DBGP tables as it parses the ACPI 2.0=
 tables during
+ * bootup.
+ */
+void __init
+setup_serial_acpi (void *tablep)
+{
+	acpi_ser_t *acpi_ser_p;
+	struct uart_port port;
+	unsigned long iobase;
+	int gsi;
+
+#ifdef SERIAL_DEBUG_ACPI
+	printk("Entering setup_serial_acpi()\n");
+#endif
+
+	/* Now get the table */
+	if (!tablep)
+		return;
+
+	memset(&port, 0, sizeof(port));
+
+	acpi_ser_p =3D (acpi_ser_t *) tablep;
+
+	/*
+	 * Perform a sanity check on the table. Table should have a signature of =
"SPCR" or
+	 * "DBGP" and it should be atleast 52 bytes long.
+	 */
+	if (strncmp(acpi_ser_p->signature, ACPI_SPCRT_SIGNATURE, ACPI_SIG_LEN) !=
=3D 0 &&
+	    strncmp(acpi_ser_p->signature, ACPI_DBGPT_SIGNATURE, ACPI_SIG_LEN) !=
=3D 0)
+		return;
+	if (acpi_ser_p->length < 52)
+		return;
+
+	iobase =3D (((u64) acpi_ser_p->base_addr.addrh) << 32) | acpi_ser_p->base=
_addr.addrl;
+	gsi =3D (  (acpi_ser_p->global_int[3] << 24) | (acpi_ser_p->global_int[2]=
 << 16)
+	       | (acpi_ser_p->global_int[1] <<  8) | (acpi_ser_p->global_int[0] <=
<  0));
+
+#ifdef SERIAL_DEBUG_ACPI
+	printk("setup_serial_acpi(): table pointer =3D 0x%p\n", acpi_ser_p);
+	printk("                     sig =3D '%c%c%c%c'\n", acpi_ser_p->signature=
[0],
+	       acpi_ser_p->signature[1], acpi_ser_p->signature[2], acpi_ser_p->si=
gnature[3]);
+	printk("                     length =3D %d\n", acpi_ser_p->length);
+	printk("                     Rev =3D %d\n", acpi_ser_p->rev);
+	printk("                     Interface type =3D %d\n", acpi_ser_p->intfc_=
type);
+	printk("                     Base address =3D 0x%lX\n", iobase);
+	printk("                     IRQ =3D %d\n", acpi_ser_p->irq);
+	printk("                     Global System Int =3D %d\n", gsi);
+	printk("                     Baud rate =3D ");
+	switch (acpi_ser_p->baud) {
+	      case ACPI_SERIAL_BAUD_9600:
+		printk("9600\n");
+		break;
+
+	      case ACPI_SERIAL_BAUD_19200:
+		printk("19200\n");
+		break;
+
+	      case ACPI_SERIAL_BAUD_57600:
+		printk("57600\n");
+		break;
+
+	      case ACPI_SERIAL_BAUD_115200:
+		printk("115200\n");
+		break;
+
+	      default:
+		printk("Huh (%d)\n", acpi_ser_p->baud);
+		break;
+	}
+	if (acpi_ser_p->base_addr.space_id =3D ACPI_SERIAL_PCICONF_SPACE) {
+		printk("                     PCI serial port:\n");
+		printk("                         Bus %d, Device %d, Vendor ID 0x%x, Dev =
ID 0x%x\n",
+		       acpi_ser_p->pci_bus, acpi_ser_p->pci_dev,
+		       acpi_ser_p->pci_vendor_id, acpi_ser_p->pci_dev_id);
+	}
+#endif
+	/*
+	 * Now build a serial_req structure to update the entry in rs_table for t=
he
+	 * headless console port.
+	 */
+	switch (acpi_ser_p->intfc_type) {
+	      case ACPI_SERIAL_INTFC_16550:
+		port.type =3D PORT_16550;
+		port.uartclk =3D BASE_BAUD * 16;
+		break;
+
+	      case ACPI_SERIAL_INTFC_16450:
+		port.type =3D PORT_16450;
+		port.uartclk =3D BASE_BAUD * 16;
+		break;
+
+	      default:
+		port.type =3D PORT_UNKNOWN;
+		break;
+	}
+	if (strncmp(acpi_ser_p->signature, ACPI_SPCRT_SIGNATURE, ACPI_SIG_LEN) =
=3D 0)
+		port.line =3D ACPI_SERIAL_CONSOLE_PORT;
+	else if (strncmp(acpi_ser_p->signature, ACPI_DBGPT_SIGNATURE, ACPI_SIG_LE=
N) =3D 0)
+		port.line =3D ACPI_SERIAL_DEBUG_PORT;
+	/*
+	 * Check if this is an I/O mapped address or a memory mapped address
+	 */
+	if (acpi_ser_p->base_addr.space_id =3D ACPI_SERIAL_MEM_SPACE) {
+		port.iobase =3D 0;
+		port.mapbase =3D iobase;
+		port.membase =3D ioremap(iobase, 64);
+		port.iotype =3D SERIAL_IO_MEM;
+	} else if (acpi_ser_p->base_addr.space_id =3D ACPI_SERIAL_IO_SPACE) {
+		port.iobase =3D iobase;
+		port.mapbase =3D 0;
+		port.membase =3D NULL;
+		port.iotype =3D SERIAL_IO_PORT;
+	} else if (acpi_ser_p->base_addr.space_id =3D ACPI_SERIAL_PCICONF_SPACE) {
+		printk("WARNING: No support for PCI serial console\n");
+		return;
+	}
+
+	/*
+	 * If the table does not have IRQ information, use 0 for IRQ.  This will =
force
+	 * rs_init() to probe for IRQ.
+	 */
+	if (acpi_ser_p->length < 53)
+		port.irq =3D 0;
+	else {
+		port.flags =3D UPF_SKIP_TEST | UPF_BOOT_AUTOCONF | UPF_AUTO_IRQ;
+		if (acpi_ser_p->int_type & (ACPI_SERIAL_INT_APIC | ACPI_SERIAL_INT_SAPIC=
))
+			port.irq =3D gsi;
+		else if (acpi_ser_p->int_type & ACPI_SERIAL_INT_PCAT)
+			port.irq =3D acpi_ser_p->irq;
+		else
+			/*
+			 * IRQ type not being set would mean UART will run in polling
+			 * mode. Do not probe for IRQ in that case.
+			 */
+			port.flags &=3D UPF_AUTO_IRQ;
+	}
+	if (early_serial_setup(&port) < 0) {
+		printk("early_serial_setup() for ACPI serial console port failed\n");
+		return;
+	}
+
+#ifdef SERIAL_DEBUG_ACPI
+	printk("Leaving setup_serial_acpi()\n");
+#endif
+}
diff -Nru a/drivers/serial/8250_hcdp.c b/drivers/serial/8250_hcdp.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/drivers/serial/8250_hcdp.c	Fri Jan 24 20:41:06 2003
@@ -0,0 +1,215 @@
+/*
+ * linux/drivers/char/hcdp_serial.c
+ *
+ * Copyright (C) 2002 Hewlett-Packard Co.
+ *	Khalid Aziz <khalid_aziz@hp.com>
+ *
+ * Parse the EFI HCDP table to locate serial console and debug ports and i=
nitialize them.
+ *
+ * 2002/08/29 davidm	Adjust it to new 2.5 serial driver infrastructure (un=
tested).
+ */
+#include <linux/config.h>
+
+#include <linux/kernel.h>
+#include <linux/efi.h>
+#include <linux/init.h>
+#include <linux/tty.h>
+#include <linux/serial.h>
+#include <linux/serial_core.h>
+#include <linux/types.h>
+
+#include <asm/io.h>
+#include <asm/serial.h>
+
+#include "8250_hcdp.h"
+
+#undef SERIAL_DEBUG_HCDP
+
+/*
+ * Parse the HCDP table to find descriptions for headless console and debu=
g serial ports
+ * and add them to rs_table[]. A pointer to HCDP table is passed as parame=
ter. This
+ * function should be called before serial_console_init() is called to mak=
e sure the HCDP
+ * serial console will be available for use. IA-64 kernel calls this funct=
ion from
+ * setup_arch() after the EFI and ACPI tables have been parsed.
+ */
+void __init
+setup_serial_hcdp (void *tablep)
+{
+	hcdp_dev_t *hcdp_dev;
+	struct uart_port port;
+	unsigned long iobase;
+	hcdp_t hcdp;
+	int gsi, nr;
+#if 0
+	static int shift_once =3D 1;
+#endif
+
+#ifdef SERIAL_DEBUG_HCDP
+	printk("Entering setup_serial_hcdp()\n");
+#endif
+
+	/* Verify we have a valid table pointer */
+	if (!tablep)
+		return;
+
+	memset(&port, 0, sizeof(port));
+
+	/*
+	 * Don't trust firmware to give us a table starting at an aligned address=
. Make a
+	 * local copy of the HCDP table with aligned structures.
+	 */
+	memcpy(&hcdp, tablep, sizeof(hcdp));
+
+	/*
+	 * Perform a sanity check on the table. Table should have a signature of =
"HCDP"
+	 * and it should be atleast 82 bytes long to have any useful information.
+	 */
+	if ((strncmp(hcdp.signature, HCDP_SIGNATURE, HCDP_SIG_LEN) !=3D 0))
+		return;
+	if (hcdp.len < 82)
+		return;
+
+#ifdef SERIAL_DEBUG_HCDP
+	printk("setup_serial_hcdp(): table pointer =3D 0x%p, sig =3D '%.4s'\n",
+	       tablep, hcdp.signature);
+	printk(" length =3D %d, rev =3D %d, ", hcdp.len, hcdp.rev);
+	printk("OEM ID =3D %.6s, # of entries =3D %d\n", hcdp.oemid, hcdp.num_ent=
ries);
+#endif
+
+	/*
+	 * Parse each device entry
+	 */
+	for (nr =3D 0; nr < hcdp.num_entries; nr++) {
+		hcdp_dev =3D hcdp.hcdp_dev + nr;
+		/*
+		 * We will parse only the primary console device which is the first entry
+		 * for these devices. We will ignore rest of the entries for the same ty=
pe
+		 * device that has already been parsed and initialized
+		 */
+		if (hcdp_dev->type !=3D HCDP_DEV_CONSOLE)
+			continue;
+
+		iobase =3D ((u64) hcdp_dev->base_addr.addrhi << 32) | hcdp_dev->base_add=
r.addrlo;
+		gsi =3D hcdp_dev->global_int;
+
+		/* See PCI spec v2.2, Appendix D (Class Codes): */
+		switch (hcdp_dev->pci_prog_intfc) {
+		      case 0x00: port.type =3D PORT_8250;  break;
+		      case 0x01: port.type =3D PORT_16450; break;
+		      case 0x02: port.type =3D PORT_16550; break;
+		      case 0x03: port.type =3D PORT_16650; break;
+		      case 0x04: port.type =3D PORT_16750; break;
+		      case 0x05: port.type =3D PORT_16850; break;
+		      case 0x06: port.type =3D PORT_16C950; break;
+		      default:
+			printk(KERN_WARNING"warning: EFI HCDP table reports unknown serial "
+			       "programming interface 0x%02x; will autoprobe.\n",
+			       hcdp_dev->pci_prog_intfc);
+			port.type =3D PORT_UNKNOWN;
+			break;
+		}
+
+#ifdef SERIAL_DEBUG_HCDP
+		printk("  type =3D %s, uart =3D %d\n", ((hcdp_dev->type =3D HCDP_DEV_CON=
SOLE)
+					 ? "Headless Console" : ((hcdp_dev->type =3D HCDP_DEV_DEBUG)
+								 ? "Debug port" : "Huh????")),
+		       port.type);
+		printk("  base address space =3D %s, base address =3D 0x%lx\n",
+		       ((hcdp_dev->base_addr.space_id =3D ACPI_MEM_SPACE)
+			? "Memory Space" : ((hcdp_dev->base_addr.space_id =3D ACPI_IO_SPACE)
+					    ? "I/O space" : "PCI space")),
+		       iobase);
+		printk("  gsi =3D %d, baud rate =3D %lu, bits =3D %d, clock =3D %d\n",
+		       gsi, (unsigned long) hcdp_dev->baud, hcdp_dev->bits, hcdp_dev->cl=
ock_rate);
+		if (hcdp_dev->base_addr.space_id =3D ACPI_PCICONF_SPACE)
+			printk(" PCI id: %02x:%02x:%02x, vendor ID=3D0x%x, dev ID=3D0x%x\n",
+			       hcdp_dev->pci_seg, hcdp_dev->pci_bus, hcdp_dev->pci_dev,
+			       hcdp_dev->pci_vendor_id, hcdp_dev->pci_dev_id);
+#endif
+		/*
+		 * Now fill in a port structure to update the 8250 port table..
+		 */
+		if (hcdp_dev->clock_rate)
+			port.uartclk =3D hcdp_dev->clock_rate;
+		else
+			port.uartclk =3D BASE_BAUD * 16;
+
+		/*
+		 * Check if this is an I/O mapped address or a memory mapped address
+		 */
+		if (hcdp_dev->base_addr.space_id =3D ACPI_MEM_SPACE) {
+			port.iobase =3D 0;
+			port.mapbase =3D iobase;
+			port.membase =3D ioremap(iobase, 64);
+			port.iotype =3D SERIAL_IO_MEM;
+		} else if (hcdp_dev->base_addr.space_id =3D ACPI_IO_SPACE) {
+			port.iobase =3D iobase;
+			port.mapbase =3D 0;
+			port.membase =3D NULL;
+			port.iotype =3D SERIAL_IO_PORT;
+		} else if (hcdp_dev->base_addr.space_id =3D ACPI_PCICONF_SPACE) {
+			printk(KERN_WARNING"warning: No support for PCI serial console\n");
+			return;
+		}
+		port.irq =3D gsi;
+		port.flags =3D UPF_SKIP_TEST | UPF_BOOT_AUTOCONF;
+		if (gsi)
+			port.flags |=3D ASYNC_AUTO_IRQ;
+
+		/*
+		 * Note: the above memset() initializes port.line to 0, so we register
+		 * this port as ttyS0.
+		 */
+		if (early_serial_setup(&port) < 0) {
+			printk("setup_serial_hcdp(): early_serial_setup() for HCDP serial "
+			       "console port failed. Will try any additional consoles in HCDP.\=
n");
+			continue;
+		}
+		break;
+	}
+
+#ifdef SERIAL_DEBUG_HCDP
+	printk("Leaving setup_serial_hcdp()\n");
+#endif
+}
+
+#ifdef CONFIG_IA64_EARLY_PRINTK_UART
+unsigned long
+hcdp_early_uart (void)
+{
+	efi_system_table_t *systab;
+	efi_config_table_t *config_tables;
+	unsigned long addr =3D 0;
+	hcdp_t *hcdp =3D 0;
+	hcdp_dev_t *dev;
+	int i;
+
+	systab =3D (efi_system_table_t *) ia64_boot_param->efi_systab;
+	if (!systab)
+		return 0;
+	systab =3D __va(systab);
+
+	config_tables =3D (efi_config_table_t *) systab->tables;
+	if (!config_tables)
+		return 0;
+	config_tables =3D __va(config_tables);
+
+	for (i =3D 0; i < systab->nr_tables; i++) {
+		if (efi_guidcmp(config_tables[i].guid, HCDP_TABLE_GUID) =3D 0) {
+			hcdp =3D (hcdp_t *) config_tables[i].table;
+			break;
+		}
+	}
+	if (!hcdp)
+		return 0;
+	hcdp =3D __va(hcdp);
+
+	for (i =3D 0, dev =3D hcdp->hcdp_dev; i < hcdp->num_entries; i++, dev++) {
+		if (dev->type =3D HCDP_DEV_CONSOLE) {
+			addr =3D (u64) dev->base_addr.addrhi << 32 | dev->base_addr.addrlo;
+			break;
+		}
+	}
+	return addr;
+}
+#endif /* CONFIG_IA64_EARLY_PRINTK_UART */
diff -Nru a/drivers/serial/8250_hcdp.h b/drivers/serial/8250_hcdp.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/drivers/serial/8250_hcdp.h	Fri Jan 24 20:41:06 2003
@@ -0,0 +1,79 @@
+/*
+ * drivers/serial/8250_hcdp.h
+ *
+ * Copyright (C) 2002 Hewlett-Packard Co.
+ *	Khalid Aziz <khalid_aziz@hp.com>
+ *
+ * Definitions for HCDP defined serial ports (Serial console and debug
+ * ports)
+ */
+
+/* ACPI table signatures */
+#define HCDP_SIG_LEN		4
+#define HCDP_SIGNATURE		"HCDP"
+
+/* Space ID as defined in ACPI generic address structure */
+#define ACPI_MEM_SPACE		0
+#define ACPI_IO_SPACE		1
+#define ACPI_PCICONF_SPACE	2
+
+/*
+ * Maximum number of HCDP devices we want to read in
+ */
+#define MAX_HCDP_DEVICES	6
+
+/*
+ * Default UART clock rate if clock rate is 0 in HCDP table.
+ */
+#define DEFAULT_UARTCLK		115200
+
+/*
+ * ACPI Generic Address Structure
+ */
+typedef struct {
+	u8  space_id;
+	u8  bit_width;
+	u8  bit_offset;
+	u8  resv;
+	u32 addrlo;
+	u32 addrhi;
+} acpi_gen_addr;
+
+/* HCDP Device descriptor entry types */
+#define HCDP_DEV_CONSOLE	0
+#define HCDP_DEV_DEBUG		1
+
+/* HCDP Device descriptor type */
+typedef struct {
+	u8	type;
+	u8	bits;
+	u8	parity;
+	u8	stop_bits;
+	u8	pci_seg;
+	u8	pci_bus;
+	u8	pci_dev;
+	u8	pci_func;
+	u64	baud;
+	acpi_gen_addr	base_addr;
+	u16	pci_dev_id;
+	u16	pci_vendor_id;
+	u32	global_int;
+	u32	clock_rate;
+	u8	pci_prog_intfc;
+	u8	resv;
+} hcdp_dev_t;
+
+/* HCDP Table format */
+typedef struct {
+	u8	signature[4];
+	u32	len;
+	u8	rev;
+	u8	chksum;
+	u8	oemid[6];
+	u8	oem_tabid[8];
+	u32	oem_rev;
+	u8	creator_id[4];
+	u32	creator_rev;
+	u32	num_entries;
+	hcdp_dev_t	hcdp_dev[MAX_HCDP_DEVICES];
+} hcdp_t;
diff -Nru a/drivers/serial/Kconfig b/drivers/serial/Kconfig
--- a/drivers/serial/Kconfig	Fri Jan 24 20:41:05 2003
+++ b/drivers/serial/Kconfig	Fri Jan 24 20:41:05 2003
@@ -39,6 +39,13 @@
 	  Most people will say Y or M here, so that they can use serial mice,
 	  modems and similar devices connecting to the standard serial ports.
=20
+config SERIAL_8250_ACPI
+	tristate "8250/16550 device discovery support via ACPI SPCR/DBGP tables"
+	depends on IA64
+	help
+	  Locate serial ports via the Microsoft proprietary ACPI SPCR/DBGP tables.
+	  This table has been superseded by the EFI HCDP table.
+
 config SERIAL_8250_CONSOLE
 	bool "Console on 8250/16550 and compatible serial port (EXPERIMENTAL)"
 	depends on SERIAL_8250=3Dy
@@ -76,6 +83,15 @@
 	  The module will be called serial_cs.o.  If you want to compile it as
 	  a module, say M here and read <file:Documentation/modules.txt>.
 	  If unsure, say N.
+
+config SERIAL_8250_HCDP
+	bool "8250/16550 device discovery support via EFI HCDP table"
+	depends on IA64
+	---help---
+	  If you wish to make the serial console port described by the EFI
+	  HCDP table available for use as serial console or general
+	  purpose port, say Y here. See
+	  <http://www.dig64.org/specifications/DIG64_HCDPv10a_01.pdf>.
=20
 config SERIAL_8250_EXTENDED
 	bool "Extended 8250/16550 serial driver options"
diff -Nru a/drivers/serial/Makefile b/drivers/serial/Makefile
--- a/drivers/serial/Makefile	Fri Jan 24 20:41:05 2003
+++ b/drivers/serial/Makefile	Fri Jan 24 20:41:05 2003
@@ -10,6 +10,8 @@
 serial-8250-$(CONFIG_GSC) +=3D 8250_gsc.o
 serial-8250-$(CONFIG_PCI) +=3D 8250_pci.o
 serial-8250-$(CONFIG_PNP) +=3D 8250_pnp.o
+serial-8250-$(CONFIG_SERIAL_8250_ACPI) +=3D acpi.o 8250_acpi.o
+serial-8250-$(CONFIG_SERIAL_8250_HCDP) +=3D 8250_hcdp.o
 obj-$(CONFIG_SERIAL_CORE) +=3D core.o
 obj-$(CONFIG_SERIAL_21285) +=3D 21285.o
 obj-$(CONFIG_SERIAL_8250) +=3D 8250.o $(serial-8250-y)
diff -Nru a/drivers/serial/acpi.c b/drivers/serial/acpi.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/drivers/serial/acpi.c	Fri Jan 24 20:41:06 2003
@@ -0,0 +1,108 @@
+/*
+ * serial/acpi.c
+ * Copyright (c) 2002-2003 Matthew Wilcox for Hewlett-Packard
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/acpi.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/serial.h>
+#include <asm/io.h>
+#include <asm/serial.h>
+#include "../acpi/acpi_bus.h"
+
+static void acpi_serial_address(struct serial_struct *req, struct acpi_res=
ource_address32 *addr32)
+{
+	unsigned long size;
+
+	size =3D addr32->max_address_range - addr32->min_address_range + 1;
+	req->iomap_base =3D addr32->min_address_range;
+	req->iomem_base =3D ioremap(req->iomap_base, size);
+	req->io_type =3D SERIAL_IO_MEM;
+}
+
+static void acpi_serial_irq(struct serial_struct *req, struct acpi_resourc=
e_ext_irq *ext_irq)
+{
+	if (ext_irq->number_of_interrupts > 0) {
+#ifdef CONFIG_IA64
+		req->irq =3D acpi_register_irq(ext_irq->interrupts[0],
+	                  ext_irq->active_high_low =3D ACPI_ACTIVE_HIGH,
+	                  ext_irq->edge_level =3D ACPI_EDGE_SENSITIVE);
+#else
+		req->irq =3D ext_irq->interrupts[0];
+#endif
+	}
+}
+
+static int acpi_serial_add(struct acpi_device *device)
+{
+	acpi_status result;
+	struct acpi_buffer buffer =3D { ACPI_ALLOCATE_BUFFER, NULL };
+	struct serial_struct serial_req;
+	int line, offset =3D 0;
+
+	memset(&serial_req, 0, sizeof(serial_req));
+	result =3D acpi_get_current_resources(device->handle, &buffer);
+	if (ACPI_FAILURE(result)) {
+		result =3D -ENODEV;
+		goto out;
+	}
+
+	while (offset <=3D buffer.length) {
+		struct acpi_resource *res =3D buffer.pointer + offset;
+		if (res->length =3D 0)
+			break;
+		offset +=3D res->length;
+		if (res->id =3D ACPI_RSTYPE_ADDRESS32) {
+			acpi_serial_address(&serial_req, &res->data.address32);
+		} else if (res->id =3D ACPI_RSTYPE_EXT_IRQ) {
+			acpi_serial_irq(&serial_req, &res->data.extended_irq);
+		}
+	}
+
+	serial_req.baud_base =3D BASE_BAUD;
+	serial_req.flags =3D ASYNC_SKIP_TEST|ASYNC_BOOT_AUTOCONF|ASYNC_AUTO_IRQ;
+
+	result =3D 0;
+	line =3D register_serial(&serial_req);
+	if (line < 0)
+		result =3D -ENODEV;
+
+ out:
+	acpi_os_free(buffer.pointer);
+	return result;
+}
+
+static int acpi_serial_remove(struct acpi_device *device, int type)
+{
+	return 0;
+}
+
+static struct acpi_driver acpi_serial_driver =3D {
+	.name =3D		"serial",
+	.class =3D	"",
+	.ids =3D		"PNP0501",
+	.ops =3D	{
+		.add =3D		acpi_serial_add,
+		.remove =3D	acpi_serial_remove,
+	},
+};
+
+static int __init acpi_serial_init(void)
+{
+	acpi_bus_register_driver(&acpi_serial_driver);
+	return 0;
+}
+
+static void __exit acpi_serial_exit(void)
+{
+	acpi_bus_unregister_driver(&acpi_serial_driver);
+}
+
+module_init(acpi_serial_init);
+module_exit(acpi_serial_exit);
diff -Nru a/drivers/video/radeonfb.c b/drivers/video/radeonfb.c
--- a/drivers/video/radeonfb.c	Fri Jan 24 20:41:05 2003
+++ b/drivers/video/radeonfb.c	Fri Jan 24 20:41:05 2003
@@ -724,7 +724,6 @@
 	radeon_set_backlight_level
 };
 #endif /* CONFIG_PMAC_BACKLIGHT */
-
 #endif /* CONFIG_ALL_PPC */
=20
=20
diff -Nru a/fs/exec.c b/fs/exec.c
--- a/fs/exec.c	Fri Jan 24 20:41:05 2003
+++ b/fs/exec.c	Fri Jan 24 20:41:05 2003
@@ -405,7 +405,7 @@
 		mpnt->vm_start =3D PAGE_MASK & (unsigned long) bprm->p;
 		mpnt->vm_end =3D STACK_TOP;
 #endif
-		mpnt->vm_page_prot =3D PAGE_COPY;
+		mpnt->vm_page_prot =3D protection_map[VM_STACK_FLAGS & 0x7];
 		mpnt->vm_flags =3D VM_STACK_FLAGS;
 		mpnt->vm_ops =3D NULL;
 		mpnt->vm_pgoff =3D 0;
diff -Nru a/fs/fcntl.c b/fs/fcntl.c
--- a/fs/fcntl.c	Fri Jan 24 20:41:05 2003
+++ b/fs/fcntl.c	Fri Jan 24 20:41:05 2003
@@ -320,6 +320,7 @@
 			 * to fix this will be in libc.
 			 */
 			err =3D filp->f_owner.pid;
+			force_successful_syscall_return();
 			break;
 		case F_SETOWN:
 			err =3D f_setown(filp, arg, 1);
diff -Nru a/fs/proc/base.c b/fs/proc/base.c
--- a/fs/proc/base.c	Fri Jan 24 20:41:05 2003
+++ b/fs/proc/base.c	Fri Jan 24 20:41:05 2003
@@ -533,7 +533,24 @@
 }
 #endif
=20
+static loff_t mem_lseek(struct file * file, loff_t offset, int orig)
+{
+	switch (orig) {
+	      case 0:
+		file->f_pos =3D offset;
+		break;
+	      case 1:
+		file->f_pos +=3D offset;
+		break;
+	      default:
+		return -EINVAL;
+	}
+	force_successful_syscall_return();
+	return file->f_pos;
+}
+
 static struct file_operations proc_mem_operations =3D {
+	.llseek		=3D mem_lseek,
 	.read		=3D mem_read,
 	.write		=3D mem_write,
 	.open		=3D mem_open,
diff -Nru a/fs/select.c b/fs/select.c
--- a/fs/select.c	Fri Jan 24 20:41:05 2003
+++ b/fs/select.c	Fri Jan 24 20:41:05 2003
@@ -176,7 +176,7 @@
 {
 	struct poll_wqueues table;
 	poll_table *wait;
-	int retval, i, off;
+	int retval, i;
 	long __timeout =3D *timeout;
=20
  	read_lock(&current->files->file_lock);
@@ -193,38 +193,53 @@
 		wait =3D NULL;
 	retval =3D 0;
 	for (;;) {
+		unsigned long *rinp, *routp, *rexp, *inp, *outp, *exp;
 		set_current_state(TASK_INTERRUPTIBLE);
-		for (i =3D 0 ; i < n; i++) {
-			unsigned long bit =3D BIT(i);
-			unsigned long mask;
-			struct file *file;
=20
-			off =3D i / __NFDBITS;
-			if (!(bit & BITS(fds, off)))
+		inp =3D fds->in; outp =3D fds->out; exp =3D fds->ex;
+		rinp =3D fds->res_in; routp =3D fds->res_out; rexp =3D fds->res_ex;
+
+		for (i =3D 0; i < n; ++rinp, ++routp, ++rexp) {
+			unsigned long in, out, ex, all_bits, bit =3D 1, mask, j;
+			unsigned long res_in =3D 0, res_out =3D 0, res_ex =3D 0;
+			struct file_operations *f_op =3D NULL;
+			struct file *file =3D NULL;
+
+			in =3D *inp++; out =3D *outp++; ex =3D *exp++;
+			all_bits =3D in | out | ex;
+			if (all_bits =3D 0)
 				continue;
-			file =3D fget(i);
-			mask =3D POLLNVAL;
-			if (file) {
+
+			for (j =3D 0; j < __NFDBITS; ++j, ++i, bit <<=3D 1) {
+				if (i >=3D n)
+					break;
+				if (!(bit & all_bits))
+					continue;
+				file =3D fget(i);
+				if (file)
+					f_op =3D file->f_op;
 				mask =3D DEFAULT_POLLMASK;
-				if (file->f_op && file->f_op->poll)
-					mask =3D file->f_op->poll(file, wait);
-				fput(file);
-			}
-			if ((mask & POLLIN_SET) && ISSET(bit, __IN(fds,off))) {
-				SET(bit, __RES_IN(fds,off));
-				retval++;
-				wait =3D NULL;
-			}
-			if ((mask & POLLOUT_SET) && ISSET(bit, __OUT(fds,off))) {
-				SET(bit, __RES_OUT(fds,off));
-				retval++;
-				wait =3D NULL;
-			}
-			if ((mask & POLLEX_SET) && ISSET(bit, __EX(fds,off))) {
-				SET(bit, __RES_EX(fds,off));
-				retval++;
-				wait =3D NULL;
+				if (file) {
+					if (f_op && f_op->poll)
+						mask =3D (*f_op->poll)(file, retval ? NULL : wait);
+					fput(file);
+					if ((mask & POLLIN_SET) && (in & bit)) {
+						res_in |=3D bit;
+						retval++;
+					}
+					if ((mask & POLLOUT_SET) && (out & bit)) {
+						res_out |=3D bit;
+						retval++;
+					}
+					if ((mask & POLLEX_SET) && (ex & bit)) {
+						res_ex |=3D bit;
+						retval++;
+					}
+				}
 			}
+			if (res_in) *rinp =3D res_in;
+			if (res_out) *routp =3D res_out;
+			if (res_ex) *rexp =3D res_ex;
 		}
 		wait =3D NULL;
 		if (retval || !__timeout || signal_pending(current))
diff -Nru a/include/asm-alpha/agp.h b/include/asm-alpha/agp.h
--- a/include/asm-alpha/agp.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-alpha/agp.h	Fri Jan 24 20:41:05 2003
@@ -10,4 +10,11 @@
 #define flush_agp_mappings()=20
 #define flush_agp_cache() mb()
=20
+/*
+ * Page-protection value to be used for AGP memory mapped into kernel spac=
e.  For
+ * platforms which use coherent AGP DMA, this can be PAGE_KERNEL.  For oth=
ers, it needs to
+ * be an uncached mapping (such as write-combining).
+ */
+#define PAGE_AGP			PAGE_KERNEL_NOCACHE	/* XXX fix me */
+
 #endif
diff -Nru a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux=
.lds.h
--- a/include/asm-generic/vmlinux.lds.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-generic/vmlinux.lds.h	Fri Jan 24 20:41:05 2003
@@ -13,18 +13,18 @@
 	}								\
 									\
 	/* Kernel symbol table: Normal symbols */			\
-	__start___ksymtab =3D .;						\
 	__ksymtab         : AT(ADDR(__ksymtab) - LOAD_OFFSET) {		\
+		__start___ksymtab =3D .;					\
 		*(__ksymtab)						\
+		__stop___ksymtab =3D .;					\
 	}								\
-	__stop___ksymtab =3D .;						\
 									\
 	/* Kernel symbol table: GPL-only symbols */			\
-	__start___gpl_ksymtab =3D .;					\
 	__gpl_ksymtab     : AT(ADDR(__gpl_ksymtab) - LOAD_OFFSET) {	\
+		__start___gpl_ksymtab =3D .;				\
 		*(__gpl_ksymtab)					\
+		__stop___gpl_ksymtab =3D .;				\
 	}								\
-	__stop___gpl_ksymtab =3D .;					\
 									\
 	/* Kernel symbol table: strings */				\
         __ksymtab_strings : AT(ADDR(__ksymtab_strings) - LOAD_OFFSET) {	\
diff -Nru a/include/asm-i386/agp.h b/include/asm-i386/agp.h
--- a/include/asm-i386/agp.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-i386/agp.h	Fri Jan 24 20:41:05 2003
@@ -20,4 +20,11 @@
    worth it. Would need a page for it. */
 #define flush_agp_cache() asm volatile("wbinvd":::"memory")
=20
+/*
+ * Page-protection value to be used for AGP memory mapped into kernel spac=
e.  For
+ * platforms which use coherent AGP DMA, this can be PAGE_KERNEL.  For oth=
ers, it needs to
+ * be an uncached mapping (such as write-combining).
+ */
+#define PAGE_AGP			PAGE_KERNEL_NOCACHE
+
 #endif
diff -Nru a/include/asm-i386/hw_irq.h b/include/asm-i386/hw_irq.h
--- a/include/asm-i386/hw_irq.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-i386/hw_irq.h	Fri Jan 24 20:41:05 2003
@@ -140,4 +140,6 @@
 static inline void hw_resend_irq(struct hw_interrupt_type *h, unsigned int=
 i) {}
 #endif
=20
+extern irq_desc_t irq_desc [NR_IRQS];
+
 #endif /* _ASM_HW_IRQ_H */
diff -Nru a/include/asm-i386/ptrace.h b/include/asm-i386/ptrace.h
--- a/include/asm-i386/ptrace.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-i386/ptrace.h	Fri Jan 24 20:41:05 2003
@@ -57,6 +57,7 @@
 #ifdef __KERNEL__
 #define user_mode(regs) ((VM_MASK & (regs)->eflags) || (3 & (regs)->xcs))
 #define instruction_pointer(regs) ((regs)->eip)
+#define force_successful_syscall_return()	do { } while (0)
 #endif
=20
 #endif
diff -Nru a/include/asm-ia64/asmmacro.h b/include/asm-ia64/asmmacro.h
--- a/include/asm-ia64/asmmacro.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-ia64/asmmacro.h	Fri Jan 24 20:41:05 2003
@@ -2,15 +2,22 @@
 #define _ASM_IA64_ASMMACRO_H
=20
 /*
- * Copyright (C) 2000-2001 Hewlett-Packard Co
+ * Copyright (C) 2000-2001, 2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
+#include <linux/config.h>
+
 #define ENTRY(name)				\
 	.align 32;				\
 	.proc name;				\
 name:
=20
+#define ENTRY_MIN_ALIGN(name)			\
+	.align 16;				\
+	.proc name;				\
+name:
+
 #define GLOBAL_ENTRY(name)			\
 	.global name;				\
 	ENTRY(name)
@@ -37,19 +44,28 @@
 	.previous
=20
 #if __GNUC__ >=3D 3
-# define EX(y,x...)					\
-	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
+# define EX(y,x...)				\
+	.xdata4 "__ex_table", 99f-., y-.;	\
   [99:]	x
-# define EXCLR(y,x...)					\
-	.xdata4 "__ex_table", @gprel(99f), @gprel(y)+4;	\
+# define EXCLR(y,x...)				\
+	.xdata4 "__ex_table", 99f-., y-.+4;	\
   [99:]	x
 #else
-# define EX(y,x...)					\
-	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
+# define EX(y,x...)				\
+	.xdata4 "__ex_table", 99f-., y-.;	\
   99:	x
-# define EXCLR(y,x...)					\
-	.xdata4 "__ex_table", @gprel(99f), @gprel(y)+4;	\
+# define EXCLR(y,x...)				\
+	.xdata4 "__ex_table", 99f-., y-.+4;	\
   99:	x
+#endif
+
+#ifdef CONFIG_MCKINLEY
+/* workaround for Itanium 2 Errata 9: */
+# define MCKINLEY_E9_WORKAROUND			\
+	br.call.sptk.many b7=1F;;		\
+1:
+#else
+# define MCKINLEY_E9_WORKAROUND
 #endif
=20
 #endif /* _ASM_IA64_ASMMACRO_H */
diff -Nru a/include/asm-ia64/bitops.h b/include/asm-ia64/bitops.h
--- a/include/asm-ia64/bitops.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-ia64/bitops.h	Fri Jan 24 20:41:05 2003
@@ -2,7 +2,7 @@
 #define _ASM_IA64_BITOPS_H
=20
 /*
- * Copyright (C) 1998-2002 Hewlett-Packard Co
+ * Copyright (C) 1998-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * 02/06/02 find_next_bit() and find_first_bit() added from Erich Focht's =
ia64 O(1)
@@ -320,7 +320,7 @@
 static inline unsigned long
 ia64_fls (unsigned long x)
 {
-	double d =3D x;
+	long double d =3D x;
 	long exp;
=20
 	__asm__ ("getf.exp %0=3D%1" : "=3Dr"(exp) : "f"(d));
diff -Nru a/include/asm-ia64/compat.h b/include/asm-ia64/compat.h
--- a/include/asm-ia64/compat.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-ia64/compat.h	Fri Jan 24 20:41:05 2003
@@ -14,11 +14,18 @@
 typedef s32		compat_pid_t;
 typedef u16		compat_uid_t;
 typedef u16		compat_gid_t;
+typedef u32		compat_uid32_t;
+typedef u32		compat_gid32_t;
 typedef u16		compat_mode_t;
 typedef u32		compat_ino_t;
 typedef u16		compat_dev_t;
 typedef s32		compat_off_t;
+typedef s64		compat_loff_t;
 typedef u16		compat_nlink_t;
+typedef u16		compat_ipc_pid_t;
+typedef s32		compat_daddr_t;
+typedef u32		compat_caddr_t;
+typedef __kernel_fsid_t	compat_fsid_t;
=20
 struct compat_timespec {
 	compat_time_t	tv_sec;
@@ -54,11 +61,31 @@
 };
=20
 struct compat_flock {
-       short		l_type;
-       short		l_whence;
-       compat_off_t	l_start;
-       compat_off_t	l_len;
-       compat_pid_t	l_pid;
+	short		l_type;
+	short		l_whence;
+	compat_off_t	l_start;
+	compat_off_t	l_len;
+	compat_pid_t	l_pid;
 };
+
+struct compat_statfs {
+	int		f_type;
+	int		f_bsize;
+	int		f_blocks;
+	int		f_bfree;
+	int		f_bavail;
+	int		f_files;
+	int		f_ffree;
+	compat_fsid_t	f_fsid;
+	int		f_namelen;	/* SunOS ignores this field. */
+	int		f_spare[6];
+};
+
+typedef u32		compat_old_sigset_t;	/* at least 32 bits */
+
+#define _COMPAT_NSIG		64
+#define _COMPAT_NSIG_BPW	32
+
+typedef u32		compat_sigset_word;
=20
 #endif /* _ASM_IA64_COMPAT_H */
diff -Nru a/include/asm-ia64/elf.h b/include/asm-ia64/elf.h
--- a/include/asm-ia64/elf.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-ia64/elf.h	Fri Jan 24 20:41:05 2003
@@ -4,10 +4,12 @@
 /*
  * ELF-specific definitions.
  *
- * Copyright (C) 1998, 1999, 2002 Hewlett-Packard Co
+ * Copyright (C) 1998-1999, 2002-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
+#include <linux/config.h>
+
 #include <asm/fpu.h>
 #include <asm/page.h>
=20
@@ -88,6 +90,11 @@
    relevant until we have real hardware to play with... */
 #define ELF_PLATFORM	0
=20
+/*
+ * This should go into linux/elf.h...
+ */
+#define AT_SYSINFO	32
+
 #ifdef __KERNEL__
 struct elf64_hdr;
 extern void ia64_set_personality (struct elf64_hdr *elf_ex, int ibcs2_inte=
rpreter);
@@ -99,7 +106,14 @@
 #define ELF_CORE_COPY_TASK_REGS(tsk, elf_gregs) dump_task_regs(tsk, elf_gr=
egs)
 #define ELF_CORE_COPY_FPREGS(tsk, elf_fpregs) dump_task_fpu(tsk, elf_fpreg=
s)
=20
-
+#ifdef CONFIG_FSYS
+#define ARCH_DLINFO					\
+do {							\
+	extern int syscall_via_epc;			\
+	NEW_AUX_ENT(AT_SYSINFO, syscall_via_epc);	\
+} while (0)
 #endif
+
+#endif /* __KERNEL__ */
=20
 #endif /* _ASM_IA64_ELF_H */
diff -Nru a/include/asm-ia64/ia32.h b/include/asm-ia64/ia32.h
--- a/include/asm-ia64/ia32.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-ia64/ia32.h	Fri Jan 24 20:41:05 2003
@@ -12,17 +12,6 @@
  * 32 bit structures for IA32 support.
  */
=20
-/* 32bit compatibility types */
-typedef unsigned short	__kernel_ipc_pid_t32;
-typedef unsigned int	__kernel_uid32_t32;
-typedef unsigned int	__kernel_gid32_t32;
-typedef unsigned short	__kernel_umode_t32;
-typedef short		__kernel_nlink_t32;
-typedef int		__kernel_daddr_t32;
-typedef unsigned int	__kernel_caddr_t32;
-typedef long		__kernel_loff_t32;
-typedef __kernel_fsid_t	__kernel_fsid_t32;
-
 #define IA32_PAGE_SHIFT		12	/* 4KB pages */
 #define IA32_PAGE_SIZE		(1UL << IA32_PAGE_SHIFT)
 #define IA32_PAGE_MASK		(~(IA32_PAGE_SIZE - 1))
@@ -143,10 +132,6 @@
 };
=20
 /* signal.h */
-#define _IA32_NSIG	       64
-#define _IA32_NSIG_BPW	       32
-#define _IA32_NSIG_WORDS	       (_IA32_NSIG / _IA32_NSIG_BPW)
-
 #define IA32_SET_SA_HANDLER(ka,handler,restorer)				\
 				((ka)->sa.sa_handler =3D (__sighandler_t)		\
 					(((unsigned long)(restorer) << 32)	\
@@ -154,23 +139,17 @@
 #define IA32_SA_HANDLER(ka)	((unsigned long) (ka)->sa.sa_handler & 0xfffff=
fff)
 #define IA32_SA_RESTORER(ka)	((unsigned long) (ka)->sa.sa_handler >> 32)
=20
-typedef struct {
-       unsigned int sig[_IA32_NSIG_WORDS];
-} sigset32_t;
-
 struct sigaction32 {
        unsigned int sa_handler;		/* Really a pointer, but need to deal wit=
h 32 bits */
        unsigned int sa_flags;
        unsigned int sa_restorer;	/* Another 32 bit pointer */
-       sigset32_t sa_mask;		/* A 32 bit mask */
+       compat_sigset_t sa_mask;		/* A 32 bit mask */
 };
=20
-typedef unsigned int old_sigset32_t;	/* at least 32 bits */
-
 struct old_sigaction32 {
        unsigned int  sa_handler;	/* Really a pointer, but need to deal
 					     with 32 bits */
-       old_sigset32_t sa_mask;		/* A 32 bit mask */
+       compat_old_sigset_t sa_mask;		/* A 32 bit mask */
        unsigned int sa_flags;
        unsigned int sa_restorer;	/* Another 32 bit pointer */
 };
@@ -212,19 +191,6 @@
 	unsigned int	st_ctime_nsec;
 	unsigned int	st_ino_lo;
 	unsigned int	st_ino_hi;
-};
-
-struct statfs32 {
-       int f_type;
-       int f_bsize;
-       int f_blocks;
-       int f_bfree;
-       int f_bavail;
-       int f_files;
-       int f_ffree;
-       __kernel_fsid_t32 f_fsid;
-       int f_namelen;  /* SunOS ignores this field. */
-       int f_spare[6];
 };
=20
 typedef union sigval32 {
diff -Nru a/include/asm-ia64/intrinsics.h b/include/asm-ia64/intrinsics.h
--- a/include/asm-ia64/intrinsics.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-ia64/intrinsics.h	Fri Jan 24 20:41:05 2003
@@ -4,9 +4,11 @@
 /*
  * Compiler-dependent intrinsics.
  *
- * Copyright (C) 2002 Hewlett-Packard Co
+ * Copyright (C) 2002-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
+
+#include <linux/config.h>
=20
 /*
  * Force an unresolved reference if someone tries to use
diff -Nru a/include/asm-ia64/mmu_context.h b/include/asm-ia64/mmu_context.h
--- a/include/asm-ia64/mmu_context.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-ia64/mmu_context.h	Fri Jan 24 20:41:05 2003
@@ -28,6 +28,36 @@
=20
 #include <asm/processor.h>
=20
+#define MMU_CONTEXT_DEBUG	0
+
+#if MMU_CONTEXT_DEBUG
+
+#include <ia64intrin.h>
+
+extern struct mmu_trace_entry {
+	char op;
+	u8 cpu;
+	u32 context;
+	void *mm;
+} mmu_tbuf[1024];
+
+extern volatile int mmu_tbuf_index;
+
+# define MMU_TRACE(_op,_cpu,_mm,_ctx)							\
+do {											\
+	int i =3D __sync_fetch_and_add(&mmu_tbuf_index, 1) % ARRAY_SIZE(mmu_tbuf)=
;	\
+	struct mmu_trace_entry e;							\
+	e.op =3D (_op);									\
+	e.cpu =3D (_cpu);									\
+	e.mm =3D (_mm);									\
+	e.context =3D (_ctx);								\
+	mmu_tbuf[i] =3D e;								\
+} while (0)
+
+#else
+# define MMU_TRACE(op,cpu,mm,ctx)	do { ; } while (0)
+#endif
+
 struct ia64_ctx {
 	spinlock_t lock;
 	unsigned int next;	/* next context number to use */
@@ -91,6 +121,7 @@
 static inline int
 init_new_context (struct task_struct *p, struct mm_struct *mm)
 {
+	MMU_TRACE('N', smp_processor_id(), mm, 0);
 	mm->context =3D 0;
 	return 0;
 }
@@ -99,6 +130,7 @@
 destroy_context (struct mm_struct *mm)
 {
 	/* Nothing to do.  */
+	MMU_TRACE('D', smp_processor_id(), mm, mm->context);
 }
=20
 static inline void
@@ -138,12 +170,17 @@
=20
 	do {
 		context =3D get_mmu_context(mm);
+		MMU_TRACE('A', smp_processor_id(), mm, context);
 		reload_context(context);
+		MMU_TRACE('a', smp_processor_id(), mm, context);
 		/* in the unlikely event of a TLB-flush by another thread, redo the load=
: */
 	} while (unlikely(context !=3D mm->context));
 }
=20
-#define deactivate_mm(tsk,mm)	do { } while (0)
+#define deactivate_mm(tsk,mm)					\
+do {								\
+	MMU_TRACE('d', smp_processor_id(), mm, mm->context);	\
+} while (0)
=20
 /*
  * Switch from address space PREV to address space NEXT.
diff -Nru a/include/asm-ia64/page.h b/include/asm-ia64/page.h
--- a/include/asm-ia64/page.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-ia64/page.h	Fri Jan 24 20:41:05 2003
@@ -88,7 +88,12 @@
 #define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
=20
 #ifndef CONFIG_DISCONTIGMEM
-#define pfn_valid(pfn)		((pfn) < max_mapnr)
+# ifdef CONFIG_VIRTUAL_MEM_MAP
+   extern int ia64_pfn_valid (unsigned long pfn);
+#  define pfn_valid(pfn)	(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
+# else
+#  define pfn_valid(pfn)	((pfn) < max_mapnr)
+# endif
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
 #define page_to_pfn(page)	((unsigned long) (page - mem_map))
 #define pfn_to_page(pfn)	(mem_map + (pfn))
diff -Nru a/include/asm-ia64/perfmon.h b/include/asm-ia64/perfmon.h
--- a/include/asm-ia64/perfmon.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-ia64/perfmon.h	Fri Jan 24 20:41:05 2003
@@ -40,6 +40,7 @@
 #define PFM_FL_INHERIT_ALL	 0x02	/* always clone pfm_context across fork()=
 */
 #define PFM_FL_NOTIFY_BLOCK    	 0x04	/* block task on user level notifica=
tions */
 #define PFM_FL_SYSTEM_WIDE	 0x08	/* create a system wide context */
+#define PFM_FL_EXCL_IDLE         0x20   /* exclude idle task from system w=
ide session */
=20
 /*
  * PMC flags
@@ -86,11 +87,12 @@
 	unsigned long	reg_long_reset;	/* reset after sampling buffer overflow (la=
rge) */
 	unsigned long	reg_short_reset;/* reset after counter overflow (small) */
=20
-	unsigned long	reg_reset_pmds[4]; /* which other counters to reset on over=
flow */
-	unsigned long	reg_random_seed;   /* seed value when randomization is used=
 */
-	unsigned long	reg_random_mask;   /* bitmask used to limit random value */
+	unsigned long	reg_reset_pmds[4];   /* which other counters to reset on ov=
erflow */
+	unsigned long	reg_random_seed;     /* seed value when randomization is us=
ed */
+	unsigned long	reg_random_mask;     /* bitmask used to limit random value =
*/
+	unsigned long	reg_last_reset_value;/* last value used to reset the PMD (P=
FM_READ_PMDS) */
=20
-	unsigned long   reserved[14];	/* for future use */
+	unsigned long   reserved[13];	/* for future use */
 } pfarg_reg_t;
=20
 typedef struct {
@@ -123,7 +125,7 @@
  * Define the version numbers for both perfmon as a whole and the sampling=
 buffer format.
  */
 #define PFM_VERSION_MAJ		1U
-#define PFM_VERSION_MIN		1U
+#define PFM_VERSION_MIN		3U
 #define PFM_VERSION		(((PFM_VERSION_MAJ&0xffff)<<16)|(PFM_VERSION_MIN & 0x=
ffff))
=20
 #define PFM_SMPL_VERSION_MAJ	1U
@@ -156,13 +158,17 @@
 	unsigned long	stamp;			/* timestamp */
 	unsigned long	ip;			/* where did the overflow interrupt happened */
 	unsigned long	regs;			/* bitmask of which registers overflowed */
-	unsigned long   period;			/* unused */
+	unsigned long   reserved;		/* unused */
 } perfmon_smpl_entry_t;
=20
 extern int perfmonctl(pid_t pid, int cmd, void *arg, int narg);
=20
 #ifdef __KERNEL__
=20
+typedef struct {
+	void (*handler)(int irq, void *arg, struct pt_regs *regs);
+} pfm_intr_handler_desc_t;
+
 extern void pfm_save_regs (struct task_struct *);
 extern void pfm_load_regs (struct task_struct *);
=20
@@ -174,9 +180,24 @@
 extern int  pfm_use_debug_registers(struct task_struct *);
 extern int  pfm_release_debug_registers(struct task_struct *);
 extern int  pfm_cleanup_smpl_buf(struct task_struct *);
-extern void pfm_syst_wide_update_task(struct task_struct *, int);
+extern void pfm_syst_wide_update_task(struct task_struct *, unsigned long =
info, int is_ctxswin);
 extern void pfm_ovfl_block_reset(void);
-extern void perfmon_init_percpu(void);
+extern void pfm_init_percpu(void);
+
+/*=20
+ * hooks to allow VTune/Prospect to cooperate with perfmon.
+ * (reserved for system wide monitoring modules only)
+ */
+extern int pfm_install_alternate_syswide_subsystem(pfm_intr_handler_desc_t=
 *h);
+extern int pfm_remove_alternate_syswide_subsystem(pfm_intr_handler_desc_t =
*h);
+
+/*
+ * describe the content of the local_cpu_date->pfm_syst_info field
+ */
+#define PFM_CPUINFO_SYST_WIDE	0x1	/* if set a system wide session exist */
+#define PFM_CPUINFO_DCR_PP	0x2	/* if set the system wide session has start=
ed */
+#define PFM_CPUINFO_EXCL_IDLE	0x4	/* the system wide session excludes the =
idle task */
+
=20
 #endif /* __KERNEL__ */
=20
diff -Nru a/include/asm-ia64/pgtable.h b/include/asm-ia64/pgtable.h
--- a/include/asm-ia64/pgtable.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-ia64/pgtable.h	Fri Jan 24 20:41:05 2003
@@ -204,7 +204,13 @@
=20
 #define VMALLOC_START		(0xa000000000000000 + 3*PERCPU_PAGE_SIZE)
 #define VMALLOC_VMADDR(x)	((unsigned long)(x))
-#define VMALLOC_END		(0xa000000000000000 + (1UL << (4*PAGE_SHIFT - 9)))
+#ifdef CONFIG_VIRTUAL_MEM_MAP
+# define VMALLOC_END_INIT	(0xa000000000000000 + (1UL << (4*PAGE_SHIFT - 9)=
))
+# define VMALLOC_END		vmalloc_end
+  extern unsigned long vmalloc_end;
+#else
+# define VMALLOC_END		(0xa000000000000000 + (1UL << (4*PAGE_SHIFT - 9)))
+#endif
=20
 /*
  * Conversion functions: convert page frame number (pfn) and a protection =
value to a page
@@ -422,6 +428,18 @@
=20
 typedef pte_t *pte_addr_t;
=20
+#  ifdef CONFIG_VIRTUAL_MEM_MAP
+
+  /* arch mem_map init routine is needed due to holes in a virtual mem_map=
 */
+#   define HAVE_ARCH_MEMMAP_INIT
+
+    typedef void memmap_init_callback_t (struct page *start, unsigned long=
 size,
+					 int nid, unsigned long zone, unsigned long start_pfn);
+
+    extern void arch_memmap_init (memmap_init_callback_t *callback, struct=
 page *start,
+				  unsigned long size, int nid, unsigned long zone,
+				  unsigned long start_pfn);
+#  endif /* CONFIG_VIRTUAL_MEM_MAP */
 # endif /* !__ASSEMBLY__ */
=20
 /*
diff -Nru a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
--- a/include/asm-ia64/processor.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-ia64/processor.h	Fri Jan 24 20:41:05 2003
@@ -2,7 +2,7 @@
 #define _ASM_IA64_PROCESSOR_H
=20
 /*
- * Copyright (C) 1998-2002 Hewlett-Packard Co
+ * Copyright (C) 1998-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *	Stephane Eranian <eranian@hpl.hp.com>
  * Copyright (C) 1999 Asit Mallick <asit.k.mallick@intel.com>
@@ -223,7 +223,10 @@
 struct siginfo;
=20
 struct thread_struct {
-	__u64 flags;			/* various thread flags (see IA64_THREAD_*) */
+	__u32 flags;			/* various thread flags (see IA64_THREAD_*) */
+	/* writing on_ustack is performance-critical, so it's worth spending 8 bi=
ts on it... */
+	__u8 on_ustack;			/* executing on user-stacks? */
+	__u8 pad[3];
 	__u64 ksp;			/* kernel stack pointer */
 	__u64 map_base;			/* base address for get_unmapped_area() */
 	__u64 task_size;		/* limit for task size */
@@ -277,6 +280,7 @@
=20
 #define INIT_THREAD {				\
 	.flags =3D	0,			\
+	.on_ustack =3D	0,			\
 	.ksp =3D		0,			\
 	.map_base =3D	DEFAULT_MAP_BASE,	\
 	.task_size =3D	DEFAULT_TASK_SIZE,	\
diff -Nru a/include/asm-ia64/ptrace.h b/include/asm-ia64/ptrace.h
--- a/include/asm-ia64/ptrace.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-ia64/ptrace.h	Fri Jan 24 20:41:05 2003
@@ -2,7 +2,7 @@
 #define _ASM_IA64_PTRACE_H
=20
 /*
- * Copyright (C) 1998-2002 Hewlett-Packard Co
+ * Copyright (C) 1998-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *	Stephane Eranian <eranian@hpl.hp.com>
  *
@@ -218,6 +218,13 @@
 # define ia64_task_regs(t)		(((struct pt_regs *) ((char *) (t) + IA64_STK_=
OFFSET)) - 1)
 # define ia64_psr(regs)			((struct ia64_psr *) &(regs)->cr_ipsr)
 # define user_mode(regs)		(((struct ia64_psr *) &(regs)->cr_ipsr)->cpl !=
=3D 0)
+# define user_stack(task,regs)	((long) regs - (long) task =3D IA64_STK_OFF=
SET - sizeof(*regs))
+# define fsys_mode(task,regs)					\
+  ({								\
+	  struct task_struct *_task =3D (task);			\
+	  struct pt_regs *_regs =3D (regs);			\
+	  !user_mode(_regs) && user_stack(_task, _regs);	\
+  })
=20
   struct task_struct;			/* forward decl */
=20
diff -Nru a/include/asm-ia64/serial.h b/include/asm-ia64/serial.h
--- a/include/asm-ia64/serial.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-ia64/serial.h	Fri Jan 24 20:41:05 2003
@@ -59,7 +59,6 @@
 	{ 0, BASE_BAUD, 0x3E8, 4, STD_COM_FLAGS },	/* ttyS2 */	\
 	{ 0, BASE_BAUD, 0x2E8, 3, STD_COM4_FLAGS },	/* ttyS3 */
=20
-
 #ifdef CONFIG_SERIAL_MANY_PORTS
 #define EXTRA_SERIAL_PORT_DEFNS			\
 	{ 0, BASE_BAUD, 0x1A0, 9, FOURPORT_FLAGS }, 	/* ttyS4 */	\
diff -Nru a/include/asm-ia64/spinlock.h b/include/asm-ia64/spinlock.h
--- a/include/asm-ia64/spinlock.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-ia64/spinlock.h	Fri Jan 24 20:41:05 2003
@@ -74,6 +74,27 @@
 #define SPIN_LOCK_UNLOCKED			(spinlock_t) { 0 }
 #define spin_lock_init(x)			((x)->lock =3D 0)
=20
+#define DEBUG_SPIN_LOCK	0
+
+#if DEBUG_SPIN_LOCK
+
+#include <ia64intrin.h>
+
+#define _raw_spin_lock(x)								\
+do {											\
+	unsigned long _timeout =3D 1000000000;						\
+	volatile unsigned int _old =3D 0, _new =3D 1, *_ptr =3D &((x)->lock);			\
+	do {										\
+		if (_timeout-- =3D 0) {							\
+			extern void dump_stack (void);					\
+			printk("kernel DEADLOCK at %s:%d?\n", __FILE__, __LINE__);	\
+			dump_stack();							\
+		}									\
+	} while (__sync_val_compare_and_swap(_ptr, _old, _new) !=3D _old);		\
+} while (0)
+
+#else
+
 /*
  * Streamlined test_and_set_bit(0, (x)).  We use test-and-test-and-set
  * rather than a simple xchg to avoid writing the cache-line when
@@ -94,6 +115,8 @@
 	"(p7) br.cond.spnt.few 1b\n"				\
 	";;\n"							\
 	:: "r"(&(x)->lock) : "ar.ccv", "p7", "r2", "r29", "memory")
+
+#endif /* !DEBUG_SPIN_LOCK */
=20
 #define spin_is_locked(x)	((x)->lock !=3D 0)
 #define _raw_spin_unlock(x)	do { barrier(); ((spinlock_t *) x)->lock =3D 0=
; } while (0)
diff -Nru a/include/asm-ia64/system.h b/include/asm-ia64/system.h
--- a/include/asm-ia64/system.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-ia64/system.h	Fri Jan 24 20:41:05 2003
@@ -7,7 +7,7 @@
  * on information published in the Processor Abstraction Layer
  * and the System Abstraction Layer manual.
  *
- * Copyright (C) 1998-2002 Hewlett-Packard Co
+ * Copyright (C) 1998-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1999 Asit Mallick <asit.k.mallick@intel.com>
  * Copyright (C) 1999 Don Dugger <don.dugger@intel.com>
@@ -17,6 +17,7 @@
 #include <asm/kregs.h>
 #include <asm/page.h>
 #include <asm/pal.h>
+#include <asm/percpu.h>
=20
 #define KERNEL_START		(PAGE_OFFSET + 68*1024*1024)
=20
@@ -26,7 +27,6 @@
=20
 #ifndef __ASSEMBLY__
=20
-#include <linux/percpu.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
=20
@@ -117,62 +117,51 @@
  */
 /* For spinlocks etc */
=20
+/* clearing psr.i is implicitly serialized (visible by next insn) */
+/* setting psr.i requires data serialization */
+#define __local_irq_save(x)	__asm__ __volatile__ ("mov %0=3Dpsr;;"			\
+						      "rsm psr.i;;"			\
+						      : "=3Dr" (x) :: "memory")
+#define __local_irq_disable()	__asm__ __volatile__ (";; rsm psr.i;;" ::: "=
memory")
+#define __local_irq_restore(x)	__asm__ __volatile__ ("cmp.ne p6,p7=3D%0,r0=
;;"		\
+						      "(p6) ssm psr.i;"			\
+						      "(p7) rsm psr.i;;"		\
+						      "(p6) srlz.d"			\
+						      :: "r" ((x) & IA64_PSR_I)		\
+						      : "p6", "p7", "memory")
+
 #ifdef CONFIG_IA64_DEBUG_IRQ
=20
   extern unsigned long last_cli_ip;
=20
-# define local_irq_save(x)								\
-do {											\
-	unsigned long ip, psr;								\
-											\
-	__asm__ __volatile__ ("mov %0=3Dpsr;; rsm psr.i;;" : "=3Dr" (psr) :: "mem=
ory");	\
-	if (psr & (1UL << 14)) {							\
-		__asm__ ("mov %0=3Dip" : "=3Dr"(ip));					\
-		last_cli_ip =3D ip;							\
-	}										\
-	(x) =3D psr;									\
-} while (0)
+# define __save_ip()		__asm__ ("mov %0=3Dip" : "=3Dr" (last_cli_ip))
=20
-# define local_irq_disable()								\
-do {											\
-	unsigned long ip, psr;								\
-											\
-	__asm__ __volatile__ ("mov %0=3Dpsr;; rsm psr.i;;" : "=3Dr" (psr) :: "mem=
ory");	\
-	if (psr & (1UL << 14)) {							\
-		__asm__ ("mov %0=3Dip" : "=3Dr"(ip));					\
-		last_cli_ip =3D ip;							\
-	}										\
+# define local_irq_save(x)					\
+do {								\
+	unsigned long psr;					\
+								\
+	__local_irq_save(psr);					\
+	if (psr & IA64_PSR_I)					\
+		__save_ip();					\
+	(x) =3D psr;						\
 } while (0)
=20
-# define local_irq_restore(x)							\
-do {										\
-	unsigned long ip, old_psr, psr =3D (x);					\
-										\
-	__asm__ __volatile__ ("mov %0=3Dpsr;"					\
-			      "cmp.ne p6,p7=3D%1,r0;;"				\
-			      "(p6) ssm psr.i;"					\
-			      "(p7) rsm psr.i;;"				\
-			      "(p6) srlz.d"					\
-			      : "=3Dr" (old_psr) : "r"((psr) & IA64_PSR_I)	\
-			      : "p6", "p7", "memory");				\
-	if ((old_psr & IA64_PSR_I) && !(psr & IA64_PSR_I)) {			\
-		__asm__ ("mov %0=3Dip" : "=3Dr"(ip));				\
-		last_cli_ip =3D ip;						\
-	}									\
+# define local_irq_disable()	do { unsigned long x; local_irq_save(x); } wh=
ile (0)
+
+# define local_irq_restore(x)					\
+do {								\
+	unsigned long old_psr, psr =3D (x);			\
+								\
+	local_save_flags(old_psr);				\
+	__local_irq_restore(psr);				\
+	if ((old_psr & IA64_PSR_I) && !(psr & IA64_PSR_I))	\
+		__save_ip();					\
 } while (0)
=20
 #else /* !CONFIG_IA64_DEBUG_IRQ */
-  /* clearing of psr.i is implicitly serialized (visible by next insn) */
-# define local_irq_save(x)	__asm__ __volatile__ ("mov %0=3Dpsr;; rsm psr.i=
;;"	\
-						      : "=3Dr" (x) :: "memory")
-# define local_irq_disable()	__asm__ __volatile__ (";; rsm psr.i;;" ::: "m=
emory")
-/* (potentially) setting psr.i requires data serialization: */
-# define local_irq_restore(x)	__asm__ __volatile__ ("cmp.ne p6,p7=3D%0,r0;=
;"	\
-						      "(p6) ssm psr.i;"		\
-						      "(p7) rsm psr.i;;"	\
-						      "srlz.d"			\
-						      :: "r"((x) & IA64_PSR_I)	\
-						      : "p6", "p7", "memory")
+# define local_irq_save(x)	__local_irq_save(x)
+# define local_irq_disable()	__local_irq_disable()
+# define local_irq_restore(x)	__local_irq_restore(x)
 #endif /* !CONFIG_IA64_DEBUG_IRQ */
=20
 #define local_irq_enable()	__asm__ __volatile__ (";; ssm psr.i;; srlz.d" :=
:: "memory")
@@ -216,8 +205,8 @@
 extern void ia64_load_extra (struct task_struct *task);
=20
 #ifdef CONFIG_PERFMON
-  DECLARE_PER_CPU(int, pfm_syst_wide);
-# define PERFMON_IS_SYSWIDE() (get_cpu_var(pfm_syst_wide) !=3D 0)
+  DECLARE_PER_CPU(unsigned long, pfm_syst_info);
+# define PERFMON_IS_SYSWIDE() (get_cpu_var(pfm_syst_info) & 0x1)
 #else
 # define PERFMON_IS_SYSWIDE() (0)
 #endif
diff -Nru a/include/asm-ia64/tlb.h b/include/asm-ia64/tlb.h
--- a/include/asm-ia64/tlb.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-ia64/tlb.h	Fri Jan 24 20:41:05 2003
@@ -1,7 +1,7 @@
 #ifndef _ASM_IA64_TLB_H
 #define _ASM_IA64_TLB_H
 /*
- * Copyright (C) 2002 Hewlett-Packard Co
+ * Copyright (C) 2002-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * This file was derived from asm-generic/tlb.h.
@@ -70,8 +70,7 @@
  * freed pages that where gathered up to this point.
  */
 static inline void
-ia64_tlb_flush_mmu(struct mmu_gather *tlb,
-		unsigned long start, unsigned long end)
+ia64_tlb_flush_mmu (struct mmu_gather *tlb, unsigned long start, unsigned =
long end)
 {
 	unsigned int nr;
=20
@@ -197,8 +196,7 @@
  * PTE, not just those pointing to (normal) physical memory.
  */
 static inline void
-__tlb_remove_tlb_entry(struct mmu_gather *tlb,
-			pte_t *ptep, unsigned long address)
+__tlb_remove_tlb_entry (struct mmu_gather *tlb, pte_t *ptep, unsigned long=
 address)
 {
 	if (tlb->start_addr =3D ~0UL)
 		tlb->start_addr =3D address;
diff -Nru a/include/asm-ia64/tlbflush.h b/include/asm-ia64/tlbflush.h
--- a/include/asm-ia64/tlbflush.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-ia64/tlbflush.h	Fri Jan 24 20:41:05 2003
@@ -47,19 +47,22 @@
 static inline void
 flush_tlb_mm (struct mm_struct *mm)
 {
+	MMU_TRACE('F', smp_processor_id(), mm, mm->context);
 	if (!mm)
-		return;
+		goto out;
=20
 	mm->context =3D 0;
=20
 	if (atomic_read(&mm->mm_users) =3D 0)
-		return;		/* happens as a result of exit_mmap() */
+		goto out;		/* happens as a result of exit_mmap() */
=20
 #ifdef CONFIG_SMP
 	smp_flush_tlb_mm(mm);
 #else
 	local_finish_flush_tlb_mm(mm);
 #endif
+  out:
+	MMU_TRACE('f', smp_processor_id(), mm, mm->context);
 }
=20
 extern void flush_tlb_range (struct vm_area_struct *vma, unsigned long sta=
rt, unsigned long end);
diff -Nru a/include/asm-ia64/uaccess.h b/include/asm-ia64/uaccess.h
--- a/include/asm-ia64/uaccess.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-ia64/uaccess.h	Fri Jan 24 20:41:05 2003
@@ -26,7 +26,7 @@
  * associated and, if so, sets r8 to -EFAULT and clears r9 to 0 and
  * then resumes execution at the continuation point.
  *
- * Copyright (C) 1998, 1999, 2001-2002 Hewlett-Packard Co
+ * Copyright (C) 1998, 1999, 2001-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
@@ -128,38 +128,28 @@
 /* We need to declare the __ex_table section before we can use it in .xdat=
a.  */
 asm (".section \"__ex_table\", \"a\"\n\t.previous");
=20
-#if __GNUC__ >=3D 3
-#  define GAS_HAS_LOCAL_TAGS	/* define if gas supports local tags a la [1:=
] */
-#endif
-
-#ifdef GAS_HAS_LOCAL_TAGS
-# define _LL	"[1:]"
-#else
-# define _LL	"1:"
-#endif
-
 #define __get_user_64(addr)									\
-	asm ("\n"_LL"\tld8 %0=3D%2%P2\t// %0 and %1 get overwritten by exception =
handler\n"	\
-	     "\t.xdata4 \"__ex_table\", @gprel(1b), @gprel(1f)+4\n"				\
-	     _LL										\
+	asm ("\n[1:]\tld8 %0=3D%2%P2\t// %0 and %1 get overwritten by exception h=
andler\n"	\
+	     "\t.xdata4 \"__ex_table\", 1b-., 1f-.+4\n"						\
+	     "[1:]"										\
 	     : "=3Dr"(__gu_val), "=3Dr"(__gu_err) : "m"(__m(addr)), "1"(__gu_err)=
);
=20
 #define __get_user_32(addr)									\
-	asm ("\n"_LL"\tld4 %0=3D%2%P2\t// %0 and %1 get overwritten by exception =
handler\n"	\
-	     "\t.xdata4 \"__ex_table\", @gprel(1b), @gprel(1f)+4\n"				\
-	     _LL										\
+	asm ("\n[1:]\tld4 %0=3D%2%P2\t// %0 and %1 get overwritten by exception h=
andler\n"	\
+	     "\t.xdata4 \"__ex_table\", 1b-., 1f-.+4\n"						\
+	     "[1:]"										\
 	     : "=3Dr"(__gu_val), "=3Dr"(__gu_err) : "m"(__m(addr)), "1"(__gu_err)=
);
=20
 #define __get_user_16(addr)									\
-	asm ("\n"_LL"\tld2 %0=3D%2%P2\t// %0 and %1 get overwritten by exception =
handler\n"	\
-	     "\t.xdata4 \"__ex_table\", @gprel(1b), @gprel(1f)+4\n"				\
-	     _LL										\
+	asm ("\n[1:]\tld2 %0=3D%2%P2\t// %0 and %1 get overwritten by exception h=
andler\n"	\
+	     "\t.xdata4 \"__ex_table\", 1b-., 1f-.+4\n"						\
+	     "[1:]"										\
 	     : "=3Dr"(__gu_val), "=3Dr"(__gu_err) : "m"(__m(addr)), "1"(__gu_err)=
);
=20
 #define __get_user_8(addr)									\
-	asm ("\n"_LL"\tld1 %0=3D%2%P2\t// %0 and %1 get overwritten by exception =
handler\n"	\
-	     "\t.xdata4 \"__ex_table\", @gprel(1b), @gprel(1f)+4\n"				\
-	     _LL										\
+	asm ("\n[1:]\tld1 %0=3D%2%P2\t// %0 and %1 get overwritten by exception h=
andler\n"	\
+	     "\t.xdata4 \"__ex_table\", 1b-., 1f-.+4\n"						\
+	     "[1:]"										\
 	     : "=3Dr"(__gu_val), "=3Dr"(__gu_err) : "m"(__m(addr)), "1"(__gu_err)=
);
=20
 extern void __put_user_unknown (void);
@@ -201,30 +191,30 @@
  */
 #define __put_user_64(x,addr)								\
 	asm volatile (									\
-		"\n"_LL"\tst8 %1=3D%r2%P1\t// %0 gets overwritten by exception handler\n=
"	\
-		"\t.xdata4 \"__ex_table\", @gprel(1b), @gprel(1f)\n"			\
-		_LL									\
+		"\n[1:]\tst8 %1=3D%r2%P1\t// %0 gets overwritten by exception handler\n"=
	\
+		"\t.xdata4 \"__ex_table\", 1b-., 1f-.\n"				\
+		"[1:]"									\
 		: "=3Dr"(__pu_err) : "m"(__m(addr)), "rO"(x), "0"(__pu_err))
=20
 #define __put_user_32(x,addr)								\
 	asm volatile (									\
-		"\n"_LL"\tst4 %1=3D%r2%P1\t// %0 gets overwritten by exception handler\n=
"	\
-		"\t.xdata4 \"__ex_table\", @gprel(1b), @gprel(1f)\n"			\
-		_LL									\
+		"\n[1:]\tst4 %1=3D%r2%P1\t// %0 gets overwritten by exception handler\n"=
	\
+		"\t.xdata4 \"__ex_table\", 1b-., 1f-.\n"				\
+		"[1:]"									\
 		: "=3Dr"(__pu_err) : "m"(__m(addr)), "rO"(x), "0"(__pu_err))
=20
 #define __put_user_16(x,addr)								\
 	asm volatile (									\
-		"\n"_LL"\tst2 %1=3D%r2%P1\t// %0 gets overwritten by exception handler\n=
"	\
-		"\t.xdata4 \"__ex_table\", @gprel(1b), @gprel(1f)\n"			\
-		_LL									\
+		"\n[1:]\tst2 %1=3D%r2%P1\t// %0 gets overwritten by exception handler\n"=
	\
+		"\t.xdata4 \"__ex_table\", 1b-., 1f-.\n"				\
+		"[1:]"									\
 		: "=3Dr"(__pu_err) : "m"(__m(addr)), "rO"(x), "0"(__pu_err))
=20
 #define __put_user_8(x,addr)								\
 	asm volatile (									\
-		"\n"_LL"\tst1 %1=3D%r2%P1\t// %0 gets overwritten by exception handler\n=
"	\
-		"\t.xdata4 \"__ex_table\", @gprel(1b), @gprel(1f)\n"			\
-		_LL									\
+		"\n[1:]\tst1 %1=3D%r2%P1\t// %0 gets overwritten by exception handler\n"=
	\
+		"\t.xdata4 \"__ex_table\", 1b-., 1f-.\n"				\
+		"[1:]"									\
 		: "=3Dr"(__pu_err) : "m"(__m(addr)), "rO"(x), "0"(__pu_err))
=20
 /*
@@ -314,26 +304,22 @@
 	int cont;	/* gp-relative continuation address; if bit 2 is set, r9 is set=
 to 0 */
 };
=20
-struct exception_fixup {
-	unsigned long cont;	/* continuation point (bit 2: clear r9 if set) */
-};
-
-extern struct exception_fixup search_exception_table (unsigned long addr);
-extern void handle_exception (struct pt_regs *regs, struct exception_fixup=
 fixup);
+extern void handle_exception (struct pt_regs *regs, const struct exception=
_table_entry *e);
+extern const struct exception_table_entry *search_exception_tables (unsign=
ed long addr);
=20
 #ifdef GAS_HAS_LOCAL_TAGS
-#define SEARCH_EXCEPTION_TABLE(regs) search_exception_table(regs->cr_iip +=
 ia64_psr(regs)->ri);
+# define SEARCH_EXCEPTION_TABLE(regs) search_exception_tables(regs->cr_iip=
 + ia64_psr(regs)->ri)
 #else
-#define SEARCH_EXCEPTION_TABLE(regs) search_exception_table(regs->cr_iip);
+# define SEARCH_EXCEPTION_TABLE(regs) search_exception_tables(regs->cr_iip)
 #endif
=20
 static inline int
 done_with_exception (struct pt_regs *regs)
 {
-	struct exception_fixup fix;
-	fix =3D SEARCH_EXCEPTION_TABLE(regs);
-	if (fix.cont) {
-		handle_exception(regs, fix);
+	const struct exception_table_entry *e;
+	e =3D SEARCH_EXCEPTION_TABLE(regs);
+	if (e) {
+		handle_exception(regs, e);
 		return 1;
 	}
 	return 0;
diff -Nru a/include/asm-ia64/unistd.h b/include/asm-ia64/unistd.h
--- a/include/asm-ia64/unistd.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-ia64/unistd.h	Fri Jan 24 20:41:05 2003
@@ -4,7 +4,7 @@
 /*
  * IA-64 Linux syscall numbers and inline-functions.
  *
- * Copyright (C) 1998-2002 Hewlett-Packard Co
+ * Copyright (C) 1998-2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
@@ -223,8 +223,8 @@
 #define __NR_sched_setaffinity		1231
 #define __NR_sched_getaffinity		1232
 #define __NR_set_tid_address		1233
-/* #define __NR_alloc_hugepages		1234 reusable */
-/* #define __NR_free_hugepages		1235 reusable */
+/* 1234 available for reuse */
+/* 1235 available for reuse */
 #define __NR_exit_group			1236
 #define __NR_lookup_dcookie		1237
 #define __NR_io_setup			1238
diff -Nru a/include/asm-sparc64/agp.h b/include/asm-sparc64/agp.h
--- a/include/asm-sparc64/agp.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-sparc64/agp.h	Fri Jan 24 20:41:05 2003
@@ -8,4 +8,11 @@
 #define flush_agp_mappings()=20
 #define flush_agp_cache() mb()
=20
+/*
+ * Page-protection value to be used for AGP memory mapped into kernel spac=
e.  For
+ * platforms which use coherent AGP DMA, this can be PAGE_KERNEL.  For oth=
ers, it needs to
+ * be an uncached mapping (such as write-combining).
+ */
+#define PAGE_AGP			PAGE_KERNEL_NOCACHE
+
 #endif
diff -Nru a/include/asm-x86_64/agp.h b/include/asm-x86_64/agp.h
--- a/include/asm-x86_64/agp.h	Fri Jan 24 20:41:05 2003
+++ b/include/asm-x86_64/agp.h	Fri Jan 24 20:41:05 2003
@@ -20,4 +20,11 @@
    worth it. Would need a page for it. */
 #define flush_agp_cache() asm volatile("wbinvd":::"memory")
=20
+/*
+ * Page-protection value to be used for AGP memory mapped into kernel spac=
e.  For
+ * platforms which use coherent AGP DMA, this can be PAGE_KERNEL.  For oth=
ers, it needs to
+ * be an uncached mapping (such as write-combining).
+ */
+#define PAGE_AGP			PAGE_KERNEL_NOCACHE
+
 #endif
diff -Nru a/include/linux/acpi_serial.h b/include/linux/acpi_serial.h
--- a/include/linux/acpi_serial.h	Fri Jan 24 20:41:05 2003
+++ b/include/linux/acpi_serial.h	Fri Jan 24 20:41:05 2003
@@ -9,6 +9,8 @@
  *
  */
=20
+#include <linux/serial.h>
+
 extern void setup_serial_acpi(void *);
=20
 #define ACPI_SIG_LEN		4
diff -Nru a/include/linux/highmem.h b/include/linux/highmem.h
--- a/include/linux/highmem.h	Fri Jan 24 20:41:05 2003
+++ b/include/linux/highmem.h	Fri Jan 24 20:41:05 2003
@@ -3,6 +3,8 @@
=20
 #include <linux/config.h>
 #include <linux/fs.h>
+#include <linux/mm.h>
+
 #include <asm/cacheflush.h>
=20
 #ifdef CONFIG_HIGHMEM
diff -Nru a/include/linux/irq.h b/include/linux/irq.h
--- a/include/linux/irq.h	Fri Jan 24 20:41:05 2003
+++ b/include/linux/irq.h	Fri Jan 24 20:41:05 2003
@@ -56,15 +56,13 @@
  *
  * Pad this out to 32 bytes for cache and indexing reasons.
  */
-typedef struct {
+typedef struct irq_desc {
 	unsigned int status;		/* IRQ status */
 	hw_irq_controller *handler;
 	struct irqaction *action;	/* IRQ action list */
 	unsigned int depth;		/* nested irq disables */
 	spinlock_t lock;
 } ____cacheline_aligned irq_desc_t;
-
-extern irq_desc_t irq_desc [NR_IRQS];
=20
 #include <asm/hw_irq.h> /* the arch dependent stuff */
=20
diff -Nru a/include/linux/irq_cpustat.h b/include/linux/irq_cpustat.h
--- a/include/linux/irq_cpustat.h	Fri Jan 24 20:41:05 2003
+++ b/include/linux/irq_cpustat.h	Fri Jan 24 20:41:05 2003
@@ -24,7 +24,7 @@
 #define __IRQ_STAT(cpu, member)	(irq_stat[cpu].member)
 #else
 #define __IRQ_STAT(cpu, member)	((void)(cpu), irq_stat[0].member)
-#endif=09
+#endif
 #endif
=20
   /* arch independent irq_stat fields */
@@ -33,5 +33,10 @@
 #define ksoftirqd_task(cpu)	__IRQ_STAT((cpu), __ksoftirqd_task)
   /* arch dependent irq_stat fields */
 #define nmi_count(cpu)		__IRQ_STAT((cpu), __nmi_count)		/* i386, ia64 */
+
+#define local_softirq_pending()	softirq_pending(smp_processor_id())
+#define local_syscall_count()	syscall_count(smp_processor_id())
+#define local_ksoftirqd_task()	ksoftirqd_task(smp_processor_id())
+#define local_nmi_count()	nmi_count(smp_processor_id())
=20
 #endif	/* __irq_cpustat_h */
diff -Nru a/include/linux/percpu.h b/include/linux/percpu.h
--- a/include/linux/percpu.h	Fri Jan 24 20:41:05 2003
+++ b/include/linux/percpu.h	Fri Jan 24 20:41:05 2003
@@ -1,9 +1,8 @@
 #ifndef __LINUX_PERCPU_H
 #define __LINUX_PERCPU_H
-#include <linux/spinlock.h> /* For preempt_disable() */
+#include <linux/preempt.h> /* For preempt_disable() */
 #include <linux/slab.h> /* For kmalloc_percpu() */
 #include <asm/percpu.h>
-
 /* Must be an lvalue. */
 #define get_cpu_var(var) (*({ preempt_disable(); &__get_cpu_var(var); }))
 #define put_cpu_var(var) preempt_enable()
diff -Nru a/include/linux/ptrace.h b/include/linux/ptrace.h
--- a/include/linux/ptrace.h	Fri Jan 24 20:41:05 2003
+++ b/include/linux/ptrace.h	Fri Jan 24 20:41:05 2003
@@ -4,6 +4,7 @@
 /* structs and defines to help the user use the ptrace system call. */
=20
 #include <linux/compiler.h>
+#include <linux/sched.h>
=20
 /* has the defines to get at the registers. */
=20
diff -Nru a/include/linux/sched.h b/include/linux/sched.h
--- a/include/linux/sched.h	Fri Jan 24 20:41:05 2003
+++ b/include/linux/sched.h	Fri Jan 24 20:41:05 2003
@@ -148,8 +148,8 @@
 extern void init_idle(task_t *idle, int cpu);
=20
 extern void show_state(void);
-extern void show_trace(unsigned long *stack);
-extern void show_stack(unsigned long *stack);
+extern void show_trace(struct task_struct *);
+extern void show_stack(struct task_struct *);
 extern void show_regs(struct pt_regs *);
=20
 void io_schedule(void);
@@ -470,14 +470,14 @@
=20
 #ifndef INIT_THREAD_SIZE
 # define INIT_THREAD_SIZE	2048*sizeof(long)
-#endif
-
 union thread_union {
 	struct thread_info thread_info;
 	unsigned long stack[INIT_THREAD_SIZE/sizeof(long)];
 };
=20
 extern union thread_union init_thread_union;
+#endif
+
 extern struct task_struct init_task;
=20
 extern struct   mm_struct init_mm;
diff -Nru a/include/linux/serial.h b/include/linux/serial.h
--- a/include/linux/serial.h	Fri Jan 24 20:41:05 2003
+++ b/include/linux/serial.h	Fri Jan 24 20:41:05 2003
@@ -179,14 +179,9 @@
 extern int register_serial(struct serial_struct *req);
 extern void unregister_serial(int line);
=20
-/* Allow complicated architectures to specify rs_table[] at run time */
-extern int early_serial_setup(struct serial_struct *req);
-
-#ifdef CONFIG_ACPI
-/* tty ports reserved for the ACPI serial console port and debug port */
-#define ACPI_SERIAL_CONSOLE_PORT        4
-#define ACPI_SERIAL_DEBUG_PORT          5
-#endif
+/* Allow architectures to override entries in serial8250_ports[] at run ti=
me: */
+struct uart_port;	/* forward declaration */
+extern int early_serial_setup(struct uart_port *port);
=20
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SERIAL_H */
diff -Nru a/include/linux/smp.h b/include/linux/smp.h
--- a/include/linux/smp.h	Fri Jan 24 20:41:05 2003
+++ b/include/linux/smp.h	Fri Jan 24 20:41:05 2003
@@ -58,10 +58,6 @@
  */
 extern int smp_threads_ready;
=20
-extern volatile unsigned long smp_msg_data;
-extern volatile int smp_src_cpu;
-extern volatile int smp_msg_id;
-
 #define MSG_ALL_BUT_SELF	0x8000	/* Assume <32768 CPU's */
 #define MSG_ALL			0x8001
=20
diff -Nru a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
--- a/include/linux/sunrpc/svc.h	Fri Jan 24 20:41:05 2003
+++ b/include/linux/sunrpc/svc.h	Fri Jan 24 20:41:05 2003
@@ -73,7 +73,7 @@
  * This assumes that the non-page part of an rpc reply will fit
  * in a page - NFSd ensures this.  lockd also has no trouble.
  */
-#define RPCSVC_MAXPAGES		((RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PAGE_SIZE + 1)
+#define RPCSVC_MAXPAGES		((RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PAGE_SIZE + 2)
=20
 static inline u32 svc_getu32(struct iovec *iov)
 {
diff -Nru a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c	Fri Jan 24 20:41:05 2003
+++ b/kernel/fork.c	Fri Jan 24 20:41:05 2003
@@ -71,6 +71,7 @@
 	return total;
 }
=20
+#if 0
 void __put_task_struct(struct task_struct *tsk)
 {
 	if (tsk !=3D current) {
@@ -88,6 +89,7 @@
 		put_cpu();
 	}
 }
+#endif
=20
 void add_wait_queue(wait_queue_head_t *q, wait_queue_t * wait)
 {
@@ -190,7 +192,11 @@
 	init_task.rlim[RLIMIT_NPROC].rlim_max =3D max_threads/2;
 }
=20
-static struct task_struct *dup_task_struct(struct task_struct *orig)
+#if 1
+extern struct task_struct *dup_task_struct (struct task_struct *orig);
+#else
+
+struct task_struct *dup_task_struct(struct task_struct *orig)
 {
 	struct task_struct *tsk;
 	struct thread_info *ti;
@@ -220,6 +226,8 @@
 	return tsk;
 }
=20
+#endif
+
 #ifdef CONFIG_MMU
 static inline int dup_mmap(struct mm_struct * mm, struct mm_struct * oldmm)
 {
@@ -839,11 +847,15 @@
=20
 	if (clone_flags & CLONE_CHILD_SETTID)
 		p->set_child_tid =3D child_tidptr;
+	else
+		p->set_child_tid =3D NULL;
 	/*
 	 * Clear TID on mm_release()?
 	 */
 	if (clone_flags & CLONE_CHILD_CLEARTID)
 		p->clear_child_tid =3D child_tidptr;
+	else
+		p->clear_child_tid =3D NULL;
=20
 	/*
 	 * Syscall tracing should be turned off in the child regardless
diff -Nru a/kernel/ksyms.c b/kernel/ksyms.c
--- a/kernel/ksyms.c	Fri Jan 24 20:41:05 2003
+++ b/kernel/ksyms.c	Fri Jan 24 20:41:05 2003
@@ -404,7 +404,9 @@
 EXPORT_SYMBOL(del_timer);
 EXPORT_SYMBOL(request_irq);
 EXPORT_SYMBOL(free_irq);
+#if !defined(CONFIG_IA64)
 EXPORT_SYMBOL(irq_stat);
+#endif
=20
 /* waitqueue handling */
 EXPORT_SYMBOL(add_wait_queue);
@@ -600,7 +602,9 @@
 /* init task, for moving kthread roots - ought to export a function ?? */
=20
 EXPORT_SYMBOL(init_task);
+#ifndef CONFIG_IA64
 EXPORT_SYMBOL(init_thread_union);
+#endif
=20
 EXPORT_SYMBOL(tasklist_lock);
 EXPORT_SYMBOL(find_task_by_pid);
diff -Nru a/kernel/printk.c b/kernel/printk.c
--- a/kernel/printk.c	Fri Jan 24 20:41:05 2003
+++ b/kernel/printk.c	Fri Jan 24 20:41:05 2003
@@ -315,6 +315,12 @@
 			__call_console_drivers(start, end);
 		}
 	}
+#ifdef CONFIG_IA64_EARLY_PRINTK
+	if (!console_drivers) {
+		void early_printk (const char *str, size_t len);
+		early_printk(&LOG_BUF(start), end - start);
+	}
+#endif
 }
=20
 /*
@@ -632,7 +638,11 @@
 		 * for us.
 		 */
 		spin_lock_irqsave(&logbuf_lock, flags);
+#ifdef CONFIG_IA64_EARLY_PRINTK
+		con_start =3D log_end;
+#else
 		con_start =3D log_start;
+#endif
 		spin_unlock_irqrestore(&logbuf_lock, flags);
 	}
 	release_console_sem();
@@ -685,3 +695,110 @@
 		tty->driver.write(tty, 0, msg, strlen(msg));
 	return;
 }
+
+#ifdef CONFIG_IA64_EARLY_PRINTK
+
+#include <asm/io.h>
+
+# ifdef CONFIG_IA64_EARLY_PRINTK_VGA
+
+
+#define VGABASE		((char *)0xc0000000000b8000)
+#define VGALINES	24
+#define VGACOLS		80
+
+static int current_ypos =3D VGALINES, current_xpos =3D 0;
+
+static void
+early_printk_vga (const char *str, size_t len)
+{
+	char c;
+	int  i, k, j;
+
+	while (len-- > 0) {
+		c =3D *str++;
+		if (current_ypos >=3D VGALINES) {
+			/* scroll 1 line up */
+			for (k =3D 1, j =3D 0; k < VGALINES; k++, j++) {
+				for (i =3D 0; i < VGACOLS; i++) {
+					writew(readw(VGABASE + 2*(VGACOLS*k + i)),
+					       VGABASE + 2*(VGACOLS*j + i));
+				}
+			}
+			for (i =3D 0; i < VGACOLS; i++) {
+				writew(0x720, VGABASE + 2*(VGACOLS*j + i));
+			}
+			current_ypos =3D VGALINES-1;
+		}
+		if (c =3D '\n') {
+			current_xpos =3D 0;
+			current_ypos++;
+		} else if (c !=3D '\r')  {
+			writew(((0x7 << 8) | (unsigned short) c),
+			       VGABASE + 2*(VGACOLS*current_ypos + current_xpos++));
+			if (current_xpos >=3D VGACOLS) {
+				current_xpos =3D 0;
+				current_ypos++;
+			}
+		}
+	}
+}
+
+# endif /* CONFIG_IA64_EARLY_PRINTK_VGA */
+
+# ifdef CONFIG_IA64_EARLY_PRINTK_UART
+
+#include <linux/serial_reg.h>
+#include <asm/system.h>
+
+static void early_printk_uart(const char *str, size_t len)
+{
+	static char *uart =3D NULL;
+	unsigned long uart_base;
+	char c;
+
+	if (!uart) {
+		uart_base =3D 0;
+#  ifdef CONFIG_SERIAL_8250_HCDP
+		{
+			extern unsigned long hcdp_early_uart(void);
+			uart_base =3D hcdp_early_uart();
+		}
+#  endif
+#  if CONFIG_IA64_EARLY_PRINTK_UART_BASE
+		if (!uart_base)
+			uart_base =3D CONFIG_IA64_EARLY_PRINTK_UART_BASE;
+#  endif
+		if (!uart_base)
+			return;
+
+		uart =3D ioremap(uart_base, 64);
+		if (!uart)
+			return;
+	}
+
+	while (len-- > 0) {
+		c =3D *str++;
+		while ((readb(uart + UART_LSR) & UART_LSR_TEMT) =3D 0)
+			cpu_relax(); /* spin */
+
+		writeb(c, uart + UART_TX);
+
+		if (c =3D '\n')
+			writeb('\r', uart + UART_TX);
+	}
+}
+
+# endif /* CONFIG_IA64_EARLY_PRINTK_UART */
+
+void early_printk(const char *str, size_t len)
+{
+#ifdef CONFIG_IA64_EARLY_PRINTK_UART
+	early_printk_uart(str, len);
+#endif
+#ifdef CONFIG_IA64_EARLY_PRINTK_VGA
+	early_printk_vga(str, len);
+#endif
+}
+
+#endif /* CONFIG_IA64_EARLY_PRINTK */
diff -Nru a/kernel/softirq.c b/kernel/softirq.c
--- a/kernel/softirq.c	Fri Jan 24 20:41:05 2003
+++ b/kernel/softirq.c	Fri Jan 24 20:41:05 2003
@@ -32,7 +32,10 @@
    - Tasklets: serialized wrt itself.
  */
=20
+/* No separate irq_stat for ia64, it is part of PSA */
+#if !defined(CONFIG_IA64)
 irq_cpustat_t irq_stat[NR_CPUS] ____cacheline_aligned;
+#endif /* CONFIG_IA64 */
=20
 static struct softirq_action softirq_vec[32] __cacheline_aligned_in_smp;
=20
@@ -63,7 +66,7 @@
 	local_irq_save(flags);
 	cpu =3D smp_processor_id();
=20
-	pending =3D softirq_pending(cpu);
+	pending =3D local_softirq_pending();
=20
 	if (pending) {
 		struct softirq_action *h;
@@ -72,7 +75,7 @@
 		local_bh_disable();
 restart:
 		/* Reset the pending bitmask before enabling irqs */
-		softirq_pending(cpu) =3D 0;
+		local_softirq_pending() =3D 0;
=20
 		local_irq_enable();
=20
@@ -87,7 +90,7 @@
=20
 		local_irq_disable();
=20
-		pending =3D softirq_pending(cpu);
+		pending =3D local_softirq_pending();
 		if (pending & mask) {
 			mask &=3D ~pending;
 			goto restart;
@@ -95,7 +98,7 @@
 		__local_bh_enable();
=20
 		if (pending)
-			wakeup_softirqd(cpu);
+			wakeup_softirqd(smp_processor_id());
 	}
=20
 	local_irq_restore(flags);
@@ -315,15 +318,15 @@
 	__set_current_state(TASK_INTERRUPTIBLE);
 	mb();
=20
-	ksoftirqd_task(cpu) =3D current;
+	local_ksoftirqd_task() =3D current;
=20
 	for (;;) {
-		if (!softirq_pending(cpu))
+		if (!local_softirq_pending())
 			schedule();
=20
 		__set_current_state(TASK_RUNNING);
=20
-		while (softirq_pending(cpu)) {
+		while (local_softirq_pending()) {
 			do_softirq();
 			cond_resched();
 		}
diff -Nru a/mm/bootmem.c b/mm/bootmem.c
--- a/mm/bootmem.c	Fri Jan 24 20:41:05 2003
+++ b/mm/bootmem.c	Fri Jan 24 20:41:05 2003
@@ -143,6 +143,7 @@
 static void * __init __alloc_bootmem_core (bootmem_data_t *bdata,=20
 	unsigned long size, unsigned long align, unsigned long goal)
 {
+	static unsigned long last_success;
 	unsigned long i, start =3D 0;
 	void *ret;
 	unsigned long offset, remaining_size;
@@ -168,6 +169,9 @@
 	if (goal && (goal >=3D bdata->node_boot_start) &&=20
 			((goal >> PAGE_SHIFT) < bdata->node_low_pfn)) {
 		preferred =3D goal - bdata->node_boot_start;
+
+		if (last_success >=3D preferred)
+			preferred =3D last_success;
 	} else
 		preferred =3D 0;
=20
@@ -179,6 +183,8 @@
 restart_scan:
 	for (i =3D preferred; i < eidx; i +=3D incr) {
 		unsigned long j;
+		i =3D find_next_zero_bit((char *)bdata->node_bootmem_map, eidx, i);
+		i =3D (i + incr - 1) & -incr;
 		if (test_bit(i, bdata->node_bootmem_map))
 			continue;
 		for (j =3D i + 1; j < i + areasize; ++j) {
@@ -197,6 +203,7 @@
 	}
 	return NULL;
 found:
+	last_success =3D start << PAGE_SHIFT;
 	if (start >=3D eidx)
 		BUG();
=20
@@ -256,21 +263,21 @@
 	map =3D bdata->node_bootmem_map;
 	for (i =3D 0; i < idx; ) {
 		unsigned long v =3D ~map[i / BITS_PER_LONG];
-		if (v) {=20
+		if (v) {
 			unsigned long m;
-			for (m =3D 1; m && i < idx; m<<=3D1, page++, i++) {=20
+			for (m =3D 1; m && i < idx; m<<=3D1, page++, i++) {
 				if (v & m) {
-			count++;
-			ClearPageReserved(page);
-			set_page_count(page, 1);
-			__free_page(page);
-		}
-	}
+					count++;
+					ClearPageReserved(page);
+					set_page_count(page, 1);
+					__free_page(page);
+				}
+			}
 		} else {
 			i+=3DBITS_PER_LONG;
-			page+=3DBITS_PER_LONG;=20
-		} =09
-	}=09
+			page+=3DBITS_PER_LONG;
+		}
+	}
 	total +=3D count;
=20
 	/*
diff -Nru a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c	Fri Jan 24 20:41:05 2003
+++ b/mm/memory.c	Fri Jan 24 20:41:05 2003
@@ -113,8 +113,10 @@
 	}
 	pmd =3D pmd_offset(dir, 0);
 	pgd_clear(dir);
-	for (j =3D 0; j < PTRS_PER_PMD ; j++)
+	for (j =3D 0; j < PTRS_PER_PMD ; j++) {
+		prefetchw(pmd + j + PREFETCH_STRIDE/sizeof(*pmd));
 		free_one_pmd(tlb, pmd+j);
+	}
 	pmd_free_tlb(tlb, pmd);
 }
=20
diff -Nru a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c	Fri Jan 24 20:41:05 2003
+++ b/mm/mmap.c	Fri Jan 24 20:41:05 2003
@@ -1265,8 +1265,8 @@
=20
 	tlb =3D tlb_gather_mmu(mm, 1);
 	flush_cache_mm(mm);
-	mm->map_count -=3D unmap_vmas(&tlb, mm, mm->mmap, 0,
-					TASK_SIZE, &nr_accounted);
+	/* Use ~0UL here to ensure all VMAs ni the mm are unmapped */
+	mm->map_count -=3D unmap_vmas(&tlb, mm, mm->mmap, 0, ~0UL, &nr_accounted);
 	vm_unacct_memory(nr_accounted);
 	BUG_ON(mm->map_count);	/* This is just debugging */
 	clear_page_tables(tlb, FIRST_USER_PGD_NR, USER_PTRS_PER_PGD);
diff -Nru a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c	Fri Jan 24 20:41:05 2003
+++ b/mm/page_alloc.c	Fri Jan 24 20:41:05 2003
@@ -1078,6 +1078,41 @@
 	memset(pgdat->valid_addr_bitmap, 0, size);
 }
=20
+static void __init memmap_init(struct page *start, unsigned long size,
+			       int nid, unsigned long zone, unsigned long start_pfn)
+{
+	struct page *page;
+
+	/*
+	 * Initially all pages are reserved - free ones are freed
+	 * up by free_all_bootmem() once the early boot process is
+	 * done. Non-atomic initialization, single-pass.
+	 */
+
+	for (page =3D start; page < (start + size); page++) {
+		set_page_zone(page, nid * MAX_NR_ZONES + zone);
+		set_page_count(page, 0);
+		SetPageReserved(page);
+		INIT_LIST_HEAD(&page->list);
+#ifdef WANT_PAGE_VIRTUAL
+		if (zone !=3D ZONE_HIGHMEM)
+			/*
+			 * The shift left won't overflow because the
+			 * ZONE_NORMAL is below 4G.
+			 */
+			set_page_address(page, __va(start_pfn << PAGE_SHIFT));
+#endif
+		start_pfn++;
+	}
+}
+
+#ifdef HAVE_ARCH_MEMMAP_INIT
+#define MEMMAP_INIT(start, size, nid, zone, start_pfn) \
+	arch_memmap_init(memmap_init, start, size, nid, zone, start_pfn)
+#else
+#define MEMMAP_INIT(start, size, nid, zone, start_pfn) \
+	memmap_init(start, size, nid, zone, start_pfn)
+#endif
 /*
  * Set up the zone data structures:
  *   - mark all pages reserved
@@ -1189,28 +1224,8 @@
 		if ((zone_start_pfn) & (zone_required_alignment-1))
 			printk("BUG: wrong zone alignment, it will crash\n");
=20
-		/*
-		 * Initially all pages are reserved - free ones are freed
-		 * up by free_all_bootmem() once the early boot process is
-		 * done. Non-atomic initialization, single-pass.
-		 */
-		for (i =3D 0; i < size; i++) {
-			struct page *page =3D lmem_map + local_offset + i;
-			set_page_zone(page, nid * MAX_NR_ZONES + j);
-			set_page_count(page, 0);
-			SetPageReserved(page);
-			INIT_LIST_HEAD(&page->list);
-#ifdef WANT_PAGE_VIRTUAL
-			if (j !=3D ZONE_HIGHMEM)
-				/*
-				 * The shift left won't overflow because the
-				 * ZONE_NORMAL is below 4G.
-				 */
-				set_page_address(page,
-					__va(zone_start_pfn << PAGE_SHIFT));
-#endif
-			zone_start_pfn++;
-		}
+		MEMMAP_INIT(lmem_map + local_offset,size,nid,j,zone_start_pfn);
+		zone_start_pfn +=3D size;
=20
 		local_offset +=3D size;
 		for (i =3D 0; ; i++) {
diff -Nru a/scripts/kallsyms.c b/scripts/kallsyms.c
--- a/scripts/kallsyms.c	Fri Jan 24 20:41:05 2003
+++ b/scripts/kallsyms.c	Fri Jan 24 20:41:05 2003
@@ -12,6 +12,15 @@
 #include <stdlib.h>
 #include <string.h>
=20
+#include <linux/config.h>
+
+#if CONFIG_ALPHA || CONFIG_IA64 || CONFIG_MIPS64 || CONFIG_PPC64 || CONFIG=
_S390X \
+ || CONFIG_SPARC64 || CONFIG_X86_64
+# define ADDR_DIRECTIVE	".quad"
+#else
+# define ADDR_DIRECTIVE	".long"
+#endif
+
 struct sym_entry {
 	unsigned long long addr;
 	char type;
diff -Nru a/sound/oss/cs4281/cs4281m.c b/sound/oss/cs4281/cs4281m.c
--- a/sound/oss/cs4281/cs4281m.c	Fri Jan 24 20:41:05 2003
+++ b/sound/oss/cs4281/cs4281m.c	Fri Jan 24 20:41:05 2003
@@ -1946,8 +1946,8 @@
 		len -=3D x;
 	}
 	CS_DBGOUT(CS_WAVE_WRITE, 4, printk(KERN_INFO
-		"cs4281: clear_advance(): memset %d at 0x%.8x for %d size \n",
-			(unsigned)c, (unsigned)((char *) buf) + bptr, len));
+		"cs4281: clear_advance(): memset %d at %p for %d size \n",
+			(unsigned)c, ((char *) buf) + bptr, len));
 	memset(((char *) buf) + bptr, c, len);
 }
=20
@@ -1982,9 +1982,8 @@
 				wake_up(&s->dma_adc.wait);
 		}
 		CS_DBGOUT(CS_PARMS, 8, printk(KERN_INFO
-			"cs4281: cs4281_update_ptr(): s=3D0x%.8x hwptr=3D%d total_bytes=3D%d co=
unt=3D%d \n",
-				(unsigned)s, s->dma_adc.hwptr,=20
-				s->dma_adc.total_bytes, s->dma_adc.count));
+			"cs4281: cs4281_update_ptr(): s=3D%p hwptr=3D%d total_bytes=3D%d count=
=3D%d \n",
+				s, s->dma_adc.hwptr, s->dma_adc.total_bytes, s->dma_adc.count));
 	}
 	// update DAC pointer=20
 	//
@@ -2016,11 +2015,10 @@
 				// Continue to play silence until the _release.
 				//
 				CS_DBGOUT(CS_WAVE_WRITE, 6, printk(KERN_INFO
-					"cs4281: cs4281_update_ptr(): memset %d at 0x%.8x for %d size \n",
+					"cs4281: cs4281_update_ptr(): memset %d at %p for %d size \n",
 						(unsigned)(s->prop_dac.fmt &=20
 						(AFMT_U8 | AFMT_U16_LE)) ? 0x80 : 0,=20
-						(unsigned)s->dma_dac.rawbuf,=20
-						s->dma_dac.dmasize));
+						s->dma_dac.rawbuf, s->dma_dac.dmasize));
 				memset(s->dma_dac.rawbuf,
 				       (s->prop_dac.
 					fmt & (AFMT_U8 | AFMT_U16_LE)) ?
@@ -2051,9 +2049,8 @@
 			}
 		}
 		CS_DBGOUT(CS_PARMS, 8, printk(KERN_INFO
-			"cs4281: cs4281_update_ptr(): s=3D0x%.8x hwptr=3D%d total_bytes=3D%d co=
unt=3D%d \n",
-				(unsigned) s, s->dma_dac.hwptr,=20
-				s->dma_dac.total_bytes, s->dma_dac.count));
+			"cs4281: cs4281_update_ptr(): s=3D%p hwptr=3D%d total_bytes=3D%d count=
=3D%d \n",
+				s, s->dma_dac.hwptr, s->dma_dac.total_bytes, s->dma_dac.count));
 	}
 }
=20
@@ -2184,8 +2181,7 @@
=20
 	VALIDATE_STATE(s);
 	CS_DBGOUT(CS_FUNCTION, 4, printk(KERN_INFO
-		 "cs4281: mixer_ioctl(): s=3D0x%.8x cmd=3D0x%.8x\n",
-			 (unsigned) s, cmd));
+		 "cs4281: mixer_ioctl(): s=3D%p cmd=3D0x%.8x\n", s, cmd));
 #if CSDEBUG
 	cs_printioctl(cmd);
 #endif
@@ -2750,9 +2746,8 @@
 	CS_DBGOUT(CS_FUNCTION, 2,
 		  printk(KERN_INFO "cs4281: CopySamples()+ "));
 	CS_DBGOUT(CS_WAVE_READ, 8, printk(KERN_INFO
-		 " dst=3D0x%x src=3D0x%x count=3D%d iChannels=3D%d fmt=3D0x%x\n",
-			 (unsigned) dst, (unsigned) src, (unsigned) count,
-			 (unsigned) iChannels, (unsigned) fmt));
+		 " dst=3D%p src=3D%p count=3D%d iChannels=3D%d fmt=3D0x%x\n",
+			 dst, src, (unsigned) count, (unsigned) iChannels, (unsigned) fmt));
=20
 	// Gershwin does format conversion in hardware so normally
 	// we don't do any host based coversion. The data formatter
@@ -2832,9 +2827,9 @@
 	void *src =3D hwsrc;	//default to the standard destination buffer addr
=20
 	CS_DBGOUT(CS_FUNCTION, 6, printk(KERN_INFO
-		"cs_copy_to_user()+ fmt=3D0x%x fmt_o=3D0x%x cnt=3D%d dest=3D0x%.8x\n",
+		"cs_copy_to_user()+ fmt=3D0x%x fmt_o=3D0x%x cnt=3D%d dest=3D%p\n",
 			s->prop_adc.fmt, s->prop_adc.fmt_original,
-			(unsigned) cnt, (unsigned) dest));
+			(unsigned) cnt, dest));
=20
 	if (cnt > s->dma_adc.dmasize) {
 		cnt =3D s->dma_adc.dmasize;
@@ -2879,7 +2874,7 @@
 	unsigned copied =3D 0;
=20
 	CS_DBGOUT(CS_FUNCTION | CS_WAVE_READ, 2,
-		  printk(KERN_INFO "cs4281: cs4281_read()+ %d \n", count));
+		  printk(KERN_INFO "cs4281: cs4281_read()+ %Zu \n", count));
=20
 	VALIDATE_STATE(s);
 	if (ppos !=3D &file->f_pos)
@@ -2902,7 +2897,7 @@
 //
 	while (count > 0) {
 		CS_DBGOUT(CS_WAVE_READ, 8, printk(KERN_INFO
-			"_read() count>0 count=3D%d .count=3D%d .swptr=3D%d .hwptr=3D%d \n",
+			"_read() count>0 count=3D%Zu .count=3D%d .swptr=3D%d .hwptr=3D%d \n",
 				count, s->dma_adc.count,
 				s->dma_adc.swptr, s->dma_adc.hwptr));
 		spin_lock_irqsave(&s->lock, flags);
@@ -2959,11 +2954,10 @@
 		// the "cnt" is the number of bytes to read.
=20
 		CS_DBGOUT(CS_WAVE_READ, 2, printk(KERN_INFO
-			"_read() copy_to cnt=3D%d count=3D%d ", cnt, count));
+			"_read() copy_to cnt=3D%d count=3D%Zu ", cnt, count));
 		CS_DBGOUT(CS_WAVE_READ, 8, printk(KERN_INFO
-			 " .dmasize=3D%d .count=3D%d buffer=3D0x%.8x ret=3D%d\n",
-				 s->dma_adc.dmasize, s->dma_adc.count,
-				 (unsigned) buffer, ret));
+			 " .dmasize=3D%d .count=3D%d buffer=3D%p ret=3D%Zd\n",
+				 s->dma_adc.dmasize, s->dma_adc.count, buffer, ret));
=20
 		if (cs_copy_to_user
 		    (s, buffer, s->dma_adc.rawbuf + swptr, cnt, &copied))
@@ -2979,7 +2973,7 @@
 		start_adc(s);
 	}
 	CS_DBGOUT(CS_FUNCTION | CS_WAVE_READ, 2,
-		  printk(KERN_INFO "cs4281: cs4281_read()- %d\n", ret));
+		  printk(KERN_INFO "cs4281: cs4281_read()- %Zd\n", ret));
 	return ret;
 }
=20
@@ -2995,7 +2989,7 @@
 	int cnt;
=20
 	CS_DBGOUT(CS_FUNCTION | CS_WAVE_WRITE, 2,
-		  printk(KERN_INFO "cs4281: cs4281_write()+ count=3D%d\n",
+		  printk(KERN_INFO "cs4281: cs4281_write()+ count=3D%Zu\n",
 			 count));
 	VALIDATE_STATE(s);
=20
@@ -3051,7 +3045,7 @@
 		start_dac(s);
 	}
 	CS_DBGOUT(CS_FUNCTION | CS_WAVE_WRITE, 2,
-		  printk(KERN_INFO "cs4281: cs4281_write()- %d\n", ret));
+		  printk(KERN_INFO "cs4281: cs4281_write()- %Zd\n", ret));
 	return ret;
 }
=20
@@ -3172,8 +3166,7 @@
 	int val, mapped, ret;
=20
 	CS_DBGOUT(CS_FUNCTION, 4, printk(KERN_INFO
-		 "cs4281: cs4281_ioctl(): file=3D0x%.8x cmd=3D0x%.8x\n",
-			 (unsigned) file, cmd));
+		 "cs4281: cs4281_ioctl(): file=3D%p cmd=3D0x%.8x\n", file, cmd));
 #if CSDEBUG
 	cs_printioctl(cmd);
 #endif
@@ -3603,8 +3596,8 @@
 	    (struct cs4281_state *) file->private_data;
=20
 	CS_DBGOUT(CS_FUNCTION | CS_RELEASE, 2, printk(KERN_INFO
-		 "cs4281: cs4281_release(): inode=3D0x%.8x file=3D0x%.8x f_mode=3D%d\n",
-			 (unsigned) inode, (unsigned) file, file->f_mode));
+		 "cs4281: cs4281_release(): inode=3D%p file=3D%p f_mode=3D%d\n",
+			 inode, file, file->f_mode));
=20
 	VALIDATE_STATE(s);
=20
@@ -3638,8 +3631,8 @@
 	struct list_head *entry;
=20
 	CS_DBGOUT(CS_FUNCTION | CS_OPEN, 2, printk(KERN_INFO
-		"cs4281: cs4281_open(): inode=3D0x%.8x file=3D0x%.8x f_mode=3D0x%x\n",
-			(unsigned) inode, (unsigned) file, file->f_mode));
+		"cs4281: cs4281_open(): inode=3D%p file=3D%p f_mode=3D0x%x\n",
+			inode, file, file->f_mode));
=20
 	list_for_each(entry, &cs4281_devs)
 	{
@@ -4348,10 +4341,8 @@
=20
 	CS_DBGOUT(CS_INIT, 2,
 		  printk(KERN_INFO
-			 "cs4281: probe() BA0=3D0x%.8x BA1=3D0x%.8x pBA0=3D0x%.8x pBA1=3D0x%.8x=
 \n",
-			 (unsigned) temp1, (unsigned) temp2,
-			 (unsigned) s->pBA0, (unsigned) s->pBA1));
-
+			 "cs4281: probe() BA0=3D0x%.8x BA1=3D0x%.8x pBA0=3D%p pBA1=3D%p \n",
+			 (unsigned) temp1, (unsigned) temp2, s->pBA0, s->pBA1));
 	CS_DBGOUT(CS_INIT, 2,
 		  printk(KERN_INFO
 			 "cs4281: probe() pBA0phys=3D0x%.8x pBA1phys=3D0x%.8x\n",
@@ -4398,15 +4389,13 @@
 	if (pmdev)
 	{
 		CS_DBGOUT(CS_INIT | CS_PM, 4, printk(KERN_INFO
-			 "cs4281: probe() pm_register() succeeded (0x%x).\n",
-				(unsigned)pmdev));
+			 "cs4281: probe() pm_register() succeeded (%p).\n", pmdev));
 		pmdev->data =3D s;
 	}
 	else
 	{
 		CS_DBGOUT(CS_INIT | CS_PM | CS_ERROR, 0, printk(KERN_INFO
-			 "cs4281: probe() pm_register() failed (0x%x).\n",
-				(unsigned)pmdev));
+			 "cs4281: probe() pm_register() failed (%p).\n", pmdev));
 		s->pm.flags |=3D CS4281_PM_NOT_REGISTERED;
 	}
 #endif
diff -Nru a/sound/oss/cs4281/cs4281pm-24.c b/sound/oss/cs4281/cs4281pm-24.c
--- a/sound/oss/cs4281/cs4281pm-24.c	Fri Jan 24 20:41:05 2003
+++ b/sound/oss/cs4281/cs4281pm-24.c	Fri Jan 24 20:41:05 2003
@@ -46,8 +46,8 @@
 	struct cs4281_state *state;
=20
 	CS_DBGOUT(CS_PM, 2, printk(KERN_INFO=20
-		"cs4281: cs4281_pm_callback dev=3D0x%x rqst=3D0x%x state=3D%d\n",
-			(unsigned)dev,(unsigned)rqst,(unsigned)data));
+		"cs4281: cs4281_pm_callback dev=3D%p rqst=3D0x%x state=3D%p\n",
+			dev,(unsigned)rqst,data));
 	state =3D (struct cs4281_state *) dev->data;
 	if (state) {
 		switch(rqst) {
diff -Nru a/usr/Makefile b/usr/Makefile
--- a/usr/Makefile	Fri Jan 24 20:41:05 2003
+++ b/usr/Makefile	Fri Jan 24 20:41:05 2003
@@ -5,12 +5,9 @@
=20
 clean-files :=3D initramfs_data.cpio.gz
=20
-LDFLAGS_initramfs_data.o :=3D $(LDFLAGS_BLOB) -r -T
-
-$(obj)/initramfs_data.o: $(src)/initramfs_data.scr $(obj)/initramfs_data.c=
pio.gz FORCE
-	$(call if_changed,ld)
-
 $(obj)/initramfs_data.cpio.gz: $(obj)/gen_init_cpio
 	./$< | gzip -9c > $@
=20
-
+$(obj)/initramfs_data.S: $(obj)/initramfs_data.cpio.gz
+	echo '.section ".init.ramfs", "a"' > $@
+	od -v -An -t x1 -w8 $^ | cut -c2- | sed -e s"/ /,0x/g" -e s"/^/.byte 0x"/=
 >> $@

