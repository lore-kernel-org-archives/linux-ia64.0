From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 22 Mar 2001 08:20:57 +0000
Subject: [Linux-ia64] kernel update (second patch relative to 2.4.2)
Message-Id: <marc-linux-ia64-105590693005334@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The latest IA-64 patch is now available at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

in file linux-2.4.2-ia64-010321.diff*

What this patch does:

	o Add AGP support for 460gx chipset [Chris Ahna]

	o Add EFI variable support to /proc [Matt Domsch]

	o Fix a typo in kernel/acpi.c that caused the wrong number
	  of CPUs to be detected if some of the CPUs were disabled
	  [Jack Steiner]

	o Fix ivt.S not to pass a bogus "break" number on a
	  non-syscall break [Keith Owens]

	o Add Big Sur ACPI workaround for problem that caused some
	  machines to hang at boot time. [Jung-ik Lee]

	o Fix csum_partial_copy.c to use copy_from_user() instead of
	  doing a byte-byte-byte.  This doubles the throughput for
	  local TCP connections.  Not bad for a one-liner... ;-)
	  Of course, this will have to be replaced by the real
	  integrated "copy-and-checksum" routine eventually; my guess
	  is this will give another nice performance boost

	o Drop backwards compatibility with old (Feb 2000) compiler;
	  this means that CONFIG_NEW_UNWIND is the default now and
	  that unwind directives are being used unconditionally.

	o Add a version of ucontext.h which defines a "ucontext"
	  structure that perfectly overlays onto the sigcontext
	  structure.  Note: this crap is intended for
	  application-level compatibility only.  IA-64 Linux always
	  passes the same sigcontext structure as the third argument
	  to a signal handler, independent of whether or not
	  SA_SIGINFO is set in the sigaction flags.  Also, since
	  sigcontext only contains the "scratch" regs, you can't
	  setcontext() to this context.  If you need to do this, use
	  sigsetjmp()/siglongjmp() to return to the signal handler
	  first and then do a normal "return" from the handler.
	  Clean, fast, and portable...

	o Modified the exception table format to take advantage of
	  local tags if they're support.  To take full advantage of
	  this, a gcc3.0 based toolchain would be necessary.  However,
	  the prerelease version of this compiler is NOT yet stable
	  enough for kernel use.  So even though you find a bunch of
	  "#if __GNUC__ >=3D 3" in the patch, I do not recommend
	  building with this compiler at this time.

CAVEAT 1: This patch does not work with the compiler Feb 2000 compiler
	anymore.  This is the compiler included with NUE, for example.
	We plan to update NUE shortly.  In the meantime, you'll either
	have to stick with an earlier kernel version or update the
	compiler yourself (not recommended unless you don't mind
	getting into gcc cross-building issues).  Of course, if you
	have a real system running a recent distro, this is not an
	issue.

CAVEAT 2: Since this patch changes the format of the exception tables,
	it is necessary to rebuild all kernel modules from scratch.
	If you don't do so, the kernel modules will fail in strange
	ways.  They load OK, but they will crash the kernel whenever
	an exception occurs.  You've been warned.

This patch has been tested on a dual Big Sur only, though I don't
expect any problems for other configurations.

Enjoy,

	--david

diff -urN --ignore-all-space linux-davidm/Documentation/Configure.help linu=
x-2.4.2-lia/Documentation/Configure.help
--- linux-davidm/Documentation/Configure.help	Wed Mar 21 23:46:39 2001
+++ linux-2.4.2-lia/Documentation/Configure.help	Wed Mar 21 22:49:09 2001
@@ -2394,6 +2394,21 @@
   the GLX component for XFree86 3.3.6, which can be downloaded from
   http://utah-glx.sourceforge.net/ .
=20
+Intel 460GX support
+CONFIG_AGP_I460
+  This option gives you AGP support for the Intel 460GX chipset.  This
+  chipset, the first to support Intel Itanium processors, is new and
+  this option is correspondingly experimental.  AGPGART support for 460GX
+  does work with the following {<video card>, <XFree86>} combinations:
+  {ATI Rage128, 4.0.2}, {ATI Radeon, latest CVS}, {Matrox G400, 4.0.2},
+  and {Matrox G450, XFree86 4.0.2}.  The G450 only works with a copy
+  of mgaHALlib.a for IA-64.
+
+  If you don't have a 460GX based machine (such as BigSur) with an AGP=20
+  slot then this option isn't going to do you much good.  If you're
+  dying to do Direct Rendering on IA-64, this is what you've been
+  waiting for.=20
+
 Intel I810/I810 DC100/I810e support
 CONFIG_AGP_I810
   This option gives you AGP support for the Xserver on the Intel 810
@@ -17159,6 +17174,16 @@
   Layer) information in /proc/pal.  This contains useful information
   about the processors in your systems, such as cache and TLB sizes
   and the PAL firmware version in use.
+
+  To use this option, you have to check that the "/proc file system
+  support" (CONFIG_PROC_FS) is enabled, too.
+
+/proc/efi support
+CONFIG_IA64_EFIVARS
+  If you say Y here, you are able to get EFI (Extensible Firmware
+  Interface) variable information in /proc/pal.  This can be used to
+  change the boot order in the EFI Boot Manager.
+
=20
   To use this option, you have to check that the "/proc file system
   support" (CONFIG_PROC_FS) is enabled, too.
diff -urN --ignore-all-space linux-davidm/Makefile linux-2.4.2-lia/Makefile
--- linux-davidm/Makefile	Wed Mar 21 23:46:39 2001
+++ linux-2.4.2-lia/Makefile	Wed Mar 21 23:18:38 2001
@@ -88,6 +89,7 @@
 CPPFLAGS :=3D -D__KERNEL__ -I$(HPATH)
=20
 CFLAGS :=3D $(CPPFLAGS) -Wall -Wstrict-prototypes -g -O2 -fomit-frame-poin=
ter -fno-strict-aliasing
+
 AFLAGS :=3D -D__ASSEMBLY__ $(CPPFLAGS)
=20
 #
@@ -133,6 +135,9 @@
=20
 DRIVERS-$(CONFIG_PARPORT) +=3D drivers/parport/driver.o
 DRIVERS-$(CONFIG_AGP) +=3D drivers/char/agp/agp.o
+ifeq ($(CONFIG_AGP), m)
+DRIVERS-y +=3D drivers/char/agp/agp.o
+endif
 DRIVERS-$(CONFIG_DRM) +=3D drivers/char/drm/drm.o
 DRIVERS-$(CONFIG_NUBUS) +=3D drivers/nubus/nubus.a
 DRIVERS-$(CONFIG_ISDN) +=3D drivers/isdn/isdn.a
diff -urN --ignore-all-space linux-davidm/arch/ia64/config.in linux-2.4.2-l=
ia/arch/ia64/config.in
--- linux-davidm/arch/ia64/config.in	Wed Mar 21 23:46:39 2001
+++ linux-2.4.2-lia/arch/ia64/config.in	Wed Mar 21 23:01:10 2001
@@ -57,7 +57,7 @@
 	if [ "$CONFIG_ITANIUM_CSTEP_SPECIFIC" =3D "y" ]; then
 	  bool '   Enable Itanium C0-step specific code' CONFIG_ITANIUM_C0_SPECIF=
IC
 	fi
-	if [ "$CONFIG_ITANIUM_ASTEP_SPECIFIC" =3D "y" -o "$CONFIG_ITANIUM_B0_SPEC=
IFIC" =3D "y"
+	if [ "$CONFIG_ITANIUM_ASTEP_SPECIFIC" =3D "y" -o "$CONFIG_ITANIUM_B0_SPEC=
IFIC" =3D "y" \
 	     -o "$CONFIG_ITANIUM_B1_SPECIFIC" =3D "y" -o "$CONFIG_ITANIUM_B2_SPEC=
IFIC" =3D "y" ]; then
 	  define_bool CONFIG_ITANIUM_PTCG n
 	else
@@ -74,8 +74,8 @@
 	  define_bool CONFIG_PM y
 	  define_bool CONFIG_ACPI y
 	  define_bool CONFIG_ACPI_INTERPRETER y
-	define_int  CONFIG_IA64_L1_CACHE_SHIFT	6	# align cache-sensitive data str=
ucture to 64 bytes
 	fi
+	define_int CONFIG_IA64_L1_CACHE_SHIFT 6 # align cache-sensitive data to 6=
4 bytes
 fi
=20
 if [ "$CONFIG_IA64_SGI_SN1" =3D "y" ]; then
@@ -90,7 +90,7 @@
 	define_int  CONFIG_CACHE_LINE_SHIFT 7
 	bool '  Enable DISCONTIGMEM support' CONFIG_DISCONTIGMEM
 	bool '	Enable NUMA support' CONFIG_NUMA
-	define_int  CONFIG_IA64_L1_CACHE_SHIFT	7	# align cache-sensitive data str=
ucture to 64 bytes
+	define_int  CONFIG_IA64_L1_CACHE_SHIFT 7 # align cache-sensitive data to =
128 bytes
 fi
=20
 define_bool CONFIG_KCORE_ELF y	# On IA-64, we always want an ELF /proc/kco=
re.
@@ -98,6 +98,7 @@
 bool 'SMP support' CONFIG_SMP
 bool 'Performance monitor support' CONFIG_PERFMON
 tristate  '/proc/pal support' CONFIG_IA64_PALINFO
+tristate '/proc/efi support' CONFIG_IA64_EFIVARS
=20
 bool 'Networking support' CONFIG_NET
 bool 'System V IPC' CONFIG_SYSVIPC
@@ -243,7 +244,7 @@
   if [ "$CONFIG_SCSI" !=3D "n" ]; then
     bool 'Simulated SCSI disk' CONFIG_SCSI_SIM
   fi
-  define_int  CONFIG_IA64_L1_CACHE_SHIFT	6	# align cache-sensitive data st=
ructure to 64 bytes
+  define_int CONFIG_IA64_L1_CACHE_SHIFT 6 # align cache-sensitive data to =
64 bytes
   endmenu
 fi
=20
@@ -264,7 +265,6 @@
 bool 'Turn on compare-and-exchange bug checking (slow!)' CONFIG_IA64_DEBUG=
_CMPXCHG
 bool 'Turn on irq debug checks (slow!)' CONFIG_IA64_DEBUG_IRQ
 bool 'Print possible IA64 hazards to console' CONFIG_IA64_PRINT_HAZARDS
-bool 'Enable new unwind support' CONFIG_IA64_NEW_UNWIND
 bool 'Disable VHPT' CONFIG_DISABLE_VHPT
=20
 endmenu
diff -urN --ignore-all-space linux-davidm/arch/ia64/ia32/ia32_entry.S linux=
-2.4.2-lia/arch/ia64/ia32/ia32_entry.S
--- linux-davidm/arch/ia64/ia32/ia32_entry.S	Wed Mar 21 23:46:39 2001
+++ linux-2.4.2-lia/arch/ia64/ia32/ia32_entry.S	Wed Mar 21 23:01:25 2001
@@ -4,6 +4,19 @@
=20
 #include "../kernel/entry.h"
=20
+	.section "__ex_table", "a"		// declare section & section attributes
+	.previous
+
+#if __GNUC__ >=3D 3
+# define EX(y,x...)					\
+	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
+  [99:]	x
+#else
+# define EX(y,x...)					\
+	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
+  99:	x
+#endif
+
 	.text
=20
 	/*
@@ -12,10 +25,10 @@
 	 * is exec'ing an IA-64 program).
 	 */
 ENTRY(ia32_execve)
-	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(3))
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(3)
 	alloc loc1=3Dar.pfs,3,2,4,0
 	mov loc0=3Drp
-	UNW(.body)
+	.body
 	mov out0=3Din0			// filename
 	;;				// stop bit between alloc and call
 	mov out1=3Din1			// argv
@@ -41,29 +54,20 @@
 	// We copy this 4-byte aligned value to an 8-byte aligned buffer
 	// in the task structure and then jump to the IA64 code.
=20
-	mov r8=3Dr0		// no memory access errors yet
-	add r10=3D4,r32
+	EX(.Lfail, ld4 r2=3D[r32],4)		// load low part of sigmask
 	;;
-1:
-	ld4 r2=3D[r32]		// get first half of sigmask
-	ld4 r3=3D[r10]		// get second half of sigmask
-2:
-	cmp.lt p6,p0=3Dr8,r0	// check memory access
-	;;
-(p6)	br.ret.sptk.many rp	//   it failed
-
+	EX(.Lfail, ld4 r3=3D[r32])		// load high part of sigmask
 	adds r32=3DIA64_TASK_THREAD_SIGMASK_OFFSET,r13
+	;;
+	st8 [r32]=3Dr2
 	adds r10=3DIA64_TASK_THREAD_SIGMASK_OFFSET+4,r13
 	;;
-	st4 [r32]=3Dr2
+
 	st4 [r10]=3Dr3
 	br.cond.sptk.many sys_rt_sigsuspend
-END(ia32_rt_sigsuspend)
=20
-	.section __ex_table,"a"
-	data4 @gprel(1b)
-	data4 (2b-1b)|1
-	.previous
+.Lfail:	br.ret.sptk.many rp	// failed to read sigmask
+END(ia32_rt_sigsuspend)
=20
 GLOBAL_ENTRY(ia32_ret_from_syscall)
 	PT_REGS_UNWIND_INFO(0)
@@ -106,7 +110,7 @@
 END(sys32_vfork)
=20
 GLOBAL_ENTRY(sys32_fork)
-	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2))
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2)
 	alloc r16=3Dar.pfs,2,2,4,0
 	mov out0=3DSIGCHLD			// out0 =3D clone_flags
 	;;
@@ -115,14 +119,14 @@
 	mov loc1=3Dr16				// save ar.pfs across do_fork
 	DO_SAVE_SWITCH_STACK
=20
-	UNW(.body)
+	.body
=20
 	mov out1=3D0
 	mov out3=3D0
 	adds out2=3DIA64_SWITCH_STACK_SIZE+16,sp	// out2 =3D &regs
 	br.call.sptk.few rp=3Ddo_fork
 .ret3:	mov ar.pfs=3Dloc1
-	UNW(.restore sp)
+	.restore sp
 	adds sp=3DIA64_SWITCH_STACK_SIZE,sp	// pop the switch stack
 	mov rp=3Dloc0
 	br.ret.sptk.many rp
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/Makefile linux-2=
.4.2-lia/arch/ia64/kernel/Makefile
--- linux-davidm/arch/ia64/kernel/Makefile	Wed Mar 21 23:46:39 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/Makefile	Wed Mar 21 23:03:01 2001
@@ -19,6 +19,7 @@
 obj-$(CONFIG_IA64_GENERIC) +=3D machvec.o iosapic.o
 obj-$(CONFIG_IA64_DIG) +=3D iosapic.o
 obj-$(CONFIG_IA64_PALINFO) +=3D palinfo.o
+obj-$(CONFIG_IA64_EFIVARS) +=3D efivars.o
 obj-$(CONFIG_PCI) +=3D pci.o
 obj-$(CONFIG_SMP) +=3D smp.o smpboot.o
 obj-$(CONFIG_IA64_MCA) +=3D mca.o mca_asm.o
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/acpi.c linux-2.4=
.2-lia/arch/ia64/kernel/acpi.c
--- linux-davidm/arch/ia64/kernel/acpi.c	Wed Mar 21 23:46:39 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/acpi.c	Wed Mar 21 23:03:12 2001
@@ -314,7 +314,7 @@
 		printk("ACPI: Found 0 CPUS; assuming 1\n");
 		available_cpus =3D 1; /* We've got at least one of these, no? */
 	}
-	smp_boot_data.cpu_count =3D available_cpus;
+	smp_boot_data.cpu_count =3D total_cpus;
 #endif
 	return 1;
 }
@@ -463,7 +463,7 @@
 		printk("ACPI: Found 0 CPUS; assuming 1\n");
 		available_cpus =3D 1; /* We've got at least one of these, no? */
 	}
-	smp_boot_data.cpu_count =3D available_cpus;
+	smp_boot_data.cpu_count =3D total_cpus;
 #endif
 	return 1;
 }
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/efi.c linux-2.4.=
2-lia/arch/ia64/kernel/efi.c
--- linux-davidm/arch/ia64/kernel/efi.c	Wed Mar 21 23:46:39 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/efi.c	Wed Mar 21 23:03:22 2001
@@ -374,7 +374,6 @@
=20
 	efi_map_pal_code();
 	efi_enter_virtual_mode();
-
 }
=20
 void
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/efi_stub.S linux=
-2.4.2-lia/arch/ia64/kernel/efi_stub.S
--- linux-davidm/arch/ia64/kernel/efi_stub.S	Wed Mar 21 23:46:39 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/efi_stub.S	Wed Mar 21 23:03:33 2001
@@ -50,11 +50,11 @@
  */
=20
 GLOBAL_ENTRY(efi_call_phys)
-	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8))
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
 	alloc loc1=3Dar.pfs,8,5,7,0
 	ld8 r2=3D[in0],8			// load EFI function's entry point
 	mov loc0=3Drp
-	UNW(.body)
+	.body
 	;;
 	mov loc2=3Dgp			// save global pointer
 	mov loc4=3Dar.rsc			// save RSE configuration
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/efivars.c linux-=
2.4.2-lia/arch/ia64/kernel/efivars.c
--- linux-davidm/arch/ia64/kernel/efivars.c	Wed Dec 31 16:00:00 1969
+++ linux-2.4.2-lia/arch/ia64/kernel/efivars.c	Wed Mar 21 23:03:43 2001
@@ -0,0 +1,435 @@
+/*
+ * EFI Variables - efivars.c
+ *
+ * Copyright (C) 2001 Dell Computer Corporation <Matt_Domsch@dell.com>
+ *
+ * This code takes all variables accessible from EFI runtime and
+ *  exports them via /proc
+ *
+ * Reads to /proc/efi/varname return an efi_variable_t structure.
+ * Writes to /proc/efi/varname must be an efi_variable_t structure.
+ * Writes with DataSize =3D 0 or Attributes =3D 0 deletes the variable.
+ * Writes with a new value in VariableName+VendorGuid creates
+ * a new variable.
+ *
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  =
USA
+ *
+ * Changelog:
+ *
+ *  12 March 2001 - Matt Domsch <Matt_Domsch@dell.com>
+ *   Feedback received from Stephane Eranian incorporated.
+ *   efivar_write() checks copy_from_user() return value.
+ *   efivar_read/write() returns proper errno.
+ *   v0.02 release to linux-ia64@linuxia64.org
+ *
+ *  26 February 2001 - Matt Domsch <Matt_Domsch@dell.com>
+ *   v0.01 release to linux-ia64@linuxia64.org
+ */
+
+#include <linux/config.h>
+#include <linux/types.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/proc_fs.h>
+#include <linux/sched.h>		/* for capable() */
+#include <linux/mm.h>
+#include <linux/module.h>
+
+#include <asm/efi.h>
+#include <asm/uaccess.h>
+#ifdef CONFIG_SMP
+#include <linux/smp.h>
+#endif
+
+MODULE_AUTHOR("Matt Domsch <Matt_Domsch@Dell.com>");
+MODULE_DESCRIPTION("/proc interface to EFI Variables");
+
+#define EFIVARS_VERSION "0.02 2001-Mar-12"
+
+static int
+efivar_read(char *page, char **start, off_t off,
+	    int count, int *eof, void *data);
+static int
+efivar_write(struct file *file, const char *buffer,
+	     unsigned long count, void *data);
+
+
+/*
+ * The maximum size of VariableName + Data =3D 1024
+ * Therefore, it's reasonable to save that much
+ * space in each part of the structure,
+ * and we use a page for reading/writing.
+ */
+
+typedef struct _efi_variable_t {
+	efi_char16_t  VariableName[1024/sizeof(efi_char16_t)];
+	efi_guid_t    VendorGuid;
+	unsigned long DataSize;
+	__u8          Data[1024];
+	efi_status_t  Status;
+	__u32         Attributes;
+} __attribute__((packed)) efi_variable_t;
+
+
+typedef struct _efivar_entry_t {
+	efi_variable_t          var;
+	struct proc_dir_entry   *entry;
+	struct list_head        list;
+} efivar_entry_t;
+
+spinlock_t efivars_lock =3D SPIN_LOCK_UNLOCKED;
+static LIST_HEAD(efivar_list);
+static struct proc_dir_entry *efi_dir =3D NULL;
+
+#define efivar_entry(n) list_entry(n, efivar_entry_t, list)
+
+/* Return the number of unicode characters in data */
+static unsigned long
+utf8_strlen(efi_char16_t *data, unsigned long maxlength)
+{
+	unsigned long length =3D 0;
+	while (*data++ !=3D 0 && length < maxlength)
+		length++;
+	return length;
+}
+
+/* Return the number of bytes is the length of this string */
+/* Note: this is NOT the same as the number of unicode characters */
+static inline unsigned long
+utf8_strsize(efi_char16_t *data, unsigned long maxlength)
+{
+	return utf8_strlen(data, maxlength/sizeof(efi_char16_t)) *
+		sizeof(efi_char16_t);
+}
+
+
+static int
+proc_calc_metrics(char *page, char **start, off_t off,
+		  int count, int *eof, int len)
+{
+	if (len <=3D off+count) *eof =3D 1;
+	*start =3D page + off;
+	len -=3D off;
+	if (len>count) len =3D count;
+	if (len<0) len =3D 0;
+	return len;
+}
+
+
+static void
+uuid_unparse(efi_guid_t *guid, char *out)
+{
+	sprintf(out, "%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
+		guid->data1, guid->data2, guid->data3,
+		guid->data4[0], guid->data4[1], guid->data4[2], guid->data4[3],
+		guid->data4[4], guid->data4[5], guid->data4[6], guid->data4[7]);
+}
+
+
+
+
+
+/*
+ * efivar_create_proc_entry()
+ * Requires:
+ *    variable_name_size =3D number of bytes required to hold
+ *                         variable_name (not counting the NULL
+ *                         character at the end.
+ * Returns 1 on failure, 0 on success
+ */
+static int
+efivar_create_proc_entry(unsigned long variable_name_size,
+			 efi_char16_t *variable_name,
+			 efi_guid_t *vendor_guid)
+{
+
+	int i, short_name_size =3D variable_name_size /
+		sizeof(efi_char16_t) + 38;
+	char *short_name =3D kmalloc(short_name_size+1,
+				   GFP_KERNEL);
+	efivar_entry_t *new_efivar =3D kmalloc(sizeof(efivar_entry_t),
+					     GFP_KERNEL);
+	if (!short_name || !new_efivar)  {
+		if (short_name)        kfree(short_name);
+		if (new_efivar)        kfree(new_efivar);
+		return 1;
+	}
+	memset(short_name, 0, short_name_size+1);
+	memset(new_efivar, 0, sizeof(efivar_entry_t));
+
+	memcpy(new_efivar->var.VariableName, variable_name,
+	       variable_name_size);
+	memcpy(&(new_efivar->var.VendorGuid), vendor_guid, sizeof(efi_guid_t));
+
+	/* Convert Unicode to normal chars (assume top bits are 0),
+	   ala UTF-8 */
+	for (i=3D0; i<variable_name_size / sizeof(efi_char16_t); i++) {
+		short_name[i] =3D variable_name[i] & 0xFF;
+	}
+
+	/* This is ugly, but necessary to separate one vendor's
+	   private variables from another's.         */
+
+	*(short_name + strlen(short_name)) =3D '-';
+	uuid_unparse(vendor_guid, short_name + strlen(short_name));
+
+
+	/* Create the entry in proc */
+	new_efivar->entry =3D create_proc_entry(short_name, 0600, efi_dir);
+	kfree(short_name); short_name =3D NULL;
+	if (!new_efivar->entry) return 1;
+
+
+	new_efivar->entry->data =3D new_efivar;
+	new_efivar->entry->read_proc =3D efivar_read;
+	new_efivar->entry->write_proc =3D efivar_write;
+
+	list_add(&new_efivar->list, &efivar_list);
+
+
+	return 0;
+}
+
+
+
+/***********************************************************
+ * efivar_read()
+ * Requires:
+ * Modifies: page
+ * Returns: number of bytes written, or -EINVAL on failure
+ ***********************************************************/
+
+static int
+efivar_read(char *page, char **start, off_t off, int count, int *eof, void=
 *data)
+{
+	int len =3D sizeof(efi_variable_t);
+	efivar_entry_t *efi_var =3D data;
+	efi_variable_t *var_data =3D (efi_variable_t *)page;
+
+	if (!page || !data) return -EINVAL;
+
+	spin_lock(&efivars_lock);
+	MOD_INC_USE_COUNT;
+
+	memcpy(var_data, &efi_var->var, len);
+
+	var_data->DataSize =3D 1024;
+	var_data->Status =3D efi.get_variable(var_data->VariableName,
+					    &var_data->VendorGuid,
+					    &var_data->Attributes,
+					    &var_data->DataSize,
+					    var_data->Data);
+
+	MOD_DEC_USE_COUNT;
+	spin_unlock(&efivars_lock);
+
+	return proc_calc_metrics(page, start, off, count, eof, len);
+}
+
+/***********************************************************
+ * efivar_write()
+ * Requires: data is an efi_setvariable_t data type,
+ *           properly filled in, possibly by a call
+ *           first to efivar_read().
+ *           Caller must have CAP_SYS_ADMIN
+ * Modifies: NVRAM
+ * Returns: var_data->DataSize on success, errno on failure
+ *
+ ***********************************************************/
+static int
+efivar_write(struct file *file, const char *buffer,
+	     unsigned long count, void *data)
+{
+	unsigned long strsize1, strsize2;
+	int found=3D0;
+	struct list_head *pos;
+	unsigned long size =3D sizeof(efi_variable_t);
+	efi_status_t status;
+	efivar_entry_t *efivar =3D data, *search_efivar =3D NULL;
+	efi_variable_t *var_data;
+	if (!data || count !=3D size) {
+		printk(KERN_WARNING "efivars: improper struct of size 0x%lx passed.\n", =
count);
+		return -EINVAL;
+	}
+	if (!capable(CAP_SYS_ADMIN))
+		return -EACCES;
+
+	spin_lock(&efivars_lock);
+	MOD_INC_USE_COUNT;
+
+	var_data =3D kmalloc(size, GFP_KERNEL);
+	if (!var_data) {
+		MOD_DEC_USE_COUNT;
+		spin_unlock(&efivars_lock);
+		return -ENOMEM;
+	}
+	if (copy_from_user(var_data, buffer, size)) {
+		MOD_DEC_USE_COUNT;
+		spin_unlock(&efivars_lock);
+		return -EFAULT;
+	}
+
+
+	/* Since the data ptr we've currently got is probably for
+	   a different variable find the right variable.
+	   This allows any properly formatted data structure to
+	   be written to any of the files in /proc/efi and it will work.
+	*/
+	list_for_each(pos, &efivar_list) {
+		search_efivar =3D efivar_entry(pos);
+		strsize1 =3D utf8_strsize(search_efivar->var.VariableName, 1024);
+		strsize2 =3D utf8_strsize(var_data->VariableName, 1024);
+		if ( strsize1 =3D strsize2 &&
+		     !memcmp(&(search_efivar->var.VariableName),
+			     var_data->VariableName, strsize1) &&
+		     !efi_guidcmp(search_efivar->var.VendorGuid,
+				  var_data->VendorGuid)) {
+			found =3D 1;
+			break;
+		}
+	}
+	if (found) efivar =3D search_efivar;
+
+	status =3D efi.set_variable(var_data->VariableName,
+				  &var_data->VendorGuid,
+				  var_data->Attributes,
+				  var_data->DataSize,
+				  var_data->Data);
+
+	if (status !=3D EFI_SUCCESS) {
+		printk(KERN_WARNING "set_variable() failed: status=3D%lx\n", status);
+		kfree(var_data);
+		MOD_DEC_USE_COUNT;
+		spin_unlock(&efivars_lock);
+		return -EIO;
+	}
+
+
+	if (!var_data->DataSize || !var_data->Attributes) {
+		/* We just deleted the NVRAM variable */
+		remove_proc_entry(efivar->entry->name, efi_dir);
+		list_del(&efivar->list);
+		kfree(efivar);
+	}
+
+	/* If this is a new variable, set up the proc entry for it. */
+	if (!found) {
+		efivar_create_proc_entry(utf8_strsize(var_data->VariableName,
+						      1024),
+					 var_data->VariableName,
+					 &var_data->VendorGuid);
+	}
+
+	kfree(var_data);
+	MOD_DEC_USE_COUNT;
+	spin_unlock(&efivars_lock);
+	return size;
+}
+
+
+
+static int __init
+efivars_init(void)
+{
+
+	efi_status_t status;
+	efi_guid_t vendor_guid;
+	efi_char16_t *variable_name =3D kmalloc(1024, GFP_KERNEL);
+	unsigned long variable_name_size =3D 1024;
+
+	spin_lock(&efivars_lock);
+
+	printk(KERN_INFO "EFI Variables Facility v%s\n", EFIVARS_VERSION);
+
+	/* Per EFI spec, the maximum storage allocated for both
+	   the variable name and variable data is 1024 bytes.
+	*/
+
+	efi_dir =3D proc_mkdir("efi", NULL);
+
+	memset(variable_name, 0, 1024);
+
+	do {
+		variable_name_size=1024;
+
+		status =3D efi.get_next_variable(&variable_name_size,
+					       variable_name,
+					       &vendor_guid);
+
+
+		switch (status) {
+		case EFI_SUCCESS:
+			efivar_create_proc_entry(variable_name_size,
+						 variable_name,
+						 &vendor_guid);
+			break;
+		case EFI_NOT_FOUND:
+			break;
+		default:
+			printk(KERN_WARNING "get_next_variable() status=3D%lx\n",
+			       status);
+			BUG();
+			status =3D EFI_NOT_FOUND;
+			break;
+		}
+
+	} while (status !=3D EFI_NOT_FOUND);
+
+	kfree(variable_name);
+	spin_unlock(&efivars_lock);
+	return 0;
+}
+
+static void __exit
+efivars_exit(void)
+{
+	struct list_head *pos;
+	efivar_entry_t *efivar;
+
+	spin_lock(&efivars_lock);
+
+	list_for_each(pos, &efivar_list) {
+		efivar =3D efivar_entry(pos);
+		remove_proc_entry(efivar->entry->name, efi_dir);
+		list_del(&efivar->list);
+		kfree(efivar);
+	}
+	remove_proc_entry(efi_dir->name, NULL);
+	spin_unlock(&efivars_lock);
+
+}
+
+module_init(efivars_init);
+module_exit(efivars_exit);
+
+/*
+ * Overrides for Emacs so that we follow Linus's tabbing style.
+ * Emacs will notice this stuff at the end of the file and automatically
+ * adjust the settings for this buffer only.  This must remain at the end
+ * of the file.
+ * -----------------------------------------------------------------------=
----
+ * Local variables:
+ * c-indent-level: 4
+ * c-brace-imaginary-offset: 0
+ * c-brace-offset: -4
+ * c-argdecl-indent: 4
+ * c-label-offset: -4
+ * c-continued-statement-offset: 4
+ * c-continued-brace-offset: 0
+ * indent-tabs-mode: nil
+ * tab-width: 8
+ * End:
+ */
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/entry.S linux-2.=
4.2-lia/arch/ia64/kernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Wed Mar 21 23:46:39 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/entry.S	Wed Mar 21 23:04:22 2001
@@ -1,5 +1,3 @@
-#define NEW_LEAVE_KERNEL_HEAD	1
-#define CLEAR_INVALID		1
 /*
  * ia64/kernel/entry.S
  *
@@ -53,10 +51,10 @@
 	 * setup a null register window frame.
 	 */
 ENTRY(ia64_execve)
-	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(3))
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(3)
 	alloc loc1=3Dar.pfs,3,2,4,0
 	mov loc0=3Drp
-	UNW(.body)
+	.body
 	mov out0=3Din0			// filename
 	;;				// stop bit between alloc and call
 	mov out1=3Din1			// argv
@@ -96,18 +94,18 @@
 END(ia64_execve)
=20
 GLOBAL_ENTRY(sys_clone2)
-	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2))
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2)
 	alloc r16=3Dar.pfs,3,2,4,0
 	DO_SAVE_SWITCH_STACK
 	mov loc0=3Drp
 	mov loc1=3Dr16				// save ar.pfs across do_fork
-	UNW(.body)
+	.body
 	mov out1=3Din1
 	mov out3=3Din2
 	adds out2=3DIA64_SWITCH_STACK_SIZE+16,sp	// out2 =3D &regs
 	mov out0=3Din0				// out0 =3D clone_flags
 	br.call.sptk.few rp=3Ddo_fork
-.ret1:	UNW(.restore sp)
+.ret1:	.restore sp
 	adds sp=3DIA64_SWITCH_STACK_SIZE,sp	// pop the switch stack
 	mov ar.pfs=3Dloc1
 	mov rp=3Dloc0
@@ -115,18 +113,18 @@
 END(sys_clone2)
=20
 GLOBAL_ENTRY(sys_clone)
-	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2))
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2)
 	alloc r16=3Dar.pfs,2,2,4,0
 	DO_SAVE_SWITCH_STACK
 	mov loc0=3Drp
 	mov loc1=3Dr16				// save ar.pfs across do_fork
-	UNW(.body)
+	.body
 	mov out1=3Din1
 	mov out3=3D0
 	adds out2=3DIA64_SWITCH_STACK_SIZE+16,sp	// out2 =3D &regs
 	mov out0=3Din0				// out0 =3D clone_flags
 	br.call.sptk.few rp=3Ddo_fork
-.ret2:	UNW(.restore sp)
+.ret2:	.restore sp
 	adds sp=3DIA64_SWITCH_STACK_SIZE,sp	// pop the switch stack
 	mov ar.pfs=3Dloc1
 	mov rp=3Dloc0
@@ -137,10 +135,10 @@
  * prev_task <- ia64_switch_to(struct task_struct *next)
  */
 GLOBAL_ENTRY(ia64_switch_to)
-	UNW(.prologue)
+	.prologue
 	alloc r16=3Dar.pfs,1,0,0,0
 	DO_SAVE_SWITCH_STACK
-	UNW(.body)
+	.body
=20
 	adds r22=3DIA64_TASK_THREAD_KSP_OFFSET,r13
 	mov r27=3DIA64_KR(CURRENT_STACK)
@@ -194,19 +192,6 @@
 	;;
 END(ia64_switch_to)
=20
-#ifndef CONFIG_IA64_NEW_UNWIND
-	/*
-	 * Like save_switch_stack, but also save the stack frame that is active
-	 * at the time this function is called.
-	 */
-ENTRY(save_switch_stack_with_current_frame)
-	UNW(.prologue)
-	alloc r16=3Dar.pfs,0,0,0,0		// pass ar.pfs to save_switch_stack
-	DO_SAVE_SWITCH_STACK
-	br.ret.sptk.few rp
-END(save_switch_stack_with_current_frame)
-#endif /* !CONFIG_IA64_NEW_UNWIND */
-
 /*
  * Note that interrupts are enabled during save_switch_stack and
  * load_switch_stack.  This means that we may get an interrupt with
@@ -226,12 +211,12 @@
  *	- rp (b0) holds return address to save
  */
 GLOBAL_ENTRY(save_switch_stack)
-	UNW(.prologue)
-	UNW(.altrp b7)
+	.prologue
+	.altrp b7
 	flushrs			// flush dirty regs to backing store (must be first in insn gro=
up)
-	UNW(.save @priunat,r17)
+	.save @priunat,r17
 	mov r17=3Dar.unat		// preserve caller's
-	UNW(.body)
+	.body
 #if !(defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) \
       || defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_=
SPECIFIC))
 	adds r3=80,sp
@@ -342,9 +327,9 @@
  *	- must not touch r8-r11
  */
 ENTRY(load_switch_stack)
-	UNW(.prologue)
-	UNW(.altrp b7)
-	UNW(.body)
+	.prologue
+	.altrp b7
+	.body
 #if !(defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) \
       || defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_=
SPECIFIC))
=20
@@ -459,11 +444,10 @@
 	 * also use it to preserve b6, which contains the syscall entry point.
 	 */
 GLOBAL_ENTRY(invoke_syscall_trace)
-#ifdef CONFIG_IA64_NEW_UNWIND
-	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8))
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
 	alloc loc1=3Dar.pfs,8,3,0,0
 	mov loc0=3Drp
-	UNW(.body)
+	.body
 	mov loc2=B6
 	;;
 	br.call.sptk.few rp=3Dsyscall_trace
@@ -471,21 +455,6 @@
 	mov ar.pfs=3Dloc1
 	mov b6=3Dloc2
 	br.ret.sptk.few rp
-#else /* !CONFIG_IA64_NEW_SYSCALL */
-	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8))
-	alloc loc1=3Dar.pfs,8,3,0,0
-	;;			// WAW on CFM at the br.call
-	mov loc0=3Drp
-	br.call.sptk.many rp=3Dsave_switch_stack_with_current_frame	// must prese=
rve b6!!
-.ret4:	mov loc2=B6
-	br.call.sptk.few rp=3Dsyscall_trace
-.ret5:	adds sp=3DIA64_SWITCH_STACK_SIZE,sp	// drop switch_stack frame
-	mov rp=3Dloc0
-	mov ar.pfs=3Dloc1
-	mov b6=3Dloc2
-	;;
-	br.ret.sptk.few rp
-#endif /* !CONFIG_IA64_NEW_UNWIND */
 END(invoke_syscall_trace)
=20
 	/*
@@ -566,55 +535,6 @@
 	// fall through
 GLOBAL_ENTRY(ia64_leave_kernel)
 	PT_REGS_UNWIND_INFO(0)
-#if !NEW_LEAVE_KERNEL_HEAD
-	movl r3=3DPERCPU_ADDR+IA64_CPU_SOFTIRQ_ACTIVE_OFFSET		// softirq_active
-	;;
-	ld8 r2=3D[r3]	// r3 (softirq_active+softirq_mask) is guaranteed to be 8-b=
yte aligned!
-	;;
-	shr r3=3Dr2,32
-	;;
-	and r2=3Dr2,r3
-	;;
-	cmp4.ne p6,p7=3Dr2,r0
-(p6)	br.call.spnt.many rp=3Dinvoke_do_softirq
-1:
-(pKern)	br.cond.dpnt.many restore_all	// yup -> skip check for reschedulin=
g & signal delivery
-
-	// call schedule() until we find a task that doesn't have need_resched se=
t:
-
-back_from_resched:
-	{ .mii
-	  adds r2=3DIA64_TASK_NEED_RESCHED_OFFSET,r13
-	  mov r3=3Dip					// r3 <- &back_from_resched
-	  adds r14=3DIA64_TASK_SIGPENDING_OFFSET,r13
-	}
-#ifdef CONFIG_PERFMON
-	adds r15=3DIA64_TASK_PFM_NOTIFY_OFFSET,r13
-#endif
-	;;
-#ifdef CONFIG_PERFMON
-	ld8 r15=3D[r15]
-#endif
-	ld8 r2=3D[r2]
-	ld4 r14=3D[r14]
-	mov rp=3Dr3			// arrange for schedule() to return to back_from_resched
-	;;
-	cmp.ne p16,p0=3Dr14,r0
-#ifdef CONFIG_PERFMON
-	cmp.ne p6,p0=3Dr15,r0		// current->task.pfm_notify !=3D 0?
-#endif
-	cmp.ne p7,p0=3Dr2,r0		// current->need_resched !=3D 0?
-#ifdef CONFIG_PERFMON
-(p6)	br.call.spnt.many b6=3Dpfm_overflow_notify
-#endif
-(p7)	br.call.spnt.many b7=3Dinvoke_schedule
-(p16)	br.call.spnt.many rp=3Dhandle_signal_delivery	// check & deliver pen=
ding signals
-.ret9:
-restore_all:
-	adds r2=3DPT(R8)+16,r12
-	adds r3=3DPT(R9)+16,r12
-	;;
-#else /* NEW_LEAVE_KERNEL_HEAD */
 	cmp.eq p16,p0=3Dr0,r0			// set the "first_time" flag
 	movl r15=3DPERCPU_ADDR+IA64_CPU_SOFTIRQ_ACTIVE_OFFSET  // r15 =3D &cpu_da=
ta.softirq.active
 	;;
@@ -647,16 +567,23 @@
 #endif
 	cmp.ne p16,p0=3Dr0,r0			// clear the "first_time" flag
 	;;
+# if __GNUC__ < 3
 (p6)	br.call.spnt.many b7=3Dinvoke_do_softirq
+# else
+(p6)	br.call.spnt.many b7=3Ddo_softirq
+# endif
 #ifdef CONFIG_PERFMON
 (p9)	br.call.spnt.many b7=3Dpfm_overflow_notify
 #endif
+# if __GNUC__ < 3
 (p7)	br.call.spnt.many b7=3Dinvoke_schedule
+#else
+(p7)	br.call.spnt.many b7=3Dschedule
+#endif
 	adds r2=3DPT(R8)+16,r12
 	adds r3=3DPT(R9)+16,r12
 (p8)	br.call.spnt.many b7=3Dhandle_signal_delivery	// check & deliver pend=
ing signals
 	;;
-#endif /* NEW_LEAVE_KERNEL_HEAD */
 	// start restoring the state saved on the kernel stack (struct pt_regs):
 	ld8.fill r8=3D[r2],16
 	ld8.fill r9=3D[r3],16
@@ -753,11 +680,9 @@
 	shr.u r18=3Dr19,16	// get byte size of existing "dirty" partition
 	;;
 	mov r16=3Dar.bsp		// get existing backing store pointer
-#if CLEAR_INVALID
 	movl r17=3DPERCPU_ADDR+IA64_CPU_PHYS_STACKED_SIZE_P8_OFFSET
 	;;
 	ld4 r17=3D[r17]		// r17 =3D cpu_data->phys_stacked_size_p8
-#endif
 (pKern)	br.cond.dpnt.few skip_rbs_switch
 	/*
 	 * Restore user backing store.
@@ -777,7 +702,6 @@
 	shl r19=3Dr19,16			// shift size of dirty partition into loadrs position
 	;;
 dont_preserve_current_frame:
-#if CLEAR_INVALID
 	/*
 	 * To prevent leaking bits between the kernel and user-space,
 	 * we must clear the stacked registers in the "invalid" partition here.
@@ -828,9 +752,6 @@
 }
 #	undef pRecurse
 #	undef pReturn
-#else
-	mov ar.rsc=3Dr19			// load ar.rsc to be used for "loadrs"
-#endif
=20
 	alloc r17=3Dar.pfs,0,0,0,0	// drop current register frame
 	;;
@@ -879,15 +800,10 @@
 #ifdef CONFIG_SMP
 	/*
 	 * Invoke schedule_tail(task) while preserving in0-in7, which may be need=
ed
-	 * in case a system call gets restarted.  Note that declaring schedule_ta=
il()
-	 * with asmlinkage() is NOT enough because that will only preserve as many
-	 * registers as there are formal arguments.
-	 *
-	 * XXX fix me: with gcc 3.0, we won't need this anymore because syscall_l=
inkage
-	 *	renders all eight input registers (in0-in7) as "untouchable".
+	 * in case a system call gets restarted.
 	 */
 ENTRY(invoke_schedule_tail)
-	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8))
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
 	alloc loc1=3Dar.pfs,8,2,1,0
 	mov loc0=3Drp
 	mov out0=3Dr8				// Address of previous task
@@ -900,6 +816,7 @@
=20
 #endif /* CONFIG_SMP */
=20
+#if __GNUC__ < 3
 	/*
 	 * Invoke do_softirq() while preserving in0-in7, which may be needed
 	 * in case a system call gets restarted.  Note that declaring do_softirq()
@@ -910,11 +827,11 @@
 	 *	renders all eight input registers (in0-in7) as "untouchable".
 	 */
 ENTRY(invoke_do_softirq)
-	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8))
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
 	alloc loc1=3Dar.pfs,8,2,0,0
 	mov loc0=3Drp
 	;;
-	UNW(.body)
+	.body
 	br.call.sptk.few rp=3Ddo_softirq
 .ret13:	mov ar.pfs=3Dloc1
 	mov rp=3Dloc0
@@ -931,24 +848,25 @@
 	 *	renders all eight input registers (in0-in7) as "untouchable".
 	 */
 ENTRY(invoke_schedule)
-	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8))
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
 	alloc loc1=3Dar.pfs,8,2,0,0
 	mov loc0=3Drp
 	;;
-	UNW(.body)
+	.body
 	br.call.sptk.few rp=3Dschedule
 .ret14:	mov ar.pfs=3Dloc1
 	mov rp=3Dloc0
 	br.ret.sptk.many rp
 END(invoke_schedule)
=20
+#endif /* __GNUC__ < 3 */
+
 	/*
 	 * Setup stack and call ia64_do_signal.  Note that pSys and pNonSys need =
to
 	 * be set up by the caller.  We declare 8 input registers so the system c=
all
 	 * args get preserved, in case we need to restart a system call.
 	 */
 ENTRY(handle_signal_delivery)
-#ifdef CONFIG_IA64_NEW_UNWIND
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
 	alloc loc1=3Dar.pfs,8,2,3,0 // preserve all eight input regs in case of s=
yscall restart!
 	mov r9=3Dar.unat
@@ -972,26 +890,9 @@
 	mov ar.unat=3Dr9
 	mov ar.pfs=3Dloc1
 	br.ret.sptk.many rp
-#else /* !CONFIG_IA64_NEW_UNWIND */
-	.prologue
-	alloc r16=3Dar.pfs,8,0,3,0 // preserve all eight input regs in case of sy=
scall restart!
-	DO_SAVE_SWITCH_STACK
-	UNW(.body)
-
-	mov out0=3D0				// there is no "oldset"
-	adds out1=16,sp				// out1=3D&sigscratch
-	.pred.rel.mutex pSys, pNonSys
-(pSys)	mov out2=3D1				// out2=3D1 =3D> we're in a syscall
-(pNonSys) mov out2=3D0				// out2=3D0 =3D> not a syscall
-	br.call.sptk.few rp=3Dia64_do_signal
-.ret16:	// restore the switch stack (ptrace may have modified it)
-	DO_LOAD_SWITCH_STACK
-	br.ret.sptk.many rp
-#endif /* !CONFIG_IA64_NEW_UNWIND */
 END(handle_signal_delivery)
=20
 GLOBAL_ENTRY(sys_rt_sigsuspend)
-#ifdef CONFIG_IA64_NEW_UNWIND
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
 	alloc loc1=3Dar.pfs,8,2,3,0 // preserve all eight input regs in case of s=
yscall restart!
 	mov r9=3Dar.unat
@@ -1014,26 +915,11 @@
 	mov ar.unat=3Dr9
 	mov ar.pfs=3Dloc1
 	br.ret.sptk.many rp
-#else /* !CONFIG_IA64_NEW_UNWIND */
-	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2))
-	alloc r16=3Dar.pfs,2,0,3,0
-	DO_SAVE_SWITCH_STACK
-	UNW(.body)
-
-	mov out0=3Din0				// mask
-	mov out1=3Din1				// sigsetsize
-	adds out2=16,sp				// out1=3D&sigscratch
-	br.call.sptk.many rp=3Dia64_rt_sigsuspend
-.ret18:	// restore the switch stack (ptrace may have modified it)
-	DO_LOAD_SWITCH_STACK
-	br.ret.sptk.many rp
-#endif /* !CONFIG_IA64_NEW_UNWIND */
 END(sys_rt_sigsuspend)
=20
 ENTRY(sys_rt_sigreturn)
-#ifdef CONFIG_IA64_NEW_UNWIND
-	.regstk 0,0,3,0	// inherited from gate.s:invoke_sighandler()
 	PT_REGS_UNWIND_INFO(0)
+	alloc r2=3Dar.pfs,0,0,1,0
 	.prologue
 	PT_REGS_SAVES(16)
 	adds sp=3D-16,sp
@@ -1042,7 +928,7 @@
 	;;
 	adds out0=16,sp				// out0 =3D &sigscratch
 	br.call.sptk.few rp=3Dia64_rt_sigreturn
-.ret19:	.restore sp
+.ret19:	.restore sp 0
 	adds sp=16,sp
 	;;
 	ld8 r9=3D[sp]				// load new ar.unat
@@ -1050,32 +936,6 @@
 	;;
 	mov ar.unat=3Dr9
 	br b7
-#else /* !CONFIG_IA64_NEW_UNWIND */
-	.regstk 0,0,3,0	// inherited from gate.s:invoke_sighandler()
-	PT_REGS_UNWIND_INFO(0)
-	UNW(.prologue)
-	UNW(.fframe IA64_PT_REGS_SIZE+IA64_SWITCH_STACK_SIZE)
-	UNW(.spillsp rp, PT(CR_IIP)+16+IA64_SWITCH_STACK_SIZE)
-	UNW(.spillsp ar.pfs, PT(CR_IFS)+16+IA64_SWITCH_STACK_SIZE)
-	UNW(.spillsp ar.unat, PT(AR_UNAT)+16+IA64_SWITCH_STACK_SIZE)
-	UNW(.spillsp pr, PT(PR)+16+IA64_SWITCH_STACK_SIZE)
-	adds sp=3D-IA64_SWITCH_STACK_SIZE,sp
-	cmp.eq pNonSys,pSys=3Dr0,r0		// sigreturn isn't a normal syscall...
-	;;
-	UNW(.body)
-
-	adds out0=16,sp				// out0 =3D &sigscratch
-	br.call.sptk.few rp=3Dia64_rt_sigreturn
-.ret20:	adds r3=3DSW(CALLER_UNAT)+16,sp
-	;;
-	ld8 r9=3D[r3]			// load new ar.unat
-	MOVBR(.sptk,b7,r8,ia64_leave_kernel)
-	;;
-	PT_REGS_UNWIND_INFO(0)
-	adds sp=3DIA64_SWITCH_STACK_SIZE,sp	// drop (dummy) switch-stack frame
-	mov ar.unat=3Dr9
-	br b7
-#endif /* !CONFIG_IA64_NEW_UNWIND */
 END(sys_rt_sigreturn)
=20
 GLOBAL_ENTRY(ia64_prepare_handle_unaligned)
@@ -1084,7 +944,7 @@
 	// privilege is still 0
 	//
 	mov r16=3Dr0
-	UNW(.prologue)
+	.prologue
 	DO_SAVE_SWITCH_STACK
 	br.call.sptk.few rp=3Dia64_handle_unaligned // stack frame setup in ivt
 .ret21:	.body
@@ -1092,8 +952,6 @@
 	br.cond.sptk.many rp			  // goes to ia64_leave_kernel
 END(ia64_prepare_handle_unaligned)
=20
-#ifdef CONFIG_IA64_NEW_UNWIND
-
 	//
 	// unw_init_running(void (*callback)(info, arg), void *arg)
 	//
@@ -1138,8 +996,6 @@
 	mov rp=3Dloc0
 	br.ret.sptk.many rp
 END(unw_init_running)
-
-#endif
=20
 	.rodata
 	.align 8
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/entry.h linux-2.=
4.2-lia/arch/ia64/kernel/entry.h
--- linux-davidm/arch/ia64/kernel/entry.h	Wed Mar 21 23:46:39 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/entry.h	Wed Mar 21 23:05:45 2001
@@ -20,42 +20,42 @@
 #define SW(f)		(IA64_SWITCH_STACK_##f##_OFFSET)
=20
 #define PT_REGS_SAVES(off)				\
-	UNW(.unwabi @svr4, 'i');			\
-	UNW(.fframe IA64_PT_REGS_SIZE+16+(off));	\
-	UNW(.spillsp rp, PT(CR_IIP)+16+(off));		\
-	UNW(.spillsp ar.pfs, PT(CR_IFS)+16+(off));	\
-	UNW(.spillsp ar.unat, PT(AR_UNAT)+16+(off));	\
-	UNW(.spillsp ar.fpsr, PT(AR_FPSR)+16+(off));	\
-	UNW(.spillsp pr, PT(PR)+16+(off));
+	.unwabi @svr4, 'i';			\
+	.fframe IA64_PT_REGS_SIZE+16+(off);	\
+	.spillsp rp, PT(CR_IIP)+16+(off);	\
+	.spillsp ar.pfs, PT(CR_IFS)+16+(off);	\
+	.spillsp ar.unat, PT(AR_UNAT)+16+(off);	\
+	.spillsp ar.fpsr, PT(AR_FPSR)+16+(off);	\
+	.spillsp pr, PT(PR)+16+(off);
=20
 #define PT_REGS_UNWIND_INFO(off)		\
-	UNW(.prologue);				\
+	.prologue;				\
 	PT_REGS_SAVES(off);			\
-	UNW(.body)
+	.body
=20
 #define SWITCH_STACK_SAVES(off)									\
-	UNW(.savesp ar.unat,SW(CALLER_UNAT)+16+(off));						\
-	UNW(.savesp ar.fpsr,SW(AR_FPSR)+16+(off));						\
-	UNW(.spillsp f2,SW(F2)+16+(off)); UNW(.spillsp f3,SW(F3)+16+(off));			\
-	UNW(.spillsp f4,SW(F4)+16+(off)); UNW(.spillsp f5,SW(F5)+16+(off));			\
-	UNW(.spillsp f16,SW(F16)+16+(off)); UNW(.spillsp f17,SW(F17)+16+(off));		=
	\
-	UNW(.spillsp f18,SW(F18)+16+(off)); UNW(.spillsp f19,SW(F19)+16+(off));		=
	\
-	UNW(.spillsp f20,SW(F20)+16+(off)); UNW(.spillsp f21,SW(F21)+16+(off));		=
	\
-	UNW(.spillsp f22,SW(F22)+16+(off)); UNW(.spillsp f23,SW(F23)+16+(off));		=
	\
-	UNW(.spillsp f24,SW(F24)+16+(off)); UNW(.spillsp f25,SW(F25)+16+(off));		=
	\
-	UNW(.spillsp f26,SW(F26)+16+(off)); UNW(.spillsp f27,SW(F27)+16+(off));		=
	\
-	UNW(.spillsp f28,SW(F28)+16+(off)); UNW(.spillsp f29,SW(F29)+16+(off));		=
	\
-	UNW(.spillsp f30,SW(F30)+16+(off)); UNW(.spillsp f31,SW(F31)+16+(off));		=
	\
-	UNW(.spillsp r4,SW(R4)+16+(off)); UNW(.spillsp r5,SW(R5)+16+(off));			\
-	UNW(.spillsp r6,SW(R6)+16+(off)); UNW(.spillsp r7,SW(R7)+16+(off));			\
-	UNW(.spillsp b0,SW(B0)+16+(off)); UNW(.spillsp b1,SW(B1)+16+(off));			\
-	UNW(.spillsp b2,SW(B2)+16+(off)); UNW(.spillsp b3,SW(B3)+16+(off));			\
-	UNW(.spillsp b4,SW(B4)+16+(off)); UNW(.spillsp b5,SW(B5)+16+(off));			\
-	UNW(.spillsp ar.pfs,SW(AR_PFS)+16+(off)); UNW(.spillsp ar.lc,SW(AR_LC)+16=
+(off));	\
-	UNW(.spillsp @priunat,SW(AR_UNAT)+16+(off));						\
-	UNW(.spillsp ar.rnat,SW(AR_RNAT)+16+(off));						\
-	UNW(.spillsp ar.bspstore,SW(AR_BSPSTORE)+16+(off));					\
-	UNW(.spillsp pr,SW(PR)+16+(off))
+	.savesp ar.unat,SW(CALLER_UNAT)+16+(off);				\
+	.savesp ar.fpsr,SW(AR_FPSR)+16+(off);					\
+	.spillsp f2,SW(F2)+16+(off); .spillsp f3,SW(F3)+16+(off);		\
+	.spillsp f4,SW(F4)+16+(off); .spillsp f5,SW(F5)+16+(off);		\
+	.spillsp f16,SW(F16)+16+(off); .spillsp f17,SW(F17)+16+(off);		\
+	.spillsp f18,SW(F18)+16+(off); .spillsp f19,SW(F19)+16+(off);		\
+	.spillsp f20,SW(F20)+16+(off); .spillsp f21,SW(F21)+16+(off);		\
+	.spillsp f22,SW(F22)+16+(off); .spillsp f23,SW(F23)+16+(off);		\
+	.spillsp f24,SW(F24)+16+(off); .spillsp f25,SW(F25)+16+(off);		\
+	.spillsp f26,SW(F26)+16+(off); .spillsp f27,SW(F27)+16+(off);		\
+	.spillsp f28,SW(F28)+16+(off); .spillsp f29,SW(F29)+16+(off);		\
+	.spillsp f30,SW(F30)+16+(off); .spillsp f31,SW(F31)+16+(off);		\
+	.spillsp r4,SW(R4)+16+(off); .spillsp r5,SW(R5)+16+(off);		\
+	.spillsp r6,SW(R6)+16+(off); .spillsp r7,SW(R7)+16+(off);		\
+	.spillsp b0,SW(B0)+16+(off); .spillsp b1,SW(B1)+16+(off);		\
+	.spillsp b2,SW(B2)+16+(off); .spillsp b3,SW(B3)+16+(off);		\
+	.spillsp b4,SW(B4)+16+(off); .spillsp b5,SW(B5)+16+(off);		\
+	.spillsp ar.pfs,SW(AR_PFS)+16+(off); .spillsp ar.lc,SW(AR_LC)+16+(off);	\
+	.spillsp @priunat,SW(AR_UNAT)+16+(off);					\
+	.spillsp ar.rnat,SW(AR_RNAT)+16+(off);					\
+	.spillsp ar.bspstore,SW(AR_BSPSTORE)+16+(off);				\
+	.spillsp pr,SW(PR)+16+(off))
=20
 #define DO_SAVE_SWITCH_STACK			\
 	movl r28=1F;				\
@@ -73,5 +73,5 @@
 	invala;					\
 	MOVBR(.ret.sptk,b7,r28,1f);		\
 	br.cond.sptk.many load_switch_stack;	\
-1:	UNW(.restore sp);			\
+1:	.restore sp;				\
 	adds sp=3DIA64_SWITCH_STACK_SIZE,sp
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/head.S linux-2.4=
.2-lia/arch/ia64/kernel/head.S
--- linux-davidm/arch/ia64/kernel/head.S	Wed Mar 21 23:46:39 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/head.S	Wed Mar 21 23:05:58 2001
@@ -58,10 +58,10 @@
 	.text
=20
 GLOBAL_ENTRY(_start)
-	UNW(.prologue)
-	UNW(.save rp, r4)		// terminate unwind chain with a NULL rp
-	UNW(mov r4=3Dr0)
-	UNW(.body)
+	.prologue
+	.save rp, r4		// terminate unwind chain with a NULL rp
+	mov r4=3Dr0
+	.body
 	// set IVT entry point---can't access I/O ports without it
 	movl r3=3Dia64_ivt
 	;;
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/ia64_ksyms.c lin=
ux-2.4.2-lia/arch/ia64/kernel/ia64_ksyms.c
--- linux-davidm/arch/ia64/kernel/ia64_ksyms.c	Wed Mar 21 23:46:39 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/ia64_ksyms.c	Wed Mar 21 23:06:55 2001
@@ -52,6 +52,9 @@
 EXPORT_SYMBOL_NOVERS(__down_write_failed);
 EXPORT_SYMBOL_NOVERS(__rwsem_wake);
=20
+#include <asm/pgalloc.h>
+EXPORT_SYMBOL(smp_flush_tlb_all);
+
 #include <asm/page.h>
 EXPORT_SYMBOL(clear_page);
=20
@@ -127,3 +130,5 @@
 EXPORT_SYMBOL(ia64_pal_call_stacked);
 EXPORT_SYMBOL(ia64_pal_call_static);
=20
+extern struct efi efi;
+EXPORT_SYMBOL(efi);
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/ivt.S linux-2.4.=
2-lia/arch/ia64/kernel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Wed Mar 21 23:46:39 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/ivt.S	Wed Mar 21 23:07:30 2001
@@ -899,7 +899,7 @@
 	// suitable spot...
=20
 	alloc r14=3Dar.pfs,0,0,2,0
-	mov out0=3Dr8
+	mov out0=3Dcr.iim
 	add out1=16,sp
 	adds r3=3D8,r2			// set up second base pointer for SAVE_REST
=20
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/pal.S linux-2.4.=
2-lia/arch/ia64/kernel/pal.S
--- linux-davidm/arch/ia64/kernel/pal.S	Wed Mar 21 23:46:39 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/pal.S	Wed Mar 21 23:08:00 2001
@@ -58,7 +58,7 @@
  *
  */
 GLOBAL_ENTRY(ia64_pal_call_static)
-	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(6))
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(6)
 	alloc loc1 =3D ar.pfs,6,90,0,0
 	movl loc2 =3D pal_entry_point
 1:	{
@@ -73,7 +73,7 @@
 	;;
 	mov loc3 =3D psr
 	mov loc0 =3D rp
-	UNW(.body)
+	.body
 	mov r30 =3D in2
=20
 (p6)	rsm psr.i | psr.ic
@@ -101,14 +101,14 @@
  * 	in2 - in3   Remaning PAL arguments
  */
 GLOBAL_ENTRY(ia64_pal_call_stacked)
-	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(5))
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(5)
 	alloc loc1 =3D ar.pfs,5,4,87,0
 	movl loc2 =3D pal_entry_point
=20
 	mov r28  =3D in0			// Index MUST be copied to r28
 	mov out0 =3D in0			// AND in0 of PAL function
 	mov loc0 =3D rp
-	UNW(.body)
+	.body
 	;;
 	ld8 loc2 =3D [loc2]		// loc2 <- entry point
 	mov out1 =3D in1
@@ -148,7 +148,7 @@
=20
=20
 GLOBAL_ENTRY(ia64_pal_call_phys_static)
-	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(6))
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(6)
 	alloc loc1 =3D ar.pfs,6,90,0,0
 	movl loc2 =3D pal_entry_point
 1:	{
@@ -156,7 +156,7 @@
 	  mov r8   =3D ip			// save ip to compute branch
 	  mov loc0 =3D rp			// save rp
 	}
-	UNW(.body)
+	.body
 	;;
 	ld8 loc2 =3D [loc2]		// loc2 <- entry point
 	mov r29  =3D in1			// first argument
@@ -204,7 +204,7 @@
  * 	in2 - in3   Remaning PAL arguments
  */
 GLOBAL_ENTRY(ia64_pal_call_phys_stacked)
-	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(5))
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(5)
 	alloc	loc1 =3D ar.pfs,5,5,86,0
 	movl	loc2 =3D pal_entry_point
 1:	{
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/process.c linux-=
2.4.2-lia/arch/ia64/kernel/process.c
--- linux-davidm/arch/ia64/kernel/process.c	Wed Mar 21 23:46:39 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/process.c	Wed Mar 21 23:08:19 2001
@@ -28,8 +28,6 @@
 #include <asm/unwind.h>
 #include <asm/user.h>
=20
-#ifdef CONFIG_IA64_NEW_UNWIND
-
 static void
 do_show_stack (struct unw_frame_info *info, void *arg)
 {
@@ -47,12 +45,9 @@
 	} while (unw_unwind(info) >=3D 0);
 }
=20
-#endif
-
 void
 show_stack (struct task_struct *task)
 {
-#ifdef CONFIG_IA64_NEW_UNWIND
 	if (!task)
 		unw_init_running(do_show_stack, 0);
 	else {
@@ -61,7 +56,6 @@
 		unw_init_from_blocked_task(&info, task);
 		do_show_stack(&info, 0);
 	}
-#endif
 }
=20
 void
@@ -109,10 +103,8 @@
 			       ((i =3D sof - 1) || (i % 3) =3D 2) ? "\n" : " ");
 		}
 	}
-#ifdef CONFIG_IA64_NEW_UNWIND
 	if (!user_mode(regs))
 		show_stack(0);
-#endif
 }
=20
 void __attribute__((noreturn))
@@ -299,8 +291,6 @@
 	return retval;
 }
=20
-#ifdef CONFIG_IA64_NEW_UNWIND
-
 void
 do_copy_regs (struct unw_frame_info *info, void *arg)
 {
@@ -347,7 +337,6 @@
 		unw_get_gr(info, i, &dst[i], &nat);
 		if (nat)
 			nat_bits |=3D mask;
-printk("r%u =3D %c%016lx\n", i, nat ? '*' : ' ', dst[i]);
 		mask <<=3D 1;
 	}
 	dst[32] =3D nat_bits;
@@ -398,91 +387,16 @@
 		memcpy(dst + 32, current->thread.fph, 96*16);
 }
=20
-#endif /* CONFIG_IA64_NEW_UNWIND */
-
 void
 ia64_elf_core_copy_regs (struct pt_regs *pt, elf_gregset_t dst)
 {
-#ifdef CONFIG_IA64_NEW_UNWIND
 	unw_init_running(do_copy_regs, dst);
-#else
-	struct switch_stack *sw =3D ((struct switch_stack *) pt) - 1;
-	unsigned long ar_ec, cfm, ar_bsp, ndirty, *krbs, addr;
-
-	ar_ec =3D (sw->ar_pfs >> 52) & 0x3f;
-
-	cfm =3D pt->cr_ifs & ((1UL << 63) - 1);
-	if ((pt->cr_ifs & (1UL << 63)) =3D 0) {
-		/* if cr_ifs isn't valid, we got here through a syscall or a break */
-		cfm =3D sw->ar_pfs & ((1UL << 38) - 1);
-	}
-
-	krbs =3D (unsigned long *) current + IA64_RBS_OFFSET/8;
-	ndirty =3D ia64_rse_num_regs(krbs, krbs + (pt->loadrs >> 19));
-	ar_bsp =3D (unsigned long) ia64_rse_skip_regs((long *) pt->ar_bspstore, n=
dirty);
-
-	/*
-	 * Write portion of RSE backing store living on the kernel
-	 * stack to the VM of the process.
-	 */
-	for (addr =3D pt->ar_bspstore; addr < ar_bsp; addr +=3D 8) {
-		long val;
-		if (ia64_peek(pt, current, addr, &val) =3D 0)
-			access_process_vm(current, addr, &val, sizeof(val), 1);
-	}
-
-	/*	r0-r31
-	 *	NaT bits (for r0-r31; bit N =3D 1 iff rN is a NaT)
-	 *	predicate registers (p0-p63)
-	 *	b0-b7
-	 *	ip cfm user-mask
-	 *	ar.rsc ar.bsp ar.bspstore ar.rnat
-	 *	ar.ccv ar.unat ar.fpsr ar.pfs ar.lc ar.ec
-	 */
-	memset(dst, 0, sizeof(dst));	/* don't leak any "random" bits */
-
-	/* r0 is zero */   dst[ 1] =3D  pt->r1; dst[ 2] =3D  pt->r2; dst[ 3] =3D =
pt->r3;
-	dst[ 4] =3D  sw->r4; dst[ 5] =3D  sw->r5; dst[ 6] =3D  sw->r6; dst[ 7] =
=3D sw->r7;
-	dst[ 8] =3D  pt->r8; dst[ 9] =3D  pt->r9; dst[10] =3D pt->r10; dst[11] =
=3D pt->r11;
-	dst[12] =3D pt->r12; dst[13] =3D pt->r13; dst[14] =3D pt->r14; dst[15] =
=3D pt->r15;
-	memcpy(dst + 16, &pt->r16, 16*8);	/* r16-r31 are contiguous */
-
-	dst[32] =3D ia64_get_nat_bits(pt, sw);
-	dst[33] =3D pt->pr;
-
-	/* branch regs: */
-	dst[34] =3D pt->b0; dst[35] =3D sw->b1; dst[36] =3D sw->b2; dst[37] =3D s=
w->b3;
-	dst[38] =3D sw->b4; dst[39] =3D sw->b5; dst[40] =3D pt->b6; dst[41] =3D p=
t->b7;
-
-	dst[42] =3D pt->cr_iip + ia64_psr(pt)->ri;
-	dst[43] =3D pt->cr_ifs;
-	dst[44] =3D pt->cr_ipsr & IA64_PSR_UM;
-
-	dst[45] =3D pt->ar_rsc; dst[46] =3D ar_bsp; dst[47] =3D pt->ar_bspstore; =
 dst[48] =3D pt->ar_rnat;
-	dst[49] =3D pt->ar_ccv; dst[50] =3D pt->ar_unat; dst[51] =3D sw->ar_fpsr;=
 dst[52] =3D pt->ar_pfs;
-	dst[53] =3D sw->ar_lc; dst[54] =3D (sw->ar_pfs >> 52) & 0x3f;
-#endif /* !CONFIG_IA64_NEW_UNWIND */
 }
=20
 int
 dump_fpu (struct pt_regs *pt, elf_fpregset_t dst)
 {
-#ifdef CONFIG_IA64_NEW_UNWIND
 	unw_init_running(do_dump_fpu, dst);
-#else
-	struct switch_stack *sw =3D ((struct switch_stack *) pt) - 1;
-
-	memset(dst, 0, sizeof (dst));	/* don't leak any "random" bits */
-
-	/* f0 is 0.0 */  /* f1 is 1.0 */  dst[2] =3D sw->f2; dst[3] =3D sw->f3;
-	dst[4] =3D sw->f4; dst[5] =3D sw->f5; dst[6] =3D pt->f6; dst[7] =3D pt->f=
7;
-	dst[8] =3D pt->f8; dst[9] =3D pt->f9;
-	memcpy(dst + 10, &sw->f10, 22*16);	/* f10-f31 are contiguous */
-
-	ia64_flush_fph(current);
-	if ((current->thread.flags & IA64_THREAD_FPH_VALID) !=3D 0)
-		memcpy(dst + 32, current->thread.fph, 96*16);
-#endif
 	return 1;	/* f0-f31 are always valid so we always return 1 */
 }
=20
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/ptrace.c linux-2=
.4.2-lia/arch/ia64/kernel/ptrace.c
--- linux-davidm/arch/ia64/kernel/ptrace.c	Wed Feb 28 12:57:33 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/ptrace.c	Wed Mar 21 23:08:50 2001
@@ -22,6 +22,7 @@
 #include <asm/rse.h>
 #include <asm/system.h>
 #include <asm/uaccess.h>
+#include <asm/unwind.h>
=20
 /*
  * Bits in the PSR that we allow ptrace() to change:
@@ -36,8 +37,6 @@
 	(IA64_PSR_UM | IA64_PSR_DB | IA64_PSR_IS | IA64_PSR_ID | IA64_PSR_DD | IA=
64_PSR_RI)
 #define IPSR_READ_MASK	IPSR_WRITE_MASK
=20
-#ifdef CONFIG_IA64_NEW_UNWIND
-
 #define PTRACE_DEBUG	1
=20
 #if PTRACE_DEBUG
@@ -97,57 +96,6 @@
 #	undef PUT_BITS
 }
=20
-#else /* !CONFIG_IA64_NEW_UNWIND */
-
-/*
- * Collect the NaT bits for r1-r31 from sw->caller_unat and
- * sw->ar_unat and return a NaT bitset where bit i is set iff the NaT
- * bit of register i is set.
- */
-long
-ia64_get_nat_bits (struct pt_regs *pt, struct switch_stack *sw)
-{
-#	define GET_BITS(str, first, last, unat)						\
-	({										\
-		unsigned long bit =3D ia64_unat_pos(&str->r##first);			\
-		unsigned long mask =3D ((1UL << (last - first + 1)) - 1) << first;	\
-		(ia64_rotl(unat, first) >> bit) & mask;					\
-	})
-	unsigned long val;
-
-	val  =3D GET_BITS(pt,  1,  3, sw->caller_unat);
-	val |=3D GET_BITS(pt, 12, 15, sw->caller_unat);
-	val |=3D GET_BITS(pt,  8, 11, sw->caller_unat);
-	val |=3D GET_BITS(pt, 16, 31, sw->caller_unat);
-	val |=3D GET_BITS(sw,  4,  7, sw->ar_unat);
-	return val;
-
-#	undef GET_BITS
-}
-
-/*
- * Store the NaT bitset NAT in pt->caller_unat and sw->ar_unat.
- */
-void
-ia64_put_nat_bits (struct pt_regs *pt, struct switch_stack *sw, unsigned l=
ong nat)
-{
-#	define PUT_BITS(str, first, last, nat)					\
-	({									\
-		unsigned long bit =3D ia64_unat_pos(&str->r##first);		\
-		unsigned long mask =3D ((1UL << (last - first + 1)) - 1) << bit;	\
-		(ia64_rotr(nat, first) << bit) & mask;				\
-	})
-	sw->caller_unat  =3D PUT_BITS(pt,  1,  3, nat);
-	sw->caller_unat |=3D PUT_BITS(pt, 12, 15, nat);
-	sw->caller_unat |=3D PUT_BITS(pt,  8, 11, nat);
-	sw->caller_unat |=3D PUT_BITS(pt, 16, 31, nat);
-	sw->ar_unat      =3D PUT_BITS(sw,  4,  7, nat);
-
-#	undef PUT_BITS
-}
-
-#endif /* !CONFIG_IA64_NEW_UNWIND */
-
 #define IA64_MLX_TEMPLATE	0x2
 #define IA64_MOVL_OPCODE	6
=20
@@ -352,11 +300,7 @@
=20
 	laddr =3D (unsigned long *) addr;
 	child_regs =3D ia64_task_regs(child);
-#ifdef CONFIG_IA64_NEW_UNWIND
 	child_stack =3D (struct switch_stack *) (child->thread.ksp + 16);
-#else
-	child_stack =3D (struct switch_stack *) child_regs - 1;
-#endif
 	bspstore =3D (unsigned long *) child_regs->ar_bspstore;
 	krbs =3D (unsigned long *) child + IA64_RBS_OFFSET/8;
 	krbs_num_regs =3D ia64_rse_num_regs(krbs, (unsigned long *) child_stack->=
ar_bspstore);
@@ -401,11 +345,7 @@
=20
 	laddr =3D (unsigned long *) addr;
 	child_regs =3D ia64_task_regs(child);
-#ifdef CONFIG_IA64_NEW_UNWIND
 	child_stack =3D (struct switch_stack *) (child->thread.ksp + 16);
-#else
-	child_stack =3D (struct switch_stack *) child_regs - 1;
-#endif
 	bspstore =3D (unsigned long *) child_regs->ar_bspstore;
 	krbs =3D (unsigned long *) child + IA64_RBS_OFFSET/8;
 	krbs_num_regs =3D ia64_rse_num_regs(krbs, (unsigned long *) child_stack->=
ar_bspstore);
@@ -468,7 +408,6 @@
 	long ndirty, ret =3D 0;
 	struct pt_regs *child_regs =3D ia64_task_regs(child);
=20
-#ifdef CONFIG_IA64_NEW_UNWIND
 	struct unw_frame_info info;
 	unsigned long cfm, sof;
=20
@@ -488,19 +427,6 @@
 		unw_get_cfm(&info, &cfm);
 	sof =3D (cfm & 0x7f);
 	rbs_end =3D (long) ia64_rse_skip_regs((long *)bspstore, sof);
-#else
-	struct switch_stack *child_stack;
-	unsigned long krbs_num_regs;
-
-	child_stack =3D (struct switch_stack *) child_regs - 1;
-	kbspstore =3D (unsigned long *) child_stack->ar_bspstore;
-	krbs =3D (unsigned long *) child + IA64_RBS_OFFSET/8;
-	ndirty =3D ia64_rse_num_regs(krbs, krbs + (child_regs->loadrs >> 19));
-	bspstore =3D child_regs->ar_bspstore;
-	bsp =3D (long) ia64_rse_skip_regs((long *)bspstore, ndirty);
-	krbs_num_regs =3D ia64_rse_num_regs(krbs, kbspstore);
-	rbs_end =3D (long) ia64_rse_skip_regs((long *)bspstore, krbs_num_regs);
-#endif
=20
 	/* Return early if nothing to do */
 	if (bsp =3D new_bsp)
@@ -588,10 +514,6 @@
 	psr->dfh =3D 1;
 }
=20
-#ifdef CONFIG_IA64_NEW_UNWIND
-
-#include <asm/unwind.h>
-
 static int
 access_fr (struct unw_frame_info *info, int regnum, int hi, unsigned long =
*data, int write_access)
 {
@@ -829,166 +751,6 @@
 		*data =3D *ptr;
 	return 0;
 }
-
-#else /* !CONFIG_IA64_NEW_UNWIND */
-
-static int
-access_uarea (struct task_struct *child, unsigned long addr, unsigned long=
 *data, int write_access)
-{
-	unsigned long *ptr =3D NULL, *rbs, *bspstore, ndirty, regnum;
-	struct switch_stack *sw;
-	struct pt_regs *pt;
-
-	if ((addr & 0x7) !=3D 0)
-		return -1;
-
-	if (addr < PT_F127+16) {
-		/* accessing fph */
-		if (write_access)
-			ia64_sync_fph(child);
-		else
-			ia64_flush_fph(child);
-		ptr =3D (unsigned long *) ((unsigned long) &child->thread.fph + addr);
-	} else if (addr < PT_F9+16) {
-		/* accessing switch_stack or pt_regs: */
-		pt =3D ia64_task_regs(child);
-		sw =3D (struct switch_stack *) pt - 1;
-
-		switch (addr) {
-		      case PT_NAT_BITS:
-			if (write_access)
-				ia64_put_nat_bits(pt, sw, *data);
-			else
-				*data =3D ia64_get_nat_bits(pt, sw);
-			return 0;
-
-		      case PT_AR_BSP:
-			if (write_access)
-				/* FIXME? Account for lack of ``cover'' in the syscall case */
-				return sync_kernel_register_backing_store(child, *data, 1);
-			else {
-				rbs =3D (unsigned long *) child + IA64_RBS_OFFSET/8;
-				bspstore =3D (unsigned long *) pt->ar_bspstore;
-				ndirty =3D ia64_rse_num_regs(rbs, rbs + (pt->loadrs >> 19));
-
-				/*
-				 * If we're in a system call, no ``cover'' was done.  So to
-				 * make things uniform, we'll add the appropriate displacement
-				 * onto bsp if we're in a system call.
-				 */
-				if (!(pt->cr_ifs & (1UL << 63)))
-					ndirty +=3D sw->ar_pfs & 0x7f;
-				*data =3D (unsigned long) ia64_rse_skip_regs(bspstore, ndirty);
-				return 0;
-			}
-
-		      case PT_CFM:
-			if (write_access) {
-				if (pt->cr_ifs & (1UL << 63))
-					pt->cr_ifs =3D ((pt->cr_ifs & ~0x3fffffffffUL)
-						      | (*data & 0x3fffffffffUL));
-				else
-					sw->ar_pfs =3D ((sw->ar_pfs & ~0x3fffffffffUL)
-						      | (*data & 0x3fffffffffUL));
-				return 0;
-			} else {
-				if ((pt->cr_ifs & (1UL << 63)) =3D 0)
-					*data =3D sw->ar_pfs;
-				else
-					/* return only the CFM */
-					*data =3D pt->cr_ifs & 0x3fffffffffUL;
-				return 0;
-			}
-
-		      case PT_CR_IPSR:
-			if (write_access)
-				pt->cr_ipsr =3D ((*data & IPSR_WRITE_MASK)
-					       | (pt->cr_ipsr & ~IPSR_WRITE_MASK));
-			else
-				*data =3D (pt->cr_ipsr & IPSR_READ_MASK);
-			return 0;
-
-		      case PT_AR_EC:
-			if (write_access)
-				sw->ar_pfs =3D (((*data & 0x3f) << 52)
-					      | (sw->ar_pfs & ~(0x3fUL << 52)));
-			else
-				*data =3D (sw->ar_pfs >> 52) & 0x3f;
-			break;
-
-		      case PT_R1: case PT_R2: case PT_R3:
-		      case PT_R4: case PT_R5: case PT_R6: case PT_R7:
-		      case PT_R8: case PT_R9: case PT_R10: case PT_R11:
-		      case PT_R12: case PT_R13: case PT_R14: case PT_R15:
-		      case PT_R16: case PT_R17: case PT_R18: case PT_R19:
-		      case PT_R20: case PT_R21: case PT_R22: case PT_R23:
-		      case PT_R24: case PT_R25: case PT_R26: case PT_R27:
-		      case PT_R28: case PT_R29: case PT_R30: case PT_R31:
-		      case PT_B0: case PT_B1: case PT_B2: case PT_B3:
-		      case PT_B4: case PT_B5: case PT_B6: case PT_B7:
-		      case PT_F2: case PT_F2+8: case PT_F3: case PT_F3+8:
-		      case PT_F4: case PT_F4+8: case PT_F5: case PT_F5+8:
-		      case PT_F6: case PT_F6+8: case PT_F7: case PT_F7+8:
-  		      case PT_F8: case PT_F8+8: case PT_F9: case PT_F9+8:
-		      case PT_F10: case PT_F10+8: case PT_F11: case PT_F11+8:
-		      case PT_F12: case PT_F12+8: case PT_F13: case PT_F13+8:
-		      case PT_F14: case PT_F14+8: case PT_F15: case PT_F15+8:
-		      case PT_F16: case PT_F16+8: case PT_F17: case PT_F17+8:
-		      case PT_F18: case PT_F18+8: case PT_F19: case PT_F19+8:
-  		      case PT_F20: case PT_F20+8: case PT_F21: case PT_F21+8:
-		      case PT_F22: case PT_F22+8: case PT_F23: case PT_F23+8:=20
-		      case PT_F24: case PT_F24+8: case PT_F25: case PT_F25+8:
-		      case PT_F26: case PT_F26+8: case PT_F27: case PT_F27+8:
- 		      case PT_F28: case PT_F28+8: case PT_F29: case PT_F29+8:
-		      case PT_F30: case PT_F30+8: case PT_F31: case PT_F31+8:
-		      case PT_AR_BSPSTORE:
-		      case PT_AR_RSC: case PT_AR_UNAT: case PT_AR_PFS: case PT_AR_RNAT:
-		      case PT_AR_CCV: case PT_AR_FPSR: case PT_CR_IIP: case PT_PR:
-		      case PT_AR_LC:
-			ptr =3D (unsigned long *) ((long) sw + addr - PT_NAT_BITS);
-			break;
-
-		      default:
-			/* disallow accessing anything else... */
-			return -1;
-		}
-	} else {
-
-		/* access debug registers */
-
-		if (!(child->thread.flags & IA64_THREAD_DBG_VALID)) {
-			child->thread.flags |=3D IA64_THREAD_DBG_VALID;
-			memset(child->thread.dbr, 0, sizeof child->thread.dbr);
-			memset(child->thread.ibr, 0, sizeof child->thread.ibr);
-		}
-		if (addr >=3D PT_IBR) {
-			regnum =3D (addr - PT_IBR) >> 3;
-			ptr =3D &child->thread.ibr[0];
-		} else {
-			regnum =3D (addr - PT_DBR) >> 3;
-			ptr =3D &child->thread.dbr[0];
-		}
-
-		if (regnum >=3D 8)
-			return -1;
-
-		ptr +=3D regnum;
-
-		if (write_access)
-			/* don't let the user set kernel-level breakpoints... */
-			*ptr =3D *data & ~(7UL << 56);
-		else
-			*data =3D *ptr;
-		return 0;
-	}
-	if (write_access)
-		*ptr =3D *data;
-	else
-		*data =3D *ptr;
-	return 0;
-}
-
-#endif /* !CONFIG_IA64_NEW_UNWIND */
=20
 asmlinkage long
 sys_ptrace (long request, pid_t pid, unsigned long addr, unsigned long dat=
a,
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/signal.c linux-2=
.4.2-lia/arch/ia64/kernel/signal.c
--- linux-davidm/arch/ia64/kernel/signal.c	Wed Mar 21 23:46:39 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/signal.c	Wed Mar 21 23:10:25 2001
@@ -38,12 +38,8 @@
 #endif
=20
 struct sigscratch {
-#ifdef CONFIG_IA64_NEW_UNWIND
 	unsigned long scratch_unat;	/* ar.unat for the general registers saved in=
 pt */
 	unsigned long pad;
-#else
-	struct switch_stack sw;
-#endif
 	struct pt_regs pt;
 };
=20
@@ -140,11 +136,7 @@
 	ia64_psr(&scr->pt)->ri =3D ip & 0x3;
 	scr->pt.cr_ipsr =3D (scr->pt.cr_ipsr & ~IA64_PSR_UM) | (um & IA64_PSR_UM);
=20
-#ifdef CONFIG_IA64_NEW_UNWIND
 	scr->scratch_unat =3D ia64_put_scratch_nat_bits(&scr->pt, nat);
-#else
-	ia64_put_nat_bits(&scr->pt, &scr->sw, nat);	/* restore the original scrat=
ch NaT bits */
-#endif
=20
 	if ((flags & IA64_SC_FLAG_FPH_VALID) !=3D 0) {
 		struct ia64_psr *psr =3D ia64_psr(&scr->pt);
@@ -303,11 +295,7 @@
 	 * preserved registers (r4-r7) are never being looked at by
 	 * the signal handler (registers r4-r7 are used instead).
 	 */
-#ifdef CONFIG_IA64_NEW_UNWIND
 	nat =3D ia64_get_scratch_nat_bits(&scr->pt, scr->scratch_unat);
-#else
-	nat =3D ia64_get_nat_bits(&scr->pt, &scr->sw);
-#endif
=20
 	err  =3D __put_user(flags, &sc->sc_flags);
=20
@@ -373,21 +361,11 @@
 	scr->pt.cr_iip =3D tramp_addr;
 	ia64_psr(&scr->pt)->ri =3D 0;			/* start executing in first slot */
=20
-#ifdef CONFIG_IA64_NEW_UNWIND
 	/*
 	 * Note: this affects only the NaT bits of the scratch regs
 	 * (the ones saved in pt_regs), which is exactly what we want.
 	 */
 	scr->scratch_unat =3D 0; /* ensure NaT bits of at least r2, r3, r12, and =
r15 are clear */
-#else
-	/*
-	 * Note: this affects only the NaT bits of the scratch regs
-	 * (the ones saved in pt_regs), which is exactly what we want.
-	 * The NaT bits for the preserved regs (r4-r7) are in
-	 * sw->ar_unat iff this process is being PTRACED.
-	 */
-	scr->sw.caller_unat =3D 0; /* ensure NaT bits of at least r2, r3, r12, an=
d r15 are clear */
-#endif
=20
 #if DEBUG_SIG
 	printk("SIG deliver (%s:%d): sig=3D%d sp=3D%lx ip=3D%lx handler=3D%lx\n",
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/unaligned.c linu=
x-2.4.2-lia/arch/ia64/kernel/unaligned.c
--- linux-davidm/arch/ia64/kernel/unaligned.c	Wed Mar 21 23:46:39 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/unaligned.c	Wed Mar 21 23:11:04 2001
@@ -1255,7 +1255,7 @@
 void
 ia64_handle_unaligned (unsigned long ifa, struct pt_regs *regs)
 {
-	const struct exception_table_entry *fix =3D NULL;
+	struct exception_fixup fix =3D { 0 };
 	struct ia64_psr *ipsr =3D ia64_psr(regs);
 	mm_segment_t old_fs =3D get_fs();
 	unsigned long bundle[2];
@@ -1275,10 +1275,17 @@
=20
 	/*
 	 * Treat kernel accesses for which there is an exception handler entry th=
e same as
-	 * user-level unaligned accesses.  Otherwise, a clever program could user=
 could
-	 * trick this handler into reading an arbitrary kernel addresses...
+	 * user-level unaligned accesses.  Otherwise, a clever program could tric=
k this
+	 * handler into reading an arbitrary kernel addresses...
 	 */
-	if (user_mode(regs) || (fix =3D search_exception_table(regs->cr_iip))) {
+	if (!user_mode(regs)) {
+#ifdef GAS_HAS_LOCAL_TAGS
+		fix =3D search_exception_table(regs->cr_iip + ia64_psr(regs)->ri);
+#else
+		fix =3D search_exception_table(regs->cr_iip);
+#endif
+	}
+	if (user_mode(regs) || fix.cont) {
 		if ((current->thread.flags & IA64_THREAD_UAC_SIGBUS) !=3D 0)
 			goto force_sigbus;
=20
@@ -1439,12 +1446,8 @@
   failure:
 	/* something went wrong... */
 	if (!user_mode(regs)) {
-		if (fix) {
-			regs->r8 =3D -EFAULT;
-			if (fix->skip & 1)
-				regs->r9 =3D 0;
-			regs->cr_iip +=3D ((long) fix->skip) & ~15;
-			regs->cr_ipsr &=3D ~IA64_PSR_RI;	/* clear exception slot number */
+		if (fix.cont) {
+			handle_exception(regs, fix);
 			goto done;
 		}
 		die_if_kernel("error during unaligned kernel access\n", regs, ret);
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/unwind.c linux-2=
.4.2-lia/arch/ia64/kernel/unwind.c
--- linux-davidm/arch/ia64/kernel/unwind.c	Wed Mar 21 23:46:39 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/unwind.c	Wed Mar 21 23:12:25 2001
@@ -31,8 +31,6 @@
=20
 #include <asm/unwind.h>
=20
-#ifdef CONFIG_IA64_NEW_UNWIND
-
 #include <asm/delay.h>
 #include <asm/page.h>
 #include <asm/ptrace.h>
@@ -1829,140 +1827,24 @@
 	STAT(unw.stat.api.init_time +=3D ia64_get_itc() - start; local_irq_restor=
e(flags));
 }
=20
-#endif /* CONFIG_IA64_NEW_UNWIND */
-
 void
 unw_init_from_blocked_task (struct unw_frame_info *info, struct task_struc=
t *t)
 {
 	struct switch_stack *sw =3D (struct switch_stack *) (t->thread.ksp + 16);
=20
-#ifdef CONFIG_IA64_NEW_UNWIND
 	unw_init_frame_info(info, t, sw);
-#else
-	unsigned long sol, limit, top;
-
-	memset(info, 0, sizeof(*info));
-
-	sol =3D (sw->ar_pfs >> 7) & 0x7f;	/* size of locals */
-
-	limit =3D (unsigned long) t + IA64_RBS_OFFSET;
-	top   =3D sw->ar_bspstore;
-	if (top - (unsigned long) t >=3D IA64_STK_OFFSET)
-		top =3D limit;
-
-	info->regstk.limit =3D limit;
-	info->regstk.top   =3D top;
-	info->sw  =3D sw;
-	info->bsp =3D (unsigned long) ia64_rse_skip_regs((unsigned long *) info->=
regstk.top, -sol);
-	info->cfm_loc =3D &sw->ar_pfs;
-	info->ip  =3D sw->b0;
-#endif
 }
=20
 void
 unw_init_from_current (struct unw_frame_info *info, struct pt_regs *regs)
 {
-#ifdef CONFIG_IA64_NEW_UNWIND
 	struct switch_stack *sw =3D (struct switch_stack *) regs - 1;
=20
 	unw_init_frame_info(info, current, sw);
 	/* skip over interrupt frame: */
 	unw_unwind(info);
-#else
-	struct switch_stack *sw =3D (struct switch_stack *) regs - 1;
-	unsigned long sol, sof, *bsp, limit, top;
-
-	limit =3D (unsigned long) current + IA64_RBS_OFFSET;
-	top   =3D sw->ar_bspstore;
-	if (top - (unsigned long) current >=3D IA64_STK_OFFSET)
-		top =3D limit;
-
-	memset(info, 0, sizeof(*info));
-
-	sol =3D (sw->ar_pfs >> 7) & 0x7f;	/* size of frame */
-
-	/* this gives us the bsp top level frame (kdb interrupt frame): */
-	bsp =3D ia64_rse_skip_regs((unsigned long *) top, -sol);
-
-	/* now skip past the interrupt frame: */
-	sof =3D regs->cr_ifs & 0x7f;	/* size of frame */
-
-	info->regstk.limit =3D limit;
-	info->regstk.top   =3D top;
-	info->sw =3D sw;
-	info->bsp =3D (unsigned long) ia64_rse_skip_regs(bsp, -sof);
-	info->cfm_loc =3D &regs->cr_ifs;
-	info->ip  =3D regs->cr_iip;
-#endif
-}
-
-#ifndef CONFIG_IA64_NEW_UNWIND
-
-static unsigned long
-read_reg (struct unw_frame_info *info, int regnum, int *is_nat)
-{
-	unsigned long *addr, *rnat_addr, rnat;
-
-	addr =3D ia64_rse_skip_regs((unsigned long *) info->bsp, regnum);
-	if ((unsigned long) addr < info->regstk.limit
-	    || (unsigned long) addr >=3D info->regstk.top || ((long) addr & 0x7) =
!=3D 0)
-	{
-		*is_nat =3D 1;
-		return 0xdeadbeefdeadbeef;
-	}
-	rnat_addr =3D ia64_rse_rnat_addr(addr);
-
-	if ((unsigned long) rnat_addr >=3D info->regstk.top)
-		rnat =3D info->sw->ar_rnat;
-	else
-		rnat =3D *rnat_addr;
-	*is_nat =3D (rnat & (1UL << ia64_rse_slot_num(addr))) !=3D 0;
-	return *addr;
 }
=20
-/*
- * On entry, info->regstk.top should point to the register backing
- * store for r32.
- */
-int
-unw_unwind (struct unw_frame_info *info)
-{
-	unsigned long sol, cfm =3D *info->cfm_loc;
-	int is_nat;
-
-	sol =3D (cfm >> 7) & 0x7f;	/* size of locals */
-
-	/*
-	 * In general, we would have to make use of unwind info to
-	 * unwind an IA-64 stack, but for now gcc uses a special
-	 * convention that makes this possible without full-fledged
-	 * unwindo info.  Specifically, we expect "rp" in the second
-	 * last, and "ar.pfs" in the last local register, so the
-	 * number of locals in a frame must be at least two.  If it's
-	 * less than that, we reached the end of the C call stack.
-	 */
-	if (sol < 2)
-		return -1;
-
-	info->ip =3D read_reg(info, sol - 2, &is_nat);
-	if (is_nat || (info->ip & (local_cpu_data->unimpl_va_mask | 0xf)))
-		/* reject let obviously bad addresses */
-		return -1;
-
-	info->cfm_loc =3D ia64_rse_skip_regs((unsigned long *) info->bsp, sol - 1=
);
-	cfm =3D read_reg(info, sol - 1, &is_nat);
-	if (is_nat)
-		return -1;
-
-	sol =3D (cfm >> 7) & 0x7f;
-
-	info->bsp =3D (unsigned long) ia64_rse_skip_regs((unsigned long *) info->=
bsp, -sol);
-	return 0;
-}
-#endif /* !CONFIG_IA64_NEW_UNWIND */
-
-#ifdef CONFIG_IA64_NEW_UNWIND
-
 static void
 init_unwind_table (struct unw_table *table, const char *name, unsigned lon=
g segment_base,
 		   unsigned long gp, void *table_start, void *table_end)
@@ -2063,12 +1945,10 @@
=20
 	kfree(table);
 }
-#endif /* CONFIG_IA64_NEW_UNWIND */
=20
 void
 unw_init (void)
 {
-#ifdef CONFIG_IA64_NEW_UNWIND
 	extern int ia64_unw_start, ia64_unw_end, __gp;
 	extern void unw_hash_index_t_is_too_narrow (void);
 	long i, off;
@@ -2104,5 +1984,4 @@
=20
 	init_unwind_table(&unw.kernel_table, "kernel", KERNEL_START, (unsigned lo=
ng) &__gp,
 			  &ia64_unw_start, &ia64_unw_end);
-#endif /* CONFIG_IA64_NEW_UNWIND */
 }
diff -urN --ignore-all-space linux-davidm/arch/ia64/lib/clear_page.S linux-=
2.4.2-lia/arch/ia64/lib/clear_page.S
--- linux-davidm/arch/ia64/lib/clear_page.S	Thu Jun 22 07:09:44 2000
+++ linux-2.4.2-lia/arch/ia64/lib/clear_page.S	Wed Mar 21 23:13:00 2001
@@ -10,25 +10,20 @@
  * Output:
  * 	none
  *
- * Copyright (C) 1999-2000 Hewlett-Packard Co
+ * Copyright (C) 1999-2001 Hewlett-Packard Co
  * Copyright (C) 1999 Stephane Eranian <eranian@hpl.hp.com>
- * Copyright (C) 1999-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #include <asm/asmmacro.h>
 #include <asm/page.h>
=20
-	.text
-	.psr abi64
-	.psr lsb
-	.lsb
-
 GLOBAL_ENTRY(clear_page)
-	UNW(.prologue)
+	.prologue
 	alloc r11=3Dar.pfs,1,0,0,0
-	UNW(.save ar.lc, r16)
+	.save ar.lc, r16
 	mov r16=3Dar.lc		// slow
=20
-	UNW(.body)
+	.body
=20
 	mov r17=3DPAGE_SIZE/32-1	// -1 =3D repeat/until
 	;;
diff -urN --ignore-all-space linux-davidm/arch/ia64/lib/clear_user.S linux-=
2.4.2-lia/arch/ia64/lib/clear_user.S
--- linux-davidm/arch/ia64/lib/clear_user.S	Thu Jun 22 07:09:44 2000
+++ linux-2.4.2-lia/arch/ia64/lib/clear_user.S	Wed Mar 21 23:13:27 2001
@@ -7,7 +7,7 @@
  * Outputs:
  *	r8:	number of bytes that didn't get cleared due to a fault
  *=20
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
+ * Copyright (C) 1998, 1999, 2001 Hewlett-Packard Co
  * Copyright (C) 1999 Stephane Eranian <eranian@hpl.hp.com>
  */
=20
@@ -51,27 +51,28 @@
 //	have side effects (same thing for writing).
 //
=20
+	.section "__ex_table", "a"		// declare section & section attributes
+	.previous
+
 // The label comes first because our store instruction contains a comma
 // and confuse the preprocessor otherwise
-//
+
+#if __GNUC__ >=3D 3
 #define EX(y,x...)				\
-	.section __ex_table,"a";		\
-	data4 @gprel(99f);			\
-	data4 y-99f;				\
-	.previous;				\
+	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
+  [99:]	x
+#else
+# define EX(y,x...)					\
+	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
 99:	x
-
-	.text
-	.psr abi64
-	.psr lsb
-	.lsb
+#endif
=20
 GLOBAL_ENTRY(__do_clear_user)
-	UNW(.prologue)
-	UNW(.save ar.pfs, saved_pfs)
+	.prologue
+	.save ar.pfs, saved_pfs
  	alloc	saved_pfs=3Dar.pfs,2,0,0,0
 	cmp.eq p6,p0=3Dr0,len		// check for zero length
-	UNW(.save ar.lc, saved_lc)
+	.save ar.lc, saved_lc
 	mov saved_lc=3Dar.lc		// preserve ar.lc (slow)
 	.body
 	;;				// avoid WAW on CFM
@@ -150,7 +151,7 @@
 	//
 	//=20
 	// We need to keep track of the remaining length. A possible (optimistic)
-	// way would be to ue ar.lc and derive how many byte were left by
+	// way would be to use ar.lc and derive how many byte were left by
 	// doing : left=3D 16*ar.lc + 16.  this would avoid the addition at
 	// every iteration.=20
 	// However we need to keep the synchronization point. A template
diff -urN --ignore-all-space linux-davidm/arch/ia64/lib/copy_page.S linux-2=
.4.2-lia/arch/ia64/lib/copy_page.S
--- linux-davidm/arch/ia64/lib/copy_page.S	Thu Jun 22 07:09:44 2000
+++ linux-2.4.2-lia/arch/ia64/lib/copy_page.S	Wed Mar 21 23:13:39 2001
@@ -10,7 +10,7 @@
  * Output:
  * 	no return value
  *
- * Copyright (C) 1999 Hewlett-Packard Co
+ * Copyright (C) 1999, 2001 Hewlett-Packard Co
  * Copyright (C) 1999 Stephane Eranian <eranian@hpl.hp.com>
  */
 #include <asm/asmmacro.h>
@@ -28,25 +28,20 @@
 #define tgt1		r22
 #define tgt2		r23
=20
-	.text
-	.psr abi64
-	.psr lsb
-	.lsb
-
 GLOBAL_ENTRY(copy_page)
-	UNW(.prologue)
-	UNW(.save ar.pfs, saved_pfs)
+	.prologue
+	.save ar.pfs, saved_pfs
 	alloc saved_pfs=3Dar.pfs,3,((2*PIPE_DEPTH+7)&~7),0,((2*PIPE_DEPTH+7)&~7)
=20
 	.rotr t1[PIPE_DEPTH], t2[PIPE_DEPTH]
 	.rotp p[PIPE_DEPTH]
=20
-	UNW(.save ar.lc, saved_lc)
+	.save ar.lc, saved_lc
 	mov saved_lc=3Dar.lc	// save ar.lc ahead of time
-	UNW(.save pr, saved_pr)
+	.save pr, saved_pr
 	mov saved_pr=3Dpr		// rotating predicates are preserved
 				// resgisters we must save.
-	UNW(.body)
+	.body
=20
 	mov src1=3Din1		// initialize 1st stream source=20
 	adds src2=3D8,in1		// initialize 2nd stream source=20
diff -urN --ignore-all-space linux-davidm/arch/ia64/lib/copy_user.S linux-2=
.4.2-lia/arch/ia64/lib/copy_user.S
--- linux-davidm/arch/ia64/lib/copy_user.S	Wed Mar 21 23:46:39 2001
+++ linux-2.4.2-lia/arch/ia64/lib/copy_user.S	Wed Mar 21 23:13:50 2001
@@ -31,19 +31,19 @@
=20
 #include <asm/asmmacro.h>
=20
+	.section "__ex_table", "a"		// declare section & section attributes
+	.previous
+
 // The label comes first because our store instruction contains a comma
 // and confuse the preprocessor otherwise
-//
-#undef DEBUG
-#ifdef DEBUG
+
+#if __GNUC__ >=3D 3
 #define EX(y,x...)				\
-99:	x
+	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
+  [99:]	x
 #else
 #define EX(y,x...)				\
-	.section __ex_table,"a";		\
-	data4 @gprel(99f);			\
-	data4 y-99f;				\
-	.previous;				\
+	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
 99:	x
 #endif
=20
@@ -85,13 +85,10 @@
 #define enddst		r29
 #define endsrc		r30
 #define saved_pfs	r31
- 	.text
- 	.psr	abi64
- 	.psr	lsb
=20
 GLOBAL_ENTRY(__copy_user)
-	UNW(.prologue)
-	UNW(.save ar.pfs, saved_pfs)
+	.prologue
+	.save ar.pfs, saved_pfs
 	alloc saved_pfs=3Dar.pfs,3,((2*PIPE_DEPTH+7)&~7),0,((2*PIPE_DEPTH+7)&~7)
=20
 	.rotr val1[PIPE_DEPTH],val2[PIPE_DEPTH]
@@ -102,16 +99,16 @@
=20
 	;;			// RAW of cfm when len=3D0
 	cmp.eq p8,p0=3Dr0,len	// check for zero length
-	UNW(.save ar.lc, saved_lc)
+	.save ar.lc, saved_lc
 	mov saved_lc=3Dar.lc	// preserve ar.lc (slow)
 (p8)	br.ret.spnt.few rp	// empty mempcy()
 	;;
 	add enddst=3Ddst,len	// first byte after end of source
 	add endsrc=3Dsrc,len	// first byte after end of destination
-	UNW(.save pr, saved_pr)
+	.save pr, saved_pr
 	mov saved_pr=3Dpr		// preserve predicates
=20
-	UNW(.body)
+	.body
=20
 	mov dst1=3Ddst		// copy because of rotation
 	mov ar.ec=3DPIPE_DEPTH
@@ -130,7 +127,6 @@
 	// p7 is necessarily false by now
 1:			=09
 	EX(failure_in_pipe1,(p16) ld1 val1[0]=3D[src1],1)
-
 	EX(failure_out,(EPI) st1 [dst1]=3Dval1[PIPE_DEPTH-1],1)
 	br.ctop.dptk.few 1b
 	;;
@@ -213,7 +209,6 @@
 	;;=20
 2:=09
 	EX(failure_in_pipe2,(p16) ld1 val1[0]=3D[src1],1)
-	;;=20
 	EX(failure_out,(EPI) st1 [dst1]=3Dval1[PIPE_DEPTH-1],1)
 	br.ctop.dptk.few 2b
 	;;
@@ -315,7 +310,6 @@
 	;;
 5:	=09
 	EX(failure_in_pipe1,(p16) ld1 val1[0]=3D[src1],1)
-=09
 	EX(failure_out,(EPI) st1 [dst1]=3Dval1[PIPE_DEPTH-1],1)
 	br.ctop.dptk.few 5b
 	;;
@@ -354,6 +348,7 @@
 	// we have never executed the ld1, therefore st1 is not executed.
 	//
 	EX(failure_in1,(p8) ld4 val2[0]=3D[src1],4)	// 4-byte aligned
+	;;
 	EX(failure_out,(p6) st1 [dst1]=3Dval1[0],1)
 	tbit.nz p9,p0=3Dsrc1,3
 	;;
diff -urN --ignore-all-space linux-davidm/arch/ia64/lib/csum_partial_copy.c=
 linux-2.4.2-lia/arch/ia64/lib/csum_partial_copy.c
--- linux-davidm/arch/ia64/lib/csum_partial_copy.c	Sun Feb  6 18:42:40 2000
+++ linux-2.4.2-lia/arch/ia64/lib/csum_partial_copy.c	Wed Mar 21 23:14:01 2=
001
@@ -107,10 +107,8 @@
 do_csum_partial_copy_from_user (const char *src, char *dst, int len,
 				unsigned int psum, int *errp)
 {
-	const unsigned char *psrc =3D src;
 	unsigned long result;
-	int cplen =3D len;
-	int r =3D 0;
+	int r;
=20
 	/* XXX Fixme
 	 * for now we separate the copy from checksum for obvious=20
@@ -118,7 +116,7 @@
 	 * scared.
 	 */
=20
-	while ( cplen-- ) r |=3D__get_user(*dst++,psrc++);
+	r =3D copy_from_user(dst, src, len);
=20
 	if ( r && errp ) *errp =3D r;
=20
diff -urN --ignore-all-space linux-davidm/arch/ia64/lib/do_csum.S linux-2.4=
.2-lia/arch/ia64/lib/do_csum.S
--- linux-davidm/arch/ia64/lib/do_csum.S	Thu Jun 22 07:09:44 2000
+++ linux-2.4.2-lia/arch/ia64/lib/do_csum.S	Wed Mar 21 23:14:18 2001
@@ -8,7 +8,7 @@
  *	in0: address of buffer to checksum (char *)
  *	in1: length of the buffer (int)
  *=20
- * Copyright (C) 1999 Hewlett-Packard Co
+ * Copyright (C) 1999, 2001 Hewlett-Packard Co
  * Copyright (C) 1999 Stephane Eranian <eranian@hpl.hp.com>
  *
  */
@@ -94,17 +94,11 @@
 #define buf		in0
 #define len		in1
=20
-
-	.text
-	.psr abi64
-	.psr lsb
-	.lsb
-
 // unsigned long do_csum(unsigned char *buf,int len)
=20
 GLOBAL_ENTRY(do_csum)
-	UNW(.prologue)
-	UNW(.save ar.pfs, saved_pfs)
+	.prologue
+	.save ar.pfs, saved_pfs
 	alloc saved_pfs=3Dar.pfs,2,8,0,8
=20
 	.rotr p[4], result[3]
@@ -126,7 +120,7 @@
 	;;
 	and lastoff=3D7,tmp1	// how many bytes off for last element
 	andcm last=3Dtmp2,tmp3	// address of word containing last byte
-	UNW(.save pr, saved_pr)
+	.save pr, saved_pr
 	mov saved_pr=3Dpr		// preserve predicates (rotation)
 	;;
 	sub tmp3=3Dlast,first	// tmp3=3Ddistance from first to last
@@ -147,11 +141,11 @@
 	shl hmask=3Dhmask,tmp2 	// build head mask, mask off [0,firstoff[
 	;;
 	shr.u tmask=3Dtmask,tmp1	// build tail mask, mask off ]8,lastoff]
-	UNW(.save ar.lc, saved_lc)
+	.save ar.lc, saved_lc
 	mov saved_lc=3Dar.lc	// save lc
 	;;
=20
-	UNW(.body)
+	.body
=20
 (p8)	and hmask=3Dhmask,tmask	// apply tail mask to head mask if 1 word only
 (p9)	and p[1]=3Dlastval,tmask	// mask last it as appropriate
diff -urN --ignore-all-space linux-davidm/arch/ia64/lib/flush.S linux-2.4.2=
-lia/arch/ia64/lib/flush.S
--- linux-davidm/arch/ia64/lib/flush.S	Thu Jan  4 22:40:10 2001
+++ linux-2.4.2-lia/arch/ia64/lib/flush.S	Wed Mar 21 23:14:33 2001
@@ -1,29 +1,24 @@
 /*
  * Cache flushing routines.
  *
- * Copyright (C) 1999-2000 Hewlett-Packard Co
- * Copyright (C) 1999-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999-2001 Hewlett-Packard Co
+ * Copyright (C) 1999-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #include <asm/asmmacro.h>
 #include <asm/page.h>
=20
-	.text
-	.psr abi64
-	.psr lsb
-	.lsb
-
 	/*
 	 * flush_icache_range(start,end)
 	 *	Must flush range from start to end-1 but nothing else (need to
 	 *	be careful not to touch addresses that may be unmapped).
 	 */
 GLOBAL_ENTRY(flush_icache_range)
-	UNW(.prologue)
+	.prologue
 	alloc r2=3Dar.pfs,2,0,0,0
 	sub r8=3Din1,in0,1
 	;;
 	shr.u r8=3Dr8,5			// we flush 32 bytes per iteration
-	UNW(.save ar.lc, r3)
+	.save ar.lc, r3
 	mov r3=3Dar.lc			// save ar.lc=09
 	;;
=20
diff -urN --ignore-all-space linux-davidm/arch/ia64/lib/idiv64.S linux-2.4.=
2-lia/arch/ia64/lib/idiv64.S
--- linux-davidm/arch/ia64/lib/idiv64.S	Wed Mar 21 23:46:39 2001
+++ linux-2.4.2-lia/arch/ia64/lib/idiv64.S	Wed Mar 21 23:14:47 2001
@@ -37,23 +37,23 @@
 #define NAME		PASTE(PASTE(__,SGN),PASTE(OP,di3))
=20
 GLOBAL_ENTRY(NAME)
-	UNW(.prologue)
+	.prologue
 	.regstk 2,0,0,0
 	// Transfer inputs to FP registers.
 	setf.sig f8 =3D in0
 	setf.sig f9 =3D in1
 	;;
-	UNW(.fframe 16)
-	UNW(.save.f 0x20)
+	.fframe 16
+	.save.f 0x20
 	stf.spill [sp] =3D f17,-16
=20
 	// Convert the inputs to FP, to avoid FP software-assist faults.
 	INT_TO_FP(f8, f8)
 	;;
=20
-	UNW(.save.f 0x10)
+	.save.f 0x10
 	stf.spill [sp] =3D f16
-	UNW(.body)
+	.body
 	INT_TO_FP(f9, f9)
 	;;
 	frcpa.s1 f17, p6 =3D f8, f9	// y0 =3D frcpa(b)
@@ -79,7 +79,7 @@
 #endif
 (p6)	fma.s1 f17 =3D f7, f6, f16	// q3 =3D r*y2 + q2
 	;;
-	UNW(.restore sp)
+	.restore sp
 	ldf.fill f16 =3D [sp], 16
 	FP_TO_INT(f17, f17)		// q =3D trunc(q3)
 	;;
diff -urN --ignore-all-space linux-davidm/arch/ia64/lib/memcpy.S linux-2.4.=
2-lia/arch/ia64/lib/memcpy.S
--- linux-davidm/arch/ia64/lib/memcpy.S	Thu Jan  4 22:40:10 2001
+++ linux-2.4.2-lia/arch/ia64/lib/memcpy.S	Wed Mar 21 23:14:56 2001
@@ -68,19 +68,19 @@
 	 * the more general copy routine handling arbitrary
 	 * sizes/alignment etc.
 	 */
-	UNW(.prologue)
-	UNW(.save ar.pfs, saved_pfs)
+	.prologue
+	.save ar.pfs, saved_pfs
 	alloc saved_pfs=3Dar.pfs,3,Nrot,0,Nrot
-	UNW(.save ar.lc, saved_lc)
+	.save ar.lc, saved_lc
 	mov saved_lc=3Dar.lc
 	or t0=3Din0,in1
 	;;
=20
 	or t0=3Dt0,in2
-	UNW(.save pr, saved_pr)
+	.save pr, saved_pr
 	mov saved_pr=3Dpr
=20
-	UNW(.body)
+	.body
=20
 	cmp.eq p6,p0=3Din2,r0	// zero length?
 	mov retval=3Din0		// return dst
diff -urN --ignore-all-space linux-davidm/arch/ia64/lib/memset.S linux-2.4.=
2-lia/arch/ia64/lib/memset.S
--- linux-davidm/arch/ia64/lib/memset.S	Thu Jun 22 07:09:44 2000
+++ linux-2.4.2-lia/arch/ia64/lib/memset.S	Wed Mar 21 23:15:05 2001
@@ -4,13 +4,12 @@
  *
  * Return: none
  *        =20
- *
  * Inputs:
  *	in0:	address of buffer
  * 	in1:	byte value to use for storing
  *	in2:	length of the buffer
  *
- * Copyright (C) 1999 Hewlett-Packard Co
+ * Copyright (C) 1999, 2001 Hewlett-Packard Co
  * Copyright (C) 1999 Stephane Eranian <eranian@hpl.hp.com>
  */
=20
@@ -31,20 +30,16 @@
 #define saved_lc	r20
 #define tmp		r21
=20
- 	.text
- 	.psr	abi64
- 	.psr	lsb
-
 GLOBAL_ENTRY(memset)
-	UNW(.prologue)
-	UNW(.save ar.pfs, saved_pfs)
+	.prologue
+	.save ar.pfs, saved_pfs
  	alloc	saved_pfs=3Dar.pfs,3,0,0,0	// cnt is sink here
 	cmp.eq p8,p0=3Dr0,len	// check for zero length
-	UNW(.save ar.lc, saved_lc)
+	.save ar.lc, saved_lc
 	mov saved_lc=3Dar.lc	// preserve ar.lc (slow)
 	;;=20
=20
-	UNW(.body)
+	.body
=20
 	adds tmp=3D-1,len		// br.ctop is repeat/until
 	tbit.nz p6,p0=3Dbuf,0	// odd alignment
diff -urN --ignore-all-space linux-davidm/arch/ia64/lib/strlen.S linux-2.4.=
2-lia/arch/ia64/lib/strlen.S
--- linux-davidm/arch/ia64/lib/strlen.S	Thu Jun 22 07:09:44 2000
+++ linux-2.4.2-lia/arch/ia64/lib/strlen.S	Wed Mar 21 23:15:15 2001
@@ -10,7 +10,7 @@
  * 	ret0	the number of characters in the string (0 if empty string)
  *         	does not count the \0
  *
- * Copyright (C) 1999 Hewlett-Packard Co
+ * Copyright (C) 1999, 2001 Hewlett-Packard Co
  * Copyright (C) 1999 Stephane Eranian <eranian@hpl.hp.com>
  *
  * 09/24/99 S.Eranian add speculation recovery code
@@ -78,15 +78,9 @@
 #define val1		r22
 #define val2		r23
=20
-
-	.text
-	.psr abi64
-	.psr lsb
-	.lsb
-
 GLOBAL_ENTRY(strlen)
-	UNW(.prologue)
-	UNW(.save ar.pfs, saved_pfs)
+	.prologue
+	.save ar.pfs, saved_pfs
 	alloc saved_pfs=3Dar.pfs,11,0,0,8 // rotating must be multiple of 8
=20
 	.rotr v[2], w[2]	// declares our 4 aliases
@@ -94,11 +88,11 @@
 	extr.u tmp=3Din0,0,3	// tmp=3Dleast significant 3 bits
 	mov orig=3Din0		// keep trackof initial byte address
 	dep src=3D0,in0,0,3	// src=8Byte-aligned in0 address
-	UNW(.save pr, saved_pr)
+	.save pr, saved_pr
 	mov saved_pr=3Dpr		// preserve predicates (rotation)
 	;;
=20
-	UNW(.body)
+	.body
=20
 	ld8 v[1]=3D[src],8	// must not speculate: can fail here
 	shl tmp=3Dtmp,3		// multiply by 8bits/byte
@@ -132,11 +126,7 @@
 	//	- there must be a better way of doing the test
 	//
 	cmp.eq  p8,p9=3D8,val1	// p6 =3D val1 had zero (disambiguate)
-#ifdef notyet
 	tnat.nz p6,p7=3Dval1	// test NaT on val1
-#else
-	tnat.z p7,p6=3Dval1	// test NaT on val1
-#endif
 (p6)	br.cond.spnt.few recover// jump to recovery if val1 is NaT
 	;;
 	//
diff -urN --ignore-all-space linux-davidm/arch/ia64/lib/strlen_user.S linux=
-2.4.2-lia/arch/ia64/lib/strlen_user.S
--- linux-davidm/arch/ia64/lib/strlen_user.S	Thu Jun 22 07:09:44 2000
+++ linux-2.4.2-lia/arch/ia64/lib/strlen_user.S	Wed Mar 21 23:15:28 2001
@@ -7,8 +7,8 @@
  * Outputs:
  *	ret0	0 in case of fault, strlen(buffer)+1 otherwise
  *=20
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998, 1999, 2001 Hewlett-Packard Co
+ * Copyright (C) 1998, 1999, 2001 David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1998, 1999 Stephane Eranian <eranian@hpl.hp.com>
  *
  * 01/19/99 S.Eranian heavily enhanced version (see details below)
@@ -68,15 +68,19 @@
 //
 //	- Clearly performance tuning is required.
 //
-//=20
-//
=20
+	.section "__ex_table", "a"		// declare section & section attributes
+	.previous
+
+#if __GNUC__ >=3D 3
+# define EX(y,x...)					\
+	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
+  [99:]	x
+#else
 #define EX(y,x...)				\
-	.section __ex_table,"a";		\
-	data4 @gprel(99f);			\
-	data4 y-99f;				\
-	.previous;				\
+	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
 99:	x
+#endif
=20
 #define saved_pfs	r11
 #define	tmp		r10
@@ -89,15 +93,9 @@
 #define val1		r22
 #define val2		r23
=20
-
-	.text
-	.psr abi64
-	.psr lsb
-	.lsb
-
 GLOBAL_ENTRY(__strlen_user)
-	UNW(.prologue)
-	UNW(.save ar.pfs, saved_pfs)
+	.prologue
+	.save ar.pfs, saved_pfs
 	alloc saved_pfs=3Dar.pfs,11,0,0,8
=20
 	.rotr v[2], w[2]	// declares our 4 aliases
@@ -105,7 +103,7 @@
 	extr.u tmp=3Din0,0,3	// tmp=3Dleast significant 3 bits
 	mov orig=3Din0		// keep trackof initial byte address
 	dep src=3D0,in0,0,3	// src=8Byte-aligned in0 address
-	UNW(.save pr, saved_pr)
+	.save pr, saved_pr
 	mov saved_pr=3Dpr		// preserve predicates (rotation)
 	;;
=20
@@ -144,11 +142,7 @@
 	//	- there must be a better way of doing the test
 	//
 	cmp.eq  p8,p9=3D8,val1	// p6 =3D val1 had zero (disambiguate)
-#ifdef notyet
 	tnat.nz p6,p7=3Dval1	// test NaT on val1
-#else
-	tnat.z p7,p6=3Dval1	// test NaT on val1
-#endif
 (p6)	br.cond.spnt.few recover// jump to recovery if val1 is NaT
 	;;
 	//
diff -urN --ignore-all-space linux-davidm/arch/ia64/lib/strncpy_from_user.S=
 linux-2.4.2-lia/arch/ia64/lib/strncpy_from_user.S
--- linux-davidm/arch/ia64/lib/strncpy_from_user.S	Thu Jun 22 07:09:44 2000
+++ linux-2.4.2-lia/arch/ia64/lib/strncpy_from_user.S	Wed Mar 21 23:15:42 2=
001
@@ -9,8 +9,8 @@
  * Outputs:
  *	r8:	-EFAULT in case of fault or number of bytes copied if no fault
  *=20
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * 00/03/06 D. Mosberger Fixed to return proper return value (bug found by
  *			 by Andreas Schwab <schwab@suse.de>).
@@ -18,17 +18,18 @@
=20
 #include <asm/asmmacro.h>
=20
-#define EX(x...)				\
-99:	x;					\
-	.section __ex_table,"a";		\
-	data4 @gprel(99b);			\
-	data4 .Lexit-99b;			\
+	.section "__ex_table", "a"		// declare section & section attributes
 	.previous
=20
-	.text
-	.psr abi64
-	.psr lsb
-	.lsb
+#if __GNUC__ >=3D 3
+# define EX(y,x...)					\
+	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
+  [99:]	x
+#else
+# define EX(y,x...)					\
+	.xdata4 "__ex_table", @gprel(99f), @gprel(y);	\
+  99:	x
+#endif
=20
 GLOBAL_ENTRY(__strncpy_from_user)
 	alloc r2=3Dar.pfs,3,0,0,0
@@ -41,15 +42,23 @@
=20
 	// XXX braindead copy loop---this needs to be optimized
 .Loop1:
-	EX(ld1 r8=3D[in1],1;; st1 [in0]=3Dr8,1; cmp.ne p6,p7=3Dr8,r0)
+	EX(.Lexit, ld1 r8=3D[in1],1)
+	;;
+	EX(.Lexit, st1 [in0]=3Dr8,1)
+	cmp.ne p6,p7=3Dr8,r0
 	;;
 (p6)	cmp.ne.unc p8,p0=3Din1,r10
 (p8)	br.cond.dpnt.few .Loop1
 	;;
 (p6)	mov r8=3Din2		// buffer filled up---return buffer length
 (p7)	sub r8=3Din1,r9,1		// return string length (excluding NUL character)
+#ifdef __GNUC__ >=3D 3
+[.Lexit:]
+	br.ret.sptk.few rp
+#else
 	br.ret.sptk.few rp
=20
 .Lexit:
 	br.ret.sptk.few rp
+#endif
 END(__strncpy_from_user)
diff -urN --ignore-all-space linux-davidm/arch/ia64/lib/strnlen_user.S linu=
x-2.4.2-lia/arch/ia64/lib/strnlen_user.S
--- linux-davidm/arch/ia64/lib/strnlen_user.S	Thu Jun 22 07:09:44 2000
+++ linux-2.4.2-lia/arch/ia64/lib/strnlen_user.S	Wed Mar 21 23:16:29 2001
@@ -9,40 +9,41 @@
  * Outputs:
  *	r8:	0 in case of fault, strlen(buffer)+1 otherwise
  *=20
- * Copyright (C) 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999, 2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 #include <asm/asmmacro.h>
=20
+	.section "__ex_table", "a"		// declare section & section attributes
+	.previous
+
 /* If a fault occurs, r8 gets set to -EFAULT and r9 gets cleared.  */
-#define EX(x...)				\
-	.section __ex_table,"a";		\
-	data4 @gprel(99f);			\
-	data4 (.Lexit-99f)|1;			\
-	.previous				\
-99:	x;
-
-	.text
-	.psr abi64
-	.psr lsb
-	.lsb
+#if __GNUC__ >=3D 3
+# define EXC(y,x...)					\
+	.xdata4 "__ex_table", @gprel(99f), @gprel(y)+4;	\
+  [99:]	x
+#else
+# define EXC(y,x...)					\
+	.xdata4 "__ex_table", @gprel(99f), @gprel(y)+4;	\
+  99:	x
+#endif
=20
 GLOBAL_ENTRY(__strnlen_user)
-	UNW(.prologue)
+	.prologue
 	alloc r2=3Dar.pfs,2,0,0,0
-	UNW(.save ar.lc, r16)
+	.save ar.lc, r16
 	mov r16=3Dar.lc			// preserve ar.lc
=20
-	UNW(.body)
+	.body
=20
 	add r3=3D-1,in1
 	;;
 	mov ar.lc=3Dr3
 	mov r9=3D0
-
+	;;
 	// XXX braindead strlen loop---this needs to be optimized
 .Loop1:
-	EX(ld1 r8=3D[in0],1)
+	EXC(.Lexit, ld1 r8=3D[in0],1)
 	add r9=3D1,r9
 	;;
 	cmp.eq p6,p0=3Dr8,r0
diff -urN --ignore-all-space linux-davidm/arch/ia64/mm/extable.c linux-2.4.=
2-lia/arch/ia64/mm/extable.c
--- linux-davidm/arch/ia64/mm/extable.c	Sun Feb  6 18:42:40 2000
+++ linux-2.4.2-lia/arch/ia64/mm/extable.c	Wed Mar 21 23:16:48 2001
@@ -1,8 +1,8 @@
 /*
  * Kernel exception handling table support.  Derived from arch/alpha/mm/ex=
table.c.
  *
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998, 1999, 2001 Hewlett-Packard Co
+ * Copyright (C) 1998, 1999, 2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 #include <linux/config.h>
@@ -43,14 +43,22 @@
         return 0;
 }
=20
-register unsigned long gp __asm__("gp");
+#ifndef CONFIG_MODULE
+register unsigned long main_gp __asm__("gp");
+#endif
=20
-const struct exception_table_entry *
+struct exception_fixup
 search_exception_table (unsigned long addr)
 {
+	const struct exception_table_entry *entry;
+	struct exception_fixup fix =3D { 0 };
+
 #ifndef CONFIG_MODULE
 	/* There is only the kernel to search.  */
-	return search_one_table(__start___ex_table, __stop___ex_table - 1, addr -=
 gp);
+	entry =3D search_one_table(__start___ex_table, __stop___ex_table - 1, add=
r - main_gp);
+	if (entry)
+		fix.cont =3D entry->cont + main_gp;
+	return fix;
 #else
 	struct exception_table_entry *ret;
 	/* The kernel is the last "module" -- no need to treat it special. */
@@ -59,10 +67,22 @@
 	for (mp =3D module_list; mp ; mp =3D mp->next) {
 		if (!mp->ex_table_start)
 			continue;
-		ret =3D search_one_table(mp->ex_table_start, mp->ex_table_end - 1, addr =
- mp->gp);
-		if (ret)
-			return ret;
+		entry =3D search_one_table(mp->ex_table_start, mp->ex_table_end - 1, add=
r - mp->gp);
+		if (entry) {
+			fix.cont =3D entry->cont + mp->gp;
+			return fix;
+		}
 	}
-	return 0;
 #endif
+	return fix;
+}
+
+void
+handle_exception (struct pt_regs *regs, struct exception_fixup fix)
+{
+	regs->r8 =3D -EFAULT;
+	if (fix.cont & 4)
+		regs->r9 =3D 0;
+	regs->cr_iip =3D (long) fix.cont & ~0xf;
+	ia64_psr(regs)->ri =3D fix.cont & 0x3;		/* set continuation slot number */
 }
diff -urN --ignore-all-space linux-davidm/arch/ia64/mm/fault.c linux-2.4.2-=
lia/arch/ia64/mm/fault.c
--- linux-davidm/arch/ia64/mm/fault.c	Thu Jan  4 22:40:10 2001
+++ linux-2.4.2-lia/arch/ia64/mm/fault.c	Wed Mar 21 23:17:05 2001
@@ -47,7 +47,7 @@
 ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_re=
gs *regs)
 {
 	struct mm_struct *mm =3D current->mm;
-	const struct exception_table_entry *fix;
+	struct exception_fixup fix;
 	struct vm_area_struct *vma, *prev_vma;
 	struct siginfo si;
 	int signal =3D SIGSEGV;
@@ -163,14 +163,13 @@
 		return;
 	}
=20
+#ifdef GAS_HAS_LOCAL_TAGS
+	fix =3D search_exception_table(regs->cr_iip + ia64_psr(regs)->ri);
+#else
 	fix =3D search_exception_table(regs->cr_iip);
-	if (fix) {
-		regs->r8 =3D -EFAULT;
-		if (fix->skip & 1) {
-			regs->r9 =3D 0;
-		}
-		regs->cr_iip +=3D ((long) fix->skip) & ~15;
-		regs->cr_ipsr &=3D ~IA64_PSR_RI;	/* clear exception slot number */
+#endif
+	if (fix.cont) {
+		handle_exception(regs, fix);
 		return;
 	}
=20
diff -urN --ignore-all-space linux-davidm/arch/ia64/tools/print_offsets.c l=
inux-2.4.2-lia/arch/ia64/tools/print_offsets.c
--- linux-davidm/arch/ia64/tools/print_offsets.c	Wed Mar 21 23:46:40 2001
+++ linux-2.4.2-lia/arch/ia64/tools/print_offsets.c	Wed Mar 21 23:17:18 2001
@@ -46,9 +46,7 @@
     { "IA64_SWITCH_STACK_SIZE",		sizeof (struct switch_stack) },
     { "IA64_SIGINFO_SIZE",		sizeof (struct siginfo) },
     { "IA64_CPU_SIZE",			sizeof (struct cpuinfo_ia64) },
-#ifdef CONFIG_IA64_NEW_UNWIND
     { "UNW_FRAME_INFO_SIZE",		sizeof (struct unw_frame_info) },
-#endif
     { "", 0 },			/* spacer */
     { "IA64_TASK_PTRACE_OFFSET",	offsetof (struct task_struct, ptrace) },
     { "IA64_TASK_SIGPENDING_OFFSET",	offsetof (struct task_struct, sigpend=
ing) },
diff -urN --ignore-all-space linux-davidm/drivers/acpi/common/cmxface.c lin=
ux-2.4.2-lia/drivers/acpi/common/cmxface.c
--- linux-davidm/drivers/acpi/common/cmxface.c	Wed Feb 28 12:57:48 2001
+++ linux-2.4.2-lia/drivers/acpi/common/cmxface.c	Wed Mar 21 23:17:31 2001
@@ -158,7 +158,12 @@
 	if (!(flags & ACPI_NO_ACPI_ENABLE)) {
 		status =3D acpi_enable ();
 		if (ACPI_FAILURE (status)) {
+#define	BIGSUR_WA
+#ifdef	BIGSUR_WA
+			printk("acpi_enable fail:ignored\n");
+#else
 			return (status);
+#endif
 		}
 	}
=20
diff -urN --ignore-all-space linux-davidm/drivers/acpi/resources/rscalc.c l=
inux-2.4.2-lia/drivers/acpi/resources/rscalc.c
--- linux-davidm/drivers/acpi/resources/rscalc.c	Wed Feb 28 12:57:48 2001
+++ linux-2.4.2-lia/drivers/acpi/resources/rscalc.c	Wed Mar 21 23:17:41 2001
@@ -866,7 +866,7 @@
 	}
=20
=20
-	*buffer_size_needed =3D temp_size_needed;
+	*buffer_size_needed =3D temp_size_needed + sizeof(PCI_ROUTING_TABLE);
=20
 	return (AE_OK);
 }
diff -urN --ignore-all-space linux-davidm/drivers/char/Config.in linux-2.4.=
2-lia/drivers/char/Config.in
--- linux-davidm/drivers/char/Config.in	Wed Feb 28 12:57:49 2001
+++ linux-2.4.2-lia/drivers/char/Config.in	Wed Mar 21 23:17:50 2001
@@ -179,6 +179,12 @@
 tristate '/dev/agpgart (AGP Support)' CONFIG_AGP $CONFIG_DRM_AGP
 if [ "$CONFIG_AGP" !=3D "n" ]; then
    bool '  Intel 440LX/BX/GX and I815/I840/I850 support' CONFIG_AGP_INTEL
+   bool '  Intel 460GX support (EXPERIMENTAL)' CONFIG_AGP_I460
+   if [ "$CONFIG_AGP_I460" !=3D "n" ]; then
+	define_bool CONFIG_AGP_PTE_FIXUPS y
+	bool '    Enable Full AGP RQ (Requires BigSur BIOS 99 or Newer)' CONFIG_A=
GP_I460_FULLRQ
+	bool '    AGPGART PTE Fixups (Required and In-Kernel)' CONFIG_AGP_PTE_FIX=
UPS
+   fi
    bool '  Intel I810/I815 (on-board) support' CONFIG_AGP_I810
    bool '  VIA chipset support' CONFIG_AGP_VIA
    bool '  AMD Irongate support' CONFIG_AGP_AMD
diff -urN --ignore-all-space linux-davidm/drivers/char/Makefile linux-2.4.2=
-lia/drivers/char/Makefile
--- linux-davidm/drivers/char/Makefile	Wed Mar 21 23:46:40 2001
+++ linux-2.4.2-lia/drivers/char/Makefile	Wed Mar 21 23:18:12 2001
@@ -160,6 +160,9 @@
 subdir-$(CONFIG_DRM) +=3D drm
 subdir-$(CONFIG_PCMCIA) +=3D pcmcia
 subdir-$(CONFIG_AGP) +=3D agp
+ifeq ($(CONFIG_AGP), m)
+	subdir-y +=3D agp
+endif
=20
 ifeq ($(CONFIG_FTAPE),y)
 obj-y       +=3D ftape/ftape.o
diff -urN --ignore-all-space linux-davidm/drivers/char/agp/Makefile linux-2=
.4.2-lia/drivers/char/agp/Makefile
--- linux-davidm/drivers/char/agp/Makefile	Fri Dec 29 14:07:21 2000
+++ linux-2.4.2-lia/drivers/char/agp/Makefile	Wed Mar 21 23:18:51 2001
@@ -11,6 +11,7 @@
 agpgart-objs :=3D agpgart_fe.o agpgart_be.o
=20
 obj-$(CONFIG_AGP) +=3D agpgart.o
+obj-y +=3D vmmap.o
=20
 include $(TOPDIR)/Rules.make
=20
diff -urN --ignore-all-space linux-davidm/drivers/char/agp/agp.h linux-2.4.=
2-lia/drivers/char/agp/agp.h
--- linux-davidm/drivers/char/agp/agp.h	Wed Feb 28 12:57:50 2001
+++ linux-2.4.2-lia/drivers/char/agp/agp.h	Wed Mar 21 23:19:01 2001
@@ -27,6 +27,8 @@
 #ifndef _AGP_BACKEND_PRIV_H
 #define _AGP_BACKEND_PRIV_H 1
=20
+#include <linux/config.h>
+
 enum aper_size_type {
 	U8_APER_SIZE,
 	U16_APER_SIZE,
@@ -84,8 +86,8 @@
 	void *dev_private_data;
 	struct pci_dev *dev;
 	gatt_mask *masks;
-	unsigned long *gatt_table;
-	unsigned long *gatt_table_real;
+	u32 *gatt_table;
+	u32 *gatt_table_real;
 	unsigned long scratch_page;
 	unsigned long gart_bus_addr;
 	unsigned long gatt_bus_addr;
@@ -110,6 +112,7 @@
 	void (*cleanup) (void);
 	void (*tlb_flush) (agp_memory *);
 	unsigned long (*mask_memory) (unsigned long, int);
+	unsigned long (*unmask_memory) (unsigned long);
 	void (*cache_flush) (void);
 	int (*create_gatt_table) (void);
 	int (*free_gatt_table) (void);
@@ -121,6 +124,11 @@
 	void (*agp_destroy_page) (unsigned long);
 };
=20
+#ifdef CONFIG_AGP_PTE_FIXUPS
+extern void *agp_vmmap(unsigned long offset, unsigned long size);
+extern void agp_vmunmap(void *handle);
+#endif
+
 #define OUTREG32(mmap, addr, val)   __raw_writel((val), (mmap)+(addr))
 #define OUTREG16(mmap, addr, val)   __raw_writew((val), (mmap)+(addr))
 #define OUTREG8 (mmap, addr, val)   __raw_writeb((val), (mmap)+(addr))
@@ -146,6 +154,10 @@
 #define min(a,b)	(((a)<(b))?(a):(b))
 #endif
=20
+#ifndef max
+#define max(a,b)	(((a)>(b))?(a):(b))
+#endif
+
 #define AGPGART_MODULE_NAME	"agpgart"
 #define PFX			AGPGART_MODULE_NAME ": "
=20
@@ -196,6 +208,9 @@
 #ifndef PCI_DEVICE_ID_INTEL_82443GX_1
 #define PCI_DEVICE_ID_INTEL_82443GX_1   0x71a1
 #endif
+#ifndef PCI_DEVICE_ID_INTEL_460GX
+#define PCI_DEVICE_ID_INTEL_460GX	 0x84ea
+#endif
 #ifndef PCI_DEVICE_ID_AMD_IRONGATE_0
 #define PCI_DEVICE_ID_AMD_IRONGATE_0    0x7006
 #endif
@@ -231,6 +246,15 @@
 #define INTEL_AGPCTRL   0xb0
 #define INTEL_NBXCFG    0x50
 #define INTEL_ERRSTS    0x91
+
+/* Intel 460GX Registers */
+#define INTEL_I460_APBASE		0x10
+#define INTEL_I460_BAPBASE		0x98
+#define INTEL_I460_GXBCTL		0xa0
+#define INTEL_I460_AGPSIZ		0xa2
+#define INTEL_I460_ATTBASE		0xfe200000
+#define INTEL_I460_GATT_VALID		(1UL << 24)
+#define INTEL_I460_GATT_COHERENT	(1UL << 25)
=20
 /* intel i840 registers */
 #define INTEL_I840_MCHCFG   0x50
diff -urN --ignore-all-space linux-davidm/drivers/char/agp/agpgart_be.c lin=
ux-2.4.2-lia/drivers/char/agp/agpgart_be.c
--- linux-davidm/drivers/char/agp/agpgart_be.c	Wed Feb 28 12:57:50 2001
+++ linux-2.4.2-lia/drivers/char/agp/agpgart_be.c	Wed Mar 21 23:19:12 2001
@@ -22,6 +22,7 @@
  * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE=20
  * OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  *
+ * 460GX support by Chris Ahna <christopher.j.ahna@intel.com>
  */
 #include <linux/config.h>
 #include <linux/version.h>
@@ -42,6 +43,11 @@
 #include <asm/uaccess.h>
 #include <asm/io.h>
 #include <asm/page.h>
+#ifdef CONFIG_AGP_PTE_FIXUPS
+# include <asm/pgalloc.h>
+# include <asm/pgtable.h>
+# include <asm/smplock.h>
+#endif
=20
 #include <linux/agp_backend.h>
 #include "agp.h"
@@ -56,9 +62,19 @@
 EXPORT_SYMBOL(agp_enable);
 EXPORT_SYMBOL(agp_backend_acquire);
 EXPORT_SYMBOL(agp_backend_release);
+#ifdef CONFIG_AGP_PTE_FIXUPS
+EXPORT_SYMBOL(agp_add_fixup);
+EXPORT_SYMBOL(agp_remove_fixup);
+#endif
=20
 static void flush_cache(void);
=20
+#ifdef CONFIG_AGP_PTE_FIXUPS
+static void agp_fixup_map_list(unsigned long pg_start, unsigned long pg_co=
unt);
+static int agp_vma_fixup(struct vm_area_struct *vma, unsigned long start, =

+				size_t size, unsigned long offset);=20
+#endif
+
 static struct agp_bridge_data agp_bridge;
 static int agp_try_unsupported __initdata =3D 0;
=20
@@ -205,7 +221,8 @@
 	}
 	if (curr->page_count !=3D 0) {
 		for (i =3D 0; i < curr->page_count; i++) {
-			curr->memory[i] &=3D ~(0x00000fff);
+			curr->memory[i] =3D agp_bridge.unmask_memory(
+							curr->memory[i]);
 			agp_bridge.agp_destroy_page((unsigned long)
 					 phys_to_virt(curr->memory[i]));
 		}
@@ -348,6 +365,11 @@
 	}
 	curr->is_bound =3D TRUE;
 	curr->pg_start =3D pg_start;
+
+#ifdef CONFIG_AGP_PTE_FIXUPS
+	agp_fixup_map_list(curr->pg_start, curr->page_count);
+#endif
+
 	return 0;
 }
=20
@@ -366,6 +388,11 @@
 	if (ret_val !=3D 0) {
 		return ret_val;
 	}
+
+#ifdef CONFIG_AGP_PTE_FIXUPS
+	agp_fixup_map_list(curr->pg_start, curr->page_count);
+#endif
+
 	curr->is_bound =3D FALSE;
 	curr->pg_start =3D 0;
 	return 0;
@@ -431,6 +458,21 @@
 			     min((mode & 0xff000000),
 				 min((command & 0xff000000),
 				     (scratch & 0xff000000))));
+			/*
+			 * With BigSur BIOSes older than build 99, chipset
+			 * misconfiguration limits safe RQ depth to 2.
+			 * Only use the expanded queue if the user says so
+			 * in menuconfig.  I don't think this warrants a
+			 * separate agp_enable function for 460 as it is a
+			 * temporary and minor change.
+			 */
+#ifndef CONFIG_AGP_I460_FULLRQ
+			if(agp_bridge.type =3D INTEL_460GX) {=09
+			    command +				((command & ~0xff000000) |
+				 ((0x02 << 24) & 0xff000000));
+			}
+#endif
=20
 			/* disable SBA if it's not supported */
 			if (!((command & 0x00000200) &&
@@ -603,7 +645,7 @@
 	for (page =3D virt_to_page(table); page <=3D virt_to_page(table_end); pag=
e++)
 		set_bit(PG_reserved, &page->flags);
=20
-	agp_bridge.gatt_table_real =3D (unsigned long *) table;
+	agp_bridge.gatt_table_real =3D (u32 *) table;
 	CACHE_FLUSH();
 	agp_bridge.gatt_table =3D ioremap_nocache(virt_to_phys(table),
 					(PAGE_SIZE * (1 << page_order)));
@@ -809,6 +851,11 @@
 	agp_bridge.agp_enable(mode);
 }
=20
+static unsigned long agp_generic_unmask_memory(unsigned long addr)
+{
+	return addr & ~(0x00000fff);
+}
+
 /* End - Generic Agp routines */
=20
 #ifdef CONFIG_AGP_I810
@@ -1073,6 +1120,7 @@
 	agp_bridge.cleanup =3D intel_i810_cleanup;
 	agp_bridge.tlb_flush =3D intel_i810_tlbflush;
 	agp_bridge.mask_memory =3D intel_i810_mask_memory;
+	agp_bridge.unmask_memory =3D agp_generic_unmask_memory;
 	agp_bridge.agp_enable =3D intel_i810_agp_enable;
 	agp_bridge.cache_flush =3D global_cache_flush;
 	agp_bridge.create_gatt_table =3D agp_generic_create_gatt_table;
@@ -1089,6 +1137,991 @@
=20
 #endif /* CONFIG_AGP_I810 */
=20
+#ifdef CONFIG_AGP_I460
+
+/* BIOS configures the chipset so that one of two apbase registers are use=
d */
+static u8 intel_i460_dynamic_apbase =3D 0x10;
+
+/* 460 supports multiple GART page sizes, so GART pageshift is dynamic */ =

+static u8 intel_i460_pageshift =3D 12;
+
+/* To speed mmap fixups, track the last entry used in the GATT. */
+static u32 intel_i460_tog =3D 0;
+
+/* Keep track of which is larger, chipset or kernel page size. */
+static u32 intel_i460_cpk =3D 1;
+
+/* Structure for tracking partial use of 4MB GART pages */
+static u32 **i460_pg_detail =3D NULL;
+static u32 *i460_pg_count =3D NULL;
+
+#define I460_CPAGES_PER_KPAGE (PAGE_SIZE >> intel_i460_pageshift)
+#define I460_KPAGES_PER_CPAGE ((1 << intel_i460_pageshift) >> PAGE_SHIFT)
+
+#define I460_SRAM_IO_DISABLE		(1 << 4)
+#define I460_BAPBASE_ENABLE		(1 << 3)
+#define I460_AGPSIZ_MASK		0x7
+#define I460_4M_PS			(1 << 1)
+
+#define log2(x)				ffz(~(x))
+
+static int intel_i460_fetch_size(void)
+{
+	int i;
+	u8 temp;
+	aper_size_info_8 *values;
+
+	/* Determine the GART page size */
+	pci_read_config_byte(agp_bridge.dev, INTEL_I460_GXBCTL, &temp);
+	intel_i460_pageshift =3D (temp & I460_4M_PS) ? 22 : 12;
+
+	values =3D A_SIZE_8(agp_bridge.aperture_sizes);
+
+	pci_read_config_byte(agp_bridge.dev, INTEL_I460_AGPSIZ, &temp);
+
+	/* Exit now if the IO drivers for the GART SRAMS are turned off */
+	if(temp & I460_SRAM_IO_DISABLE) {
+		printk("[agpgart] GART SRAMS disabled on 460GX chipset\n");
+		printk("[agpgart] AGPGART operation not possible\n");
+		return 0;
+	}
+
+	/* Make sure we don't try to create an 2 ^ 23 entry GATT */
+	if((intel_i460_pageshift =3D 0) && ((temp & I460_AGPSIZ_MASK) =3D 4)) {
+		printk("[agpgart] We can't have a 32GB aperture with 4KB"
+			" GART pages\n");
+		return 0;
+	}
+
+	/* Determine the proper APBASE register */
+	if(temp & I460_BAPBASE_ENABLE)
+		intel_i460_dynamic_apbase =3D INTEL_I460_BAPBASE;
+	else intel_i460_dynamic_apbase =3D INTEL_I460_APBASE;
+
+	for (i =3D 0; i < agp_bridge.num_aperture_sizes; i++) {
+
+		/*
+		 * Dynamically calculate the proper num_entries and page_order=20
+		 * values for the define aperture sizes. Take care not to
+		 * shift off the end of values[i].size.
+		 */=09
+		values[i].num_entries =3D (values[i].size << 8) >>
+						(intel_i460_pageshift - 12);
+		values[i].page_order =3D log2((sizeof(u32)*values[i].num_entries)
+						>> PAGE_SHIFT);
+	}
+
+	for (i =3D 0; i < agp_bridge.num_aperture_sizes; i++) {
+		/* Neglect control bits when matching up size_value */
+		if ((temp & I460_AGPSIZ_MASK) =3D values[i].size_value) {
+			agp_bridge.previous_size +			    agp_bridge.current_size =3D (void *) (=
values + i);
+			agp_bridge.aperture_size_idx =3D i;
+			return values[i].size;
+		}
+	}
+
+	return 0;
+}
+
+/* There isn't anything to do here since 460 has no GART TLB. */=20
+static void intel_i460_tlb_flush(agp_memory * mem)
+{
+	return;
+}
+
+/*
+ * This utility function is needed to prevent corruption of the control bi=
ts
+ * which are stored along with the aperture size in 460's AGPSIZ register
+ */
+static void intel_i460_write_agpsiz(u8 size_value)
+{
+	u8 temp;
+
+	pci_read_config_byte(agp_bridge.dev, INTEL_I460_AGPSIZ, &temp);
+	pci_write_config_byte(agp_bridge.dev, INTEL_I460_AGPSIZ,
+		((temp & ~I460_AGPSIZ_MASK) | size_value));
+}
+
+static void intel_i460_cleanup(void)
+{
+	aper_size_info_8 *previous_size;
+
+	previous_size =3D A_SIZE_8(agp_bridge.previous_size);
+	intel_i460_write_agpsiz(previous_size->size_value);
+
+	if(intel_i460_cpk =3D 0)
+	{
+		vfree(i460_pg_detail);
+		vfree(i460_pg_count);
+	}
+}
+
+
+/* Control bits for Out-Of-GART coherency and Burst Write Combining */
+#define I460_GXBCTL_OOG		(1UL << 0)
+#define I460_GXBCTL_BWC		(1UL << 2)
+
+static int intel_i460_configure(void)
+{
+	union {
+		u32 small[2];
+		u64 large;
+	} temp;
+	u8 scratch;
+	int i;
+
+	aper_size_info_8 *current_size;
+
+	temp.large =3D 0;
+
+	current_size =3D A_SIZE_8(agp_bridge.current_size);
+	intel_i460_write_agpsiz(current_size->size_value);=09
+
+	/*
+	 * Do the necessary rigmarole to read all eight bytes of APBASE.
+	 * This has to be done since the AGP aperture can be above 4GB on
+	 * 460 based systems.
+	 */
+	pci_read_config_dword(agp_bridge.dev, intel_i460_dynamic_apbase,=20
+		&(temp.small[0]));
+	pci_read_config_dword(agp_bridge.dev, intel_i460_dynamic_apbase + 4,
+		&(temp.small[1]));
+
+	/* Clear BAR control bits */
+	agp_bridge.gart_bus_addr =3D temp.large & ~((1UL << 3) - 1);=20
+
+	pci_read_config_byte(agp_bridge.dev, INTEL_I460_GXBCTL, &scratch);
+	pci_write_config_byte(agp_bridge.dev, INTEL_I460_GXBCTL,
+			  (scratch & 0x02) | I460_GXBCTL_OOG | I460_GXBCTL_BWC);
+
+	/*=20
+	 * Initialize partial allocation trackers if a GART page is bigger than
+	 * a kernel page.
+	 */
+	if(I460_CPAGES_PER_KPAGE >=3D 1) {
+		intel_i460_cpk =3D 1;
+	} else {
+		intel_i460_cpk =3D 0;
+
+		i460_pg_detail =3D (void *) vmalloc(sizeof(*i460_pg_detail) *
+					current_size->num_entries);
+		i460_pg_count =3D (void *) vmalloc(sizeof(*i460_pg_count) *
+					current_size->num_entries);
+=09
+		for (i =3D 0; i < current_size->num_entries; i++) {
+			i460_pg_count[i] =3D 0;
+			i460_pg_detail[i] =3D NULL;
+		}
+	}
+
+	return 0;
+}
+
+static int intel_i460_create_gatt_table(void) {
+
+	char *table;
+	int i;
+	int page_order;
+	int num_entries;
+	void *temp;
+	unsigned int read_back;
+
+	/*
+	 * Load up the fixed address of the GART SRAMS which hold our
+	 * GATT table.
+	 */
+	table =3D (char *) __va(INTEL_I460_ATTBASE);
+
+	temp =3D agp_bridge.current_size;
+	page_order =3D A_SIZE_8(temp)->page_order;
+	num_entries =3D A_SIZE_8(temp)->num_entries;
+
+	agp_bridge.gatt_table_real =3D (u32 *) table;
+	agp_bridge.gatt_table =3D ioremap_nocache(virt_to_phys(table),
+		 			     (PAGE_SIZE * (1 << page_order)));
+	agp_bridge.gatt_bus_addr =3D virt_to_phys(agp_bridge.gatt_table_real);
+
+	for (i =3D 0; i < num_entries; i++) {
+		agp_bridge.gatt_table[i] =3D 0;
+	}
+
+	/*=20
+	 * The 460 spec says we have to read the last location written to=20
+	 * make sure that all writes have taken effect
+	 */
+	read_back =3D agp_bridge.gatt_table[i - 1];
+
+	/* Set the Top-Of-GATT to 0 */
+	intel_i460_tog =3D 0;
+
+	return 0;
+}
+
+static int intel_i460_free_gatt_table(void)
+{
+	int num_entries;
+	int i;
+	void *temp;
+	unsigned int read_back;
+
+	temp =3D agp_bridge.current_size;
+
+	num_entries =3D A_SIZE_8(temp)->num_entries;
+
+	for (i =3D 0; i < num_entries; i++) {
+		agp_bridge.gatt_table[i] =3D 0;
+	}
+=09
+	/*=20
+	 * The 460 spec says we have to read the last location written to=20
+	 * make sure that all writes have taken effect
+	 */
+	read_back =3D agp_bridge.gatt_table[i - 1];
+
+	iounmap(agp_bridge.gatt_table);
+	intel_i460_tog =3D 0;
+
+	return 0;
+}
+
+/*
+ * When the Top-Of-GATT is cleared, this routine is called to roll tog back
+ * to point to the last valid GATT entry. This code is needed to traverse
+ * unused portions of the GATT, since we don't know about such gaps in
+ * intel_i460_remove_memory.=20
+ */
+static void intel_i460_rollback_tog(void) {
+
+	while(intel_i460_tog > 0) {
+	=09
+		if(agp_bridge.gatt_table[intel_i460_tog - 1] &
+		      		INTEL_I460_GATT_VALID)
+			return;
+
+		intel_i460_tog--;
+	}
+}
+
+/* These functions are called when PAGE_SIZE exceeds the GART page size */=
=09
+
+static int intel_i460_insert_memory_cpk(agp_memory * mem,
+				     off_t pg_start, int type)
+{
+	int i, j, k, num_entries;
+	void *temp;
+	unsigned int hold;
+	unsigned int read_back;
+
+	/*=20
+	 * The rest of the kernel will compute page offsets in terms of
+	 * PAGE_SIZE.
+	 */
+	pg_start =3D I460_CPAGES_PER_KPAGE * pg_start;
+
+	temp =3D agp_bridge.current_size;
+	num_entries =3D A_SIZE_8(temp)->num_entries;
+
+	if((pg_start + I460_CPAGES_PER_KPAGE * mem->page_count) > num_entries) {
+		printk("[agpgart] Looks like we're out of AGP memory\n");
+		return -EINVAL;
+	}
+
+	j =3D pg_start;
+	while (j < (pg_start + I460_CPAGES_PER_KPAGE * mem->page_count)) {
+		if (!PGE_EMPTY(agp_bridge.gatt_table[j])) {
+			return -EBUSY;
+		}
+		j++;
+	}
+
+	if (mem->is_flushed =3D FALSE) {
+		CACHE_FLUSH();
+		mem->is_flushed =3D TRUE;
+	}
+
+	for (i =3D 0, j =3D pg_start; i < mem->page_count; i++) {
+
+		hold =3D (unsigned int) (mem->memory[i]);
+
+		for (k =3D 0; k < I460_CPAGES_PER_KPAGE; k++, j++, hold++)
+			agp_bridge.gatt_table[j] =3D hold;
+	}
+
+	/*=20
+	 * The 460 spec says we have to read the last location written to=20
+	 * make sure that all writes have taken effect
+	 */
+	read_back =3D agp_bridge.gatt_table[j - 1];
+
+	if(j > intel_i460_tog)
+		intel_i460_tog =3D j;
+
+	return 0;
+}
+
+static int intel_i460_remove_memory_cpk(agp_memory * mem, off_t pg_start,
+				     int type)
+{
+	int i;
+	unsigned int read_back;
+
+	pg_start =3D I460_CPAGES_PER_KPAGE * pg_start;
+
+	for (i =3D pg_start; i < (pg_start + I460_CPAGES_PER_KPAGE *=20
+							mem->page_count); i++)=20
+		agp_bridge.gatt_table[i] =3D 0;
+
+	/*=20
+	 * The 460 spec says we have to read the last location written to=20
+	 * make sure that all writes have taken effect
+	 */
+	read_back =3D agp_bridge.gatt_table[i - 1];
+
+	if(i =3D intel_i460_tog)
+		intel_i460_rollback_tog();
+
+	return 0;
+}
+
+/*
+ * These functions are called when the GART page size exceeds PAGE_SIZE.
+ *
+ * This situation is interesting since AGP memory allocations that are
+ * smaller than a single GART page are possible.  The structures i460_pg_c=
ount
+ * and i460_pg_detail track partial allocation of the large GART pages to
+ * work around this issue.
+ *
+ * i460_pg_count[pg_num] tracks the number of kernel pages in use within
+ * GART page pg_num.  i460_pg_detail[pg_num] is an array containing a
+ * psuedo-GART entry for each of the aforementioned kernel pages.  The who=
le
+ * of i460_pg_detail is equivalent to a giant GATT with page size equal to
+ * that of the kernel.
+ */=09
+
+static void *intel_i460_alloc_large_page(int pg_num)
+{
+	int i;
+	void *bp, *bp_end;
+	struct page *page;
+
+	i460_pg_detail[pg_num] =3D (void *) vmalloc(sizeof(u32) *=20
+							I460_KPAGES_PER_CPAGE);
+
+	if(i460_pg_detail[pg_num] =3D NULL) {
+		printk("[agpgart] Out of memory, we're in trouble...\n");
+		return NULL;
+	}
+
+	for(i =3D 0; i < I460_KPAGES_PER_CPAGE; i++)
+		i460_pg_detail[pg_num][i] =3D 0;
+
+	bp =3D (void *) __get_free_pages(GFP_KERNEL,=20
+					intel_i460_pageshift - PAGE_SHIFT);
+	bp_end =3D bp + ((PAGE_SIZE *=20
+			    (1 << (intel_i460_pageshift - PAGE_SHIFT))) - 1);
+
+	for (page =3D virt_to_page(bp); page <=3D virt_to_page(bp_end); page++)
+	{
+		atomic_inc(&page->count);
+		set_bit(PG_locked, &page->flags);
+		atomic_inc(&agp_bridge.current_memory_agp);
+	}
+
+	return bp;	=09
+}
+
+static void intel_i460_free_large_page(int pg_num, unsigned long addr)
+{
+	struct page *page;
+	void *bp, *bp_end;
+
+	bp =3D (void *) __va(addr);
+	bp_end =3D bp + (PAGE_SIZE *=20
+			(1 << (intel_i460_pageshift - PAGE_SHIFT)));
+
+	vfree(i460_pg_detail[pg_num]);
+	i460_pg_detail[pg_num] =3D NULL;
+
+	for (page =3D virt_to_page(bp); page < virt_to_page(bp_end); page++)
+	{
+		atomic_dec(&page->count);
+		clear_bit(PG_locked, &page->flags);
+		wake_up(&page->wait);
+		atomic_dec(&agp_bridge.current_memory_agp);
+	}
+
+	free_pages((unsigned long) bp, intel_i460_pageshift - PAGE_SHIFT);
+}
+=09
+static int intel_i460_insert_memory_kpc(agp_memory * mem,
+				     off_t pg_start, int type)
+{
+	int i, pg, start_pg, end_pg, start_offset, end_offset, idx;
+	int num_entries;=09
+	void *temp;
+	unsigned int read_back;
+
+	temp =3D agp_bridge.current_size;
+	num_entries =3D A_SIZE_8(temp)->num_entries;
+
+	/* Figure out what pg_start means in terms of our large GART pages */
+	start_pg 	=3D pg_start / I460_KPAGES_PER_CPAGE;
+	start_offset 	=3D pg_start % I460_KPAGES_PER_CPAGE;
+	end_pg 		=3D (pg_start + mem->page_count - 1) /=20
+							I460_KPAGES_PER_CPAGE;
+	end_offset 	=3D (pg_start + mem->page_count - 1) %=20
+							I460_KPAGES_PER_CPAGE;
+
+	if(end_pg > num_entries)
+	{
+		printk("[agpgart] Looks like we're out of AGP memory\n");
+		return -EINVAL;
+	}
+
+	/* Check if the requested region of the aperture is free */
+	for(pg =3D start_pg; pg <=3D end_pg; pg++)
+	{
+		/* Allocate new GART pages if necessary */
+		if(i460_pg_detail[pg] =3D NULL) {
+			agp_bridge.gatt_table[pg] =3D agp_bridge.mask_memory(
+			    (unsigned long) intel_i460_alloc_large_page(pg), 0);
+			read_back =3D agp_bridge.gatt_table[pg];
+		}
+
+		for(idx =3D ((pg =3D start_pg) ? start_offset : 0);
+		    idx < ((pg =3D end_pg) ? (end_offset + 1)=20
+				       : I460_KPAGES_PER_CPAGE);
+		    idx++)=20
+		{
+			if(i460_pg_detail[pg][idx] !=3D 0)
+				return -EBUSY;
+		}
+	}
+	=09
+	if (mem->is_flushed =3D FALSE) {
+		CACHE_FLUSH();
+		mem->is_flushed =3D TRUE;
+	}
+
+	for(pg =3D start_pg, i =3D 0; pg <=3D end_pg; pg++)
+	{
+		for(idx =3D ((pg =3D start_pg) ? start_offset : 0);
+		    idx < ((pg =3D end_pg) ? (end_offset + 1)
+				       : I460_KPAGES_PER_CPAGE);
+		    idx++, i++)
+		{
+			i460_pg_detail[pg][idx] =3D agp_bridge.gatt_table[pg] +=20
+						      ((idx * PAGE_SIZE) >> 12);
+			i460_pg_count[pg]++;
+
+			/* Finally we fill in mem->memory... */
+			mem->memory[i] =3D ((unsigned long) (0xffffff &=20
+						i460_pg_detail[pg][idx])) << 12;
+		}
+	}
+
+	if(end_pg > intel_i460_tog)
+		intel_i460_tog =3D end_pg + 1;
+
+	return 0;
+}
+=09
+static int intel_i460_remove_memory_kpc(agp_memory * mem,
+				     off_t pg_start, int type)
+{
+	int i, pg, start_pg, end_pg, start_offset, end_offset, idx;
+	int num_entries, addr;
+	void *temp;
+	unsigned int read_back;
+
+	temp =3D agp_bridge.current_size;
+	num_entries =3D A_SIZE_8(temp)->num_entries;
+
+	/* Figure out what pg_start means in terms of our large GART pages */
+	start_pg 	=3D pg_start / I460_KPAGES_PER_CPAGE;
+	start_offset 	=3D pg_start % I460_KPAGES_PER_CPAGE;
+	end_pg 		=3D (pg_start + mem->page_count - 1) /=20
+						I460_KPAGES_PER_CPAGE;
+	end_offset 	=3D (pg_start + mem->page_count - 1) %=20
+						I460_KPAGES_PER_CPAGE;
+
+	for(i =3D 0, pg =3D start_pg; pg <=3D end_pg; pg++)
+	{
+		for(idx =3D ((pg =3D start_pg) ? start_offset : 0);
+		    idx < ((pg =3D end_pg) ? (end_offset + 1)
+				       : I460_KPAGES_PER_CPAGE);
+		    idx++, i++)=20
+		{
+			mem->memory[i] =3D 0;
+			i460_pg_detail[pg][idx] =3D 0;
+			i460_pg_count[pg]--;
+		}
+
+		/* Free GART pages if they are unused */
+		if(i460_pg_count[pg] =3D 0) {
+			addr =3D (0xffffff & agp_bridge.gatt_table[pg]) << 12;
+
+			agp_bridge.gatt_table[pg] =3D 0;
+			read_back =3D agp_bridge.gatt_table[pg];
+
+			intel_i460_free_large_page(pg, addr);
+		}
+	}
+	=09
+	if(end_pg =3D intel_i460_tog - 1)
+		intel_i460_rollback_tog();
+
+	return 0;
+}
+
+/* Dummy routines to call the approriate {cpk,kpc} function */
+
+static int intel_i460_insert_memory(agp_memory * mem,
+				     off_t pg_start, int type)
+{
+	if(intel_i460_cpk)
+		return intel_i460_insert_memory_cpk(mem, pg_start, type);
+	else
+		return intel_i460_insert_memory_kpc(mem, pg_start, type);
+}
+
+static int intel_i460_remove_memory(agp_memory * mem,
+				     off_t pg_start, int type)
+{
+	if(intel_i460_cpk)
+		return intel_i460_remove_memory_cpk(mem, pg_start, type);
+	else
+		return intel_i460_remove_memory_kpc(mem, pg_start, type);
+}
+
+/*
+ * This block contains support routines which attempt to circumvent an
+ * extremely "interesting" feature of 460.  On (I think) all other AGP
+ * chipsets, accesses from the processor into the AGP aperture are dutiful=
ly
+ * translated by the AGP bridge.  On 460, only accesses from the
+ * graphics adapter itself are translated.  Accesses into the aperture
+ * from the processor result in master aborts and return all 1's.
+ *
+ * This problem is of course not insurmountable.  The GART just provides
+ * a convenient service, we can always access the physical RAM addresses
+ * that correspond to the different parts of the AGP aperture.  Doing this
+ * via brute force would require graphics applications to track two
+ * different pointers for all memory in the aperture.  The first would be
+ * the address in the aperture, for use by the graphics adapter.  The seco=
nd
+ * would be the corresponding RAM address, for use by processes running on
+ * the host processor.  Making this change would require a pretty thorough
+ * rework of the AGP savvy video drivers that exist today.
+ *
+ * An alternate, more elegant solution is found when one considers using
+ * the processor's virtual addressing mechanisms to emulate GART
+ * translation.  Using this technique, applications could be presented
+ * with a block of virtual memory which represents the AGP aperture.
+ * Accesses to these virtual addresses could then be routed to the
+ * appropriate physical memory through the processor's existing address
+ * translation mechanisms (i.e. page tables, TLBs, etc...).
+ *=20
+ * The following routines try to do what is described above.  There could =
be
+ * some things wrong with this method (I'm not a kernel mm expert),
+ * so suggestions are very welcome.
+ */
+
+#ifdef CONFIG_AGP_PTE_FIXUPS
+
+/*
+ * agp_fixup_entry_t defines the list we'll use to track memory mappings
+ * in the AGP aperture.  We have to do this because maps overlapping with
+ * the aperture must be kept in exact agreement with the current state of
+ * the GART table.  Whenever this driver changes the GART, we can walk this
+ * list and keep all of the maps up to date.  Currently, all maps are
+ * registered through DRM.
+ *
+ * User space maps will be tracked by their corresponding vm_area_struct,
+ * kernel space vmmap's (see vmmap.c) will be tracked by their virtual
+ * address (only one pgd, pgd_offset_k).
+ */
+typedef struct agp_fixup_entry {
+	unsigned long		offset;
+	size_t			size;
+	unsigned long		handle;
+	struct vm_area_struct	*vma;
+	struct agp_fixup_entry  *next;
+} agp_fixup_entry_t;
+
+static agp_fixup_entry_t *agp_fixup_list =3D NULL;
+static spinlock_t agp_fixup_lock =3D SPIN_LOCK_UNLOCKED;
+
+#define RID(_x)		  ((_x) >> 61)
+
+void agp_fixup_map_list(unsigned long pg_offset, unsigned long pg_count)
+{
+	agp_fixup_entry_t *pt;
+	unsigned long offset, size;
+	unsigned long start, end;
+
+	offset =3D agp_bridge.gart_bus_addr + (pg_offset << PAGE_SHIFT);
+	size =3D pg_count << PAGE_SHIFT;
+
+	for (pt =3D agp_fixup_list; pt; pt =3D pt->next) {
+		/* Calculate the overlap */
+		start =3D max(offset, pt->offset);
+		end =3D min(offset + size, pt->offset + pt->size);
+=09
+		/* Perform the fixup if necessary */
+		if(start < end)
+			agp_vma_fixup(pt->vma, (unsigned long) pt->handle +
+			       start - pt->offset, end - start, start);
+	}
+}
+
+void *agp_add_fixup(struct vm_area_struct *vma, unsigned long size,=20
+							unsigned long offset)
+{
+	agp_fixup_entry_t *entry;
+	void *handle;
+
+	if(!(entry =3D kmalloc(sizeof(*entry), GFP_KERNEL))) {
+		printk("[agpgart][%s] out of memory!\n", __FUNCTION__);
+		return NULL;
+	}
+	memset(entry, 0, sizeof(*entry));
+
+	if(vma =3D NULL) {
+		handle =3D agp_vmmap(offset, size);
+	} else {
+		handle =3D (void *) vma->vm_start;
+	}
+
+	spin_lock(&agp_fixup_lock);=09
+	entry->next =3D agp_fixup_list;
+	entry->offset =3D offset;
+	entry->size =3D size;
+	entry->handle =3D (unsigned long) handle;
+	entry->vma =3D vma;
+	agp_fixup_list =3D entry;
+	spin_unlock(&agp_fixup_lock);
+
+	/* Do the initial fixup */
+	agp_vma_fixup(entry->vma, entry->handle, entry->size, entry->offset);
+
+	return handle;
+}
+
+void agp_remove_fixup(struct vm_area_struct *vma, void *handle)
+{
+	agp_fixup_entry_t *pt, *prev;
+
+	if(vma =3D NULL) {
+		if(RID((unsigned long) handle) =3D 5)
+			agp_vmunmap(handle);
+		else {
+			printk("[agpgart][%s] need a vma with non-kernel"
+				"maps!!\n", __FUNCTION__);
+			return;
+		}
+	}
+
+	spin_lock(&agp_fixup_lock);=09
+	for (pt =3D agp_fixup_list, prev =3D NULL; pt; prev =3D pt, pt =3D pt->ne=
xt)
+	{
+		if ((vma =3D NULL && pt->handle =3D ((unsigned long) handle)) ||
+			(pt->vma =3D vma)) {=20
+
+			if (prev) {
+				prev->next =3D pt->next;
+			} else {
+				agp_fixup_list =3D pt->next;
+			}
+
+			kfree(pt);
+			break;
+		}
+	}
+	spin_unlock(&agp_fixup_lock);
+}
+
+/*
+ * Look up and return the pte corresponding to addr.  Take into account th=
at
+ * addr might be part of a vmmap in the vmalloc area.
+ */
+static pte_t * agp_lookup_pte(struct vm_area_struct *vma, unsigned long ad=
dr,=20
+								int kernel) {
+
+	pgd_t			*dir;
+	pmd_t			*pmd;
+	pte_t			*pte;
+
+	if(kernel) {
+		dir =3D pgd_offset_k(addr);
+	} else {
+		dir =3D pgd_offset(vma->vm_mm, addr);
+	}
+
+	pmd =3D pmd_offset(dir, addr);
+
+	if(pmd) {
+		pte =3D pte_offset(pmd, addr);
+
+		if(pte)
+			return pte;
+		else
+			return NULL;
+	} else
+		return NULL;
+}
+
+#define I460_GART_PAGE_MASK ((1UL << 24) - 1)
+#define APER_SIZE	    (((unsigned long)A_SIZE_8(agp_bridge.current_size) \
+						->size) << 20)
+/*=20
+ * Return a GART page number (equivalent to an offset in the GATT) for
+ * address _a.  Don't call this unless you know _a is in the AGP aperture.
+ */
+#define APGN(_a)   	  (((_a) - agp_bridge.gart_bus_addr) >>		\
+						intel_i460_pageshift)
+/*
+ * Return the address' offset within its GART page.
+ */
+#define APGOFF(_a)	  ((_a) & ((1 << intel_i460_pageshift) - 1))
+
+#define HIGH_ENOUGH(addr) ((addr) >=3D agp_bridge.gart_bus_addr)
+#define LOW_ENOUGH(addr)  ((addr) < agp_bridge.gart_bus_addr + APER_SIZE)
+#define IN_APER(addr)     (HIGH_ENOUGH(addr) && LOW_ENOUGH(addr))
+=09
+/*
+ * Do the page table fixup.  This routine walks page by page through the
+ * block of virtual addresses in question and manually alters the
+ * corresponding page table entries so that they point to the appropriate
+ * physical addresses.
+ */
+int agp_vma_fixup(struct vm_area_struct *vma, unsigned long start, size_t =
size,=20
+					unsigned long offset) {
+
+	unsigned long			current_addr;
+	unsigned long			old_pa, new_pa;
+	pte_t				*pte;
+	int				kflag =3D 0;
+	u32				entry;
+	int				num_entries;
+
+	if((start & (~PAGE_MASK)) || (size & (~PAGE_MASK)))
+		return -EINVAL;
+
+	if(!IN_APER(offset))
+		return 0;
+
+	num_entries =3D A_SIZE_8(agp_bridge.current_size)->num_entries;
+
+	/*
+	 * Figure out if start is in the vmalloc area.  This method obviously
+	 * only works on IA-64.
+	 */
+	if(vma =3D NULL) {
+		if(RID(start) =3D 5)
+			kflag =3D 1;
+		else
+			printk("[agpgart][%s] need vma for non-kernel maps!!\n",
+				__FUNCTION__);
+	}
+
+	lock_kernel();
+
+	for(current_addr =3D start;=20
+		((current_addr < start + size) &&=20
+				(APGN(offset) < intel_i460_tog));=20
+		current_addr +=3D PAGE_SIZE, offset +=3D PAGE_SIZE)
+	{
+		pte =3D agp_lookup_pte(vma, current_addr, kflag);
+
+		if(!pte)
+			goto finish_fixup;
+
+		/*
+		 * Look at the pte and the current GART table to determine this
+		 * pte's old target and the current physical page corresponding
+		 * to this offset in the aperture.
+		 */
+
+		old_pa =3D pte_val(*pte) & _PFN_MASK;
+
+		if(intel_i460_cpk)
+			entry =3D agp_bridge.gatt_table[APGN(offset)];
+		else {
+			/*
+			 * We might be fixing up a map that covers unbound
+			 * section of the aperture.  Consequently there's no
+			 * guarantee that i460_pg_detail is valid for this
+			 * section.
+			 */
+			if(i460_pg_detail[APGN(offset)] =3D NULL)
+				entry =3D 0;
+			else
+				entry =3D i460_pg_detail[APGN(offset)]
+					   	[APGOFF(offset) >> PAGE_SHIFT];
+		}
+=09
+		/*
+		 * Handle a valid GATT entry at the current offset=20
+		 */
+		if(entry & INTEL_I460_GATT_VALID) {
+			new_pa =3D (entry & I460_GART_PAGE_MASK) << 12;
+
+			/*
+			 * Only do a fix up if the physical page addressed by
+			 * the GATT entry has changed.
+			 */
+			if(old_pa !=3D new_pa) {
+				/*
+				 * Only decrement reference counts on pages
+				 * of physical memory which appear here due
+				 * to previous fixups.
+				 */
+				if(old_pa !=3D offset)
+					atomic_dec(&virt_to_page(__va(old_pa))
+								->count);
+				/*
+				 * Replace the physical page referenced by pte
+				 * with the new one.
+				 */
+				*pte =3D mk_pte_phys(new_pa,=20
+					__pgprot(pte_val(*pte) & ~_PFN_MASK));
+
+				/*
+				 * Indicate that we're using this page. (This
+				 * really has to be done since __free_pages
+				 * will be called on the page corresponding
+				 * to new_pa when the mmap we're dealing with
+				 * is released).
+				 */
+				atomic_inc(&virt_to_page(__va(new_pa))->count);
+			}
+		/*
+		 * If this pte points somewhere other than its original place
+		 * in the aperture, it has already been fixed up.  Therefore
+		 * the reference count corresponding to old_pa's page has
+		 * been incremented by this routine.  Now that this GATT entry
+		 * has been somehow invalidated, the map we're working with
+		 * no longer needs this page of physical memory.
+		 *
+		 * Decrement the count for old_pa and return this pte to its
+		 * original state (pointing to the aperture).
+		 */=09
+		} else if(old_pa !=3D offset) {
+			atomic_dec(&virt_to_page(__va(old_pa))->count);
+			*pte =3D mk_pte_phys(offset,=20
+				__pgprot(pte_val(*pte) & ~_PFN_MASK));
+		}
+
+		/*
+		 * If we miss the above conditional structure, then we're
+		 * at a point in the map that hasn't been fixed up and
+		 * corresponds to an unbound part of the AGP aperture.
+		 * Continue looping to account for holes of unused space in
+		 * the aperture.
+		 */
+	}
+
+finish_fixup:
+	unlock_kernel();
+	flush_tlb_all();
+	return 0;
+}=20
+
+#endif /* CONFIG_AGP_PTE_FIXUPS */
+
+/*
+ * If the kernel page size is smaller that the chipset page size, we don't
+ * want to allocate memory until we know where it is to be bound in the
+ * aperture (a multi-kernel-page alloc might fit inside of an already
+ * allocated GART page).  Consequently, don't allocate or free anything
+ * if i460_cpk (meaning chipset pages per kernel page) isn't set.
+ *
+ * Let's just hope nobody counts on the allocated AGP memory being there
+ * before bind time (I don't think current drivers do)...
+ */=20
+static unsigned long intel_i460_alloc_page(void)
+{
+	if(intel_i460_cpk)
+		return agp_generic_alloc_page();
+
+	/* Returning NULL would cause problems */
+	return ((unsigned long) __va(0));
+}
+
+static void intel_i460_destroy_page(unsigned long page)
+{
+	if(intel_i460_cpk)
+		agp_generic_destroy_page(page);
+}
+
+static gatt_mask intel_i460_masks[] +{
+	{=20
+	  INTEL_I460_GATT_COHERENT |
+	  INTEL_I460_GATT_VALID,=20
+	  0
+	}
+};
+
+static unsigned long intel_i460_mask_memory(unsigned long addr, int type) =

+{
+	/* Make sure the returned address is a valid GATT entry */
+	return (agp_bridge.masks[0].mask | (((addr &=20
+		     ~((1 << intel_i460_pageshift) - 1)) & 0xffffff000) >> 12));
+}
+
+static unsigned long intel_i460_unmask_memory(unsigned long addr)
+{
+	/* Turn a GATT entry into a physical address */
+	return ((addr & 0xffffff) << 12);
+}
+
+static aper_size_info_8 intel_i460_sizes[3] +{
+	/*=20
+	 * The 32GB aperture is only available with a 4M GART page size.
+	 * Due to the dynamic GART page size, we can't figure out page_order
+	 * or num_entries until runtime.
+	 */
+	{32768, 0, 0, 4},
+	{1024, 0, 0, 2},
+	{256, 0, 0, 1}
+};
+
+static int __init intel_i460_setup (struct pci_dev *pdev)
+{
+
+        agp_bridge.masks =3D intel_i460_masks;
+        agp_bridge.num_of_masks =3D 1;
+        agp_bridge.aperture_sizes =3D (void *) intel_i460_sizes;
+        agp_bridge.size_type =3D U8_APER_SIZE;
+        agp_bridge.num_aperture_sizes =3D 3;
+        agp_bridge.dev_private_data =3D NULL;
+        agp_bridge.needs_scratch_page =3D FALSE;
+        agp_bridge.configure =3D intel_i460_configure;
+        agp_bridge.fetch_size =3D intel_i460_fetch_size;
+        agp_bridge.cleanup =3D intel_i460_cleanup;
+        agp_bridge.tlb_flush =3D intel_i460_tlb_flush;
+        agp_bridge.mask_memory =3D intel_i460_mask_memory;
+        agp_bridge.unmask_memory =3D intel_i460_unmask_memory;
+        agp_bridge.agp_enable =3D agp_generic_agp_enable;
+        agp_bridge.cache_flush =3D global_cache_flush;
+        agp_bridge.create_gatt_table =3D intel_i460_create_gatt_table;
+        agp_bridge.free_gatt_table =3D intel_i460_free_gatt_table;
+        agp_bridge.insert_memory =3D intel_i460_insert_memory;
+        agp_bridge.remove_memory =3D intel_i460_remove_memory;
+        agp_bridge.alloc_by_type =3D agp_generic_alloc_by_type;
+        agp_bridge.free_by_type =3D agp_generic_free_by_type;
+        agp_bridge.agp_alloc_page =3D intel_i460_alloc_page;
+        agp_bridge.agp_destroy_page =3D intel_i460_destroy_page;
+
+        return 0;
+
+        (void) pdev; /* unused */
+}
+
+#endif		/* CONFIG_AGP_I460 */
+
 #ifdef CONFIG_AGP_INTEL
=20
 static int intel_fetch_size(void)
@@ -1265,6 +2298,7 @@
 	agp_bridge.cleanup =3D intel_cleanup;
 	agp_bridge.tlb_flush =3D intel_tlbflush;
 	agp_bridge.mask_memory =3D intel_mask_memory;
+	agp_bridge.unmask_memory =3D agp_generic_unmask_memory;
 	agp_bridge.agp_enable =3D agp_generic_agp_enable;
 	agp_bridge.cache_flush =3D global_cache_flush;
 	agp_bridge.create_gatt_table =3D agp_generic_create_gatt_table;
@@ -1295,6 +2329,7 @@
 	agp_bridge.cleanup =3D intel_cleanup;
 	agp_bridge.tlb_flush =3D intel_tlbflush;
 	agp_bridge.mask_memory =3D intel_mask_memory;
+	agp_bridge.unmask_memory =3D agp_generic_unmask_memory;
 	agp_bridge.agp_enable =3D agp_generic_agp_enable;
 	agp_bridge.cache_flush =3D global_cache_flush;
 	agp_bridge.create_gatt_table =3D agp_generic_create_gatt_table;
@@ -1325,6 +2360,7 @@
 	agp_bridge.cleanup =3D intel_cleanup;
 	agp_bridge.tlb_flush =3D intel_tlbflush;
 	agp_bridge.mask_memory =3D intel_mask_memory;
+	agp_bridge.unmask_memory =3D agp_generic_unmask_memory;
 	agp_bridge.agp_enable =3D agp_generic_agp_enable;
 	agp_bridge.cache_flush =3D global_cache_flush;
 	agp_bridge.create_gatt_table =3D agp_generic_create_gatt_table;
@@ -1442,6 +2478,7 @@
 	agp_bridge.cleanup =3D via_cleanup;
 	agp_bridge.tlb_flush =3D via_tlbflush;
 	agp_bridge.mask_memory =3D via_mask_memory;
+	agp_bridge.unmask_memory =3D agp_generic_unmask_memory;
 	agp_bridge.agp_enable =3D agp_generic_agp_enable;
 	agp_bridge.cache_flush =3D global_cache_flush;
 	agp_bridge.create_gatt_table =3D agp_generic_create_gatt_table;
@@ -1553,6 +2590,7 @@
 	agp_bridge.cleanup =3D sis_cleanup;
 	agp_bridge.tlb_flush =3D sis_tlbflush;
 	agp_bridge.mask_memory =3D sis_mask_memory;
+	agp_bridge.unmask_memory =3D agp_generic_unmask_memory;
 	agp_bridge.agp_enable =3D agp_generic_agp_enable;
 	agp_bridge.cache_flush =3D global_cache_flush;
 	agp_bridge.create_gatt_table =3D agp_generic_create_gatt_table;
@@ -1928,6 +2966,7 @@
 	agp_bridge.cleanup =3D amd_irongate_cleanup;
 	agp_bridge.tlb_flush =3D amd_irongate_tlbflush;
 	agp_bridge.mask_memory =3D amd_irongate_mask_memory;
+	agp_bridge.unmask_memory =3D agp_generic_unmask_memory;
 	agp_bridge.agp_enable =3D agp_generic_agp_enable;
 	agp_bridge.cache_flush =3D global_cache_flush;
 	agp_bridge.create_gatt_table =3D amd_create_gatt_table;
@@ -2171,6 +3210,7 @@
 	agp_bridge.cleanup =3D ali_cleanup;
 	agp_bridge.tlb_flush =3D ali_tlbflush;
 	agp_bridge.mask_memory =3D ali_mask_memory;
+	agp_bridge.unmask_memory =3D agp_generic_unmask_memory;
 	agp_bridge.agp_enable =3D agp_generic_agp_enable;
 	agp_bridge.cache_flush =3D ali_cache_flush;
 	agp_bridge.create_gatt_table =3D agp_generic_create_gatt_table;
@@ -2314,6 +3354,15 @@
 		intel_generic_setup },
 #endif /* CONFIG_AGP_INTEL */
=20
+#ifdef CONFIG_AGP_I460
+	{ PCI_DEVICE_ID_INTEL_460GX,
+		PCI_VENDOR_ID_INTEL,
+		INTEL_460GX,
+		"Intel",
+		"460GX",
+		intel_i460_setup },
+#endif
+
 #ifdef CONFIG_AGP_SIS
 	{ PCI_DEVICE_ID_SI_630,
 		PCI_VENDOR_ID_SI,
@@ -2494,6 +3543,18 @@
 	return -ENODEV;
 }
=20
+static int agp_check_supported_device(struct pci_dev *dev) {
+
+	int i;
+
+	for(i =3D 0; i < ARRAY_SIZE (agp_bridge_info); i++) {
+		if(dev->vendor =3D agp_bridge_info[i].vendor_id &&
+		   dev->device =3D agp_bridge_info[i].device_id)
+			return 1;
+	}
+
+	return 0;
+}
=20
 /* Supported Device Scanning routine */
=20
@@ -2503,8 +3564,14 @@
 	u8 cap_ptr =3D 0x00;
 	u32 cap_id, scratch;
=20
-	if ((dev =3D pci_find_class(PCI_CLASS_BRIDGE_HOST << 8, NULL)) =3D NULL)
+	/*=20
+	 * Some systems have multiple host bridges (i.e. BigSur), so
+	 * we can't just use the first one we find.
+	 */
+	do {
+		if ((dev =3D pci_find_class(PCI_CLASS_BRIDGE_HOST << 8, dev)) =3D NULL)
 		return -ENODEV;
+	} while(!agp_check_supported_device(dev));
=20
 	agp_bridge.dev =3D dev;
=20
@@ -2697,7 +3764,7 @@
 	size_value =3D agp_bridge.fetch_size();
=20
 	if (size_value =3D 0) {
-		printk(KERN_ERR PFX "unable to detrimine aperture size.\n");
+		printk(KERN_ERR PFX "unable to determine aperture size.\n");
 		rc =3D -EINVAL;
 		goto err_out;
 	}
@@ -2770,7 +3837,13 @@
 	&agp_enable,
 	&agp_backend_acquire,
 	&agp_backend_release,
+#ifdef CONFIG_AGP_PTE_FIXUPS
+	&agp_copy_info,
+	&agp_add_fixup,
+	&agp_remove_fixup
+#else
 	&agp_copy_info
+#endif
 };
=20
 static int __init agp_init(void)
diff -urN --ignore-all-space linux-davidm/drivers/char/agp/vmmap.c linux-2.=
4.2-lia/drivers/char/agp/vmmap.c
--- linux-davidm/drivers/char/agp/vmmap.c	Wed Dec 31 16:00:00 1969
+++ linux-2.4.2-lia/drivers/char/agp/vmmap.c	Wed Mar 21 23:19:51 2001
@@ -0,0 +1,231 @@
+/*
+ * vmmap.c
+ *
+ * Hack to allow virtual addressing fixups in the kernel's
+ * vmalloc area.  This is needed so that the page tables in the
+ * kernel's vmalloc area can be used to emulate GART translation
+ * (which sadly isn't done on accesses from the processor in 460GX,
+ * see the comments in the I460 section of the AGPGART driver).
+ *
+ * This file is basically a copy of mm/vmalloc.c modified to not
+ * allocate and free pages.
+ *
+ * Chris Ahna <christopher.j.ahna@intel.com>
+ *
+ */
+
+#include <linux/config.h>
+#include <linux/malloc.h>
+#include <linux/vmalloc.h>
+#include <linux/spinlock.h>
+#include <linux/smp_lock.h>
+#include <linux/agp_backend.h>
+#include <linux/module.h>
+
+#include <asm/uaccess.h>
+#include <asm/pgalloc.h>
+
+#include "agp.h"
+
+#ifdef CONFIG_AGP_PTE_FIXUPS
+EXPORT_SYMBOL(agp_vmmap);
+EXPORT_SYMBOL(agp_vmunmap);
+
+static inline void agp_free_area_pte(pmd_t * pmd, unsigned long address, u=
nsigned long size)
+{
+	pte_t * pte;
+	unsigned long end;
+
+	if (pmd_none(*pmd))
+		return;
+	if (pmd_bad(*pmd)) {
+		pmd_ERROR(*pmd);
+		pmd_clear(pmd);
+		return;
+	}
+	pte =3D pte_offset(pmd, address);
+	address &=3D ~PMD_MASK;
+	end =3D address + size;
+	if (end > PMD_SIZE)
+		end =3D PMD_SIZE;
+	do {
+		pte_t page;
+		page =3D ptep_get_and_clear(pte);
+		address +=3D PAGE_SIZE;
+		pte++;
+		if (pte_none(page) || pte_present(page)) {
+			continue;
+		}
+		printk(KERN_CRIT "Whee.. Swapped out page in kernel page table\n");
+	} while (address < end);
+}
+
+static inline void agp_free_area_pmd(pgd_t * dir, unsigned long address, u=
nsigned long size)
+{
+	pmd_t * pmd;
+	unsigned long end;
+
+	if (pgd_none(*dir))
+		return;
+	if (pgd_bad(*dir)) {
+		pgd_ERROR(*dir);
+		pgd_clear(dir);
+		return;
+	}
+	pmd =3D pmd_offset(dir, address);
+	address &=3D ~PGDIR_MASK;
+	end =3D address + size;
+	if (end > PGDIR_SIZE)
+		end =3D PGDIR_SIZE;
+	do {
+		agp_free_area_pte(pmd, address, end - address);
+		address =3D (address + PMD_SIZE) & PMD_MASK;
+		pmd++;
+	} while (address < end);
+}
+
+void agp_vmfree_area_pages(unsigned long address, unsigned long size)
+{
+	pgd_t * dir;
+	unsigned long end =3D address + size;
+
+	dir =3D pgd_offset_k(address);
+	flush_cache_all();
+	do {
+		agp_free_area_pmd(dir, address, end - address);
+		address =3D (address + PGDIR_SIZE) & PGDIR_MASK;
+		dir++;
+	} while (address && (address < end));
+	flush_tlb_all();
+}
+
+static inline int agp_alloc_area_pte (pte_t * pte, unsigned long address,
+			unsigned long size, unsigned long target, pgprot_t prot)
+{
+	unsigned long end;
+
+	address &=3D ~PMD_MASK;
+	end =3D address + size;
+	if (end > PMD_SIZE)
+		end =3D PMD_SIZE;
+	target =3D (unsigned long) __va(target);
+	do {
+		struct page * page;
+		if (!pte_none(*pte))
+			printk(KERN_ERR "alloc_area_pte: page already exists\n");
+		page =3D virt_to_page(target);
+		if (!page)
+			return -ENOMEM;
+		set_pte(pte, mk_pte(page, prot));
+		address +=3D PAGE_SIZE;
+		target +=3D PAGE_SIZE;
+		pte++;
+	} while (address < end);
+	return 0;
+}
+
+static inline int agp_alloc_area_pmd(pmd_t * pmd, unsigned long address, u=
nsigned long size, unsigned long target, pgprot_t prot)
+{
+	unsigned long end;
+
+	address &=3D ~PGDIR_MASK;
+	end =3D address + size;
+	if (end > PGDIR_SIZE)
+		end =3D PGDIR_SIZE;
+	do {
+		pte_t * pte =3D pte_alloc_kernel(pmd, address);
+		if (!pte)
+			return -ENOMEM;
+		if (agp_alloc_area_pte(pte, address, end - address, target, prot))
+			return -ENOMEM;
+		target +=3D ((address + PMD_SIZE) & PMD_MASK) - address;
+		address =3D (address + PMD_SIZE) & PMD_MASK;
+		pmd++;
+	} while (address < end);
+	return 0;
+}
+
+inline int agp_vmalloc_area_pages (unsigned long address, unsigned long si=
ze,
+                               unsigned long target, pgprot_t prot)
+{
+	pgd_t * dir;
+	unsigned long end =3D address + size;
+	int ret;
+
+	dir =3D pgd_offset_k(address);
+	flush_cache_all();
+	lock_kernel();
+	do {
+		pmd_t *pmd;
+	=09
+		pmd =3D pmd_alloc_kernel(dir, address);
+		ret =3D -ENOMEM;
+		if (!pmd)
+			break;
+
+		ret =3D -ENOMEM;
+		if (agp_alloc_area_pmd(pmd, address, end - address, target, prot))
+			break;
+
+		target +=3D ((address + PGDIR_SIZE) & PGDIR_MASK) - address;
+		address =3D (address + PGDIR_SIZE) & PGDIR_MASK;
+		dir++;
+
+		ret =3D 0;
+	} while (address && (address < end));
+	unlock_kernel();
+	flush_tlb_all();
+	return ret;
+}
+
+void agp_vmunmap(void *addr)
+{
+	struct vm_struct **p, *tmp;
+
+	if (!addr)
+		return;
+	if ((PAGE_SIZE-1) & (unsigned long) addr) {
+		printk(KERN_ERR "Trying to vfree() bad address (%p)\n", addr);
+		return;
+	}
+	write_lock(&vmlist_lock);
+	for (p =3D &vmlist ; (tmp =3D *p) ; p =3D &tmp->next) {
+		if (tmp->addr =3D addr) {
+			*p =3D tmp->next;
+			agp_vmfree_area_pages(VMALLOC_VMADDR(tmp->addr), tmp->size);
+			kfree(tmp);
+			write_unlock(&vmlist_lock);
+			return;
+		}
+	}
+	write_unlock(&vmlist_lock);
+	printk(KERN_ERR "Trying to vfree() nonexistent vm area (%p)\n", addr);
+}
+
+void *__agp_vmmap (unsigned long size, unsigned long target, pgprot_t prot)
+{
+	void * addr;
+	struct vm_struct *area;
+
+	size =3D PAGE_ALIGN(size);
+	if (!size) {
+		BUG();
+		return NULL;
+	}
+	area =3D get_vm_area(size, VM_ALLOC);
+	if (!area)
+		return NULL;
+	addr =3D area->addr;
+	if (agp_vmalloc_area_pages(VMALLOC_VMADDR(addr), size, target, prot)) {
+		vfree(addr);
+		return NULL;
+	}
+
+	return addr;
+}
+
+void *agp_vmmap(unsigned long offset, unsigned long size)
+{
+	return __agp_vmmap(size, offset, PAGE_KERNEL);
+}
+#endif /* CONFIG_AGP_PTE_FIXUPS */
diff -urN --ignore-all-space linux-davidm/drivers/char/drm/agpsupport.c lin=
ux-2.4.2-lia/drivers/char/drm/agpsupport.c
--- linux-davidm/drivers/char/drm/agpsupport.c	Thu Nov 16 14:05:49 2000
+++ linux-2.4.2-lia/drivers/char/drm/agpsupport.c	Wed Mar 21 23:21:29 2001
@@ -30,6 +30,7 @@
=20
 #define __NO_VERSION__
 #include "drmP.h"
+#include <linux/config.h>
 #include <linux/module.h>
 #if LINUX_VERSION_CODE < 0x020400
 #include "agpsupport-pre24.h"
@@ -40,6 +41,11 @@
=20
 static const drm_agp_t *drm_agp =3D NULL;
=20
+#ifdef CONFIG_AGP_PTE_FIXUPS
+unsigned long		drm_agp_aper_base =3D 0;
+unsigned long		drm_agp_aper_size =3D 0;
+#endif
+
 int drm_agp_info(struct inode *inode, struct file *filp, unsigned int cmd,
 		 unsigned long arg)
 {
@@ -192,6 +198,19 @@
 	return drm_unbind_agp(entry->memory);
 }
=20
+#ifdef CONFIG_AGP_PTE_FIXUPS
+void *drm_agp_add_fixup(struct vm_area_struct *vma, size_t size,
+				unsigned long offset)
+{
+	return drm_agp->add_fixup(vma, size, offset);
+}
+
+void drm_agp_remove_fixup(struct vm_area_struct *vma, void *handle)=20
+{
+	drm_agp->remove_fixup(vma, handle);
+}
+#endif /* CONFIG_AGP_PTE_FIXUPS */
+
 int drm_agp_bind(struct inode *inode, struct file *filp, unsigned int cmd,
 		 unsigned long arg)
 {
@@ -264,6 +283,7 @@
 #if LINUX_VERSION_CODE >=3D 0x020400
 		case INTEL_I840:	head->chipset =3D "Intel i840";    break;
 #endif
+		case INTEL_460GX:	head->chipset =3D "Intel 460GX";	 break;
=20
 		case VIA_GENERIC:	head->chipset =3D "VIA";           break;
 		case VIA_VP3:		head->chipset =3D "VIA VP3";       break;
@@ -292,6 +312,12 @@
 			 head->chipset,
 			 head->agp_info.aper_base,
 			 head->agp_info.aper_size);
+
+#ifdef CONFIG_AGP_PTE_FIXUPS
+		drm_agp_aper_base =3D head->agp_info.aper_base;
+		drm_agp_aper_size =3D ((unsigned long) head->agp_info.aper_size)
+								 << 20;
+#endif
 	}
 	return head;
 }
diff -urN --ignore-all-space linux-davidm/drivers/char/drm/bufs.c linux-2.4=
.2-lia/drivers/char/drm/bufs.c
--- linux-davidm/drivers/char/drm/bufs.c	Tue Aug 29 14:09:15 2000
+++ linux-2.4.2-lia/drivers/char/drm/bufs.c	Wed Mar 21 23:21:41 2001
@@ -73,7 +73,7 @@
 	switch (map->type) {
 	case _DRM_REGISTERS:
 	case _DRM_FRAME_BUFFER:
-#ifndef __sparc__
+#if !defined(__sparc__) && !defined(__ia64__)
 		if (map->offset + map->size < map->offset
 		    || map->offset < virt_to_phys(high_memory)) {
 			drm_free(map, sizeof(*map), DRM_MEM_MAPS);
diff -urN --ignore-all-space linux-davidm/drivers/char/drm/drmP.h linux-2.4=
.2-lia/drivers/char/drm/drmP.h
--- linux-davidm/drivers/char/drm/drmP.h	Sun Dec 31 11:17:22 2000
+++ linux-2.4.2-lia/drivers/char/drm/drmP.h	Wed Mar 21 23:21:59 2001
@@ -293,6 +293,20 @@
 #define DRM_BUFCOUNT(x) ((x)->count - DRM_LEFTCOUNT(x))
 #define DRM_WAITCOUNT(dev,idx) DRM_BUFCOUNT(&dev->queuelist[idx]->waitlist)
=20
+#ifdef CONFIG_AGP_PTE_FIXUPS
+# define HIGH_ENOUGH(addr)    ((addr) >=3D drm_agp_aper_base)
+# define LOW_ENOUGH(addr)     ((addr) < drm_agp_aper_base + drm_agp_aper_s=
ize)
+# define IN_APER(addr)	      (HIGH_ENOUGH(addr) && LOW_ENOUGH(addr))
+# define RID(_x)	      ((_x) >> 61)
+# define IOREMAP_SAFE(_x, _y) (IN_APER(_x) ? drm_agp_add_fixup(NULL, _y, _=
x) \
+							: ioremap(_x, _y))
+# define IOUNMAP_SAFE(_x)     ((RID((unsigned long) (_x)) =3D 5) ? \
+				   drm_agp_remove_fixup(NULL, _x) : iounmap(_x))
+#else
+# define IOREMAP_SAFE(_x, _y)	ioremap(_x, _y)
+# define IOUNMAP_SAFE(_x)	iounmap(_x)
+#endif
+
 typedef int drm_ioctl_t(struct inode *inode, struct file *filp,
 			unsigned int cmd, unsigned long arg);
=20
@@ -605,6 +619,14 @@
 	sigset_t          sigmask;
 } drm_device_t;
=20
+#ifdef CONFIG_AGP_PTE_FIXUPS
+/*
+ * We need these to determine if addresses are in the aperture when we don=
't
+ * have access to the drm_device_t structure.
+ */
+extern unsigned long drm_agp_aper_base;
+extern unsigned long drm_agp_aper_size;
+#endif
=20
 				/* Internal function definitions */
=20
@@ -830,6 +852,12 @@
 extern int            drm_agp_free_memory(agp_memory *handle);
 extern int            drm_agp_bind_memory(agp_memory *handle, off_t start);
 extern int            drm_agp_unbind_memory(agp_memory *handle);
+#ifdef CONFIG_AGP_PTE_FIXUPS
+extern void           *drm_agp_add_fixup(struct vm_area_struct *vma,
+			       size_t size, unsigned long offset);
+extern void           drm_agp_remove_fixup(struct vm_area_struct *vma,
+			       void *handle);
+#endif
 #endif
 #endif
 #endif
diff -urN --ignore-all-space linux-davidm/drivers/char/drm/memory.c linux-2=
.4.2-lia/drivers/char/drm/memory.c
--- linux-davidm/drivers/char/drm/memory.c	Thu Nov 16 14:05:49 2000
+++ linux-2.4.2-lia/drivers/char/drm/memory.c	Wed Mar 21 23:23:22 2001
@@ -306,7 +306,7 @@
 		return NULL;
 	}
 =09
-	if (!(pt =3D ioremap(offset, size))) {
+	if (!(pt =3D IOREMAP_SAFE(offset, size))) {
 		spin_lock(&drm_mem_lock);
 		++drm_mem_stats[DRM_MEM_MAPPINGS].fail_count;
 		spin_unlock(&drm_mem_lock);
@@ -328,7 +328,7 @@
 		DRM_MEM_ERROR(DRM_MEM_MAPPINGS,
 			      "Attempt to free NULL pointer\n");
 	else
-		iounmap(pt);
+		IOUNMAP_SAFE(pt);
 =09
 	spin_lock(&drm_mem_lock);
 	drm_mem_stats[DRM_MEM_MAPPINGS].bytes_freed +=3D size;
diff -urN --ignore-all-space linux-davidm/drivers/char/drm/mga_dma.c linux-=
2.4.2-lia/drivers/char/drm/mga_dma.c
--- linux-davidm/drivers/char/drm/mga_dma.c	Mon Dec 11 12:39:44 2000
+++ linux-2.4.2-lia/drivers/char/drm/mga_dma.c	Wed Mar 21 23:23:33 2001
@@ -673,6 +673,8 @@
 	drm_mga_private_t *dev_priv;
 	drm_map_t *sarea_map =3D NULL;
=20
+	u32 status_page_flag =3D 0;
+
 	dev_priv =3D drm_alloc(sizeof(drm_mga_private_t), DRM_MEM_DRIVER);
 	if(dev_priv =3D NULL) return -ENOMEM;
 	dev->dev_private =3D (void *) dev_priv;
@@ -741,10 +743,21 @@
 		return -ENOMEM;
 	}
=20
+	/*
+	 * Make sure we don't ask the G400 to do reads and writes above
+	 * 4GB for status information.
+	 */
+	if((sizeof(void *) =3D 8) &&=20
+			(((unsigned long) virt_to_phys(high_memory)) >=3D (1UL << 32))) {
+		status_page_flag =3D 0x00000000;
+	} else {
+		status_page_flag =3D 0x00000003;
+	}
+
    	/* Write status page when secend or softrap occurs */
    	MGA_WRITE(MGAREG_PRIMPTR,
-		  virt_to_bus((void *)dev_priv->real_status_page) | 0x00000003);
-
+		  virt_to_bus((void *)dev_priv->real_status_page) |=20
+		      					status_page_flag);
=20
 	/* Private is now filled in, initialize the hardware */
 	{
diff -urN --ignore-all-space linux-davidm/drivers/char/drm/mga_drv.h linux-=
2.4.2-lia/drivers/char/drm/mga_drv.h
--- linux-davidm/drivers/char/drm/mga_drv.h	Thu Jan  4 22:40:11 2001
+++ linux-2.4.2-lia/drivers/char/drm/mga_drv.h	Wed Mar 21 23:23:58 2001
@@ -295,7 +295,7 @@
 		       num_dwords + 1 + outcount, ADRINDEX(reg), val);	\
 	if( ++outcount =3D 4) {						\
 		outcount =3D 0;						\
-		dma_ptr[0] =3D *(unsigned long *)tempIndex;		\
+		dma_ptr[0] =3D *(u32 *)tempIndex;				\
 		dma_ptr+=3D5;						\
 		num_dwords +=3D 5;					\
 	}								\
diff -urN --ignore-all-space linux-davidm/drivers/char/drm/r128_cce.c linux=
-2.4.2-lia/drivers/char/drm/r128_cce.c
--- linux-davidm/drivers/char/drm/r128_cce.c	Thu Jan  4 22:40:11 2001
+++ linux-2.4.2-lia/drivers/char/drm/r128_cce.c	Wed Mar 21 23:24:08 2001
@@ -229,7 +229,17 @@
 	int i;
=20
 	for ( i =3D 0 ; i < dev_priv->usec_timeout ; i++ ) {
-		if ( *dev_priv->ring.head =3D dev_priv->ring.tail ) {
+		/*
+		 * XXX - this is (I think) a 460GX specific hack
+		 *
+		 * When doing texturing, ring.tail sometimes gets ahead of
+		 * PM4_BUFFER_DL_WPTR by 2; consequently, the card processes
+		 * its whole quota of instructions and *ring.head is still 2
+		 * short of ring.tail.  Work around this for now in lieu of
+		 * a better solution.
+		 */
+		if ( (*dev_priv->ring.head =3D dev_priv->ring.tail) ||
+			((dev_priv->ring.tail - *dev_priv->ring.head) =3D 2) ) {
 			int pm4stat =3D R128_READ( R128_PM4_STAT );
 			if ( ( (pm4stat & R128_PM4_FIFOCNT_MASK) > 			       dev_priv->cce_fifo=
_size ) &&
@@ -342,10 +352,20 @@
 	R128_WRITE( R128_PM4_BUFFER_DL_WPTR, 0 );
 	R128_WRITE( R128_PM4_BUFFER_DL_RPTR, 0 );
=20
-	/* DL_RPTR_ADDR is a physical address in AGP space. */
+	/*
+	 * XXX - This is a 460GX specific hack
+	 *
+	 * We have to hack this right now.  460GX isn't claiming PCI writes
+	 * from the card into the AGP aperture.  Because of this, we have
+	 * to get space outside of the aperture for RPTR_ADDR.
+	 */
+	dev_priv->ring.head =3D (void *) __get_free_page(GFP_KERNEL);
+	atomic_inc(&virt_to_page(dev_priv->ring.head)->count);
+	set_bit(PG_locked, &virt_to_page(dev_priv->ring.head)->flags);
+	dev_priv->ring.head =3D __va(dev_priv->ring.head);
+
 	*dev_priv->ring.head =3D 0;
-	R128_WRITE( R128_PM4_BUFFER_DL_RPTR_ADDR,
-		    dev_priv->ring_rptr->offset );
+	R128_WRITE(R128_PM4_BUFFER_DL_RPTR_ADDR, __pa(dev_priv->ring.head));
=20
 	/* Set watermark control */
 	R128_WRITE( R128_PM4_BUFFER_WM_CNTL,
@@ -530,6 +550,14 @@
 		}
 #endif
=20
+		/*
+		 * Free the page we grabbed for RPTR_ADDR
+		 */
+		atomic_dec(&virt_to_page(dev_priv->ring.head)->count);
+		clear_bit(PG_locked, &virt_to_page(dev_priv->ring.head)->flags);
+		wake_up(&virt_to_page(dev_priv->ring.head)->wait);
+		free_page((unsigned long) dev_priv->ring.head);
+	=09
 		drm_free( dev->dev_private, sizeof(drm_r128_private_t),
 			  DRM_MEM_DRIVER );
 		dev->dev_private =3D NULL;
diff -urN --ignore-all-space linux-davidm/drivers/char/drm/r128_drv.h linux=
-2.4.2-lia/drivers/char/drm/r128_drv.h
--- linux-davidm/drivers/char/drm/r128_drv.h	Thu Jan  4 22:40:11 2001
+++ linux-2.4.2-lia/drivers/char/drm/r128_drv.h	Wed Mar 21 23:24:21 2001
@@ -385,7 +385,7 @@
 #define R128_MAX_VB_VERTS		(0xffff)
=20
=20
-#define R128_BASE(reg)		((u32)(dev_priv->mmio->handle))
+#define R128_BASE(reg)		((unsigned long)(dev_priv->mmio->handle))
 #define R128_ADDR(reg)		(R128_BASE(reg) + reg)
=20
 #define R128_DEREF(reg)		*(__volatile__ int *)R128_ADDR(reg)
diff -urN --ignore-all-space linux-davidm/drivers/char/drm/radeon_cp.c linu=
x-2.4.2-lia/drivers/char/drm/radeon_cp.c
--- linux-davidm/drivers/char/drm/radeon_cp.c	Tue Jan 30 10:43:27 2001
+++ linux-2.4.2-lia/drivers/char/drm/radeon_cp.c	Wed Mar 21 23:24:32 2001
@@ -592,10 +592,23 @@
 	/* Initialize the ring buffer's read and write pointers */
 	cur_read_ptr =3D RADEON_READ( RADEON_CP_RB_RPTR );
 	RADEON_WRITE( RADEON_CP_RB_WPTR, cur_read_ptr );
+
+	/*
+	 * XXX - This is a 460GX specific hack
+	 *
+	 * We have to hack this right now.  The GXB isn't claiming PCI writes
+	 * from the card into the AGP aperture.  Because of this, we have
+	 * to get space outside of the aperture for RPTR_ADDR.
+	 */
+	dev_priv->ring.head =3D (void *) __get_free_page(GFP_KERNEL);
+	atomic_inc(&virt_to_page(dev_priv->ring.head)->count);
+	set_bit(PG_locked, &virt_to_page(dev_priv->ring.head)->flags);
+	dev_priv->ring.head =3D __va(dev_priv->ring.head);
+
 	*dev_priv->ring.head =3D cur_read_ptr;
 	dev_priv->ring.tail =3D cur_read_ptr;
=20
-	RADEON_WRITE( RADEON_CP_RB_RPTR_ADDR, dev_priv->ring_rptr->offset );
+	RADEON_WRITE(RADEON_CP_RB_RPTR_ADDR, __pa(dev_priv->ring.head));
=20
 	/* Set ring buffer size */
 	RADEON_WRITE( RADEON_CP_RB_CNTL, dev_priv->ring.size_l2qw );
@@ -837,6 +850,14 @@
 		}
 #endif
=20
+		/*
+		 * Free the page we grabbed for RPTR_ADDR.
+		 */
+		atomic_dec(&virt_to_page(dev_priv->ring.head)->count);
+		clear_bit(PG_locked, &virt_to_page(dev_priv->ring.head)->flags);
+		wake_up(&virt_to_page(dev_priv->ring.head)->wait);
+		free_page((unsigned long) dev_priv->ring.head);
+	=09
 		drm_free( dev->dev_private, sizeof(drm_radeon_private_t),
 			  DRM_MEM_DRIVER );
 		dev->dev_private =3D NULL;
diff -urN --ignore-all-space linux-davidm/drivers/char/drm/radeon_drv.h lin=
ux-2.4.2-lia/drivers/char/drm/radeon_drv.h
--- linux-davidm/drivers/char/drm/radeon_drv.h	Tue Jan 30 10:43:27 2001
+++ linux-2.4.2-lia/drivers/char/drm/radeon_drv.h	Wed Mar 21 23:24:45 2001
@@ -535,7 +535,7 @@
 #define RADEON_MAX_VB_VERTS		(0xffff)
=20
=20
-#define RADEON_BASE(reg)	((u32)(dev_priv->mmio->handle))
+#define RADEON_BASE(reg)	((unsigned long)(dev_priv->mmio->handle))
 #define RADEON_ADDR(reg)	(RADEON_BASE(reg) + reg)
=20
 #define RADEON_DEREF(reg)	*(__volatile__ u32 *)RADEON_ADDR(reg)
diff -urN --ignore-all-space linux-davidm/drivers/char/drm/vm.c linux-2.4.2=
-lia/drivers/char/drm/vm.c
--- linux-davidm/drivers/char/drm/vm.c	Wed Mar 21 23:46:40 2001
+++ linux-2.4.2-lia/drivers/char/drm/vm.c	Wed Mar 21 23:25:22 2001
@@ -30,6 +30,7 @@
  */
=20
 #define __NO_VERSION__
+#include <linux/config.h>
 #include "drmP.h"
=20
 struct vm_operations_struct   drm_vm_ops =3D {
@@ -200,6 +201,12 @@
 		up(&dev->struct_sem);
 	}
 #endif
+
+#ifdef CONFIG_AGP_PTE_FIXUPS
+	if(IN_APER(VM_OFFSET(vma)))
+		drm_agp_add_fixup(vma, vma->vm_end - vma->vm_start,=20
+							VM_OFFSET(vma));
+#endif
 }
=20
 void drm_vm_close(struct vm_area_struct *vma)
@@ -231,6 +238,11 @@
 		}
 	}
 	up(&dev->struct_sem);
+#endif
+
+#ifdef CONFIG_AGP_PTE_FIXUPS
+	if(IN_APER(VM_OFFSET(vma)))
+		drm_agp_remove_fixup(vma, (void *) vma->vm_start);
 #endif
 }
=20
diff -urN --ignore-all-space linux-davidm/fs/exec.c linux-2.4.2-lia/fs/exec=
.c
--- linux-davidm/fs/exec.c	Wed Feb 28 12:58:16 2001
+++ linux-2.4.2-lia/fs/exec.c	Wed Mar 21 23:25:45 2001
@@ -150,7 +150,7 @@
 }
=20
 /*
- * count() counts the number of arguments/envelopes
+ * count() counts the number of strings in array ARGV.
  */
 static int count(char ** argv, int max)
 {
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/asmmacro.h linux=
-2.4.2-lia/include/asm-ia64/asmmacro.h
--- linux-davidm/include/asm-ia64/asmmacro.h	Fri Aug 11 19:09:06 2000
+++ linux-2.4.2-lia/include/asm-ia64/asmmacro.h	Wed Mar 21 23:26:04 2001
@@ -2,25 +2,9 @@
 #define _ASM_IA64_ASMMACRO_H
=20
 /*
- * Copyright (C) 2000 Hewlett-Packard Co
- * Copyright (C) 2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 2000-2001 Hewlett-Packard Co
+ * Copyright (C) 2000-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
-
-#if 1
-
-/*
- * This is a hack that's necessary as long as we support old versions
- * of gas, that have no unwind support.
- */
-#include <linux/config.h>
-
-#ifdef CONFIG_IA64_NEW_UNWIND
-# define UNW(args...)	args
-#else
-# define UNW(args...)
-#endif
-
-#endif
=20
 #define ENTRY(name)				\
 	.align 32;				\
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/efi.h linux-2.4.=
2-lia/include/asm-ia64/efi.h
--- linux-davidm/include/asm-ia64/efi.h	Wed Mar 21 23:46:40 2001
+++ linux-2.4.2-lia/include/asm-ia64/efi.h	Wed Mar 21 23:26:14 2001
@@ -20,9 +20,12 @@
 #include <asm/system.h>
=20
 #define EFI_SUCCESS		0
-#define EFI_INVALID_PARAMETER	2
-#define EFI_UNSUPPORTED		3
-#define EFI_BUFFER_TOO_SMALL	4
+#define EFI_LOAD_ERROR          (1L | (1L << 63))
+#define EFI_INVALID_PARAMETER	(2L | (1L << 63))
+#define EFI_UNSUPPORTED		(3L | (1L << 63))
+#define EFI_BAD_BUFFER_SIZE     (4L | (1L << 63))
+#define EFI_BUFFER_TOO_SMALL	(5L | (1L << 63))
+#define EFI_NOT_FOUND          (14L | (1L << 63))
=20
 typedef unsigned long efi_status_t;
 typedef u8 efi_bool_t;
@@ -234,5 +237,13 @@
 extern void efi_memmap_walk (efi_freemem_callback_t callback, void *arg);
 extern void efi_gettimeofday (struct timeval *tv);
 extern void efi_enter_virtual_mode (void);	/* switch EFI to virtual mode, =
if possible */
+
+
+/*
+ * Variable Attributes
+ */
+#define EFI_VARIABLE_NON_VOLATILE       0x0000000000000001
+#define EFI_VARIABLE_BOOTSERVICE_ACCESS 0x0000000000000002
+#define EFI_VARIABLE_RUNTIME_ACCESS     0x0000000000000004
=20
 #endif /* _ASM_IA64_EFI_H */
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/module.h linux-2=
.4.2-lia/include/asm-ia64/module.h
--- linux-davidm/include/asm-ia64/module.h	Thu Jan  4 22:40:20 2001
+++ linux-2.4.2-lia/include/asm-ia64/module.h	Wed Mar 21 23:26:39 2001
@@ -35,7 +35,6 @@
 static inline int
 ia64_module_init(struct module *mod)
 {
-#ifdef CONFIG_IA64_NEW_UNWIND
 	struct archdata *archdata;
=20
 	if (!mod_member_present(mod, archdata_start) || !mod->archdata_start)
@@ -79,14 +78,12 @@
 						   (unsigned long) archdata->segment_base,
 						   (unsigned long) archdata->gp,
 						   archdata->unw_start, archdata->unw_end);
-#endif /* CONFIG_IA64_NEW_UNWIND */
 	return 0;
 }
=20
 static inline void
 ia64_module_unmap(void * addr)
 {
-#ifdef CONFIG_IA64_NEW_UNWIND
 	struct module *mod =3D (struct module *) addr;
 	struct archdata *archdata;
=20
@@ -100,7 +97,6 @@
 		if (archdata->unw_table !=3D NULL)
 			unw_remove_unwind_table((void *) archdata->unw_table);
 	}
-#endif /* CONFIG_IA64_NEW_UNWIND */
=20
 	vfree(addr);
 }
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/ptrace.h linux-2=
.4.2-lia/include/asm-ia64/ptrace.h
--- linux-davidm/include/asm-ia64/ptrace.h	Thu Jan  4 22:40:20 2001
+++ linux-2.4.2-lia/include/asm-ia64/ptrace.h	Wed Mar 21 23:26:51 2001
@@ -2,8 +2,8 @@
 #define _ASM_IA64_PTRACE_H
=20
 /*
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1998, 1999 Stephane Eranian <eranian@hpl.hp.com>
  *
  * 12/07/98	S. Eranian	added pt_regs & switch_stack
@@ -225,17 +225,10 @@
   extern void ia64_flush_fph (struct task_struct *t);
   extern void ia64_sync_fph (struct task_struct *t);
=20
-#ifdef CONFIG_IA64_NEW_UNWIND
   /* get nat bits for scratch registers such that bit N=3D1 iff scratch re=
gister rN is a NaT */
   extern unsigned long ia64_get_scratch_nat_bits (struct pt_regs *pt, unsi=
gned long scratch_unat);
   /* put nat bits for scratch registers such that scratch register rN is a=
 NaT iff bit N=3D1 */
   extern unsigned long ia64_put_scratch_nat_bits (struct pt_regs *pt, unsi=
gned long nat);
-#else
-  /* get nat bits for r1-r31 such that bit N=3D1 iff rN is a NaT */
-  extern long ia64_get_nat_bits (struct pt_regs *pt, struct switch_stack *=
sw);
-  /* put nat bits for r1-r31 such that rN is a NaT iff bit N=3D1 */
-  extern void ia64_put_nat_bits (struct pt_regs *pt, struct switch_stack *=
sw, unsigned long nat);
-#endif
=20
   extern void ia64_increment_ip (struct pt_regs *pt);
   extern void ia64_decrement_ip (struct pt_regs *pt);
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/sigcontext.h lin=
ux-2.4.2-lia/include/asm-ia64/sigcontext.h
--- linux-davidm/include/asm-ia64/sigcontext.h	Sun Feb  6 18:42:40 2000
+++ linux-2.4.2-lia/include/asm-ia64/sigcontext.h	Wed Mar 21 23:27:19 2001
@@ -36,6 +36,7 @@
 	unsigned long		sc_ar_lc;	/* loop count register */
 	unsigned long		sc_pr;		/* predicate registers */
 	unsigned long		sc_br[8];	/* branch registers */
+	/* Note: sc_gr[0] is used as the "uc_link" member of ucontext_t */
 	unsigned long		sc_gr[32];	/* general registers (static partition) */
 	struct ia64_fpreg	sc_fr[128];	/* floating-point registers */
=20
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/uaccess.h linux-=
2.4.2-lia/include/asm-ia64/uaccess.h
--- linux-davidm/include/asm-ia64/uaccess.h	Thu Jan  4 22:40:21 2001
+++ linux-2.4.2-lia/include/asm-ia64/uaccess.h	Wed Mar 21 23:27:37 2001
@@ -26,8 +26,8 @@
  * associated and, if so, sets r8 to -EFAULT and clears r9 to 0 and
  * then resumes execution at the continuation point.
  *=20
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998, 1999, 2001 Hewlett-Packard Co
+ * Copyright (C) 1998, 1999, 2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 #include <linux/errno.h>
@@ -90,8 +90,8 @@
=20
 #define __get_user_nocheck(x,ptr,size)				\
 ({								\
-	register long __gu_err __asm__ ("r8") =3D 0;		\
-	register long __gu_val __asm__ ("r9") =3D 0;		\
+	register long __gu_err asm ("r8") =3D 0;	\
+	register long __gu_val asm ("r9") =3D 0;	\
 	switch (size) {						\
 	  case 1: __get_user_8(ptr); break;			\
 	  case 2: __get_user_16(ptr); break;			\
@@ -105,8 +105,8 @@
=20
 #define __get_user_check(x,ptr,size,segment)			\
 ({								\
-	register long __gu_err __asm__ ("r8") =3D -EFAULT;	\
-	register long __gu_val __asm__ ("r9") =3D 0;		\
+	register long __gu_err asm ("r8") =3D -EFAULT;		\
+	register long __gu_val asm ("r9") =3D 0;			\
 	const __typeof__(*(ptr)) *__gu_addr =3D (ptr);		\
 	if (__access_ok((long)__gu_addr,size,segment)) {	\
 		__gu_err =3D 0;					\
@@ -126,33 +126,47 @@
 #define __m(x) (*(struct __large_struct *)(x))
=20
 /* We need to declare the __ex_table section before we can use it in .xdat=
a.  */
-__asm__ (".section \"__ex_table\", \"a\"\n\t.previous");
+asm (".section \"__ex_table\", \"a\"\n\t.previous");
+
+#if __GNUC__ >=3D 3
+#  define GAS_HAS_LOCAL_TAGS	/* define if gas supports local tags a la [1:=
] */
+#endif
+
+#ifdef GAS_HAS_LOCAL_TAGS
+# define _LL	"[1:]"
+#else
+# define _LL	"1:"
+#endif
=20
 #define __get_user_64(addr)									\
-	__asm__ ("\n1:\tld8 %0=3D%2%P2\t// %0 and %1 get overwritten by exception=
 handler\n"	\
-		 "2:\n\t.xdata4 \"__ex_table\", @gprel(1b), (2b-1b)|1\n"			\
+	asm ("\n"_LL"\tld8 %0=3D%2%P2\t// %0 and %1 get overwritten by exception =
handler\n"	\
+	     "\t.xdata4 \"__ex_table\", @gprel(1b), @gprel(1f)+4\n"				\
+	     _LL										\
 		: "=3Dr"(__gu_val), "=3Dr"(__gu_err) : "m"(__m(addr)), "1"(__gu_err));
=20
 #define __get_user_32(addr)									\
-	__asm__ ("\n1:\tld4 %0=3D%2%P2\t// %0 and %1 get overwritten by exception=
 handler\n"	\
-		 "2:\n\t.xdata4 \"__ex_table\", @gprel(1b), (2b-1b)|1\n"			\
+	asm ("\n"_LL"\tld4 %0=3D%2%P2\t// %0 and %1 get overwritten by exception =
handler\n"	\
+	     "\t.xdata4 \"__ex_table\", @gprel(1b), @gprel(1f)+4\n"				\
+	     _LL										\
 		: "=3Dr"(__gu_val), "=3Dr"(__gu_err) : "m"(__m(addr)), "1"(__gu_err));
=20
 #define __get_user_16(addr)									\
-	__asm__ ("\n1:\tld2 %0=3D%2%P2\t// %0 and %1 get overwritten by exception=
 handler\n"	\
-		 "2:\n\t.xdata4 \"__ex_table\", @gprel(1b), (2b-1b)|1\n"			\
+	asm ("\n"_LL"\tld2 %0=3D%2%P2\t// %0 and %1 get overwritten by exception =
handler\n"	\
+	     "\t.xdata4 \"__ex_table\", @gprel(1b), @gprel(1f)+4\n"				\
+	     _LL										\
 		: "=3Dr"(__gu_val), "=3Dr"(__gu_err) : "m"(__m(addr)), "1"(__gu_err));
=20
 #define __get_user_8(addr)									\
-	__asm__ ("\n1:\tld1 %0=3D%2%P2\t// %0 and %1 get overwritten by exception=
 handler\n"	\
-		 "2:\n\t.xdata4 \"__ex_table\", @gprel(1b), (2b-1b)|1\n"			\
+	asm ("\n"_LL"\tld1 %0=3D%2%P2\t// %0 and %1 get overwritten by exception =
handler\n"	\
+	     "\t.xdata4 \"__ex_table\", @gprel(1b), @gprel(1f)+4\n"				\
+	     _LL										\
 		: "=3Dr"(__gu_val), "=3Dr"(__gu_err) : "m"(__m(addr)), "1"(__gu_err));
=20
 extern void __put_user_unknown (void);
=20
 #define __put_user_nocheck(x,ptr,size)				\
 ({								\
-	register long __pu_err __asm__ ("r8") =3D 0;		\
+	register long __pu_err asm ("r8") =3D 0;	\
 	switch (size) {						\
 	  case 1: __put_user_8(x,ptr); break;			\
 	  case 2: __put_user_16(x,ptr); break;			\
@@ -165,7 +179,7 @@
=20
 #define __put_user_check(x,ptr,size,segment)			\
 ({								\
-	register long __pu_err __asm__ ("r8") =3D -EFAULT;	\
+	register long __pu_err asm ("r8") =3D -EFAULT;		\
 	__typeof__(*(ptr)) *__pu_addr =3D (ptr);			\
 	if (__access_ok((long)__pu_addr,size,segment)) {	\
 		__pu_err =3D 0;					\
@@ -186,27 +200,31 @@
  * any memory gcc knows about, so there are no aliasing issues
  */
 #define __put_user_64(x,addr)								\
-	__asm__ __volatile__ (								\
-		 "\n1:\tst8 %1=3D%r2%P1\t// %0 gets overwritten by exception handler\n"	\
-		 "2:\n\t.xdata4 \"__ex_table\", @gprel(1b), (2b-1b)\n"			\
+	asm volatile (									\
+		"\n"_LL"\tst8 %1=3D%r2%P1\t// %0 gets overwritten by exception handler\n=
"	\
+		"\t.xdata4 \"__ex_table\", @gprel(1b), @gprel(1f)\n"			\
+		_LL									\
 		: "=3Dr"(__pu_err) : "m"(__m(addr)), "rO"(x), "0"(__pu_err))
=20
 #define __put_user_32(x,addr)								\
-	__asm__ __volatile__ (								\
-		 "\n1:\tst4 %1=3D%r2%P1\t// %0 gets overwritten by exception handler\n"	\
-		 "2:\n\t.xdata4 \"__ex_table\", @gprel(1b), (2b-1b)\n"			\
+	asm volatile (									\
+		"\n"_LL"\tst4 %1=3D%r2%P1\t// %0 gets overwritten by exception handler\n=
"	\
+		"\t.xdata4 \"__ex_table\", @gprel(1b), @gprel(1f)\n"			\
+		_LL									\
 		: "=3Dr"(__pu_err) : "m"(__m(addr)), "rO"(x), "0"(__pu_err))
=20
 #define __put_user_16(x,addr)								\
-	__asm__ __volatile__ (								\
-		 "\n1:\tst2 %1=3D%r2%P1\t// %0 gets overwritten by exception handler\n"	\
-		 "2:\n\t.xdata4 \"__ex_table\", @gprel(1b), (2b-1b)\n"			\
+	asm volatile (									\
+		"\n"_LL"\tst2 %1=3D%r2%P1\t// %0 gets overwritten by exception handler\n=
"	\
+		"\t.xdata4 \"__ex_table\", @gprel(1b), @gprel(1f)\n"			\
+		_LL									\
 		: "=3Dr"(__pu_err) : "m"(__m(addr)), "rO"(x), "0"(__pu_err))
=20
 #define __put_user_8(x,addr)								\
-	__asm__ __volatile__ (								\
-		 "\n1:\tst1 %1=3D%r2%P1\t// %0 gets overwritten by exception handler\n"	\
-		 "2:\n\t.xdata4 \"__ex_table\", @gprel(1b), (2b-1b)\n"			\
+	asm volatile (									\
+		"\n"_LL"\tst1 %1=3D%r2%P1\t// %0 gets overwritten by exception handler\n=
"	\
+		"\t.xdata4 \"__ex_table\", @gprel(1b), @gprel(1f)\n"			\
+		_LL									\
 		: "=3Dr"(__pu_err) : "m"(__m(addr)), "rO"(x), "0"(__pu_err))
=20
 /*
@@ -293,10 +311,14 @@
=20
 struct exception_table_entry {
 	int addr;	/* gp-relative address of insn this fixup is for */
-	int skip;	/* number of bytes to skip to get to the continuation point.
-			   Bit 0 tells us if r9 should be cleared to 0*/
+	int cont;	/* gp-relative continuation address; if bit 2 is set, r9 is set=
 to 0 */
+};
+
+struct exception_fixup {
+	unsigned long cont;	/* continuation point (bit 2: clear r9 if set) */
 };
=20
-extern const struct exception_table_entry *search_exception_table (unsigne=
d long addr);
+extern struct exception_fixup search_exception_table (unsigned long addr);
+extern void handle_exception (struct pt_regs *regs, struct exception_fixup=
 fixup);
=20
 #endif /* _ASM_IA64_UACCESS_H */
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/ucontext.h linux=
-2.4.2-lia/include/asm-ia64/ucontext.h
--- linux-davidm/include/asm-ia64/ucontext.h	Wed Dec 31 16:00:00 1969
+++ linux-2.4.2-lia/include/asm-ia64/ucontext.h	Wed Mar 21 23:27:56 2001
@@ -0,0 +1,12 @@
+#ifndef _ASM_IA64_UCONTEXT_H
+#define _ASM_IA64_UCONTEXT_H
+
+struct ucontext {
+	struct sigcontext uc_mcontext;
+};
+
+#define uc_link		uc_mcontext.sc_gr[0]	/* wrong type; nobody cares */
+#define uc_sigmask	uc_mcontext.sc_sigmask
+#define uc_stack	uc_mcontext.sc_stack
+
+#endif /* _ASM_IA64_UCONTEXT_H */
diff -urN --ignore-all-space linux-davidm/include/linux/agp_backend.h linux=
-2.4.2-lia/include/linux/agp_backend.h
--- linux-davidm/include/linux/agp_backend.h	Wed Feb 28 12:58:27 2001
+++ linux-2.4.2-lia/include/linux/agp_backend.h	Wed Mar 21 23:28:07 2001
@@ -27,6 +27,8 @@
 #ifndef _AGP_BACKEND_H
 #define _AGP_BACKEND_H 1
=20
+#include <linux/config.h>
+
 #ifndef TRUE
 #define TRUE 1
 #endif
@@ -48,6 +50,7 @@
        INTEL_I815,
 	INTEL_I840,
 	INTEL_I850,
+	INTEL_460GX,
 	VIA_GENERIC,
 	VIA_VP3,
 	VIA_MVP3,
@@ -234,6 +237,25 @@
  *=20
  */
=20
+#ifdef CONFIG_AGP_PTE_FIXUPS
+extern void *agp_add_fixup(struct vm_area_struct *vma,
+				size_t size, unsigned long offset);
+/*
+ * agp_add_fixup :
+ *
+ * This function notifies AGPGART of a new virtual mapping it needs to keep
+ * in sync with the GART table.
+ */
+
+extern void agp_remove_fixup(struct vm_area_struct *vma, void *handle);
+/*
+ * agp_remove_fixup :
+ *
+ * This function tells AGPGART to forget about a previously registered
+ * fixup area.
+ */
+#endif
+
 typedef struct {
 	void       (*free_memory)(agp_memory *);
 	agp_memory *(*allocate_memory)(size_t, u32);
@@ -243,6 +265,11 @@
 	int        (*acquire)(void);
 	void       (*release)(void);
 	void       (*copy_info)(agp_kern_info *);
+#ifdef CONFIG_AGP_PTE_FIXUPS
+	void	   *(*add_fixup)(struct vm_area_struct *, size_t,=20
+							unsigned long);
+	void	   (*remove_fixup)(struct vm_area_struct *, void *);
+#endif
 } drm_agp_t;
=20
 extern const drm_agp_t *drm_agp_p;
diff -urN --ignore-all-space linux-davidm/kernel/printk.c linux-2.4.2-lia/k=
ernel/printk.c
--- linux-davidm/kernel/printk.c	Wed Mar 21 23:46:40 2001
+++ linux-2.4.2-lia/kernel/printk.c	Wed Mar 21 23:29:37 2001
@@ -513,8 +513,10 @@
 #include <asm/io.h>
=20
 #define VGABASE		((char *)0xc0000000000b8000)
+#define VGALINES	24
+#define VGACOLS		80
=20
-static int current_ypos =3D 50, current_xpos =3D 0;
+static int current_ypos =3D VGALINES, current_xpos =3D 0;
=20
 void
 early_printk (const char *str)
@@ -523,26 +525,26 @@
 	int  i, k, j;
=20
 	while ((c =3D *str++) !=3D '\0') {
-		if (current_ypos >=3D 50) {
+		if (current_ypos >=3D VGALINES) {
 			/* scroll 1 line up */
-			for (k =3D 1, j =3D 0; k < 50; k++, j++) {
-				for (i =3D 0; i < 80; i++) {
-					writew(readw(VGABASE + 2*(80*k + i)),
-					       VGABASE + 2*(80*j + i));
+			for (k =3D 1, j =3D 0; k < VGALINES; k++, j++) {
+				for (i =3D 0; i < VGACOLS; i++) {
+					writew(readw(VGABASE + 2*(VGACOLS*k + i)),
+					       VGABASE + 2*(VGACOLS*j + i));
 				}
 			}
-			for (i =3D 0; i < 80; i++) {
-				writew(0x720, VGABASE + 2*(80*j + i));
+			for (i =3D 0; i < VGACOLS; i++) {
+				writew(0x720, VGABASE + 2*(VGACOLS*j + i));
 			}
-			current_ypos =3D 49;
+			current_ypos =3D VGALINES-1;
 		}
 		if (c =3D '\n') {
 			current_xpos =3D 0;
 			current_ypos++;
 		} else if (c !=3D '\r')  {
 			writew(((0x7 << 8) | (unsigned short) c),
-			       VGABASE + 2*(80*current_ypos + current_xpos++));
-			if (current_xpos >=3D 80) {
+			       VGABASE + 2*(VGACOLS*current_ypos + current_xpos++));
+			if (current_xpos >=3D VGACOLS) {
 				current_xpos =3D 0;
 				current_ypos++;
 			}

