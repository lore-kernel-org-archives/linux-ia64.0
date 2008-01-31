From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 10:28:56 +0000
Subject: [PATCH][05] Add header files for kvm/ia64.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCD31FC8@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C863F4.15F1B537"
List-Id: <linux-ia64.vger.kernel.org>
To: Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Xu, Anthony" <anthony.xu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Zhang, Xiantao" <xiantao.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-ia64-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C863F4.15F1B537
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 15:38:36 +0800
Subject: [PATCH] kvm/ia64: Add header files for kvm/ia64.

Three header files are added:
asm-ia64/kvm.h
asm-ia64/kvm_host.h
asm-ia64/kvm_para.h
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 include/asm-ia64/kvm.h      |   69 +++++
 include/asm-ia64/kvm_host.h |  610
+++++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/kvm_para.h |   29 ++
 3 files changed, 708 insertions(+), 0 deletions(-)
 create mode 100644 include/asm-ia64/kvm.h
 create mode 100644 include/asm-ia64/kvm_host.h
 create mode 100644 include/asm-ia64/kvm_para.h

diff --git a/include/asm-ia64/kvm.h b/include/asm-ia64/kvm.h
new file mode 100644
index 0000000..1822335
--- /dev/null
+++ b/include/asm-ia64/kvm.h
@@ -0,0 +1,69 @@
+#ifndef __ASM_KVM_IA64_H
+#define __ASM_KVM_IA64_H
+
+/*
+ * asm-ia64/kvm.h: kvm structure definitions  for ia64
+ *
+ * Copyright (C) 2007 Zhang Xiantao <xiantao.zhang@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but
WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License
along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
59 Temple
+ * Place - Suite 330, Boston, MA 02111-1307 USA.
+ *
+ */
+
+#include <asm/types.h>
+#include <linux/ioctl.h>
+
+/* Architectural interrupt line count. */
+#define KVM_NR_INTERRUPTS 256
+
+#define KVM_IOAPIC_NUM_PINS  24
+
+struct kvm_ioapic_state {
+	__u64 base_address;
+	__u32 ioregsel;
+	__u32 id;
+	__u32 irr;
+	__u32 pad;
+	union {
+		__u64 bits;
+		struct {
+			__u8 vector;
+			__u8 delivery_mode:3;
+			__u8 dest_mode:1;
+			__u8 delivery_status:1;
+			__u8 polarity:1;
+			__u8 remote_irr:1;
+			__u8 trig_mode:1;
+			__u8 mask:1;
+			__u8 reserve:7;
+			__u8 reserved[4];
+			__u8 dest_id;
+		} fields;
+	} redirtbl[KVM_IOAPIC_NUM_PINS];
+};
+
+#define KVM_IRQCHIP_PIC_MASTER   0
+#define KVM_IRQCHIP_PIC_SLAVE    1
+#define KVM_IRQCHIP_IOAPIC       2
+
+struct kvm_regs {
+};
+
+struct kvm_sregs {
+};
+
+struct kvm_fpu {
+};
+
+#endif
diff --git a/include/asm-ia64/kvm_host.h b/include/asm-ia64/kvm_host.h
new file mode 100644
index 0000000..200a870
--- /dev/null
+++ b/include/asm-ia64/kvm_host.h
@@ -0,0 +1,610 @@
+/* -*-  Mode:C; c-basic-offset:4; tab-width:4; indent-tabs-mode:nil -*-
*/
+/*
+ * ia64.h: used for kvm module, and hold ia64-specific sections.
+ *
+ * Copyright (C) 2007, Intel Corporation.
+ *
+ * Zhang Xiantao <xiantao.zhang@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but
WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License
along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
59 Temple
+ * Place - Suite 330, Boston, MA 02111-1307 USA.
+ *
+ */
+
+#ifndef __ASM_KVM_HOST_H
+#define __ASM_KVM_HOST_H
+
+
+#include <linux/types.h>
+#include <linux/mm.h>
+#include <linux/kvm.h>
+#include <linux/kvm_para.h>
+#include <linux/kvm_types.h>
+
+#include <asm/pal.h>
+#include <asm/sal.h>
+#include <asm/fpu.h>
+
+/* define exit reasons from vmm to kvm*/
+#define EXIT_REASON_VM_PANIC		0
+#define EXIT_REASON_MMIO_INSTRUCTION	1
+#define EXIT_REASON_PAL_CALL		2
+#define EXIT_REASON_SAL_CALL		3
+#define EXIT_REASON_SWITCH_RR6		4
+#define EXIT_REASON_VM_DESTROY		5
+#define EXIT_REASON_EXTERNAL_INTERRUPT	6
+#define EXIT_REASON_IPI			7
+#define EXIT_REASON_PTC_G		8
+
+/*Define vmm address space and vm data space.*/
+#define KVM_VMM_SIZE (16UL<<20)
+#define KVM_VMM_SHIFT 24
+#define KVM_VMM_BASE 0xD000000000000000UL
+#define VMM_SIZE (8UL<<20)
+
+/*
+ * Define vm_buffer, used by PAL Services, base address.
+ * Note: vmbuffer is in the VMM-BLOCK, the size must be < 8M
+ */
+#define KVM_VM_BUFFER_BASE (KVM_VMM_BASE + VMM_SIZE)
+#define KVM_VM_BUFFER_SIZE (8UL<<20)
+
+/*Define Virtual machine data layout.*/
+#define KVM_VM_DATA_SHIFT  24
+#define KVM_VM_DATA_SIZE (1UL << KVM_VM_DATA_SHIFT)
+#define KVM_VM_DATA_BASE (KVM_VMM_BASE + KVM_VMM_SIZE)
+
+
+#define KVM_P2M_BASE    KVM_VM_DATA_BASE
+#define KVM_P2M_OFS     0
+#define KVM_P2M_SIZE    (8UL << 20)
+
+#define KVM_VHPT_BASE   (KVM_P2M_BASE + KVM_P2M_SIZE)
+#define KVM_VHPT_OFS    KVM_P2M_SIZE
+#define KVM_VHPT_BLOCK_SIZE   (2UL << 20)
+#define VHPT_SHIFT      18
+#define VHPT_SIZE       (1UL << VHPT_SHIFT)
+#define VHPT_NUM_ENTRIES (1<<(VHPT_SHIFT-5))
+
+#define KVM_VTLB_BASE   (KVM_VHPT_BASE+KVM_VHPT_BLOCK_SIZE)
+#define KVM_VTLB_OFS    (KVM_VHPT_OFS+KVM_VHPT_BLOCK_SIZE)
+#define KVM_VTLB_BLOCK_SIZE   (1UL<<20)
+#define VTLB_SHIFT      17
+#define VTLB_SIZE       (1UL<<VTLB_SHIFT)
+#define VTLB_NUM_ENTRIES (1<<(VTLB_SHIFT-5))
+
+#define KVM_VPD_BASE   (KVM_VTLB_BASE+KVM_VTLB_BLOCK_SIZE)
+#define KVM_VPD_OFS    (KVM_VTLB_OFS+KVM_VTLB_BLOCK_SIZE)
+#define KVM_VPD_BLOCK_SIZE   (2UL<<20)
+#define VPD_SHIFT       16
+#define VPD_SIZE        (1UL<<VPD_SHIFT)
+
+#define KVM_VCPU_BASE   (KVM_VPD_BASE+KVM_VPD_BLOCK_SIZE)
+#define KVM_VCPU_OFS    (KVM_VPD_OFS+KVM_VPD_BLOCK_SIZE)
+#define KVM_VCPU_BLOCK_SIZE   (2UL<<20)
+#define VCPU_SHIFT 18
+#define VCPU_SIZE (1UL<<VCPU_SHIFT)
+#define MAX_VCPU_NUM KVM_VCPU_BLOCK_SIZE/VCPU_SIZE
+
+#define KVM_VM_BASE     (KVM_VCPU_BASE+KVM_VCPU_BLOCK_SIZE)
+#define KVM_VM_OFS      (KVM_VCPU_OFS+KVM_VCPU_BLOCK_SIZE)
+#define KVM_VM_BLOCK_SIZE     (1UL<<20)
+
+/* Get vpd, vhpt, tlb, vcpu, base*/
+#define VPD_ADDR(n) (KVM_VPD_BASE+n*VPD_SIZE)
+#define VHPT_ADDR(n) (KVM_VHPT_BASE+n*VHPT_SIZE)
+#define VTLB_ADDR(n) (KVM_VTLB_BASE+n*VTLB_SIZE)
+#define VCPU_ADDR(n) (KVM_VCPU_BASE+n*VCPU_SIZE)
+
+/*IO section definitions*/
+#define IOREQ_READ      1
+#define IOREQ_WRITE     0
+
+#define STATE_IOREQ_NONE        0
+#define STATE_IOREQ_READY       1
+#define STATE_IOREQ_INPROCESS   2
+#define STATE_IORESP_READY      3
+
+/*Guest Physical address layout.*/
+#define GPFN_MEM        (0UL << 60) /* Guest pfn is normal mem */
+#define GPFN_FRAME_BUFFER   (1UL << 60) /* VGA framebuffer */
+#define GPFN_LOW_MMIO       (2UL << 60) /* Low MMIO range */
+#define GPFN_PIB        (3UL << 60) /* PIB base */
+#define GPFN_IOSAPIC        (4UL << 60) /* IOSAPIC base */
+#define GPFN_LEGACY_IO      (5UL << 60) /* Legacy I/O base */
+#define GPFN_GFW        (6UL << 60) /* Guest Firmware */
+#define GPFN_HIGH_MMIO      (7UL << 60) /* High MMIO range */
+
+#define GPFN_IO_MASK        (7UL << 60) /* Guest pfn is I/O type */
+#define GPFN_INV_MASK       (1UL << 63) /* Guest pfn is invalid */
+#define INVALID_MFN       (~0UL)
+#define MEM_G   (1UL << 30)
+#define MEM_M   (1UL << 20)
+#define MMIO_START       (3 * MEM_G)
+#define MMIO_SIZE        (512 * MEM_M)
+#define VGA_IO_START     0xA0000UL
+#define VGA_IO_SIZE      0x20000
+#define LEGACY_IO_START  (MMIO_START + MMIO_SIZE)
+#define LEGACY_IO_SIZE   (64*MEM_M)
+#define IO_SAPIC_START   0xfec00000UL
+#define IO_SAPIC_SIZE    0x100000
+#define PIB_START 0xfee00000UL
+#define PIB_SIZE 0x200000
+#define GFW_START        (4*MEM_G-16*MEM_M)
+#define GFW_SIZE         (16*MEM_M)
+
+/*Deliver mode, defined for ioapic.c*/
+#define dest_Fixed IOSAPIC_FIXED
+#define dest_LowestPrio IOSAPIC_LOWEST_PRIORITY
+
+#define NMI_VECTOR      		2
+#define ExtINT_VECTOR       		0
+#define NULL_VECTOR     		-1
+#define IA64_SPURIOUS_INT_VECTOR    	0x0f
+
+#define VCPU_LID(v) (((u64)(v)->vcpu_id)<<24)
+
+/*
+ *Delivery mode
+ */
+#define SAPIC_DELIV_SHIFT      8
+#define SAPIC_FIXED            0x0
+#define SAPIC_LOWEST_PRIORITY  0x1
+#define SAPIC_PMI              0x2
+#define SAPIC_NMI              0x4
+#define SAPIC_INIT             0x5
+#define SAPIC_EXTINT           0x7
+
+/*
+ * vcpu->requests bit members for arch
+ */
+#define KVM_REQ_PTC_G		32
+#define KVM_REQ_FLUSH_ALL	33
+
+struct kvm;
+struct kvm_vcpu;
+
+struct kvm_ioreq {
+	uint64_t addr;          /*  physical address		*/
+	uint64_t size;          /*  size in bytes		*/
+	uint64_t data;          /*  data (or paddr of data)     */
+	uint8_t state:4;
+	uint8_t dir:1;          /*  1=3Dread, 0=3Dwrite             */
+};
+typedef struct kvm_ioreq ioreq_t;
+
+/*Pal data struct */
+typedef struct pal_call{
+	/*In area*/
+	uint64_t gr28;
+	uint64_t gr29;
+	uint64_t gr30;
+	uint64_t gr31;
+	/*Out area*/
+	struct ia64_pal_retval ret;
+} pal_call_t;
+
+/* Sal data structure */
+typedef struct sal_call{
+	/*In area*/
+	uint64_t in0;
+	uint64_t in1;
+	uint64_t in2;
+	uint64_t in3;
+	uint64_t in4;
+	uint64_t in5;
+	uint64_t in6;
+	uint64_t in7;
+	/*Our area*/
+	struct sal_ret_values ret;
+} sal_call_t;
+
+/*Guest change rr6*/
+typedef struct switch_rr6 {
+	uint64_t old_rr;
+	uint64_t new_rr;
+} switch_rr6_t;
+
+typedef union{
+	unsigned long val;
+	struct {
+		unsigned long rv  : 3;
+		unsigned long ir  : 1;
+		unsigned long eid : 8;
+		unsigned long id  : 8;
+		unsigned long ib_base : 44;
+	};
+} ia64_ipi_a;
+
+typedef union{
+	unsigned long val;
+	struct {
+		unsigned long vector : 8;
+		unsigned long dm  : 3;
+		unsigned long ig  : 53;
+	};
+} ia64_ipi_d;
+
+/*ipi check exit data*/
+typedef struct ipi_data{
+	ia64_ipi_a addr;
+	ia64_ipi_d data;
+} ipi_data_t;
+
+/*global purge data*/
+typedef struct kvm_ptc_g {
+	unsigned long vaddr;
+	unsigned long rr;
+	unsigned long ps;
+	struct kvm_vcpu *vcpu;
+} ptc_g_t;
+
+/*Exit control data */
+struct exit_ctl_data{
+	uint32_t exit_reason;
+	uint32_t vm_status;
+	union {
+		ioreq_t		ioreq;
+		pal_call_t	pal_data;
+		sal_call_t	sal_data;
+		switch_rr6_t	rr_data;
+		ipi_data_t	ipi_data;
+		ptc_g_t		ptc_g_data;
+	} u;
+};
+
+union pte_flags {
+	struct {
+		unsigned long p    :  1; /*0      */
+		unsigned long      :  1; /* 1     */
+		unsigned long ma   :  3; /* 2-4   */
+		unsigned long a    :  1; /* 5     */
+		unsigned long d    :  1; /* 6     */
+		unsigned long pl   :  2; /* 7-8   */
+		unsigned long ar   :  3; /* 9-11  */
+		unsigned long ppn  : 38; /* 12-49 */
+		unsigned long      :  2; /* 50-51 */
+		unsigned long ed   :  1; /* 52    */
+	};
+	unsigned long val;
+};
+
+
+typedef struct thash_data {
+	union {
+		struct {
+			unsigned long p    :  1; /* 0 */
+			unsigned long rv1  :  1; /* 1 */
+			unsigned long ma   :  3; /* 2-4 */
+			unsigned long a    :  1; /* 5 */
+			unsigned long d    :  1; /* 6 */
+			unsigned long pl   :  2; /* 7-8 */
+			unsigned long ar   :  3; /* 9-11 */
+			unsigned long ppn  : 38; /* 12-49 */
+			unsigned long rv2  :  2; /* 50-51 */
+			unsigned long ed   :  1; /* 52 */
+			unsigned long ig1  : 11; /* 53-63 */
+		};
+		struct {
+			unsigned long __rv1 : 53;     /* 0-52 */
+			unsigned long contiguous : 1; /*53 */
+			unsigned long tc : 1;         /* 54 TR or TC */
+			unsigned long cl : 1;
+			/* 55 I side or D side cache line */
+			unsigned long len  :  4;      /* 56-59 */
+			unsigned long io  : 1;	/* 60 entry is for io or
not */
+			unsigned long nomap : 1;
+			/* 61 entry cann't be inserted into machine
TLB.*/
+			unsigned long checked : 1;
+			/* 62 for VTLB/VHPT sanity check */
+			unsigned long invalid : 1;
+			/* 63 invalid entry */
+		};
+		unsigned long page_flags;
+	};                  /* same for VHPT and TLB */
+
+	union {
+		struct {
+			unsigned long rv3  :  2;
+			unsigned long ps   :  6;
+			unsigned long key  : 24;
+			unsigned long rv4  : 32;
+		};
+		unsigned long itir;
+	};
+	union {
+		struct {
+			unsigned long ig2  :  12;
+			unsigned long vpn  :  49;
+			unsigned long vrn  :   3;
+		};
+		unsigned long ifa;
+		unsigned long vadr;
+		struct {
+			unsigned long tag  :  63;
+			unsigned long ti   :  1;
+		};
+		unsigned long etag;
+	};
+	union {
+		struct thash_data *next;
+		unsigned long rid;
+		unsigned long gpaddr;
+	};
+} thash_data_t;
+
+typedef union {
+	unsigned long val;
+	struct {
+		unsigned long ve : 1;
+		unsigned long reserved0 : 1;
+		unsigned long size : 6;
+		unsigned long vf : 1;
+		unsigned long reserved1 : 6;
+		unsigned long base : 49;
+	};
+} ia64_pta;
+
+typedef struct thash_cb {
+	/* THASH base information */
+	thash_data_t  *hash; /* hash table pointer, aligned at
thash_sz.*/
+	ia64_pta      pta;
+	int           num;
+} thash_cb_t;
+
+typedef union context {
+	/* 8K size */
+	unsigned long       dummy[1024];
+	struct {
+		unsigned long       psr;
+		unsigned long       pr;
+		unsigned long       caller_unat;
+		unsigned long       pad;
+		unsigned long       gr[32];
+		unsigned long       ar[128];
+		unsigned long       br[8];
+		unsigned long       cr[128];
+		unsigned long       rr[8];
+		unsigned long       ibr[8];
+		unsigned long       dbr[8];
+		unsigned long       pkr[8];
+		struct ia64_fpreg   fr[128];
+	};
+} context_t;
+
+#define	NITRS	8
+#define NDTRS	8
+
+struct kvm_vcpu_stat {
+};
+struct kvm_vcpu_arch {
+	int launched;
+	int last_exit;
+	int last_run_cpu;
+
+#define VCPU_MP_STATE_RUNNABLE          0
+#define VCPU_MP_STATE_UNINITIALIZED     1
+#define VCPU_MP_STATE_INIT_RECEIVED     2
+#define VCPU_MP_STATE_HALTED            3
+	int mp_state;
+
+#define MAX_PTC_G_NUM			3
+	int ptc_g_count;
+	struct kvm_ptc_g ptc_g_data[MAX_PTC_G_NUM];
+
+	/*halt timer to wake up sleepy vcpus*/
+	struct hrtimer hlt_timer;
+	long ht_active;
+
+	void *pio_data;
+	struct kvm_pio_request pio;
+	struct kvm_lapic *apic;    /* kernel irqchip context */
+	struct vpd *vpd;
+
+	/* Exit data for vmm_transition*/
+	struct exit_ctl_data exit_data;
+
+	cpumask_t cache_coherent_map;
+
+	unsigned long vmm_rr;
+	unsigned long host_rr6;
+	unsigned long psbits[8];
+	unsigned long cr_iipa;
+	unsigned long cr_isr;
+	unsigned long vsa_base;
+	unsigned long __gp;
+	/* TR and TC.  */
+	thash_data_t itrs[NITRS];
+	thash_data_t dtrs[NDTRS];
+	/* Bit is set if there is a tr/tc for the region.  */
+	unsigned char itr_regions;
+	unsigned char dtr_regions;
+	unsigned char tc_regions;
+	/* purge all */
+	unsigned long ptce_base;
+	unsigned long ptce_count[2];
+	unsigned long ptce_stride[2];
+	/* itc/itm */
+	unsigned long last_itc;
+	long itc_offset;
+	unsigned long itc_check;
+	unsigned long timer_check;
+	unsigned long timer_pending;
+
+
+	unsigned long vrr[8];
+	unsigned long ibr[8];
+	unsigned long dbr[8];
+	unsigned long insvc[4];		/* Interrupt in service.  */
+	unsigned long xtp;
+
+	/* These fields are copied from arch_domain to make access
+	easier/faster in assembly code.  */
+	unsigned long metaphysical_rr0; /* from kvm_arch (so is pinned)
*/
+	unsigned long metaphysical_rr4;	/* from kvm_arch (so is pinned)
*/
+	unsigned long metaphysical_saved_rr0; /* from kvm_arch
*/
+	unsigned long metaphysical_saved_rr4; /* from kvm_arch
*/
+	unsigned long fp_psr;       /*used for lazy float register */
+	unsigned long saved_gp;
+	/*for phycial  emulation */
+	int mode_flags;
+	thash_cb_t vtlb;
+	thash_cb_t vhpt;
+	char irq_check;
+	char irq_new_pending;
+
+	unsigned long opcode;
+	unsigned long cause;
+	context_t host;
+	context_t guest;
+
+};
+
+struct kvm_vm_stat {
+	u64 remote_tlb_flush;
+};
+
+struct kvm_sal_data {
+	unsigned long boot_ip;
+	unsigned long boot_gp;
+};
+
+struct kvm_arch {
+	unsigned long	vm_base;
+	unsigned long	metaphysical_rr0;
+	unsigned long	metaphysical_rr4;
+	unsigned long	vmm_init_rr;
+	unsigned long	vhpt_base;
+	unsigned long	vtlb_base;
+	unsigned long 	vpd_base;
+	struct kvm_ioapic *vioapic;
+	struct kvm_vm_stat stat;
+	struct kvm_sal_data rdv_sal_data;
+};
+
+typedef union {
+	u64 value;
+	struct {
+		u64 number : 8;
+		u64 revision : 8;
+		u64 model : 8;
+		u64 family : 8;
+		u64 archrev : 8;
+		u64 rv : 24;
+	};
+} cpuid3_t;
+
+struct kvm_pt_regs {
+    /* The following registers are saved by SAVE_MIN: */
+    unsigned long b6;  /* scratch */
+    unsigned long b7;  /* scratch */
+
+    unsigned long ar_csd; /* used by cmp8xchg16 (scratch) */
+    unsigned long ar_ssd; /* reserved for future use (scratch) */
+
+    unsigned long r8;  /* scratch (return value register 0) */
+    unsigned long r9;  /* scratch (return value register 1) */
+    unsigned long r10; /* scratch (return value register 2) */
+    unsigned long r11; /* scratch (return value register 3) */
+
+    unsigned long cr_ipsr; /* interrupted task's psr */
+    unsigned long cr_iip;  /* interrupted task's instruction pointer */
+    unsigned long cr_ifs;  /* interrupted task's function state */
+
+    unsigned long ar_unat; /* interrupted task's NaT register
(preserved) */
+    unsigned long ar_pfs;  /* prev function state  */
+    unsigned long ar_rsc;  /* RSE configuration */
+    /* The following two are valid only if cr_ipsr.cpl > 0: */
+    unsigned long ar_rnat;  /* RSE NaT */
+    unsigned long ar_bspstore; /* RSE bspstore */
+
+    unsigned long pr;  /* 64 predicate registers (1 bit each) */
+    unsigned long b0;  /* return pointer (bp) */
+    unsigned long loadrs;  /* size of dirty partition << 16 */
+
+    unsigned long r1;  /* the gp pointer */
+    unsigned long r12; /* interrupted task's memory stack pointer */
+    unsigned long r13; /* thread pointer */
+
+    unsigned long ar_fpsr;  /* floating point status (preserved) */
+    unsigned long r15;  /* scratch */
+
+ /* The remaining registers are NOT saved for system calls.  */
+
+    unsigned long r14;  /* scratch */
+    unsigned long r2;  /* scratch */
+    unsigned long r3;  /* scratch */
+    unsigned long r16;  /* scratch */
+    unsigned long r17;  /* scratch */
+    unsigned long r18;  /* scratch */
+    unsigned long r19;  /* scratch */
+    unsigned long r20;  /* scratch */
+    unsigned long r21;  /* scratch */
+    unsigned long r22;  /* scratch */
+    unsigned long r23;  /* scratch */
+    unsigned long r24;  /* scratch */
+    unsigned long r25;  /* scratch */
+    unsigned long r26;  /* scratch */
+    unsigned long r27;  /* scratch */
+    unsigned long r28;  /* scratch */
+    unsigned long r29;  /* scratch */
+    unsigned long r30;  /* scratch */
+    unsigned long r31;  /* scratch */
+    unsigned long ar_ccv;  /* compare/exchange value (scratch) */
+
+
+    /*
+     * Floating point registers that the kernel considers scratch:
+     */
+    struct ia64_fpreg f6;  /* scratch */
+    struct ia64_fpreg f7;  /* scratch */
+    struct ia64_fpreg f8;  /* scratch */
+    struct ia64_fpreg f9;  /* scratch */
+    struct ia64_fpreg f10;  /* scratch */
+    struct ia64_fpreg f11;  /* scratch */
+
+    unsigned long r4;  /* preserved */
+    unsigned long r5;  /* preserved */
+    unsigned long r6;  /* preserved */
+    unsigned long r7;  /* preserved */
+    unsigned long eml_unat;    /* used for emulating instruction */
+    unsigned long pad0;     /* alignment pad */
+
+};
+
+static inline struct kvm_pt_regs *vcpu_regs(struct kvm_vcpu *v)
+{
+	return (struct kvm_pt_regs *) ((unsigned long) v +
IA64_STK_OFFSET) - 1;
+}
+
+typedef int kvm_vmm_entry(void);
+typedef void kvm_tramp_entry(context_t *host, context_t *guest);
+
+struct kvm_vmm_info{
+	struct module	*module;
+	kvm_vmm_entry 	*vmm_entry;
+	kvm_tramp_entry *tramp_entry;
+	unsigned long 	vmm_ivt;
+};
+
+int kvm_highest_pending_irq(struct kvm_vcpu *vcpu);
+int kvm_emulate_halt(struct kvm_vcpu *vcpu);
+int kvm_pal_emul(struct kvm_vcpu *vcpu, struct kvm_run *kvm_run);
+void kvm_sal_emul(struct kvm_vcpu *vcpu);
+
+/*Currently, this macro is not used by kvm/ia64, Once necessary,
+ it should be implemented later!!*/
+#define smp_call_function_mask(cpus_mask, func, info, wait)\
+	smp_call_function(func, info, 0, wait)
+
+#endif
diff --git a/include/asm-ia64/kvm_para.h b/include/asm-ia64/kvm_para.h
new file mode 100644
index 0000000..90d5658
--- /dev/null
+++ b/include/asm-ia64/kvm_para.h
@@ -0,0 +1,29 @@
+#ifndef __IA64_KVM_PARA_H
+#define __IA64_KVM_PARA_H
+
+/*
+ * asm-ia64/kvm_para.h
+ *
+ * Copyright (C) 2007 Zhang Xiantao <xiantao.zhang@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but
WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License
along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
59 Temple
+ * Place - Suite 330, Boston, MA 02111-1307 USA.
+ *
+ */
+
+static inline unsigned int kvm_arch_para_features(void)
+{
+	return 0;
+}
+
+#endif
--=20
1.5.1

------_=_NextPart_001_01C863F4.15F1B537
Content-Type: application/octet-stream;
	name="0005-kvm-ia64-Add-header-files-for-kvm-ia64.patch"
Content-Transfer-Encoding: base64
Content-Description: 0005-kvm-ia64-Add-header-files-for-kvm-ia64.patch
Content-Disposition: attachment;
	filename="0005-kvm-ia64-Add-header-files-for-kvm-ia64.patch"

RnJvbSA4Mzc4MTUzOTgzNWI4MDk2OWIwNzA5ZmQ0YmIxNTlmNGU0ZTA2OWRmIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVGh1LCAzMSBKYW4gMjAwOCAxNTozODozNiArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IGt2bS9pYTY0OiBBZGQgaGVhZGVyIGZpbGVzIGZvciBrdm0vaWE2NC4KClRocmVlIGhlYWRlciBm
aWxlcyBhcmUgYWRkZWQ6CmFzbS1pYTY0L2t2bS5oCmFzbS1pYTY0L2t2bV9ob3N0LmgKYXNtLWlh
NjQva3ZtX3BhcmEuaApTaWduZWQtb2ZmLWJ5OiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5n
QGludGVsLmNvbT4KLS0tCiBpbmNsdWRlL2FzbS1pYTY0L2t2bS5oICAgICAgfCAgIDY5ICsrKysr
CiBpbmNsdWRlL2FzbS1pYTY0L2t2bV9ob3N0LmggfCAgNjEwICsrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysKIGluY2x1ZGUvYXNtLWlhNjQva3ZtX3BhcmEuaCB8ICAg
MjkgKysKIDMgZmlsZXMgY2hhbmdlZCwgNzA4IGluc2VydGlvbnMoKyksIDAgZGVsZXRpb25zKC0p
CiBjcmVhdGUgbW9kZSAxMDA2NDQgaW5jbHVkZS9hc20taWE2NC9rdm0uaAogY3JlYXRlIG1vZGUg
MTAwNjQ0IGluY2x1ZGUvYXNtLWlhNjQva3ZtX2hvc3QuaAogY3JlYXRlIG1vZGUgMTAwNjQ0IGlu
Y2x1ZGUvYXNtLWlhNjQva3ZtX3BhcmEuaAoKZGlmZiAtLWdpdCBhL2luY2x1ZGUvYXNtLWlhNjQv
a3ZtLmggYi9pbmNsdWRlL2FzbS1pYTY0L2t2bS5oCm5ldyBmaWxlIG1vZGUgMTAwNjQ0CmluZGV4
IDAwMDAwMDAuLjE4MjIzMzUKLS0tIC9kZXYvbnVsbAorKysgYi9pbmNsdWRlL2FzbS1pYTY0L2t2
bS5oCkBAIC0wLDAgKzEsNjkgQEAKKyNpZm5kZWYgX19BU01fS1ZNX0lBNjRfSAorI2RlZmluZSBf
X0FTTV9LVk1fSUE2NF9ICisKKy8qCisgKiBhc20taWE2NC9rdm0uaDoga3ZtIHN0cnVjdHVyZSBk
ZWZpbml0aW9ucyAgZm9yIGlhNjQKKyAqCisgKiBDb3B5cmlnaHQgKEMpIDIwMDcgWmhhbmcgWGlh
bnRhbyA8eGlhbnRhby56aGFuZ0BpbnRlbC5jb20+CisgKgorICogVGhpcyBwcm9ncmFtIGlzIGZy
ZWUgc29mdHdhcmU7IHlvdSBjYW4gcmVkaXN0cmlidXRlIGl0IGFuZC9vciBtb2RpZnkgaXQKKyAq
IHVuZGVyIHRoZSB0ZXJtcyBhbmQgY29uZGl0aW9ucyBvZiB0aGUgR05VIEdlbmVyYWwgUHVibGlj
IExpY2Vuc2UsCisgKiB2ZXJzaW9uIDIsIGFzIHB1Ymxpc2hlZCBieSB0aGUgRnJlZSBTb2Z0d2Fy
ZSBGb3VuZGF0aW9uLgorICoKKyAqIFRoaXMgcHJvZ3JhbSBpcyBkaXN0cmlidXRlZCBpbiB0aGUg
aG9wZSBpdCB3aWxsIGJlIHVzZWZ1bCwgYnV0IFdJVEhPVVQKKyAqIEFOWSBXQVJSQU5UWTsgd2l0
aG91dCBldmVuIHRoZSBpbXBsaWVkIHdhcnJhbnR5IG9mIE1FUkNIQU5UQUJJTElUWSBvcgorICog
RklUTkVTUyBGT1IgQSBQQVJUSUNVTEFSIFBVUlBPU0UuICBTZWUgdGhlIEdOVSBHZW5lcmFsIFB1
YmxpYyBMaWNlbnNlIGZvcgorICogbW9yZSBkZXRhaWxzLgorICoKKyAqIFlvdSBzaG91bGQgaGF2
ZSByZWNlaXZlZCBhIGNvcHkgb2YgdGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlIGFsb25n
IHdpdGgKKyAqIHRoaXMgcHJvZ3JhbTsgaWYgbm90LCB3cml0ZSB0byB0aGUgRnJlZSBTb2Z0d2Fy
ZSBGb3VuZGF0aW9uLCBJbmMuLCA1OSBUZW1wbGUKKyAqIFBsYWNlIC0gU3VpdGUgMzMwLCBCb3N0
b24sIE1BIDAyMTExLTEzMDcgVVNBLgorICoKKyAqLworCisjaW5jbHVkZSA8YXNtL3R5cGVzLmg+
CisjaW5jbHVkZSA8bGludXgvaW9jdGwuaD4KKworLyogQXJjaGl0ZWN0dXJhbCBpbnRlcnJ1cHQg
bGluZSBjb3VudC4gKi8KKyNkZWZpbmUgS1ZNX05SX0lOVEVSUlVQVFMgMjU2CisKKyNkZWZpbmUg
S1ZNX0lPQVBJQ19OVU1fUElOUyAgMjQKKworc3RydWN0IGt2bV9pb2FwaWNfc3RhdGUgeworCV9f
dTY0IGJhc2VfYWRkcmVzczsKKwlfX3UzMiBpb3JlZ3NlbDsKKwlfX3UzMiBpZDsKKwlfX3UzMiBp
cnI7CisJX191MzIgcGFkOworCXVuaW9uIHsKKwkJX191NjQgYml0czsKKwkJc3RydWN0IHsKKwkJ
CV9fdTggdmVjdG9yOworCQkJX191OCBkZWxpdmVyeV9tb2RlOjM7CisJCQlfX3U4IGRlc3RfbW9k
ZToxOworCQkJX191OCBkZWxpdmVyeV9zdGF0dXM6MTsKKwkJCV9fdTggcG9sYXJpdHk6MTsKKwkJ
CV9fdTggcmVtb3RlX2lycjoxOworCQkJX191OCB0cmlnX21vZGU6MTsKKwkJCV9fdTggbWFzazox
OworCQkJX191OCByZXNlcnZlOjc7CisJCQlfX3U4IHJlc2VydmVkWzRdOworCQkJX191OCBkZXN0
X2lkOworCQl9IGZpZWxkczsKKwl9IHJlZGlydGJsW0tWTV9JT0FQSUNfTlVNX1BJTlNdOworfTsK
KworI2RlZmluZSBLVk1fSVJRQ0hJUF9QSUNfTUFTVEVSICAgMAorI2RlZmluZSBLVk1fSVJRQ0hJ
UF9QSUNfU0xBVkUgICAgMQorI2RlZmluZSBLVk1fSVJRQ0hJUF9JT0FQSUMgICAgICAgMgorCitz
dHJ1Y3Qga3ZtX3JlZ3MgeworfTsKKworc3RydWN0IGt2bV9zcmVncyB7Cit9OworCitzdHJ1Y3Qg
a3ZtX2ZwdSB7Cit9OworCisjZW5kaWYKZGlmZiAtLWdpdCBhL2luY2x1ZGUvYXNtLWlhNjQva3Zt
X2hvc3QuaCBiL2luY2x1ZGUvYXNtLWlhNjQva3ZtX2hvc3QuaApuZXcgZmlsZSBtb2RlIDEwMDY0
NAppbmRleCAwMDAwMDAwLi4yMDBhODcwCi0tLSAvZGV2L251bGwKKysrIGIvaW5jbHVkZS9hc20t
aWE2NC9rdm1faG9zdC5oCkBAIC0wLDAgKzEsNjEwIEBACisvKiAtKi0gIE1vZGU6QzsgYy1iYXNp
Yy1vZmZzZXQ6NDsgdGFiLXdpZHRoOjQ7IGluZGVudC10YWJzLW1vZGU6bmlsIC0qLSAqLworLyoK
KyAqIGlhNjQuaDogdXNlZCBmb3Iga3ZtIG1vZHVsZSwgYW5kIGhvbGQgaWE2NC1zcGVjaWZpYyBz
ZWN0aW9ucy4KKyAqCisgKiBDb3B5cmlnaHQgKEMpIDIwMDcsIEludGVsIENvcnBvcmF0aW9uLgor
ICoKKyAqIFpoYW5nIFhpYW50YW8gPHhpYW50YW8uemhhbmdAaW50ZWwuY29tPgorICoKKyAqIFRo
aXMgcHJvZ3JhbSBpcyBmcmVlIHNvZnR3YXJlOyB5b3UgY2FuIHJlZGlzdHJpYnV0ZSBpdCBhbmQv
b3IgbW9kaWZ5IGl0CisgKiB1bmRlciB0aGUgdGVybXMgYW5kIGNvbmRpdGlvbnMgb2YgdGhlIEdO
VSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlLAorICogdmVyc2lvbiAyLCBhcyBwdWJsaXNoZWQgYnkg
dGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlvbi4KKyAqCisgKiBUaGlzIHByb2dyYW0gaXMgZGlz
dHJpYnV0ZWQgaW4gdGhlIGhvcGUgaXQgd2lsbCBiZSB1c2VmdWwsIGJ1dCBXSVRIT1VUCisgKiBB
TlkgV0FSUkFOVFk7IHdpdGhvdXQgZXZlbiB0aGUgaW1wbGllZCB3YXJyYW50eSBvZiBNRVJDSEFO
VEFCSUxJVFkgb3IKKyAqIEZJVE5FU1MgRk9SIEEgUEFSVElDVUxBUiBQVVJQT1NFLiAgU2VlIHRo
ZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSBmb3IKKyAqIG1vcmUgZGV0YWlscy4KKyAqCisg
KiBZb3Ugc2hvdWxkIGhhdmUgcmVjZWl2ZWQgYSBjb3B5IG9mIHRoZSBHTlUgR2VuZXJhbCBQdWJs
aWMgTGljZW5zZSBhbG9uZyB3aXRoCisgKiB0aGlzIHByb2dyYW07IGlmIG5vdCwgd3JpdGUgdG8g
dGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlvbiwgSW5jLiwgNTkgVGVtcGxlCisgKiBQbGFjZSAt
IFN1aXRlIDMzMCwgQm9zdG9uLCBNQSAwMjExMS0xMzA3IFVTQS4KKyAqCisgKi8KKworI2lmbmRl
ZiBfX0FTTV9LVk1fSE9TVF9ICisjZGVmaW5lIF9fQVNNX0tWTV9IT1NUX0gKKworCisjaW5jbHVk
ZSA8bGludXgvdHlwZXMuaD4KKyNpbmNsdWRlIDxsaW51eC9tbS5oPgorI2luY2x1ZGUgPGxpbnV4
L2t2bS5oPgorI2luY2x1ZGUgPGxpbnV4L2t2bV9wYXJhLmg+CisjaW5jbHVkZSA8bGludXgva3Zt
X3R5cGVzLmg+CisKKyNpbmNsdWRlIDxhc20vcGFsLmg+CisjaW5jbHVkZSA8YXNtL3NhbC5oPgor
I2luY2x1ZGUgPGFzbS9mcHUuaD4KKworLyogZGVmaW5lIGV4aXQgcmVhc29ucyBmcm9tIHZtbSB0
byBrdm0qLworI2RlZmluZSBFWElUX1JFQVNPTl9WTV9QQU5JQwkJMAorI2RlZmluZSBFWElUX1JF
QVNPTl9NTUlPX0lOU1RSVUNUSU9OCTEKKyNkZWZpbmUgRVhJVF9SRUFTT05fUEFMX0NBTEwJCTIK
KyNkZWZpbmUgRVhJVF9SRUFTT05fU0FMX0NBTEwJCTMKKyNkZWZpbmUgRVhJVF9SRUFTT05fU1dJ
VENIX1JSNgkJNAorI2RlZmluZSBFWElUX1JFQVNPTl9WTV9ERVNUUk9ZCQk1CisjZGVmaW5lIEVY
SVRfUkVBU09OX0VYVEVSTkFMX0lOVEVSUlVQVAk2CisjZGVmaW5lIEVYSVRfUkVBU09OX0lQSQkJ
CTcKKyNkZWZpbmUgRVhJVF9SRUFTT05fUFRDX0cJCTgKKworLypEZWZpbmUgdm1tIGFkZHJlc3Mg
c3BhY2UgYW5kIHZtIGRhdGEgc3BhY2UuKi8KKyNkZWZpbmUgS1ZNX1ZNTV9TSVpFICgxNlVMPDwy
MCkKKyNkZWZpbmUgS1ZNX1ZNTV9TSElGVCAyNAorI2RlZmluZSBLVk1fVk1NX0JBU0UgMHhEMDAw
MDAwMDAwMDAwMDAwVUwKKyNkZWZpbmUgVk1NX1NJWkUgKDhVTDw8MjApCisKKy8qCisgKiBEZWZp
bmUgdm1fYnVmZmVyLCB1c2VkIGJ5IFBBTCBTZXJ2aWNlcywgYmFzZSBhZGRyZXNzLgorICogTm90
ZTogdm1idWZmZXIgaXMgaW4gdGhlIFZNTS1CTE9DSywgdGhlIHNpemUgbXVzdCBiZSA8IDhNCisg
Ki8KKyNkZWZpbmUgS1ZNX1ZNX0JVRkZFUl9CQVNFIChLVk1fVk1NX0JBU0UgKyBWTU1fU0laRSkK
KyNkZWZpbmUgS1ZNX1ZNX0JVRkZFUl9TSVpFICg4VUw8PDIwKQorCisvKkRlZmluZSBWaXJ0dWFs
IG1hY2hpbmUgZGF0YSBsYXlvdXQuKi8KKyNkZWZpbmUgS1ZNX1ZNX0RBVEFfU0hJRlQgIDI0Cisj
ZGVmaW5lIEtWTV9WTV9EQVRBX1NJWkUgKDFVTCA8PCBLVk1fVk1fREFUQV9TSElGVCkKKyNkZWZp
bmUgS1ZNX1ZNX0RBVEFfQkFTRSAoS1ZNX1ZNTV9CQVNFICsgS1ZNX1ZNTV9TSVpFKQorCisKKyNk
ZWZpbmUgS1ZNX1AyTV9CQVNFICAgIEtWTV9WTV9EQVRBX0JBU0UKKyNkZWZpbmUgS1ZNX1AyTV9P
RlMgICAgIDAKKyNkZWZpbmUgS1ZNX1AyTV9TSVpFICAgICg4VUwgPDwgMjApCisKKyNkZWZpbmUg
S1ZNX1ZIUFRfQkFTRSAgIChLVk1fUDJNX0JBU0UgKyBLVk1fUDJNX1NJWkUpCisjZGVmaW5lIEtW
TV9WSFBUX09GUyAgICBLVk1fUDJNX1NJWkUKKyNkZWZpbmUgS1ZNX1ZIUFRfQkxPQ0tfU0laRSAg
ICgyVUwgPDwgMjApCisjZGVmaW5lIFZIUFRfU0hJRlQgICAgICAxOAorI2RlZmluZSBWSFBUX1NJ
WkUgICAgICAgKDFVTCA8PCBWSFBUX1NISUZUKQorI2RlZmluZSBWSFBUX05VTV9FTlRSSUVTICgx
PDwoVkhQVF9TSElGVC01KSkKKworI2RlZmluZSBLVk1fVlRMQl9CQVNFICAgKEtWTV9WSFBUX0JB
U0UrS1ZNX1ZIUFRfQkxPQ0tfU0laRSkKKyNkZWZpbmUgS1ZNX1ZUTEJfT0ZTICAgIChLVk1fVkhQ
VF9PRlMrS1ZNX1ZIUFRfQkxPQ0tfU0laRSkKKyNkZWZpbmUgS1ZNX1ZUTEJfQkxPQ0tfU0laRSAg
ICgxVUw8PDIwKQorI2RlZmluZSBWVExCX1NISUZUICAgICAgMTcKKyNkZWZpbmUgVlRMQl9TSVpF
ICAgICAgICgxVUw8PFZUTEJfU0hJRlQpCisjZGVmaW5lIFZUTEJfTlVNX0VOVFJJRVMgKDE8PChW
VExCX1NISUZULTUpKQorCisjZGVmaW5lIEtWTV9WUERfQkFTRSAgIChLVk1fVlRMQl9CQVNFK0tW
TV9WVExCX0JMT0NLX1NJWkUpCisjZGVmaW5lIEtWTV9WUERfT0ZTICAgIChLVk1fVlRMQl9PRlMr
S1ZNX1ZUTEJfQkxPQ0tfU0laRSkKKyNkZWZpbmUgS1ZNX1ZQRF9CTE9DS19TSVpFICAgKDJVTDw8
MjApCisjZGVmaW5lIFZQRF9TSElGVCAgICAgICAxNgorI2RlZmluZSBWUERfU0laRSAgICAgICAg
KDFVTDw8VlBEX1NISUZUKQorCisjZGVmaW5lIEtWTV9WQ1BVX0JBU0UgICAoS1ZNX1ZQRF9CQVNF
K0tWTV9WUERfQkxPQ0tfU0laRSkKKyNkZWZpbmUgS1ZNX1ZDUFVfT0ZTICAgIChLVk1fVlBEX09G
UytLVk1fVlBEX0JMT0NLX1NJWkUpCisjZGVmaW5lIEtWTV9WQ1BVX0JMT0NLX1NJWkUgICAoMlVM
PDwyMCkKKyNkZWZpbmUgVkNQVV9TSElGVCAxOAorI2RlZmluZSBWQ1BVX1NJWkUgKDFVTDw8VkNQ
VV9TSElGVCkKKyNkZWZpbmUgTUFYX1ZDUFVfTlVNIEtWTV9WQ1BVX0JMT0NLX1NJWkUvVkNQVV9T
SVpFCisKKyNkZWZpbmUgS1ZNX1ZNX0JBU0UgICAgIChLVk1fVkNQVV9CQVNFK0tWTV9WQ1BVX0JM
T0NLX1NJWkUpCisjZGVmaW5lIEtWTV9WTV9PRlMgICAgICAoS1ZNX1ZDUFVfT0ZTK0tWTV9WQ1BV
X0JMT0NLX1NJWkUpCisjZGVmaW5lIEtWTV9WTV9CTE9DS19TSVpFICAgICAoMVVMPDwyMCkKKwor
LyogR2V0IHZwZCwgdmhwdCwgdGxiLCB2Y3B1LCBiYXNlKi8KKyNkZWZpbmUgVlBEX0FERFIobikg
KEtWTV9WUERfQkFTRStuKlZQRF9TSVpFKQorI2RlZmluZSBWSFBUX0FERFIobikgKEtWTV9WSFBU
X0JBU0UrbipWSFBUX1NJWkUpCisjZGVmaW5lIFZUTEJfQUREUihuKSAoS1ZNX1ZUTEJfQkFTRStu
KlZUTEJfU0laRSkKKyNkZWZpbmUgVkNQVV9BRERSKG4pIChLVk1fVkNQVV9CQVNFK24qVkNQVV9T
SVpFKQorCisvKklPIHNlY3Rpb24gZGVmaW5pdGlvbnMqLworI2RlZmluZSBJT1JFUV9SRUFEICAg
ICAgMQorI2RlZmluZSBJT1JFUV9XUklURSAgICAgMAorCisjZGVmaW5lIFNUQVRFX0lPUkVRX05P
TkUgICAgICAgIDAKKyNkZWZpbmUgU1RBVEVfSU9SRVFfUkVBRFkgICAgICAgMQorI2RlZmluZSBT
VEFURV9JT1JFUV9JTlBST0NFU1MgICAyCisjZGVmaW5lIFNUQVRFX0lPUkVTUF9SRUFEWSAgICAg
IDMKKworLypHdWVzdCBQaHlzaWNhbCBhZGRyZXNzIGxheW91dC4qLworI2RlZmluZSBHUEZOX01F
TSAgICAgICAgKDBVTCA8PCA2MCkgLyogR3Vlc3QgcGZuIGlzIG5vcm1hbCBtZW0gKi8KKyNkZWZp
bmUgR1BGTl9GUkFNRV9CVUZGRVIgICAoMVVMIDw8IDYwKSAvKiBWR0EgZnJhbWVidWZmZXIgKi8K
KyNkZWZpbmUgR1BGTl9MT1dfTU1JTyAgICAgICAoMlVMIDw8IDYwKSAvKiBMb3cgTU1JTyByYW5n
ZSAqLworI2RlZmluZSBHUEZOX1BJQiAgICAgICAgKDNVTCA8PCA2MCkgLyogUElCIGJhc2UgKi8K
KyNkZWZpbmUgR1BGTl9JT1NBUElDICAgICAgICAoNFVMIDw8IDYwKSAvKiBJT1NBUElDIGJhc2Ug
Ki8KKyNkZWZpbmUgR1BGTl9MRUdBQ1lfSU8gICAgICAoNVVMIDw8IDYwKSAvKiBMZWdhY3kgSS9P
IGJhc2UgKi8KKyNkZWZpbmUgR1BGTl9HRlcgICAgICAgICg2VUwgPDwgNjApIC8qIEd1ZXN0IEZp
cm13YXJlICovCisjZGVmaW5lIEdQRk5fSElHSF9NTUlPICAgICAgKDdVTCA8PCA2MCkgLyogSGln
aCBNTUlPIHJhbmdlICovCisKKyNkZWZpbmUgR1BGTl9JT19NQVNLICAgICAgICAoN1VMIDw8IDYw
KSAvKiBHdWVzdCBwZm4gaXMgSS9PIHR5cGUgKi8KKyNkZWZpbmUgR1BGTl9JTlZfTUFTSyAgICAg
ICAoMVVMIDw8IDYzKSAvKiBHdWVzdCBwZm4gaXMgaW52YWxpZCAqLworI2RlZmluZSBJTlZBTElE
X01GTiAgICAgICAofjBVTCkKKyNkZWZpbmUgTUVNX0cgICAoMVVMIDw8IDMwKQorI2RlZmluZSBN
RU1fTSAgICgxVUwgPDwgMjApCisjZGVmaW5lIE1NSU9fU1RBUlQgICAgICAgKDMgKiBNRU1fRykK
KyNkZWZpbmUgTU1JT19TSVpFICAgICAgICAoNTEyICogTUVNX00pCisjZGVmaW5lIFZHQV9JT19T
VEFSVCAgICAgMHhBMDAwMFVMCisjZGVmaW5lIFZHQV9JT19TSVpFICAgICAgMHgyMDAwMAorI2Rl
ZmluZSBMRUdBQ1lfSU9fU1RBUlQgIChNTUlPX1NUQVJUICsgTU1JT19TSVpFKQorI2RlZmluZSBM
RUdBQ1lfSU9fU0laRSAgICg2NCpNRU1fTSkKKyNkZWZpbmUgSU9fU0FQSUNfU1RBUlQgICAweGZl
YzAwMDAwVUwKKyNkZWZpbmUgSU9fU0FQSUNfU0laRSAgICAweDEwMDAwMAorI2RlZmluZSBQSUJf
U1RBUlQgMHhmZWUwMDAwMFVMCisjZGVmaW5lIFBJQl9TSVpFIDB4MjAwMDAwCisjZGVmaW5lIEdG
V19TVEFSVCAgICAgICAgKDQqTUVNX0ctMTYqTUVNX00pCisjZGVmaW5lIEdGV19TSVpFICAgICAg
ICAgKDE2Kk1FTV9NKQorCisvKkRlbGl2ZXIgbW9kZSwgZGVmaW5lZCBmb3IgaW9hcGljLmMqLwor
I2RlZmluZSBkZXN0X0ZpeGVkIElPU0FQSUNfRklYRUQKKyNkZWZpbmUgZGVzdF9Mb3dlc3RQcmlv
IElPU0FQSUNfTE9XRVNUX1BSSU9SSVRZCisKKyNkZWZpbmUgTk1JX1ZFQ1RPUiAgICAgIAkJMgor
I2RlZmluZSBFeHRJTlRfVkVDVE9SICAgICAgIAkJMAorI2RlZmluZSBOVUxMX1ZFQ1RPUiAgICAg
CQktMQorI2RlZmluZSBJQTY0X1NQVVJJT1VTX0lOVF9WRUNUT1IgICAgCTB4MGYKKworI2RlZmlu
ZSBWQ1BVX0xJRCh2KSAoKCh1NjQpKHYpLT52Y3B1X2lkKTw8MjQpCisKKy8qCisgKkRlbGl2ZXJ5
IG1vZGUKKyAqLworI2RlZmluZSBTQVBJQ19ERUxJVl9TSElGVCAgICAgIDgKKyNkZWZpbmUgU0FQ
SUNfRklYRUQgICAgICAgICAgICAweDAKKyNkZWZpbmUgU0FQSUNfTE9XRVNUX1BSSU9SSVRZICAw
eDEKKyNkZWZpbmUgU0FQSUNfUE1JICAgICAgICAgICAgICAweDIKKyNkZWZpbmUgU0FQSUNfTk1J
ICAgICAgICAgICAgICAweDQKKyNkZWZpbmUgU0FQSUNfSU5JVCAgICAgICAgICAgICAweDUKKyNk
ZWZpbmUgU0FQSUNfRVhUSU5UICAgICAgICAgICAweDcKKworLyoKKyAqIHZjcHUtPnJlcXVlc3Rz
IGJpdCBtZW1iZXJzIGZvciBhcmNoCisgKi8KKyNkZWZpbmUgS1ZNX1JFUV9QVENfRwkJMzIKKyNk
ZWZpbmUgS1ZNX1JFUV9GTFVTSF9BTEwJMzMKKworc3RydWN0IGt2bTsKK3N0cnVjdCBrdm1fdmNw
dTsKKworc3RydWN0IGt2bV9pb3JlcSB7CisJdWludDY0X3QgYWRkcjsgICAgICAgICAgLyogIHBo
eXNpY2FsIGFkZHJlc3MJCSovCisJdWludDY0X3Qgc2l6ZTsgICAgICAgICAgLyogIHNpemUgaW4g
Ynl0ZXMJCSovCisJdWludDY0X3QgZGF0YTsgICAgICAgICAgLyogIGRhdGEgKG9yIHBhZGRyIG9m
IGRhdGEpICAgICAqLworCXVpbnQ4X3Qgc3RhdGU6NDsKKwl1aW50OF90IGRpcjoxOyAgICAgICAg
ICAvKiAgMT1yZWFkLCAwPXdyaXRlICAgICAgICAgICAgICovCit9OwordHlwZWRlZiBzdHJ1Y3Qg
a3ZtX2lvcmVxIGlvcmVxX3Q7CisKKy8qUGFsIGRhdGEgc3RydWN0ICovCit0eXBlZGVmIHN0cnVj
dCBwYWxfY2FsbHsKKwkvKkluIGFyZWEqLworCXVpbnQ2NF90IGdyMjg7CisJdWludDY0X3QgZ3Iy
OTsKKwl1aW50NjRfdCBncjMwOworCXVpbnQ2NF90IGdyMzE7CisJLypPdXQgYXJlYSovCisJc3Ry
dWN0IGlhNjRfcGFsX3JldHZhbCByZXQ7Cit9IHBhbF9jYWxsX3Q7CisKKy8qIFNhbCBkYXRhIHN0
cnVjdHVyZSAqLwordHlwZWRlZiBzdHJ1Y3Qgc2FsX2NhbGx7CisJLypJbiBhcmVhKi8KKwl1aW50
NjRfdCBpbjA7CisJdWludDY0X3QgaW4xOworCXVpbnQ2NF90IGluMjsKKwl1aW50NjRfdCBpbjM7
CisJdWludDY0X3QgaW40OworCXVpbnQ2NF90IGluNTsKKwl1aW50NjRfdCBpbjY7CisJdWludDY0
X3QgaW43OworCS8qT3VyIGFyZWEqLworCXN0cnVjdCBzYWxfcmV0X3ZhbHVlcyByZXQ7Cit9IHNh
bF9jYWxsX3Q7CisKKy8qR3Vlc3QgY2hhbmdlIHJyNiovCit0eXBlZGVmIHN0cnVjdCBzd2l0Y2hf
cnI2IHsKKwl1aW50NjRfdCBvbGRfcnI7CisJdWludDY0X3QgbmV3X3JyOworfSBzd2l0Y2hfcnI2
X3Q7CisKK3R5cGVkZWYgdW5pb257CisJdW5zaWduZWQgbG9uZyB2YWw7CisJc3RydWN0IHsKKwkJ
dW5zaWduZWQgbG9uZyBydiAgOiAzOworCQl1bnNpZ25lZCBsb25nIGlyICA6IDE7CisJCXVuc2ln
bmVkIGxvbmcgZWlkIDogODsKKwkJdW5zaWduZWQgbG9uZyBpZCAgOiA4OworCQl1bnNpZ25lZCBs
b25nIGliX2Jhc2UgOiA0NDsKKwl9OworfSBpYTY0X2lwaV9hOworCit0eXBlZGVmIHVuaW9uewor
CXVuc2lnbmVkIGxvbmcgdmFsOworCXN0cnVjdCB7CisJCXVuc2lnbmVkIGxvbmcgdmVjdG9yIDog
ODsKKwkJdW5zaWduZWQgbG9uZyBkbSAgOiAzOworCQl1bnNpZ25lZCBsb25nIGlnICA6IDUzOwor
CX07Cit9IGlhNjRfaXBpX2Q7CisKKy8qaXBpIGNoZWNrIGV4aXQgZGF0YSovCit0eXBlZGVmIHN0
cnVjdCBpcGlfZGF0YXsKKwlpYTY0X2lwaV9hIGFkZHI7CisJaWE2NF9pcGlfZCBkYXRhOworfSBp
cGlfZGF0YV90OworCisvKmdsb2JhbCBwdXJnZSBkYXRhKi8KK3R5cGVkZWYgc3RydWN0IGt2bV9w
dGNfZyB7CisJdW5zaWduZWQgbG9uZyB2YWRkcjsKKwl1bnNpZ25lZCBsb25nIHJyOworCXVuc2ln
bmVkIGxvbmcgcHM7CisJc3RydWN0IGt2bV92Y3B1ICp2Y3B1OworfSBwdGNfZ190OworCisvKkV4
aXQgY29udHJvbCBkYXRhICovCitzdHJ1Y3QgZXhpdF9jdGxfZGF0YXsKKwl1aW50MzJfdCBleGl0
X3JlYXNvbjsKKwl1aW50MzJfdCB2bV9zdGF0dXM7CisJdW5pb24geworCQlpb3JlcV90CQlpb3Jl
cTsKKwkJcGFsX2NhbGxfdAlwYWxfZGF0YTsKKwkJc2FsX2NhbGxfdAlzYWxfZGF0YTsKKwkJc3dp
dGNoX3JyNl90CXJyX2RhdGE7CisJCWlwaV9kYXRhX3QJaXBpX2RhdGE7CisJCXB0Y19nX3QJCXB0
Y19nX2RhdGE7CisJfSB1OworfTsKKwordW5pb24gcHRlX2ZsYWdzIHsKKwlzdHJ1Y3QgeworCQl1
bnNpZ25lZCBsb25nIHAgICAgOiAgMTsgLyowICAgICAgKi8KKwkJdW5zaWduZWQgbG9uZyAgICAg
IDogIDE7IC8qIDEgICAgICovCisJCXVuc2lnbmVkIGxvbmcgbWEgICA6ICAzOyAvKiAyLTQgICAq
LworCQl1bnNpZ25lZCBsb25nIGEgICAgOiAgMTsgLyogNSAgICAgKi8KKwkJdW5zaWduZWQgbG9u
ZyBkICAgIDogIDE7IC8qIDYgICAgICovCisJCXVuc2lnbmVkIGxvbmcgcGwgICA6ICAyOyAvKiA3
LTggICAqLworCQl1bnNpZ25lZCBsb25nIGFyICAgOiAgMzsgLyogOS0xMSAgKi8KKwkJdW5zaWdu
ZWQgbG9uZyBwcG4gIDogMzg7IC8qIDEyLTQ5ICovCisJCXVuc2lnbmVkIGxvbmcgICAgICA6ICAy
OyAvKiA1MC01MSAqLworCQl1bnNpZ25lZCBsb25nIGVkICAgOiAgMTsgLyogNTIgICAgKi8KKwl9
OworCXVuc2lnbmVkIGxvbmcgdmFsOworfTsKKworCit0eXBlZGVmIHN0cnVjdCB0aGFzaF9kYXRh
IHsKKwl1bmlvbiB7CisJCXN0cnVjdCB7CisJCQl1bnNpZ25lZCBsb25nIHAgICAgOiAgMTsgLyog
MCAqLworCQkJdW5zaWduZWQgbG9uZyBydjEgIDogIDE7IC8qIDEgKi8KKwkJCXVuc2lnbmVkIGxv
bmcgbWEgICA6ICAzOyAvKiAyLTQgKi8KKwkJCXVuc2lnbmVkIGxvbmcgYSAgICA6ICAxOyAvKiA1
ICovCisJCQl1bnNpZ25lZCBsb25nIGQgICAgOiAgMTsgLyogNiAqLworCQkJdW5zaWduZWQgbG9u
ZyBwbCAgIDogIDI7IC8qIDctOCAqLworCQkJdW5zaWduZWQgbG9uZyBhciAgIDogIDM7IC8qIDkt
MTEgKi8KKwkJCXVuc2lnbmVkIGxvbmcgcHBuICA6IDM4OyAvKiAxMi00OSAqLworCQkJdW5zaWdu
ZWQgbG9uZyBydjIgIDogIDI7IC8qIDUwLTUxICovCisJCQl1bnNpZ25lZCBsb25nIGVkICAgOiAg
MTsgLyogNTIgKi8KKwkJCXVuc2lnbmVkIGxvbmcgaWcxICA6IDExOyAvKiA1My02MyAqLworCQl9
OworCQlzdHJ1Y3QgeworCQkJdW5zaWduZWQgbG9uZyBfX3J2MSA6IDUzOyAgICAgLyogMC01MiAq
LworCQkJdW5zaWduZWQgbG9uZyBjb250aWd1b3VzIDogMTsgLyo1MyAqLworCQkJdW5zaWduZWQg
bG9uZyB0YyA6IDE7ICAgICAgICAgLyogNTQgVFIgb3IgVEMgKi8KKwkJCXVuc2lnbmVkIGxvbmcg
Y2wgOiAxOworCQkJLyogNTUgSSBzaWRlIG9yIEQgc2lkZSBjYWNoZSBsaW5lICovCisJCQl1bnNp
Z25lZCBsb25nIGxlbiAgOiAgNDsgICAgICAvKiA1Ni01OSAqLworCQkJdW5zaWduZWQgbG9uZyBp
byAgOiAxOwkvKiA2MCBlbnRyeSBpcyBmb3IgaW8gb3Igbm90ICovCisJCQl1bnNpZ25lZCBsb25n
IG5vbWFwIDogMTsKKwkJCS8qIDYxIGVudHJ5IGNhbm4ndCBiZSBpbnNlcnRlZCBpbnRvIG1hY2hp
bmUgVExCLiovCisJCQl1bnNpZ25lZCBsb25nIGNoZWNrZWQgOiAxOworCQkJLyogNjIgZm9yIFZU
TEIvVkhQVCBzYW5pdHkgY2hlY2sgKi8KKwkJCXVuc2lnbmVkIGxvbmcgaW52YWxpZCA6IDE7CisJ
CQkvKiA2MyBpbnZhbGlkIGVudHJ5ICovCisJCX07CisJCXVuc2lnbmVkIGxvbmcgcGFnZV9mbGFn
czsKKwl9OyAgICAgICAgICAgICAgICAgIC8qIHNhbWUgZm9yIFZIUFQgYW5kIFRMQiAqLworCisJ
dW5pb24geworCQlzdHJ1Y3QgeworCQkJdW5zaWduZWQgbG9uZyBydjMgIDogIDI7CisJCQl1bnNp
Z25lZCBsb25nIHBzICAgOiAgNjsKKwkJCXVuc2lnbmVkIGxvbmcga2V5ICA6IDI0OworCQkJdW5z
aWduZWQgbG9uZyBydjQgIDogMzI7CisJCX07CisJCXVuc2lnbmVkIGxvbmcgaXRpcjsKKwl9Owor
CXVuaW9uIHsKKwkJc3RydWN0IHsKKwkJCXVuc2lnbmVkIGxvbmcgaWcyICA6ICAxMjsKKwkJCXVu
c2lnbmVkIGxvbmcgdnBuICA6ICA0OTsKKwkJCXVuc2lnbmVkIGxvbmcgdnJuICA6ICAgMzsKKwkJ
fTsKKwkJdW5zaWduZWQgbG9uZyBpZmE7CisJCXVuc2lnbmVkIGxvbmcgdmFkcjsKKwkJc3RydWN0
IHsKKwkJCXVuc2lnbmVkIGxvbmcgdGFnICA6ICA2MzsKKwkJCXVuc2lnbmVkIGxvbmcgdGkgICA6
ICAxOworCQl9OworCQl1bnNpZ25lZCBsb25nIGV0YWc7CisJfTsKKwl1bmlvbiB7CisJCXN0cnVj
dCB0aGFzaF9kYXRhICpuZXh0OworCQl1bnNpZ25lZCBsb25nIHJpZDsKKwkJdW5zaWduZWQgbG9u
ZyBncGFkZHI7CisJfTsKK30gdGhhc2hfZGF0YV90OworCit0eXBlZGVmIHVuaW9uIHsKKwl1bnNp
Z25lZCBsb25nIHZhbDsKKwlzdHJ1Y3QgeworCQl1bnNpZ25lZCBsb25nIHZlIDogMTsKKwkJdW5z
aWduZWQgbG9uZyByZXNlcnZlZDAgOiAxOworCQl1bnNpZ25lZCBsb25nIHNpemUgOiA2OworCQl1
bnNpZ25lZCBsb25nIHZmIDogMTsKKwkJdW5zaWduZWQgbG9uZyByZXNlcnZlZDEgOiA2OworCQl1
bnNpZ25lZCBsb25nIGJhc2UgOiA0OTsKKwl9OworfSBpYTY0X3B0YTsKKwordHlwZWRlZiBzdHJ1
Y3QgdGhhc2hfY2IgeworCS8qIFRIQVNIIGJhc2UgaW5mb3JtYXRpb24gKi8KKwl0aGFzaF9kYXRh
X3QgICpoYXNoOyAvKiBoYXNoIHRhYmxlIHBvaW50ZXIsIGFsaWduZWQgYXQgdGhhc2hfc3ouKi8K
KwlpYTY0X3B0YSAgICAgIHB0YTsKKwlpbnQgICAgICAgICAgIG51bTsKK30gdGhhc2hfY2JfdDsK
KwordHlwZWRlZiB1bmlvbiBjb250ZXh0IHsKKwkvKiA4SyBzaXplICovCisJdW5zaWduZWQgbG9u
ZyAgICAgICBkdW1teVsxMDI0XTsKKwlzdHJ1Y3QgeworCQl1bnNpZ25lZCBsb25nICAgICAgIHBz
cjsKKwkJdW5zaWduZWQgbG9uZyAgICAgICBwcjsKKwkJdW5zaWduZWQgbG9uZyAgICAgICBjYWxs
ZXJfdW5hdDsKKwkJdW5zaWduZWQgbG9uZyAgICAgICBwYWQ7CisJCXVuc2lnbmVkIGxvbmcgICAg
ICAgZ3JbMzJdOworCQl1bnNpZ25lZCBsb25nICAgICAgIGFyWzEyOF07CisJCXVuc2lnbmVkIGxv
bmcgICAgICAgYnJbOF07CisJCXVuc2lnbmVkIGxvbmcgICAgICAgY3JbMTI4XTsKKwkJdW5zaWdu
ZWQgbG9uZyAgICAgICBycls4XTsKKwkJdW5zaWduZWQgbG9uZyAgICAgICBpYnJbOF07CisJCXVu
c2lnbmVkIGxvbmcgICAgICAgZGJyWzhdOworCQl1bnNpZ25lZCBsb25nICAgICAgIHBrcls4XTsK
KwkJc3RydWN0IGlhNjRfZnByZWcgICBmclsxMjhdOworCX07Cit9IGNvbnRleHRfdDsKKworI2Rl
ZmluZQlOSVRSUwk4CisjZGVmaW5lIE5EVFJTCTgKKworc3RydWN0IGt2bV92Y3B1X3N0YXQgewor
fTsKK3N0cnVjdCBrdm1fdmNwdV9hcmNoIHsKKwlpbnQgbGF1bmNoZWQ7CisJaW50IGxhc3RfZXhp
dDsKKwlpbnQgbGFzdF9ydW5fY3B1OworCisjZGVmaW5lIFZDUFVfTVBfU1RBVEVfUlVOTkFCTEUg
ICAgICAgICAgMAorI2RlZmluZSBWQ1BVX01QX1NUQVRFX1VOSU5JVElBTElaRUQgICAgIDEKKyNk
ZWZpbmUgVkNQVV9NUF9TVEFURV9JTklUX1JFQ0VJVkVEICAgICAyCisjZGVmaW5lIFZDUFVfTVBf
U1RBVEVfSEFMVEVEICAgICAgICAgICAgMworCWludCBtcF9zdGF0ZTsKKworI2RlZmluZSBNQVhf
UFRDX0dfTlVNCQkJMworCWludCBwdGNfZ19jb3VudDsKKwlzdHJ1Y3Qga3ZtX3B0Y19nIHB0Y19n
X2RhdGFbTUFYX1BUQ19HX05VTV07CisKKwkvKmhhbHQgdGltZXIgdG8gd2FrZSB1cCBzbGVlcHkg
dmNwdXMqLworCXN0cnVjdCBocnRpbWVyIGhsdF90aW1lcjsKKwlsb25nIGh0X2FjdGl2ZTsKKwor
CXZvaWQgKnBpb19kYXRhOworCXN0cnVjdCBrdm1fcGlvX3JlcXVlc3QgcGlvOworCXN0cnVjdCBr
dm1fbGFwaWMgKmFwaWM7ICAgIC8qIGtlcm5lbCBpcnFjaGlwIGNvbnRleHQgKi8KKwlzdHJ1Y3Qg
dnBkICp2cGQ7CisKKwkvKiBFeGl0IGRhdGEgZm9yIHZtbV90cmFuc2l0aW9uKi8KKwlzdHJ1Y3Qg
ZXhpdF9jdGxfZGF0YSBleGl0X2RhdGE7CisKKwljcHVtYXNrX3QgY2FjaGVfY29oZXJlbnRfbWFw
OworCisJdW5zaWduZWQgbG9uZyB2bW1fcnI7CisJdW5zaWduZWQgbG9uZyBob3N0X3JyNjsKKwl1
bnNpZ25lZCBsb25nIHBzYml0c1s4XTsKKwl1bnNpZ25lZCBsb25nIGNyX2lpcGE7CisJdW5zaWdu
ZWQgbG9uZyBjcl9pc3I7CisJdW5zaWduZWQgbG9uZyB2c2FfYmFzZTsKKwl1bnNpZ25lZCBsb25n
IF9fZ3A7CisJLyogVFIgYW5kIFRDLiAgKi8KKwl0aGFzaF9kYXRhX3QgaXRyc1tOSVRSU107CisJ
dGhhc2hfZGF0YV90IGR0cnNbTkRUUlNdOworCS8qIEJpdCBpcyBzZXQgaWYgdGhlcmUgaXMgYSB0
ci90YyBmb3IgdGhlIHJlZ2lvbi4gICovCisJdW5zaWduZWQgY2hhciBpdHJfcmVnaW9uczsKKwl1
bnNpZ25lZCBjaGFyIGR0cl9yZWdpb25zOworCXVuc2lnbmVkIGNoYXIgdGNfcmVnaW9uczsKKwkv
KiBwdXJnZSBhbGwgKi8KKwl1bnNpZ25lZCBsb25nIHB0Y2VfYmFzZTsKKwl1bnNpZ25lZCBsb25n
IHB0Y2VfY291bnRbMl07CisJdW5zaWduZWQgbG9uZyBwdGNlX3N0cmlkZVsyXTsKKwkvKiBpdGMv
aXRtICovCisJdW5zaWduZWQgbG9uZyBsYXN0X2l0YzsKKwlsb25nIGl0Y19vZmZzZXQ7CisJdW5z
aWduZWQgbG9uZyBpdGNfY2hlY2s7CisJdW5zaWduZWQgbG9uZyB0aW1lcl9jaGVjazsKKwl1bnNp
Z25lZCBsb25nIHRpbWVyX3BlbmRpbmc7CisKKworCXVuc2lnbmVkIGxvbmcgdnJyWzhdOworCXVu
c2lnbmVkIGxvbmcgaWJyWzhdOworCXVuc2lnbmVkIGxvbmcgZGJyWzhdOworCXVuc2lnbmVkIGxv
bmcgaW5zdmNbNF07CQkvKiBJbnRlcnJ1cHQgaW4gc2VydmljZS4gICovCisJdW5zaWduZWQgbG9u
ZyB4dHA7CisKKwkvKiBUaGVzZSBmaWVsZHMgYXJlIGNvcGllZCBmcm9tIGFyY2hfZG9tYWluIHRv
IG1ha2UgYWNjZXNzCisJZWFzaWVyL2Zhc3RlciBpbiBhc3NlbWJseSBjb2RlLiAgKi8KKwl1bnNp
Z25lZCBsb25nIG1ldGFwaHlzaWNhbF9ycjA7IC8qIGZyb20ga3ZtX2FyY2ggKHNvIGlzIHBpbm5l
ZCkgKi8KKwl1bnNpZ25lZCBsb25nIG1ldGFwaHlzaWNhbF9ycjQ7CS8qIGZyb20ga3ZtX2FyY2gg
KHNvIGlzIHBpbm5lZCkgKi8KKwl1bnNpZ25lZCBsb25nIG1ldGFwaHlzaWNhbF9zYXZlZF9ycjA7
IC8qIGZyb20ga3ZtX2FyY2ggICAgICAgICAgKi8KKwl1bnNpZ25lZCBsb25nIG1ldGFwaHlzaWNh
bF9zYXZlZF9ycjQ7IC8qIGZyb20ga3ZtX2FyY2ggICAgICAgICAgKi8KKwl1bnNpZ25lZCBsb25n
IGZwX3BzcjsgICAgICAgLyp1c2VkIGZvciBsYXp5IGZsb2F0IHJlZ2lzdGVyICovCisJdW5zaWdu
ZWQgbG9uZyBzYXZlZF9ncDsKKwkvKmZvciBwaHljaWFsICBlbXVsYXRpb24gKi8KKwlpbnQgbW9k
ZV9mbGFnczsKKwl0aGFzaF9jYl90IHZ0bGI7CisJdGhhc2hfY2JfdCB2aHB0OworCWNoYXIgaXJx
X2NoZWNrOworCWNoYXIgaXJxX25ld19wZW5kaW5nOworCisJdW5zaWduZWQgbG9uZyBvcGNvZGU7
CisJdW5zaWduZWQgbG9uZyBjYXVzZTsKKwljb250ZXh0X3QgaG9zdDsKKwljb250ZXh0X3QgZ3Vl
c3Q7CisKK307CisKK3N0cnVjdCBrdm1fdm1fc3RhdCB7CisJdTY0IHJlbW90ZV90bGJfZmx1c2g7
Cit9OworCitzdHJ1Y3Qga3ZtX3NhbF9kYXRhIHsKKwl1bnNpZ25lZCBsb25nIGJvb3RfaXA7CisJ
dW5zaWduZWQgbG9uZyBib290X2dwOworfTsKKworc3RydWN0IGt2bV9hcmNoIHsKKwl1bnNpZ25l
ZCBsb25nCXZtX2Jhc2U7CisJdW5zaWduZWQgbG9uZwltZXRhcGh5c2ljYWxfcnIwOworCXVuc2ln
bmVkIGxvbmcJbWV0YXBoeXNpY2FsX3JyNDsKKwl1bnNpZ25lZCBsb25nCXZtbV9pbml0X3JyOwor
CXVuc2lnbmVkIGxvbmcJdmhwdF9iYXNlOworCXVuc2lnbmVkIGxvbmcJdnRsYl9iYXNlOworCXVu
c2lnbmVkIGxvbmcgCXZwZF9iYXNlOworCXN0cnVjdCBrdm1faW9hcGljICp2aW9hcGljOworCXN0
cnVjdCBrdm1fdm1fc3RhdCBzdGF0OworCXN0cnVjdCBrdm1fc2FsX2RhdGEgcmR2X3NhbF9kYXRh
OworfTsKKwordHlwZWRlZiB1bmlvbiB7CisJdTY0IHZhbHVlOworCXN0cnVjdCB7CisJCXU2NCBu
dW1iZXIgOiA4OworCQl1NjQgcmV2aXNpb24gOiA4OworCQl1NjQgbW9kZWwgOiA4OworCQl1NjQg
ZmFtaWx5IDogODsKKwkJdTY0IGFyY2hyZXYgOiA4OworCQl1NjQgcnYgOiAyNDsKKwl9OworfSBj
cHVpZDNfdDsKKworc3RydWN0IGt2bV9wdF9yZWdzIHsKKyAgICAvKiBUaGUgZm9sbG93aW5nIHJl
Z2lzdGVycyBhcmUgc2F2ZWQgYnkgU0FWRV9NSU46ICovCisgICAgdW5zaWduZWQgbG9uZyBiNjsg
IC8qIHNjcmF0Y2ggKi8KKyAgICB1bnNpZ25lZCBsb25nIGI3OyAgLyogc2NyYXRjaCAqLworCisg
ICAgdW5zaWduZWQgbG9uZyBhcl9jc2Q7IC8qIHVzZWQgYnkgY21wOHhjaGcxNiAoc2NyYXRjaCkg
Ki8KKyAgICB1bnNpZ25lZCBsb25nIGFyX3NzZDsgLyogcmVzZXJ2ZWQgZm9yIGZ1dHVyZSB1c2Ug
KHNjcmF0Y2gpICovCisKKyAgICB1bnNpZ25lZCBsb25nIHI4OyAgLyogc2NyYXRjaCAocmV0dXJu
IHZhbHVlIHJlZ2lzdGVyIDApICovCisgICAgdW5zaWduZWQgbG9uZyByOTsgIC8qIHNjcmF0Y2gg
KHJldHVybiB2YWx1ZSByZWdpc3RlciAxKSAqLworICAgIHVuc2lnbmVkIGxvbmcgcjEwOyAvKiBz
Y3JhdGNoIChyZXR1cm4gdmFsdWUgcmVnaXN0ZXIgMikgKi8KKyAgICB1bnNpZ25lZCBsb25nIHIx
MTsgLyogc2NyYXRjaCAocmV0dXJuIHZhbHVlIHJlZ2lzdGVyIDMpICovCisKKyAgICB1bnNpZ25l
ZCBsb25nIGNyX2lwc3I7IC8qIGludGVycnVwdGVkIHRhc2sncyBwc3IgKi8KKyAgICB1bnNpZ25l
ZCBsb25nIGNyX2lpcDsgIC8qIGludGVycnVwdGVkIHRhc2sncyBpbnN0cnVjdGlvbiBwb2ludGVy
ICovCisgICAgdW5zaWduZWQgbG9uZyBjcl9pZnM7ICAvKiBpbnRlcnJ1cHRlZCB0YXNrJ3MgZnVu
Y3Rpb24gc3RhdGUgKi8KKworICAgIHVuc2lnbmVkIGxvbmcgYXJfdW5hdDsgLyogaW50ZXJydXB0
ZWQgdGFzaydzIE5hVCByZWdpc3RlciAocHJlc2VydmVkKSAqLworICAgIHVuc2lnbmVkIGxvbmcg
YXJfcGZzOyAgLyogcHJldiBmdW5jdGlvbiBzdGF0ZSAgKi8KKyAgICB1bnNpZ25lZCBsb25nIGFy
X3JzYzsgIC8qIFJTRSBjb25maWd1cmF0aW9uICovCisgICAgLyogVGhlIGZvbGxvd2luZyB0d28g
YXJlIHZhbGlkIG9ubHkgaWYgY3JfaXBzci5jcGwgPiAwOiAqLworICAgIHVuc2lnbmVkIGxvbmcg
YXJfcm5hdDsgIC8qIFJTRSBOYVQgKi8KKyAgICB1bnNpZ25lZCBsb25nIGFyX2JzcHN0b3JlOyAv
KiBSU0UgYnNwc3RvcmUgKi8KKworICAgIHVuc2lnbmVkIGxvbmcgcHI7ICAvKiA2NCBwcmVkaWNh
dGUgcmVnaXN0ZXJzICgxIGJpdCBlYWNoKSAqLworICAgIHVuc2lnbmVkIGxvbmcgYjA7ICAvKiBy
ZXR1cm4gcG9pbnRlciAoYnApICovCisgICAgdW5zaWduZWQgbG9uZyBsb2FkcnM7ICAvKiBzaXpl
IG9mIGRpcnR5IHBhcnRpdGlvbiA8PCAxNiAqLworCisgICAgdW5zaWduZWQgbG9uZyByMTsgIC8q
IHRoZSBncCBwb2ludGVyICovCisgICAgdW5zaWduZWQgbG9uZyByMTI7IC8qIGludGVycnVwdGVk
IHRhc2sncyBtZW1vcnkgc3RhY2sgcG9pbnRlciAqLworICAgIHVuc2lnbmVkIGxvbmcgcjEzOyAv
KiB0aHJlYWQgcG9pbnRlciAqLworCisgICAgdW5zaWduZWQgbG9uZyBhcl9mcHNyOyAgLyogZmxv
YXRpbmcgcG9pbnQgc3RhdHVzIChwcmVzZXJ2ZWQpICovCisgICAgdW5zaWduZWQgbG9uZyByMTU7
ICAvKiBzY3JhdGNoICovCisKKyAvKiBUaGUgcmVtYWluaW5nIHJlZ2lzdGVycyBhcmUgTk9UIHNh
dmVkIGZvciBzeXN0ZW0gY2FsbHMuICAqLworCisgICAgdW5zaWduZWQgbG9uZyByMTQ7ICAvKiBz
Y3JhdGNoICovCisgICAgdW5zaWduZWQgbG9uZyByMjsgIC8qIHNjcmF0Y2ggKi8KKyAgICB1bnNp
Z25lZCBsb25nIHIzOyAgLyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxvbmcgcjE2OyAgLyog
c2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxvbmcgcjE3OyAgLyogc2NyYXRjaCAqLworICAgIHVu
c2lnbmVkIGxvbmcgcjE4OyAgLyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxvbmcgcjE5OyAg
Lyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxvbmcgcjIwOyAgLyogc2NyYXRjaCAqLworICAg
IHVuc2lnbmVkIGxvbmcgcjIxOyAgLyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxvbmcgcjIy
OyAgLyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxvbmcgcjIzOyAgLyogc2NyYXRjaCAqLwor
ICAgIHVuc2lnbmVkIGxvbmcgcjI0OyAgLyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxvbmcg
cjI1OyAgLyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxvbmcgcjI2OyAgLyogc2NyYXRjaCAq
LworICAgIHVuc2lnbmVkIGxvbmcgcjI3OyAgLyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxv
bmcgcjI4OyAgLyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxvbmcgcjI5OyAgLyogc2NyYXRj
aCAqLworICAgIHVuc2lnbmVkIGxvbmcgcjMwOyAgLyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVk
IGxvbmcgcjMxOyAgLyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxvbmcgYXJfY2N2OyAgLyog
Y29tcGFyZS9leGNoYW5nZSB2YWx1ZSAoc2NyYXRjaCkgKi8KKworCisgICAgLyoKKyAgICAgKiBG
bG9hdGluZyBwb2ludCByZWdpc3RlcnMgdGhhdCB0aGUga2VybmVsIGNvbnNpZGVycyBzY3JhdGNo
OgorICAgICAqLworICAgIHN0cnVjdCBpYTY0X2ZwcmVnIGY2OyAgLyogc2NyYXRjaCAqLworICAg
IHN0cnVjdCBpYTY0X2ZwcmVnIGY3OyAgLyogc2NyYXRjaCAqLworICAgIHN0cnVjdCBpYTY0X2Zw
cmVnIGY4OyAgLyogc2NyYXRjaCAqLworICAgIHN0cnVjdCBpYTY0X2ZwcmVnIGY5OyAgLyogc2Ny
YXRjaCAqLworICAgIHN0cnVjdCBpYTY0X2ZwcmVnIGYxMDsgIC8qIHNjcmF0Y2ggKi8KKyAgICBz
dHJ1Y3QgaWE2NF9mcHJlZyBmMTE7ICAvKiBzY3JhdGNoICovCisKKyAgICB1bnNpZ25lZCBsb25n
IHI0OyAgLyogcHJlc2VydmVkICovCisgICAgdW5zaWduZWQgbG9uZyByNTsgIC8qIHByZXNlcnZl
ZCAqLworICAgIHVuc2lnbmVkIGxvbmcgcjY7ICAvKiBwcmVzZXJ2ZWQgKi8KKyAgICB1bnNpZ25l
ZCBsb25nIHI3OyAgLyogcHJlc2VydmVkICovCisgICAgdW5zaWduZWQgbG9uZyBlbWxfdW5hdDsg
ICAgLyogdXNlZCBmb3IgZW11bGF0aW5nIGluc3RydWN0aW9uICovCisgICAgdW5zaWduZWQgbG9u
ZyBwYWQwOyAgICAgLyogYWxpZ25tZW50IHBhZCAqLworCit9OworCitzdGF0aWMgaW5saW5lIHN0
cnVjdCBrdm1fcHRfcmVncyAqdmNwdV9yZWdzKHN0cnVjdCBrdm1fdmNwdSAqdikKK3sKKwlyZXR1
cm4gKHN0cnVjdCBrdm1fcHRfcmVncyAqKSAoKHVuc2lnbmVkIGxvbmcpIHYgKyBJQTY0X1NUS19P
RkZTRVQpIC0gMTsKK30KKwordHlwZWRlZiBpbnQga3ZtX3ZtbV9lbnRyeSh2b2lkKTsKK3R5cGVk
ZWYgdm9pZCBrdm1fdHJhbXBfZW50cnkoY29udGV4dF90ICpob3N0LCBjb250ZXh0X3QgKmd1ZXN0
KTsKKworc3RydWN0IGt2bV92bW1faW5mb3sKKwlzdHJ1Y3QgbW9kdWxlCSptb2R1bGU7CisJa3Zt
X3ZtbV9lbnRyeSAJKnZtbV9lbnRyeTsKKwlrdm1fdHJhbXBfZW50cnkgKnRyYW1wX2VudHJ5Owor
CXVuc2lnbmVkIGxvbmcgCXZtbV9pdnQ7Cit9OworCitpbnQga3ZtX2hpZ2hlc3RfcGVuZGluZ19p
cnEoc3RydWN0IGt2bV92Y3B1ICp2Y3B1KTsKK2ludCBrdm1fZW11bGF0ZV9oYWx0KHN0cnVjdCBr
dm1fdmNwdSAqdmNwdSk7CitpbnQga3ZtX3BhbF9lbXVsKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwg
c3RydWN0IGt2bV9ydW4gKmt2bV9ydW4pOwordm9pZCBrdm1fc2FsX2VtdWwoc3RydWN0IGt2bV92
Y3B1ICp2Y3B1KTsKKworLypDdXJyZW50bHksIHRoaXMgbWFjcm8gaXMgbm90IHVzZWQgYnkga3Zt
L2lhNjQsIE9uY2UgbmVjZXNzYXJ5LAorIGl0IHNob3VsZCBiZSBpbXBsZW1lbnRlZCBsYXRlciEh
Ki8KKyNkZWZpbmUgc21wX2NhbGxfZnVuY3Rpb25fbWFzayhjcHVzX21hc2ssIGZ1bmMsIGluZm8s
IHdhaXQpXAorCXNtcF9jYWxsX2Z1bmN0aW9uKGZ1bmMsIGluZm8sIDAsIHdhaXQpCisKKyNlbmRp
ZgpkaWZmIC0tZ2l0IGEvaW5jbHVkZS9hc20taWE2NC9rdm1fcGFyYS5oIGIvaW5jbHVkZS9hc20t
aWE2NC9rdm1fcGFyYS5oCm5ldyBmaWxlIG1vZGUgMTAwNjQ0CmluZGV4IDAwMDAwMDAuLjkwZDU2
NTgKLS0tIC9kZXYvbnVsbAorKysgYi9pbmNsdWRlL2FzbS1pYTY0L2t2bV9wYXJhLmgKQEAgLTAs
MCArMSwyOSBAQAorI2lmbmRlZiBfX0lBNjRfS1ZNX1BBUkFfSAorI2RlZmluZSBfX0lBNjRfS1ZN
X1BBUkFfSAorCisvKgorICogYXNtLWlhNjQva3ZtX3BhcmEuaAorICoKKyAqIENvcHlyaWdodCAo
QykgMjAwNyBaaGFuZyBYaWFudGFvIDx4aWFudGFvLnpoYW5nQGludGVsLmNvbT4KKyAqCisgKiBU
aGlzIHByb2dyYW0gaXMgZnJlZSBzb2Z0d2FyZTsgeW91IGNhbiByZWRpc3RyaWJ1dGUgaXQgYW5k
L29yIG1vZGlmeSBpdAorICogdW5kZXIgdGhlIHRlcm1zIGFuZCBjb25kaXRpb25zIG9mIHRoZSBH
TlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSwKKyAqIHZlcnNpb24gMiwgYXMgcHVibGlzaGVkIGJ5
IHRoZSBGcmVlIFNvZnR3YXJlIEZvdW5kYXRpb24uCisgKgorICogVGhpcyBwcm9ncmFtIGlzIGRp
c3RyaWJ1dGVkIGluIHRoZSBob3BlIGl0IHdpbGwgYmUgdXNlZnVsLCBidXQgV0lUSE9VVAorICog
QU5ZIFdBUlJBTlRZOyB3aXRob3V0IGV2ZW4gdGhlIGltcGxpZWQgd2FycmFudHkgb2YgTUVSQ0hB
TlRBQklMSVRZIG9yCisgKiBGSVRORVNTIEZPUiBBIFBBUlRJQ1VMQVIgUFVSUE9TRS4gIFNlZSB0
aGUgR05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2UgZm9yCisgKiBtb3JlIGRldGFpbHMuCisgKgor
ICogWW91IHNob3VsZCBoYXZlIHJlY2VpdmVkIGEgY29weSBvZiB0aGUgR05VIEdlbmVyYWwgUHVi
bGljIExpY2Vuc2UgYWxvbmcgd2l0aAorICogdGhpcyBwcm9ncmFtOyBpZiBub3QsIHdyaXRlIHRv
IHRoZSBGcmVlIFNvZnR3YXJlIEZvdW5kYXRpb24sIEluYy4sIDU5IFRlbXBsZQorICogUGxhY2Ug
LSBTdWl0ZSAzMzAsIEJvc3RvbiwgTUEgMDIxMTEtMTMwNyBVU0EuCisgKgorICovCisKK3N0YXRp
YyBpbmxpbmUgdW5zaWduZWQgaW50IGt2bV9hcmNoX3BhcmFfZmVhdHVyZXModm9pZCkKK3sKKwly
ZXR1cm4gMDsKK30KKworI2VuZGlmCi0tIAoxLjUuMQoK

------_=_NextPart_001_01C863F4.15F1B537--
