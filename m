From: "David Mosberger-Tang" <David.Mosberger@acm.org>
Date: Sat, 27 May 2006 14:54:30 +0000
Subject: ESI module
Message-Id: <ed5aea430605270754ka41f2d4w88451d236928d069@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_9624_26111170.1148741670335"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

------=_Part_9624_26111170.1148741670335
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Attached below is a small patch that adds an optional module that
supports making ESI calls [1].  ESI stands for "Extensible SAL
specification" and is basically a way for invoking firmware
subroutines which are identified by a GUID.  I don't know whether ESI
is used by vendors other than HP (if you do, please let me know) but
as firmware "backdoors" go, this seems one of the cleaner methods, so
it seems reasonable to support it, even though I'm not aware of any
publicly documented ESI calls.  I'd have liked to make the ESI module
completely stand-alone, but unfortunately that is not easily (or not
at all) possible because in order to make ESI calls in physical mode,
a small stub similar to the EFI stub is needed in the kernel proper.
I did try to create a stub that would work in user-level, but it
quickly got ugly beyond recognition (e.g., the stub had to make
assumptions about how the module-loader generated call-stubs work) and
I didn't even get it to work (that's probably fixable, but I didn't
bother because I concluded it was too ugly anyhow).  While it's not
terribly elegant to have kernel code which isn't actively used in the
kernel proper, I think it might be worth making an exception here for
two reasons: the code is trivially small (all that's really needed is
esi_stub.S) and by including it in the normal kernel distro, it might
encourage other OEMs to also use ESI, which I think would be far
better than each inventing their own firmware "backdoor".

The code was originally written by Alex.  I just massaged and packaged
it a bit (and perhaps messed up some things along the way...).

  --david

[1] h21007.www2.hp.com/dspp/tech/tech_TechDocumentDetailPage_IDX/1,1701,919,00.html
--
Mosberger Consulting LLC, http://www.mosberger-consulting.com/

------=_Part_9624_26111170.1148741670335
Content-Type: text/x-patch; name=esi.diff; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_enq3437s
Content-Disposition: attachment; filename="esi.diff"

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -430,6 +430,14 @@ config KEXEC
 	  support.  As of this writing the exact hardware interface is
 	  strongly in flux, so no good recommendation can be made.
 
+config IA64_ESI
+	tristate "ESI (Extensible SAL Interface) support"
+	help
+	  If you say Y or M here, support is built into the kernel to
+	  make ESI calls.  ESI calls are used to support vendor-specific
+	  firmware extensions, such as the ability to inject memory-errors
+	  for test-purposes.  If you're unsure, say N.
+
 source "drivers/sn/Kconfig"
 
 source "drivers/firmware/Kconfig"
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -32,6 +32,11 @@ obj-$(CONFIG_KEXEC)		+= machine_kexec.o 
 obj-$(CONFIG_IA64_UNCACHED_ALLOCATOR)	+= uncached.o
 mca_recovery-y			+= mca_drv.o mca_drv_asm.o
 
+obj-$(CONFIG_IA64_ESI)		+= esi.o
+ifneq ($(CONFIG_IA64_ESI),)
+obj-y				+= esi_stub.o	# must be in kernel proper
+endif
+
 # The gate DSO image is built using a special linker script.
 targets += gate.so gate-syms.o
 
diff --git a/arch/ia64/kernel/esi.c b/arch/ia64/kernel/esi.c
new file mode 100644
--- /dev/null
+++ b/arch/ia64/kernel/esi.c
@@ -0,0 +1,152 @@
+/*
+ * Extensible SAL Interface (ESI) support routines.
+ *
+ * Copyright (C) 2006 Hewlett-Packard Co
+ * 	Alex Williamson <alex.williamson@hp.com>
+ */
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/string.h>
+
+#include <asm/esi.h>
+#include <asm/sal.h>
+
+MODULE_AUTHOR("Alex Williamson <alex.williamson@hp.com>");
+MODULE_DESCRIPTION("Extensible SAL Interface (ESI) support");
+MODULE_LICENSE("GPL");
+
+#define MODULE_NAME	"esi"
+
+struct pdesc {
+	void *addr;
+	void *gp;
+};
+
+static struct ia64_sal_systab *esi_systab;
+
+static int __init esi_init (void)
+{
+	efi_config_table_t *config_tables;
+	struct ia64_sal_systab *systab;
+	unsigned long esi = 0;
+	char *p;
+	int i;
+
+	config_tables = __va(efi.systab->tables);
+
+	for (i = 0; i < (int) efi.systab->nr_tables; ++i) {
+		if (efi_guidcmp(config_tables[i].guid, ESI_TABLE_GUID) == 0) {
+			esi = config_tables[i].table;
+			break;
+		}
+	}
+
+	if (!esi)
+		return -ENODEV;;
+
+	systab = __va(esi);
+
+	if (strncmp(systab->signature, "ESIT", 4) != 0) {
+		printk(KERN_ERR "bad signature in ESI system table!");
+		return -ENODEV;
+	}
+
+	p = (char *) (systab + 1);
+	for (i = 0; i < systab->entry_count; i++) {
+		/*
+		 * The first byte of each entry type contains the type
+		 * descriptor.
+		 */
+		switch (*p) {
+		      case ESI_DESC_ENTRY_POINT:
+			break;
+		      default:
+			printk(KERN_WARNING "Unkown table type %d found in "
+			       "ESI table, ignoring rest of table\n", *p);
+			return -ENODEV;
+		}
+
+		p += ESI_DESC_SIZE(*p);
+	}
+
+	esi_systab = systab;
+	return 0;
+}
+
+
+int ia64_esi_call (efi_guid_t guid, struct ia64_sal_retval *isrvp, u64 func,
+		   u64 arg1, u64 arg2, u64 arg3, u64 arg4, u64 arg5, u64 arg6,
+		   u64 arg7)
+{
+	int i;
+	char *p;
+
+	if (!esi_systab)
+		return -1;
+
+	p = (char *) (esi_systab + 1);
+	for (i = 0; i < esi_systab->entry_count; i++) {
+		if (*p == ESI_DESC_ENTRY_POINT) {
+			ia64_esi_desc_entry_point_t *esi = (void *)p;
+			if (!efi_guidcmp(guid, esi->guid)) {
+				ia64_sal_handler esi_proc;
+				struct pdesc pdesc;
+
+				pdesc.addr = __va(esi->esi_proc);
+				pdesc.gp = __va(esi->gp);
+
+				esi_proc = (ia64_sal_handler) &pdesc;
+
+				ESI_CALL(esi_proc, *isrvp, func, arg1, arg2,
+				         arg3, arg4, arg5, arg6, arg7);
+				return 0;
+			}
+		}
+		p += ESI_DESC_SIZE(*p);
+	}
+	return -1;
+}
+EXPORT_SYMBOL(ia64_esi_call);
+
+int ia64_esi_call_phys (efi_guid_t guid, struct ia64_sal_retval *isrvp,
+			u64 func, u64 arg1, u64 arg2, u64 arg3, u64 arg4,
+			u64 arg5, u64 arg6, u64 arg7)
+{
+	int i;
+	char *p;
+
+	if (!esi_systab)
+		return -1;
+
+	p = (char *) (esi_systab + 1);
+	for (i = 0; i < esi_systab->entry_count; i++) {
+		if (*p == ESI_DESC_ENTRY_POINT) {
+			ia64_esi_desc_entry_point_t *esi = (void *)p;
+			if (!efi_guidcmp(guid, esi->guid)) {
+				ia64_sal_handler esi_proc;
+				struct pdesc pdesc;
+
+				pdesc.addr = (void *)esi->esi_proc;
+				pdesc.gp = (void *)esi->gp;
+
+				esi_proc = (ia64_sal_handler) &pdesc;
+
+				ESI_CALL_PHYS(esi_proc, *isrvp, func, arg1,
+				              arg2, arg3, arg4, arg5, arg6,
+				              arg7);
+				return 0;
+			}
+		}
+		p += ESI_DESC_SIZE(*p);
+	}
+	return -1;
+}
+EXPORT_SYMBOL(ia64_esi_call_phys);
+
+static void __exit esi_exit (void)
+{
+}
+
+module_init(esi_init);
+module_exit(esi_exit);	/* makes module removable... */
diff --git a/arch/ia64/kernel/esi_stub.S b/arch/ia64/kernel/esi_stub.S
new file mode 100644
--- /dev/null
+++ b/arch/ia64/kernel/esi_stub.S
@@ -0,0 +1,96 @@
+/*
+ * ESI call stub.
+ *
+ * Copyright (C) 2005 Hewlett-Packard Co
+ *	Alex Williamson <alex.williamson@hp.com>
+ *
+ * Based on EFI call stub by David Mosberger.  The stub is virtually
+ * identical to the one for EFI phys-mode calls, except that ESI
+ * calls may have up to 8 arguments, so they get passed to this routine
+ * through memory.
+ *
+ * This stub allows us to make ESI calls in physical mode with interrupts
+ * turned off.  ESI calls may not support calling from virtual mode.
+ *
+ * Google for "Extensible SAL specification" for a document describing the
+ * ESI standard.
+ */
+
+/*
+ * PSR settings as per SAL spec (Chapter 8 in the "IA-64 System
+ * Abstraction Layer Specification", revision 2.6e).  Note that
+ * psr.dfl and psr.dfh MUST be cleared, despite what this manual says.
+ * Otherwise, SAL dies whenever it's trying to do an IA-32 BIOS call
+ * (the br.ia instruction fails unless psr.dfl and psr.dfh are
+ * cleared).  Fortunately, SAL promises not to touch the floating
+ * point regs, so at least we don't have to save f2-f127.
+ */
+#define PSR_BITS_TO_CLEAR						\
+	(IA64_PSR_I | IA64_PSR_IT | IA64_PSR_DT | IA64_PSR_RT |		\
+	 IA64_PSR_DD | IA64_PSR_SS | IA64_PSR_RI | IA64_PSR_ED |	\
+	 IA64_PSR_DFL | IA64_PSR_DFH)
+
+#define PSR_BITS_TO_SET							\
+	(IA64_PSR_BN)
+
+#include <asm/processor.h>
+#include <asm/asmmacro.h>
+
+/*
+ * Inputs:
+ *	in0 = address of function descriptor of ESI routine to call
+ *	in1 = address of array of ESI parameters
+ *
+ * Outputs:
+ *	r8 = result returned by called function
+ */
+GLOBAL_ENTRY(esi_call_phys)
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2)
+	alloc loc1=ar.pfs,2,7,8,0
+	ld8 r2=[in0],8			// load ESI function's entry point
+	mov loc0=rp
+	.body
+	;;
+	ld8 out0=[in1],8		// ESI params loaded from array
+	;;				// passing all as inputs doesn't work
+	ld8 out1=[in1],8
+	;;
+	ld8 out2=[in1],8
+	;;
+	ld8 out3=[in1],8
+	;;
+	ld8 out4=[in1],8
+	;;
+	ld8 out5=[in1],8
+	;;
+	ld8 out6=[in1],8
+	;;
+	ld8 out7=[in1]
+	mov loc2=gp			// save global pointer
+	mov loc4=ar.rsc			// save RSE configuration
+	mov ar.rsc=0			// put RSE in enforced lazy, LE mode
+	;;
+	ld8 gp=[in0]			// load ESI function's global pointer
+	movl r16=PSR_BITS_TO_CLEAR
+	mov loc3=psr			// save processor status word
+	movl r17=PSR_BITS_TO_SET
+	;;
+	or loc3=loc3,r17
+	mov b6=r2
+	;;
+	andcm r16=loc3,r16	// get psr with IT, DT, and RT bits cleared
+	br.call.sptk.many rp=ia64_switch_mode_phys
+.ret0:	mov loc5=r19			// old ar.bsp
+	mov loc6=r20			// old sp
+	br.call.sptk.many rp=b6		// call the ESI function
+.ret1:	mov ar.rsc=0			// put RSE in enforced lazy, LE mode
+	mov r16=loc3			// save virtual mode psr
+	mov r19=loc5			// save virtual mode bspstore
+	mov r20=loc6			// save virtual mode sp
+	br.call.sptk.many rp=ia64_switch_mode_virt // return to virtual mode
+.ret2:	mov ar.rsc=loc4			// restore RSE configuration
+	mov ar.pfs=loc1
+	mov rp=loc0
+	mov gp=loc2
+	br.ret.sptk.many rp
+END(esi_call_phys)
diff --git a/arch/ia64/kernel/ia64_ksyms.c b/arch/ia64/kernel/ia64_ksyms.c
--- a/arch/ia64/kernel/ia64_ksyms.c
+++ b/arch/ia64/kernel/ia64_ksyms.c
@@ -106,5 +106,7 @@ EXPORT_SYMBOL(ia64_spinlock_contention);
 # endif
 #endif
 
+extern void esi_call_phys (void);
+EXPORT_SYMBOL(esi_call_phys);
 extern char ia64_ivt[];
 EXPORT_SYMBOL(ia64_ivt);
diff --git a/include/asm-ia64/esi.h b/include/asm-ia64/esi.h
new file mode 100644
--- /dev/null
+++ b/include/asm-ia64/esi.h
@@ -0,0 +1,74 @@
+/*
+ * ESI service calls.
+ *
+ * Copyright (c) Copyright 2005-2006 Hewlett-Packard Development Company, L.P.
+ * 	Alex Williamson <alex.williamson@hp.com>
+ */
+#ifndef esi_h
+#define esi_h
+
+#include <linux/efi.h>
+
+#define ESI_TABLE_GUID					\
+    EFI_GUID(0x43EA58DC, 0xCF28, 0x4b06, 0xB3,		\
+	     0x91, 0xB7, 0x50, 0x59, 0x34, 0x2B, 0xD4)
+
+#define ESI_QUERY			0x00000001
+#define ESI_OPEN_HANDLE			0x02000000
+#define ESI_CLOSE_HANDLE		0x02000001
+
+enum esi_systab_entry_type {
+	ESI_DESC_ENTRY_POINT = 0
+};
+
+/*
+ * Entry type:	Size:
+ *	0	48
+ */
+#define ESI_DESC_SIZE(type)	"\060"[(unsigned) (type)]
+
+typedef struct ia64_esi_desc_entry_point {
+	u8 type;
+	u8 reserved1[15];
+	u64 esi_proc;
+	u64 gp;
+	efi_guid_t guid;
+} ia64_esi_desc_entry_point_t;
+
+# define ESI_CALL(esi_proc,result,a0,a1,a2,a3,a4,a5,a6,a7) do {		\
+	unsigned long __ia64_sc_flags;					\
+	struct ia64_fpreg __ia64_sc_fr[6];				\
+	ia64_save_scratch_fpregs(__ia64_sc_fr);				\
+	spin_lock_irqsave(&sal_lock, __ia64_sc_flags);			\
+	result = (*esi_proc)(a0,a1,a2,a3,a4,a5,a6,a7);			\
+	spin_unlock_irqrestore(&sal_lock, __ia64_sc_flags);		\
+	ia64_load_scratch_fpregs(__ia64_sc_fr);				\
+} while (0)
+
+# define ESI_CALL_PHYS(esi_proc,result,a0,a1,a2,a3,a4,a5,a6,a7) do {	\
+	unsigned long __ia64_sc_flags;					\
+	struct ia64_fpreg __ia64_sc_fr[6];				\
+	u64 esi_params[8];						\
+	esi_params[0] = a0;						\
+	esi_params[1] = a1;						\
+	esi_params[2] = a2;						\
+	esi_params[3] = a3;						\
+	esi_params[4] = a4;						\
+	esi_params[5] = a5;						\
+	esi_params[6] = a6;						\
+	esi_params[7] = a7;						\
+	ia64_save_scratch_fpregs(__ia64_sc_fr);				\
+	spin_lock_irqsave(&sal_lock, __ia64_sc_flags);			\
+	result = esi_call_phys(esi_proc, esi_params);			\
+	spin_unlock_irqrestore(&sal_lock, __ia64_sc_flags);		\
+	ia64_load_scratch_fpregs(__ia64_sc_fr);				\
+} while (0)
+
+extern int ia64_esi_init (void);
+extern struct ia64_sal_retval esi_call_phys (void *, u64 *);
+extern int ia64_esi_call(efi_guid_t, struct ia64_sal_retval *, u64, u64, u64,
+                         u64, u64, u64, u64, u64);
+extern int ia64_esi_call_phys(efi_guid_t, struct ia64_sal_retval *, u64, u64,
+                              u64, u64, u64, u64, u64, u64);
+
+#endif /* esi_h */

------=_Part_9624_26111170.1148741670335--
