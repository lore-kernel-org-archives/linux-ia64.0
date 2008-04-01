From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Tue, 01 Apr 2008 10:43:52 +0000
Subject: [Patch][04/18] KVM: IA64: Add header files for kvm/ia64. V9
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC01048723@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C893E5.477AAB0B"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C893E5.477AAB0B
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 759f98f6cb61f5f6064180562656ef052f38490c Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Tue, 1 Apr 2008 14:45:06 +0800
Subject: [PATCH] KVM: IA64: Add header files for kvm/ia64.

Three header files are added:
asm-ia64/kvm.h
asm-ia64/kvm_host.h
asm-ia64/kvm_para.h
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 include/asm-ia64/kvm.h      |  205 +++++++++++++++++
 include/asm-ia64/kvm_host.h |  524
+++++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/kvm_para.h |   29 +++
 3 files changed, 758 insertions(+), 0 deletions(-)
 create mode 100644 include/asm-ia64/kvm.h
 create mode 100644 include/asm-ia64/kvm_host.h
 create mode 100644 include/asm-ia64/kvm_para.h

diff --git a/include/asm-ia64/kvm.h b/include/asm-ia64/kvm.h
new file mode 100644
index 0000000..eb2d355
--- /dev/null
+++ b/include/asm-ia64/kvm.h
@@ -0,0 +1,205 @@
+#ifndef __ASM_IA64_KVM_H
+#define __ASM_IA64_KVM_H
+
+/*
+ * asm-ia64/kvm.h: kvm structure definitions  for ia64
+ *
+ * Copyright (C) 2007 Xiantao Zhang <xiantao.zhang@intel.com>
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
+#include <asm/fpu.h>
+
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
+#define KVM_CONTEXT_SIZE	8*1024
+
+union context {
+	/* 8K size */
+	char	dummy[KVM_CONTEXT_SIZE];
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
+};
+
+struct thash_data {
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
+};
+
+#define	NITRS	8
+#define NDTRS	8
+
+struct saved_vpd {
+	unsigned long  vhpi;
+	unsigned long  vgr[16];
+	unsigned long  vbgr[16];
+	unsigned long  vnat;
+	unsigned long  vbnat;
+	unsigned long  vcpuid[5];
+	unsigned long  vpsr;
+	unsigned long  vpr;
+	unsigned long  vcr[128];
+};
+
+struct kvm_regs {
+	char *saved_guest;
+	char *saved_stack;
+	struct saved_vpd vpd;
+	/*Arch-regs*/
+	int mp_state;
+	unsigned long vmm_rr;
+	/* TR and TC.  */
+	struct thash_data itrs[NITRS];
+	struct thash_data dtrs[NDTRS];
+	/* Bit is set if there is a tr/tc for the region.  */
+	unsigned char itr_regions;
+	unsigned char dtr_regions;
+	unsigned char tc_regions;
+
+	char irq_check;
+	unsigned long saved_itc;
+	unsigned long itc_check;
+	unsigned long timer_check;
+	unsigned long timer_pending;
+	unsigned long last_itc;
+
+	unsigned long vrr[8];
+	unsigned long ibr[8];
+	unsigned long dbr[8];
+	unsigned long insvc[4];		/* Interrupt in service.  */
+	unsigned long xtp;
+
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
index 0000000..d6d6e15
--- /dev/null
+++ b/include/asm-ia64/kvm_host.h
@@ -0,0 +1,524 @@
+/*
+ * kvm_host.h: used for kvm module, and hold ia64-specific sections.
+ *
+ * Copyright (C) 2007, Intel Corporation.
+ *
+ * Xiantao Zhang <xiantao.zhang@intel.com>
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
+
+#define KVM_MAX_VCPUS 4
+#define KVM_MEMORY_SLOTS 32
+/* memory slots that does not exposed to userspace */
+#define KVM_PRIVATE_MEM_SLOTS 4
+
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
+#define KVM_VM_BLOCK_SIZE     (1UL<<19)
+
+#define KVM_MEM_DIRTY_LOG_BASE (KVM_VM_BASE+KVM_VM_BLOCK_SIZE)
+#define KVM_MEM_DIRTY_LOG_OFS  (KVM_VM_OFS+KVM_VM_BLOCK_SIZE)
+#define KVM_MEM_DIRTY_LOG_SIZE (1UL<<19)
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
+#define LEGACY_IO_SIZE   (64 * MEM_M)
+#define IO_SAPIC_START   0xfec00000UL
+#define IO_SAPIC_SIZE    0x100000
+#define PIB_START 0xfee00000UL
+#define PIB_SIZE 0x200000
+#define GFW_START        (4 * MEM_G - 16 * MEM_M)
+#define GFW_SIZE         (16 * MEM_M)
+
+/*Deliver mode, defined for ioapic.c*/
+#define dest_Fixed IOSAPIC_FIXED
+#define dest_LowestPrio IOSAPIC_LOWEST_PRIORITY
+
+#define NMI_VECTOR      		2
+#define ExtINT_VECTOR       		0
+#define NULL_VECTOR     		(-1)
+#define IA64_SPURIOUS_INT_VECTOR    	0x0f
+
+#define VCPU_LID(v) (((u64)(v)->vcpu_id) << 24)
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
+#define KVM_REQ_RESUME		33
+
+#define KVM_PAGES_PER_HPAGE	1
+
+struct kvm;
+struct kvm_vcpu;
+struct kvm_guest_debug{
+};
+
+struct kvm_mmio_req {
+	uint64_t addr;          /*  physical address		*/
+	uint64_t size;          /*  size in bytes		*/
+	uint64_t data;          /*  data (or paddr of data)     */
+	uint8_t state:4;
+	uint8_t dir:1;          /*  1=3Dread, 0=3Dwrite             */
+};
+
+/*Pal data struct */
+struct kvm_pal_call{
+	/*In area*/
+	uint64_t gr28;
+	uint64_t gr29;
+	uint64_t gr30;
+	uint64_t gr31;
+	/*Out area*/
+	struct ia64_pal_retval ret;
+};
+
+/* Sal data structure */
+struct kvm_sal_call{
+	/*In area*/
+	uint64_t in0;
+	uint64_t in1;
+	uint64_t in2;
+	uint64_t in3;
+	uint64_t in4;
+	uint64_t in5;
+	uint64_t in6;
+	uint64_t in7;
+	struct sal_ret_values ret;
+};
+
+/*Guest change rr6*/
+struct kvm_switch_rr6 {
+	uint64_t old_rr;
+	uint64_t new_rr;
+};
+
+union ia64_ipi_a{
+	unsigned long val;
+	struct {
+		unsigned long rv  : 3;
+		unsigned long ir  : 1;
+		unsigned long eid : 8;
+		unsigned long id  : 8;
+		unsigned long ib_base : 44;
+	};
+};
+
+union ia64_ipi_d {
+	unsigned long val;
+	struct {
+		unsigned long vector : 8;
+		unsigned long dm  : 3;
+		unsigned long ig  : 53;
+	};
+};
+
+/*ipi check exit data*/
+struct kvm_ipi_data{
+	union ia64_ipi_a addr;
+	union ia64_ipi_d data;
+};
+
+/*global purge data*/
+struct kvm_ptc_g {
+	unsigned long vaddr;
+	unsigned long rr;
+	unsigned long ps;
+	struct kvm_vcpu *vcpu;
+};
+
+/*Exit control data */
+struct exit_ctl_data{
+	uint32_t exit_reason;
+	uint32_t vm_status;
+	union {
+		struct kvm_mmio_req	ioreq;
+		struct kvm_pal_call	pal_data;
+		struct kvm_sal_call	sal_data;
+		struct kvm_switch_rr6	rr_data;
+		struct kvm_ipi_data	ipi_data;
+		struct kvm_ptc_g	ptc_g_data;
+	} u;
+};
+
+union pte_flags {
+	unsigned long val;
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
+};
+
+union ia64_pta {
+	unsigned long val;
+	struct {
+		unsigned long ve : 1;
+		unsigned long reserved0 : 1;
+		unsigned long size : 6;
+		unsigned long vf : 1;
+		unsigned long reserved1 : 6;
+		unsigned long base : 49;
+	};
+};
+
+struct thash_cb {
+	/* THASH base information */
+	struct thash_data	*hash; /* hash table pointer */
+	union ia64_pta		pta;
+	int           num;
+};
+
+struct kvm_vcpu_stat {
+};
+
+struct kvm_vcpu_arch {
+	int launched;
+	int last_exit;
+	int last_run_cpu;
+	int vmm_tr_slot;
+	int vm_tr_slot;
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
+	unsigned long dirty_log_lock_pa;
+	unsigned long __gp;
+	/* TR and TC.  */
+	struct thash_data itrs[NITRS];
+	struct thash_data dtrs[NDTRS];
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
+	unsigned long vrr[8];
+	unsigned long ibr[8];
+	unsigned long dbr[8];
+	unsigned long insvc[4];		/* Interrupt in service.  */
+	unsigned long xtp;
+
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
+	struct thash_cb vtlb;
+	struct thash_cb vhpt;
+	char irq_check;
+	char irq_new_pending;
+
+	unsigned long opcode;
+	unsigned long cause;
+	union context host;
+	union context guest;
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
+	spinlock_t dirty_log_lock;
+	struct kvm_ioapic *vioapic;
+	struct kvm_vm_stat stat;
+	struct kvm_sal_data rdv_sal_data;
+};
+
+union cpuid3_t {
+	u64 value;
+	struct {
+		u64 number : 8;
+		u64 revision : 8;
+		u64 model : 8;
+		u64 family : 8;
+		u64 archrev : 8;
+		u64 rv : 24;
+	};
+};
+
+struct kvm_pt_regs {
+	/* The following registers are saved by SAVE_MIN: */
+	unsigned long b6;  /* scratch */
+	unsigned long b7;  /* scratch */
+
+	unsigned long ar_csd; /* used by cmp8xchg16 (scratch) */
+	unsigned long ar_ssd; /* reserved for future use (scratch) */
+
+	unsigned long r8;  /* scratch (return value register 0) */
+	unsigned long r9;  /* scratch (return value register 1) */
+	unsigned long r10; /* scratch (return value register 2) */
+	unsigned long r11; /* scratch (return value register 3) */
+
+	unsigned long cr_ipsr; /* interrupted task's psr */
+	unsigned long cr_iip;  /* interrupted task's instruction pointer
*/
+	unsigned long cr_ifs;  /* interrupted task's function state */
+
+	unsigned long ar_unat; /* interrupted task's NaT register
(preserved) */
+	unsigned long ar_pfs;  /* prev function state  */
+	unsigned long ar_rsc;  /* RSE configuration */
+	/* The following two are valid only if cr_ipsr.cpl > 0: */
+	unsigned long ar_rnat;  /* RSE NaT */
+	unsigned long ar_bspstore; /* RSE bspstore */
+
+	unsigned long pr;  /* 64 predicate registers (1 bit each) */
+	unsigned long b0;  /* return pointer (bp) */
+	unsigned long loadrs;  /* size of dirty partition << 16 */
+
+	unsigned long r1;  /* the gp pointer */
+	unsigned long r12; /* interrupted task's memory stack pointer */
+	unsigned long r13; /* thread pointer */
+
+	unsigned long ar_fpsr;  /* floating point status (preserved) */
+	unsigned long r15;  /* scratch */
+
+	/* The remaining registers are NOT saved for system calls.  */
+	unsigned long r14;  /* scratch */
+	unsigned long r2;  /* scratch */
+	unsigned long r3;  /* scratch */
+	unsigned long r16;  /* scratch */
+	unsigned long r17;  /* scratch */
+	unsigned long r18;  /* scratch */
+	unsigned long r19;  /* scratch */
+	unsigned long r20;  /* scratch */
+	unsigned long r21;  /* scratch */
+	unsigned long r22;  /* scratch */
+	unsigned long r23;  /* scratch */
+	unsigned long r24;  /* scratch */
+	unsigned long r25;  /* scratch */
+	unsigned long r26;  /* scratch */
+	unsigned long r27;  /* scratch */
+	unsigned long r28;  /* scratch */
+	unsigned long r29;  /* scratch */
+	unsigned long r30;  /* scratch */
+	unsigned long r31;  /* scratch */
+	unsigned long ar_ccv;  /* compare/exchange value (scratch) */
+
+	/*
+	 * Floating point registers that the kernel considers scratch:
+	 */
+	struct ia64_fpreg f6;  /* scratch */
+	struct ia64_fpreg f7;  /* scratch */
+	struct ia64_fpreg f8;  /* scratch */
+	struct ia64_fpreg f9;  /* scratch */
+	struct ia64_fpreg f10;  /* scratch */
+	struct ia64_fpreg f11;  /* scratch */
+
+	unsigned long r4;  /* preserved */
+	unsigned long r5;  /* preserved */
+	unsigned long r6;  /* preserved */
+	unsigned long r7;  /* preserved */
+	unsigned long eml_unat;    /* used for emulating instruction */
+	unsigned long pad0;     /* alignment pad */
+};
+
+static inline struct kvm_pt_regs *vcpu_regs(struct kvm_vcpu *v)
+{
+	return (struct kvm_pt_regs *) ((unsigned long) v +
IA64_STK_OFFSET) - 1;
+}
+
+typedef int kvm_vmm_entry(void);
+typedef void kvm_tramp_entry(union context *host, union context
*guest);
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
+#endif
diff --git a/include/asm-ia64/kvm_para.h b/include/asm-ia64/kvm_para.h
new file mode 100644
index 0000000..9f9796b
--- /dev/null
+++ b/include/asm-ia64/kvm_para.h
@@ -0,0 +1,29 @@
+#ifndef __IA64_KVM_PARA_H
+#define __IA64_KVM_PARA_H
+
+/*
+ * asm-ia64/kvm_para.h
+ *
+ * Copyright (C) 2007 Xiantao Zhang <xiantao.zhang@intel.com>
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
1.5.2

------_=_NextPart_001_01C893E5.477AAB0B
Content-Type: application/octet-stream;
	name="0004-KVM-IA64-Add-header-files-for-kvm-ia64.patch"
Content-Transfer-Encoding: base64
Content-Description: 0004-KVM-IA64-Add-header-files-for-kvm-ia64.patch
Content-Disposition: attachment;
	filename="0004-KVM-IA64-Add-header-files-for-kvm-ia64.patch"

RnJvbSA3NTlmOThmNmNiNjFmNWY2MDY0MTgwNTYyNjU2ZWYwNTJmMzg0OTBjIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAxIEFwciAyMDA4IDE0OjQ1OjA2ICswODAwClN1YmplY3Q6IFtQQVRDSF0g
S1ZNOiBJQTY0OiBBZGQgaGVhZGVyIGZpbGVzIGZvciBrdm0vaWE2NC4KClRocmVlIGhlYWRlciBm
aWxlcyBhcmUgYWRkZWQ6CmFzbS1pYTY0L2t2bS5oCmFzbS1pYTY0L2t2bV9ob3N0LmgKYXNtLWlh
NjQva3ZtX3BhcmEuaApTaWduZWQtb2ZmLWJ5OiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5n
QGludGVsLmNvbT4KLS0tCiBpbmNsdWRlL2FzbS1pYTY0L2t2bS5oICAgICAgfCAgMjA1ICsrKysr
KysrKysrKysrKysrCiBpbmNsdWRlL2FzbS1pYTY0L2t2bV9ob3N0LmggfCAgNTI0ICsrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysKIGluY2x1ZGUvYXNtLWlhNjQva3Zt
X3BhcmEuaCB8ICAgMjkgKysrCiAzIGZpbGVzIGNoYW5nZWQsIDc1OCBpbnNlcnRpb25zKCspLCAw
IGRlbGV0aW9ucygtKQogY3JlYXRlIG1vZGUgMTAwNjQ0IGluY2x1ZGUvYXNtLWlhNjQva3ZtLmgK
IGNyZWF0ZSBtb2RlIDEwMDY0NCBpbmNsdWRlL2FzbS1pYTY0L2t2bV9ob3N0LmgKIGNyZWF0ZSBt
b2RlIDEwMDY0NCBpbmNsdWRlL2FzbS1pYTY0L2t2bV9wYXJhLmgKCmRpZmYgLS1naXQgYS9pbmNs
dWRlL2FzbS1pYTY0L2t2bS5oIGIvaW5jbHVkZS9hc20taWE2NC9rdm0uaApuZXcgZmlsZSBtb2Rl
IDEwMDY0NAppbmRleCAwMDAwMDAwLi5lYjJkMzU1Ci0tLSAvZGV2L251bGwKKysrIGIvaW5jbHVk
ZS9hc20taWE2NC9rdm0uaApAQCAtMCwwICsxLDIwNSBAQAorI2lmbmRlZiBfX0FTTV9JQTY0X0tW
TV9ICisjZGVmaW5lIF9fQVNNX0lBNjRfS1ZNX0gKKworLyoKKyAqIGFzbS1pYTY0L2t2bS5oOiBr
dm0gc3RydWN0dXJlIGRlZmluaXRpb25zICBmb3IgaWE2NAorICoKKyAqIENvcHlyaWdodCAoQykg
MjAwNyBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNvbT4KKyAqCisgKiBUaGlz
IHByb2dyYW0gaXMgZnJlZSBzb2Z0d2FyZTsgeW91IGNhbiByZWRpc3RyaWJ1dGUgaXQgYW5kL29y
IG1vZGlmeSBpdAorICogdW5kZXIgdGhlIHRlcm1zIGFuZCBjb25kaXRpb25zIG9mIHRoZSBHTlUg
R2VuZXJhbCBQdWJsaWMgTGljZW5zZSwKKyAqIHZlcnNpb24gMiwgYXMgcHVibGlzaGVkIGJ5IHRo
ZSBGcmVlIFNvZnR3YXJlIEZvdW5kYXRpb24uCisgKgorICogVGhpcyBwcm9ncmFtIGlzIGRpc3Ry
aWJ1dGVkIGluIHRoZSBob3BlIGl0IHdpbGwgYmUgdXNlZnVsLCBidXQgV0lUSE9VVAorICogQU5Z
IFdBUlJBTlRZOyB3aXRob3V0IGV2ZW4gdGhlIGltcGxpZWQgd2FycmFudHkgb2YgTUVSQ0hBTlRB
QklMSVRZIG9yCisgKiBGSVRORVNTIEZPUiBBIFBBUlRJQ1VMQVIgUFVSUE9TRS4gIFNlZSB0aGUg
R05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2UgZm9yCisgKiBtb3JlIGRldGFpbHMuCisgKgorICog
WW91IHNob3VsZCBoYXZlIHJlY2VpdmVkIGEgY29weSBvZiB0aGUgR05VIEdlbmVyYWwgUHVibGlj
IExpY2Vuc2UgYWxvbmcgd2l0aAorICogdGhpcyBwcm9ncmFtOyBpZiBub3QsIHdyaXRlIHRvIHRo
ZSBGcmVlIFNvZnR3YXJlIEZvdW5kYXRpb24sIEluYy4sIDU5IFRlbXBsZQorICogUGxhY2UgLSBT
dWl0ZSAzMzAsIEJvc3RvbiwgTUEgMDIxMTEtMTMwNyBVU0EuCisgKgorICovCisKKyNpbmNsdWRl
IDxhc20vdHlwZXMuaD4KKyNpbmNsdWRlIDxhc20vZnB1Lmg+CisKKyNpbmNsdWRlIDxsaW51eC9p
b2N0bC5oPgorCisvKiBBcmNoaXRlY3R1cmFsIGludGVycnVwdCBsaW5lIGNvdW50LiAqLworI2Rl
ZmluZSBLVk1fTlJfSU5URVJSVVBUUyAyNTYKKworI2RlZmluZSBLVk1fSU9BUElDX05VTV9QSU5T
ICAyNAorCitzdHJ1Y3Qga3ZtX2lvYXBpY19zdGF0ZSB7CisJX191NjQgYmFzZV9hZGRyZXNzOwor
CV9fdTMyIGlvcmVnc2VsOworCV9fdTMyIGlkOworCV9fdTMyIGlycjsKKwlfX3UzMiBwYWQ7CisJ
dW5pb24geworCQlfX3U2NCBiaXRzOworCQlzdHJ1Y3QgeworCQkJX191OCB2ZWN0b3I7CisJCQlf
X3U4IGRlbGl2ZXJ5X21vZGU6MzsKKwkJCV9fdTggZGVzdF9tb2RlOjE7CisJCQlfX3U4IGRlbGl2
ZXJ5X3N0YXR1czoxOworCQkJX191OCBwb2xhcml0eToxOworCQkJX191OCByZW1vdGVfaXJyOjE7
CisJCQlfX3U4IHRyaWdfbW9kZToxOworCQkJX191OCBtYXNrOjE7CisJCQlfX3U4IHJlc2VydmU6
NzsKKwkJCV9fdTggcmVzZXJ2ZWRbNF07CisJCQlfX3U4IGRlc3RfaWQ7CisJCX0gZmllbGRzOwor
CX0gcmVkaXJ0YmxbS1ZNX0lPQVBJQ19OVU1fUElOU107Cit9OworCisjZGVmaW5lIEtWTV9JUlFD
SElQX1BJQ19NQVNURVIgICAwCisjZGVmaW5lIEtWTV9JUlFDSElQX1BJQ19TTEFWRSAgICAxCisj
ZGVmaW5lIEtWTV9JUlFDSElQX0lPQVBJQyAgICAgICAyCisKKyNkZWZpbmUgS1ZNX0NPTlRFWFRf
U0laRQk4KjEwMjQKKwordW5pb24gY29udGV4dCB7CisJLyogOEsgc2l6ZSAqLworCWNoYXIJZHVt
bXlbS1ZNX0NPTlRFWFRfU0laRV07CisJc3RydWN0IHsKKwkJdW5zaWduZWQgbG9uZyAgICAgICBw
c3I7CisJCXVuc2lnbmVkIGxvbmcgICAgICAgcHI7CisJCXVuc2lnbmVkIGxvbmcgICAgICAgY2Fs
bGVyX3VuYXQ7CisJCXVuc2lnbmVkIGxvbmcgICAgICAgcGFkOworCQl1bnNpZ25lZCBsb25nICAg
ICAgIGdyWzMyXTsKKwkJdW5zaWduZWQgbG9uZyAgICAgICBhclsxMjhdOworCQl1bnNpZ25lZCBs
b25nICAgICAgIGJyWzhdOworCQl1bnNpZ25lZCBsb25nICAgICAgIGNyWzEyOF07CisJCXVuc2ln
bmVkIGxvbmcgICAgICAgcnJbOF07CisJCXVuc2lnbmVkIGxvbmcgICAgICAgaWJyWzhdOworCQl1
bnNpZ25lZCBsb25nICAgICAgIGRicls4XTsKKwkJdW5zaWduZWQgbG9uZyAgICAgICBwa3JbOF07
CisJCXN0cnVjdCBpYTY0X2ZwcmVnICAgZnJbMTI4XTsKKwl9OworfTsKKworc3RydWN0IHRoYXNo
X2RhdGEgeworCXVuaW9uIHsKKwkJc3RydWN0IHsKKwkJCXVuc2lnbmVkIGxvbmcgcCAgICA6ICAx
OyAvKiAwICovCisJCQl1bnNpZ25lZCBsb25nIHJ2MSAgOiAgMTsgLyogMSAqLworCQkJdW5zaWdu
ZWQgbG9uZyBtYSAgIDogIDM7IC8qIDItNCAqLworCQkJdW5zaWduZWQgbG9uZyBhICAgIDogIDE7
IC8qIDUgKi8KKwkJCXVuc2lnbmVkIGxvbmcgZCAgICA6ICAxOyAvKiA2ICovCisJCQl1bnNpZ25l
ZCBsb25nIHBsICAgOiAgMjsgLyogNy04ICovCisJCQl1bnNpZ25lZCBsb25nIGFyICAgOiAgMzsg
LyogOS0xMSAqLworCQkJdW5zaWduZWQgbG9uZyBwcG4gIDogMzg7IC8qIDEyLTQ5ICovCisJCQl1
bnNpZ25lZCBsb25nIHJ2MiAgOiAgMjsgLyogNTAtNTEgKi8KKwkJCXVuc2lnbmVkIGxvbmcgZWQg
ICA6ICAxOyAvKiA1MiAqLworCQkJdW5zaWduZWQgbG9uZyBpZzEgIDogMTE7IC8qIDUzLTYzICov
CisJCX07CisJCXN0cnVjdCB7CisJCQl1bnNpZ25lZCBsb25nIF9fcnYxIDogNTM7ICAgICAvKiAw
LTUyICovCisJCQl1bnNpZ25lZCBsb25nIGNvbnRpZ3VvdXMgOiAxOyAvKjUzICovCisJCQl1bnNp
Z25lZCBsb25nIHRjIDogMTsgICAgICAgICAvKiA1NCBUUiBvciBUQyAqLworCQkJdW5zaWduZWQg
bG9uZyBjbCA6IDE7CisJCQkvKiA1NSBJIHNpZGUgb3IgRCBzaWRlIGNhY2hlIGxpbmUgKi8KKwkJ
CXVuc2lnbmVkIGxvbmcgbGVuICA6ICA0OyAgICAgIC8qIDU2LTU5ICovCisJCQl1bnNpZ25lZCBs
b25nIGlvICA6IDE7CS8qIDYwIGVudHJ5IGlzIGZvciBpbyBvciBub3QgKi8KKwkJCXVuc2lnbmVk
IGxvbmcgbm9tYXAgOiAxOworCQkJLyogNjEgZW50cnkgY2Fubid0IGJlIGluc2VydGVkIGludG8g
bWFjaGluZSBUTEIuKi8KKwkJCXVuc2lnbmVkIGxvbmcgY2hlY2tlZCA6IDE7CisJCQkvKiA2MiBm
b3IgVlRMQi9WSFBUIHNhbml0eSBjaGVjayAqLworCQkJdW5zaWduZWQgbG9uZyBpbnZhbGlkIDog
MTsKKwkJCS8qIDYzIGludmFsaWQgZW50cnkgKi8KKwkJfTsKKwkJdW5zaWduZWQgbG9uZyBwYWdl
X2ZsYWdzOworCX07ICAgICAgICAgICAgICAgICAgLyogc2FtZSBmb3IgVkhQVCBhbmQgVExCICov
CisKKwl1bmlvbiB7CisJCXN0cnVjdCB7CisJCQl1bnNpZ25lZCBsb25nIHJ2MyAgOiAgMjsKKwkJ
CXVuc2lnbmVkIGxvbmcgcHMgICA6ICA2OworCQkJdW5zaWduZWQgbG9uZyBrZXkgIDogMjQ7CisJ
CQl1bnNpZ25lZCBsb25nIHJ2NCAgOiAzMjsKKwkJfTsKKwkJdW5zaWduZWQgbG9uZyBpdGlyOwor
CX07CisJdW5pb24geworCQlzdHJ1Y3QgeworCQkJdW5zaWduZWQgbG9uZyBpZzIgIDogIDEyOwor
CQkJdW5zaWduZWQgbG9uZyB2cG4gIDogIDQ5OworCQkJdW5zaWduZWQgbG9uZyB2cm4gIDogICAz
OworCQl9OworCQl1bnNpZ25lZCBsb25nIGlmYTsKKwkJdW5zaWduZWQgbG9uZyB2YWRyOworCQlz
dHJ1Y3QgeworCQkJdW5zaWduZWQgbG9uZyB0YWcgIDogIDYzOworCQkJdW5zaWduZWQgbG9uZyB0
aSAgIDogIDE7CisJCX07CisJCXVuc2lnbmVkIGxvbmcgZXRhZzsKKwl9OworCXVuaW9uIHsKKwkJ
c3RydWN0IHRoYXNoX2RhdGEgKm5leHQ7CisJCXVuc2lnbmVkIGxvbmcgcmlkOworCQl1bnNpZ25l
ZCBsb25nIGdwYWRkcjsKKwl9OworfTsKKworI2RlZmluZQlOSVRSUwk4CisjZGVmaW5lIE5EVFJT
CTgKKworc3RydWN0IHNhdmVkX3ZwZCB7CisJdW5zaWduZWQgbG9uZyAgdmhwaTsKKwl1bnNpZ25l
ZCBsb25nICB2Z3JbMTZdOworCXVuc2lnbmVkIGxvbmcgIHZiZ3JbMTZdOworCXVuc2lnbmVkIGxv
bmcgIHZuYXQ7CisJdW5zaWduZWQgbG9uZyAgdmJuYXQ7CisJdW5zaWduZWQgbG9uZyAgdmNwdWlk
WzVdOworCXVuc2lnbmVkIGxvbmcgIHZwc3I7CisJdW5zaWduZWQgbG9uZyAgdnByOworCXVuc2ln
bmVkIGxvbmcgIHZjclsxMjhdOworfTsKKworc3RydWN0IGt2bV9yZWdzIHsKKwljaGFyICpzYXZl
ZF9ndWVzdDsKKwljaGFyICpzYXZlZF9zdGFjazsKKwlzdHJ1Y3Qgc2F2ZWRfdnBkIHZwZDsKKwkv
KkFyY2gtcmVncyovCisJaW50IG1wX3N0YXRlOworCXVuc2lnbmVkIGxvbmcgdm1tX3JyOworCS8q
IFRSIGFuZCBUQy4gICovCisJc3RydWN0IHRoYXNoX2RhdGEgaXRyc1tOSVRSU107CisJc3RydWN0
IHRoYXNoX2RhdGEgZHRyc1tORFRSU107CisJLyogQml0IGlzIHNldCBpZiB0aGVyZSBpcyBhIHRy
L3RjIGZvciB0aGUgcmVnaW9uLiAgKi8KKwl1bnNpZ25lZCBjaGFyIGl0cl9yZWdpb25zOworCXVu
c2lnbmVkIGNoYXIgZHRyX3JlZ2lvbnM7CisJdW5zaWduZWQgY2hhciB0Y19yZWdpb25zOworCisJ
Y2hhciBpcnFfY2hlY2s7CisJdW5zaWduZWQgbG9uZyBzYXZlZF9pdGM7CisJdW5zaWduZWQgbG9u
ZyBpdGNfY2hlY2s7CisJdW5zaWduZWQgbG9uZyB0aW1lcl9jaGVjazsKKwl1bnNpZ25lZCBsb25n
IHRpbWVyX3BlbmRpbmc7CisJdW5zaWduZWQgbG9uZyBsYXN0X2l0YzsKKworCXVuc2lnbmVkIGxv
bmcgdnJyWzhdOworCXVuc2lnbmVkIGxvbmcgaWJyWzhdOworCXVuc2lnbmVkIGxvbmcgZGJyWzhd
OworCXVuc2lnbmVkIGxvbmcgaW5zdmNbNF07CQkvKiBJbnRlcnJ1cHQgaW4gc2VydmljZS4gICov
CisJdW5zaWduZWQgbG9uZyB4dHA7CisKKwl1bnNpZ25lZCBsb25nIG1ldGFwaHlzaWNhbF9ycjA7
IC8qIGZyb20ga3ZtX2FyY2ggKHNvIGlzIHBpbm5lZCkgKi8KKwl1bnNpZ25lZCBsb25nIG1ldGFw
aHlzaWNhbF9ycjQ7CS8qIGZyb20ga3ZtX2FyY2ggKHNvIGlzIHBpbm5lZCkgKi8KKwl1bnNpZ25l
ZCBsb25nIG1ldGFwaHlzaWNhbF9zYXZlZF9ycjA7IC8qIGZyb20ga3ZtX2FyY2ggICAgICAgICAg
Ki8KKwl1bnNpZ25lZCBsb25nIG1ldGFwaHlzaWNhbF9zYXZlZF9ycjQ7IC8qIGZyb20ga3ZtX2Fy
Y2ggICAgICAgICAgKi8KKwl1bnNpZ25lZCBsb25nIGZwX3BzcjsgICAgICAgLyp1c2VkIGZvciBs
YXp5IGZsb2F0IHJlZ2lzdGVyICovCisJdW5zaWduZWQgbG9uZyBzYXZlZF9ncDsKKwkvKmZvciBw
aHljaWFsICBlbXVsYXRpb24gKi8KK307CisKK3N0cnVjdCBrdm1fc3JlZ3MgeworfTsKKworc3Ry
dWN0IGt2bV9mcHUgeworfTsKKworI2VuZGlmCmRpZmYgLS1naXQgYS9pbmNsdWRlL2FzbS1pYTY0
L2t2bV9ob3N0LmggYi9pbmNsdWRlL2FzbS1pYTY0L2t2bV9ob3N0LmgKbmV3IGZpbGUgbW9kZSAx
MDA2NDQKaW5kZXggMDAwMDAwMC4uZDZkNmUxNQotLS0gL2Rldi9udWxsCisrKyBiL2luY2x1ZGUv
YXNtLWlhNjQva3ZtX2hvc3QuaApAQCAtMCwwICsxLDUyNCBAQAorLyoKKyAqIGt2bV9ob3N0Lmg6
IHVzZWQgZm9yIGt2bSBtb2R1bGUsIGFuZCBob2xkIGlhNjQtc3BlY2lmaWMgc2VjdGlvbnMuCisg
KgorICogQ29weXJpZ2h0IChDKSAyMDA3LCBJbnRlbCBDb3Jwb3JhdGlvbi4KKyAqCisgKiBYaWFu
dGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNvbT4KKyAqCisgKiBUaGlzIHByb2dyYW0g
aXMgZnJlZSBzb2Z0d2FyZTsgeW91IGNhbiByZWRpc3RyaWJ1dGUgaXQgYW5kL29yIG1vZGlmeSBp
dAorICogdW5kZXIgdGhlIHRlcm1zIGFuZCBjb25kaXRpb25zIG9mIHRoZSBHTlUgR2VuZXJhbCBQ
dWJsaWMgTGljZW5zZSwKKyAqIHZlcnNpb24gMiwgYXMgcHVibGlzaGVkIGJ5IHRoZSBGcmVlIFNv
ZnR3YXJlIEZvdW5kYXRpb24uCisgKgorICogVGhpcyBwcm9ncmFtIGlzIGRpc3RyaWJ1dGVkIGlu
IHRoZSBob3BlIGl0IHdpbGwgYmUgdXNlZnVsLCBidXQgV0lUSE9VVAorICogQU5ZIFdBUlJBTlRZ
OyB3aXRob3V0IGV2ZW4gdGhlIGltcGxpZWQgd2FycmFudHkgb2YgTUVSQ0hBTlRBQklMSVRZIG9y
CisgKiBGSVRORVNTIEZPUiBBIFBBUlRJQ1VMQVIgUFVSUE9TRS4gIFNlZSB0aGUgR05VIEdlbmVy
YWwgUHVibGljIExpY2Vuc2UgZm9yCisgKiBtb3JlIGRldGFpbHMuCisgKgorICogWW91IHNob3Vs
ZCBoYXZlIHJlY2VpdmVkIGEgY29weSBvZiB0aGUgR05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2Ug
YWxvbmcgd2l0aAorICogdGhpcyBwcm9ncmFtOyBpZiBub3QsIHdyaXRlIHRvIHRoZSBGcmVlIFNv
ZnR3YXJlIEZvdW5kYXRpb24sIEluYy4sIDU5IFRlbXBsZQorICogUGxhY2UgLSBTdWl0ZSAzMzAs
IEJvc3RvbiwgTUEgMDIxMTEtMTMwNyBVU0EuCisgKgorICovCisKKyNpZm5kZWYgX19BU01fS1ZN
X0hPU1RfSAorI2RlZmluZSBfX0FTTV9LVk1fSE9TVF9ICisKKworI2luY2x1ZGUgPGxpbnV4L3R5
cGVzLmg+CisjaW5jbHVkZSA8bGludXgvbW0uaD4KKyNpbmNsdWRlIDxsaW51eC9rdm0uaD4KKyNp
bmNsdWRlIDxsaW51eC9rdm1fcGFyYS5oPgorI2luY2x1ZGUgPGxpbnV4L2t2bV90eXBlcy5oPgor
CisjaW5jbHVkZSA8YXNtL3BhbC5oPgorI2luY2x1ZGUgPGFzbS9zYWwuaD4KKworI2RlZmluZSBL
Vk1fTUFYX1ZDUFVTIDQKKyNkZWZpbmUgS1ZNX01FTU9SWV9TTE9UUyAzMgorLyogbWVtb3J5IHNs
b3RzIHRoYXQgZG9lcyBub3QgZXhwb3NlZCB0byB1c2Vyc3BhY2UgKi8KKyNkZWZpbmUgS1ZNX1BS
SVZBVEVfTUVNX1NMT1RTIDQKKworCisvKiBkZWZpbmUgZXhpdCByZWFzb25zIGZyb20gdm1tIHRv
IGt2bSovCisjZGVmaW5lIEVYSVRfUkVBU09OX1ZNX1BBTklDCQkwCisjZGVmaW5lIEVYSVRfUkVB
U09OX01NSU9fSU5TVFJVQ1RJT04JMQorI2RlZmluZSBFWElUX1JFQVNPTl9QQUxfQ0FMTAkJMgor
I2RlZmluZSBFWElUX1JFQVNPTl9TQUxfQ0FMTAkJMworI2RlZmluZSBFWElUX1JFQVNPTl9TV0lU
Q0hfUlI2CQk0CisjZGVmaW5lIEVYSVRfUkVBU09OX1ZNX0RFU1RST1kJCTUKKyNkZWZpbmUgRVhJ
VF9SRUFTT05fRVhURVJOQUxfSU5URVJSVVBUCTYKKyNkZWZpbmUgRVhJVF9SRUFTT05fSVBJCQkJ
NworI2RlZmluZSBFWElUX1JFQVNPTl9QVENfRwkJOAorCisvKkRlZmluZSB2bW0gYWRkcmVzcyBz
cGFjZSBhbmQgdm0gZGF0YSBzcGFjZS4qLworI2RlZmluZSBLVk1fVk1NX1NJWkUgKDE2VUw8PDIw
KQorI2RlZmluZSBLVk1fVk1NX1NISUZUIDI0CisjZGVmaW5lIEtWTV9WTU1fQkFTRSAweEQwMDAw
MDAwMDAwMDAwMDBVTAorI2RlZmluZSBWTU1fU0laRSAoOFVMPDwyMCkKKworLyoKKyAqIERlZmlu
ZSB2bV9idWZmZXIsIHVzZWQgYnkgUEFMIFNlcnZpY2VzLCBiYXNlIGFkZHJlc3MuCisgKiBOb3Rl
OiB2bWJ1ZmZlciBpcyBpbiB0aGUgVk1NLUJMT0NLLCB0aGUgc2l6ZSBtdXN0IGJlIDwgOE0KKyAq
LworI2RlZmluZSBLVk1fVk1fQlVGRkVSX0JBU0UgKEtWTV9WTU1fQkFTRSArIFZNTV9TSVpFKQor
I2RlZmluZSBLVk1fVk1fQlVGRkVSX1NJWkUgKDhVTDw8MjApCisKKy8qRGVmaW5lIFZpcnR1YWwg
bWFjaGluZSBkYXRhIGxheW91dC4qLworI2RlZmluZSBLVk1fVk1fREFUQV9TSElGVCAgMjQKKyNk
ZWZpbmUgS1ZNX1ZNX0RBVEFfU0laRSAoMVVMIDw8IEtWTV9WTV9EQVRBX1NISUZUKQorI2RlZmlu
ZSBLVk1fVk1fREFUQV9CQVNFIChLVk1fVk1NX0JBU0UgKyBLVk1fVk1NX1NJWkUpCisKKworI2Rl
ZmluZSBLVk1fUDJNX0JBU0UgICAgS1ZNX1ZNX0RBVEFfQkFTRQorI2RlZmluZSBLVk1fUDJNX09G
UyAgICAgMAorI2RlZmluZSBLVk1fUDJNX1NJWkUgICAgKDhVTCA8PCAyMCkKKworI2RlZmluZSBL
Vk1fVkhQVF9CQVNFICAgKEtWTV9QMk1fQkFTRSArIEtWTV9QMk1fU0laRSkKKyNkZWZpbmUgS1ZN
X1ZIUFRfT0ZTICAgIEtWTV9QMk1fU0laRQorI2RlZmluZSBLVk1fVkhQVF9CTE9DS19TSVpFICAg
KDJVTCA8PCAyMCkKKyNkZWZpbmUgVkhQVF9TSElGVCAgICAgIDE4CisjZGVmaW5lIFZIUFRfU0la
RSAgICAgICAoMVVMIDw8IFZIUFRfU0hJRlQpCisjZGVmaW5lIFZIUFRfTlVNX0VOVFJJRVMgKDE8
PChWSFBUX1NISUZULTUpKQorCisjZGVmaW5lIEtWTV9WVExCX0JBU0UgICAoS1ZNX1ZIUFRfQkFT
RStLVk1fVkhQVF9CTE9DS19TSVpFKQorI2RlZmluZSBLVk1fVlRMQl9PRlMgICAgKEtWTV9WSFBU
X09GUytLVk1fVkhQVF9CTE9DS19TSVpFKQorI2RlZmluZSBLVk1fVlRMQl9CTE9DS19TSVpFICAg
KDFVTDw8MjApCisjZGVmaW5lIFZUTEJfU0hJRlQgICAgICAxNworI2RlZmluZSBWVExCX1NJWkUg
ICAgICAgKDFVTDw8VlRMQl9TSElGVCkKKyNkZWZpbmUgVlRMQl9OVU1fRU5UUklFUyAoMTw8KFZU
TEJfU0hJRlQtNSkpCisKKyNkZWZpbmUgS1ZNX1ZQRF9CQVNFICAgKEtWTV9WVExCX0JBU0UrS1ZN
X1ZUTEJfQkxPQ0tfU0laRSkKKyNkZWZpbmUgS1ZNX1ZQRF9PRlMgICAgKEtWTV9WVExCX09GUytL
Vk1fVlRMQl9CTE9DS19TSVpFKQorI2RlZmluZSBLVk1fVlBEX0JMT0NLX1NJWkUgICAoMlVMPDwy
MCkKKyNkZWZpbmUgVlBEX1NISUZUICAgICAgIDE2CisjZGVmaW5lIFZQRF9TSVpFICAgICAgICAo
MVVMPDxWUERfU0hJRlQpCisKKyNkZWZpbmUgS1ZNX1ZDUFVfQkFTRSAgIChLVk1fVlBEX0JBU0Ur
S1ZNX1ZQRF9CTE9DS19TSVpFKQorI2RlZmluZSBLVk1fVkNQVV9PRlMgICAgKEtWTV9WUERfT0ZT
K0tWTV9WUERfQkxPQ0tfU0laRSkKKyNkZWZpbmUgS1ZNX1ZDUFVfQkxPQ0tfU0laRSAgICgyVUw8
PDIwKQorI2RlZmluZSBWQ1BVX1NISUZUIDE4CisjZGVmaW5lIFZDUFVfU0laRSAoMVVMPDxWQ1BV
X1NISUZUKQorI2RlZmluZSBNQVhfVkNQVV9OVU0gS1ZNX1ZDUFVfQkxPQ0tfU0laRS9WQ1BVX1NJ
WkUKKworI2RlZmluZSBLVk1fVk1fQkFTRSAgICAgKEtWTV9WQ1BVX0JBU0UrS1ZNX1ZDUFVfQkxP
Q0tfU0laRSkKKyNkZWZpbmUgS1ZNX1ZNX09GUyAgICAgIChLVk1fVkNQVV9PRlMrS1ZNX1ZDUFVf
QkxPQ0tfU0laRSkKKyNkZWZpbmUgS1ZNX1ZNX0JMT0NLX1NJWkUgICAgICgxVUw8PDE5KQorCisj
ZGVmaW5lIEtWTV9NRU1fRElSVFlfTE9HX0JBU0UgKEtWTV9WTV9CQVNFK0tWTV9WTV9CTE9DS19T
SVpFKQorI2RlZmluZSBLVk1fTUVNX0RJUlRZX0xPR19PRlMgIChLVk1fVk1fT0ZTK0tWTV9WTV9C
TE9DS19TSVpFKQorI2RlZmluZSBLVk1fTUVNX0RJUlRZX0xPR19TSVpFICgxVUw8PDE5KQorCisv
KiBHZXQgdnBkLCB2aHB0LCB0bGIsIHZjcHUsIGJhc2UqLworI2RlZmluZSBWUERfQUREUihuKSAo
S1ZNX1ZQRF9CQVNFK24qVlBEX1NJWkUpCisjZGVmaW5lIFZIUFRfQUREUihuKSAoS1ZNX1ZIUFRf
QkFTRStuKlZIUFRfU0laRSkKKyNkZWZpbmUgVlRMQl9BRERSKG4pIChLVk1fVlRMQl9CQVNFK24q
VlRMQl9TSVpFKQorI2RlZmluZSBWQ1BVX0FERFIobikgKEtWTV9WQ1BVX0JBU0UrbipWQ1BVX1NJ
WkUpCisKKy8qSU8gc2VjdGlvbiBkZWZpbml0aW9ucyovCisjZGVmaW5lIElPUkVRX1JFQUQgICAg
ICAxCisjZGVmaW5lIElPUkVRX1dSSVRFICAgICAwCisKKyNkZWZpbmUgU1RBVEVfSU9SRVFfTk9O
RSAgICAgICAgMAorI2RlZmluZSBTVEFURV9JT1JFUV9SRUFEWSAgICAgICAxCisjZGVmaW5lIFNU
QVRFX0lPUkVRX0lOUFJPQ0VTUyAgIDIKKyNkZWZpbmUgU1RBVEVfSU9SRVNQX1JFQURZICAgICAg
MworCisvKkd1ZXN0IFBoeXNpY2FsIGFkZHJlc3MgbGF5b3V0LiovCisjZGVmaW5lIEdQRk5fTUVN
ICAgICAgICAoMFVMIDw8IDYwKSAvKiBHdWVzdCBwZm4gaXMgbm9ybWFsIG1lbSAqLworI2RlZmlu
ZSBHUEZOX0ZSQU1FX0JVRkZFUiAgICgxVUwgPDwgNjApIC8qIFZHQSBmcmFtZWJ1ZmZlciAqLwor
I2RlZmluZSBHUEZOX0xPV19NTUlPICAgICAgICgyVUwgPDwgNjApIC8qIExvdyBNTUlPIHJhbmdl
ICovCisjZGVmaW5lIEdQRk5fUElCICAgICAgICAoM1VMIDw8IDYwKSAvKiBQSUIgYmFzZSAqLwor
I2RlZmluZSBHUEZOX0lPU0FQSUMgICAgICAgICg0VUwgPDwgNjApIC8qIElPU0FQSUMgYmFzZSAq
LworI2RlZmluZSBHUEZOX0xFR0FDWV9JTyAgICAgICg1VUwgPDwgNjApIC8qIExlZ2FjeSBJL08g
YmFzZSAqLworI2RlZmluZSBHUEZOX0dGVyAgICAgICAgKDZVTCA8PCA2MCkgLyogR3Vlc3QgRmly
bXdhcmUgKi8KKyNkZWZpbmUgR1BGTl9ISUdIX01NSU8gICAgICAoN1VMIDw8IDYwKSAvKiBIaWdo
IE1NSU8gcmFuZ2UgKi8KKworI2RlZmluZSBHUEZOX0lPX01BU0sgICAgICAgICg3VUwgPDwgNjAp
IC8qIEd1ZXN0IHBmbiBpcyBJL08gdHlwZSAqLworI2RlZmluZSBHUEZOX0lOVl9NQVNLICAgICAg
ICgxVUwgPDwgNjMpIC8qIEd1ZXN0IHBmbiBpcyBpbnZhbGlkICovCisjZGVmaW5lIElOVkFMSURf
TUZOICAgICAgICh+MFVMKQorI2RlZmluZSBNRU1fRyAgICgxVUwgPDwgMzApCisjZGVmaW5lIE1F
TV9NICAgKDFVTCA8PCAyMCkKKyNkZWZpbmUgTU1JT19TVEFSVCAgICAgICAoMyAqIE1FTV9HKQor
I2RlZmluZSBNTUlPX1NJWkUgICAgICAgICg1MTIgKiBNRU1fTSkKKyNkZWZpbmUgVkdBX0lPX1NU
QVJUICAgICAweEEwMDAwVUwKKyNkZWZpbmUgVkdBX0lPX1NJWkUgICAgICAweDIwMDAwCisjZGVm
aW5lIExFR0FDWV9JT19TVEFSVCAgKE1NSU9fU1RBUlQgKyBNTUlPX1NJWkUpCisjZGVmaW5lIExF
R0FDWV9JT19TSVpFICAgKDY0ICogTUVNX00pCisjZGVmaW5lIElPX1NBUElDX1NUQVJUICAgMHhm
ZWMwMDAwMFVMCisjZGVmaW5lIElPX1NBUElDX1NJWkUgICAgMHgxMDAwMDAKKyNkZWZpbmUgUElC
X1NUQVJUIDB4ZmVlMDAwMDBVTAorI2RlZmluZSBQSUJfU0laRSAweDIwMDAwMAorI2RlZmluZSBH
RldfU1RBUlQgICAgICAgICg0ICogTUVNX0cgLSAxNiAqIE1FTV9NKQorI2RlZmluZSBHRldfU0la
RSAgICAgICAgICgxNiAqIE1FTV9NKQorCisvKkRlbGl2ZXIgbW9kZSwgZGVmaW5lZCBmb3IgaW9h
cGljLmMqLworI2RlZmluZSBkZXN0X0ZpeGVkIElPU0FQSUNfRklYRUQKKyNkZWZpbmUgZGVzdF9M
b3dlc3RQcmlvIElPU0FQSUNfTE9XRVNUX1BSSU9SSVRZCisKKyNkZWZpbmUgTk1JX1ZFQ1RPUiAg
ICAgIAkJMgorI2RlZmluZSBFeHRJTlRfVkVDVE9SICAgICAgIAkJMAorI2RlZmluZSBOVUxMX1ZF
Q1RPUiAgICAgCQkoLTEpCisjZGVmaW5lIElBNjRfU1BVUklPVVNfSU5UX1ZFQ1RPUiAgICAJMHgw
ZgorCisjZGVmaW5lIFZDUFVfTElEKHYpICgoKHU2NCkodiktPnZjcHVfaWQpIDw8IDI0KQorCisv
KgorICpEZWxpdmVyeSBtb2RlCisgKi8KKyNkZWZpbmUgU0FQSUNfREVMSVZfU0hJRlQgICAgICA4
CisjZGVmaW5lIFNBUElDX0ZJWEVEICAgICAgICAgICAgMHgwCisjZGVmaW5lIFNBUElDX0xPV0VT
VF9QUklPUklUWSAgMHgxCisjZGVmaW5lIFNBUElDX1BNSSAgICAgICAgICAgICAgMHgyCisjZGVm
aW5lIFNBUElDX05NSSAgICAgICAgICAgICAgMHg0CisjZGVmaW5lIFNBUElDX0lOSVQgICAgICAg
ICAgICAgMHg1CisjZGVmaW5lIFNBUElDX0VYVElOVCAgICAgICAgICAgMHg3CisKKy8qCisgKiB2
Y3B1LT5yZXF1ZXN0cyBiaXQgbWVtYmVycyBmb3IgYXJjaAorICovCisjZGVmaW5lIEtWTV9SRVFf
UFRDX0cJCTMyCisjZGVmaW5lIEtWTV9SRVFfUkVTVU1FCQkzMworCisjZGVmaW5lIEtWTV9QQUdF
U19QRVJfSFBBR0UJMQorCitzdHJ1Y3Qga3ZtOworc3RydWN0IGt2bV92Y3B1Oworc3RydWN0IGt2
bV9ndWVzdF9kZWJ1Z3sKK307CisKK3N0cnVjdCBrdm1fbW1pb19yZXEgeworCXVpbnQ2NF90IGFk
ZHI7ICAgICAgICAgIC8qICBwaHlzaWNhbCBhZGRyZXNzCQkqLworCXVpbnQ2NF90IHNpemU7ICAg
ICAgICAgIC8qICBzaXplIGluIGJ5dGVzCQkqLworCXVpbnQ2NF90IGRhdGE7ICAgICAgICAgIC8q
ICBkYXRhIChvciBwYWRkciBvZiBkYXRhKSAgICAgKi8KKwl1aW50OF90IHN0YXRlOjQ7CisJdWlu
dDhfdCBkaXI6MTsgICAgICAgICAgLyogIDE9cmVhZCwgMD13cml0ZSAgICAgICAgICAgICAqLwor
fTsKKworLypQYWwgZGF0YSBzdHJ1Y3QgKi8KK3N0cnVjdCBrdm1fcGFsX2NhbGx7CisJLypJbiBh
cmVhKi8KKwl1aW50NjRfdCBncjI4OworCXVpbnQ2NF90IGdyMjk7CisJdWludDY0X3QgZ3IzMDsK
Kwl1aW50NjRfdCBncjMxOworCS8qT3V0IGFyZWEqLworCXN0cnVjdCBpYTY0X3BhbF9yZXR2YWwg
cmV0OworfTsKKworLyogU2FsIGRhdGEgc3RydWN0dXJlICovCitzdHJ1Y3Qga3ZtX3NhbF9jYWxs
eworCS8qSW4gYXJlYSovCisJdWludDY0X3QgaW4wOworCXVpbnQ2NF90IGluMTsKKwl1aW50NjRf
dCBpbjI7CisJdWludDY0X3QgaW4zOworCXVpbnQ2NF90IGluNDsKKwl1aW50NjRfdCBpbjU7CisJ
dWludDY0X3QgaW42OworCXVpbnQ2NF90IGluNzsKKwlzdHJ1Y3Qgc2FsX3JldF92YWx1ZXMgcmV0
OworfTsKKworLypHdWVzdCBjaGFuZ2UgcnI2Ki8KK3N0cnVjdCBrdm1fc3dpdGNoX3JyNiB7CisJ
dWludDY0X3Qgb2xkX3JyOworCXVpbnQ2NF90IG5ld19ycjsKK307CisKK3VuaW9uIGlhNjRfaXBp
X2F7CisJdW5zaWduZWQgbG9uZyB2YWw7CisJc3RydWN0IHsKKwkJdW5zaWduZWQgbG9uZyBydiAg
OiAzOworCQl1bnNpZ25lZCBsb25nIGlyICA6IDE7CisJCXVuc2lnbmVkIGxvbmcgZWlkIDogODsK
KwkJdW5zaWduZWQgbG9uZyBpZCAgOiA4OworCQl1bnNpZ25lZCBsb25nIGliX2Jhc2UgOiA0NDsK
Kwl9OworfTsKKwordW5pb24gaWE2NF9pcGlfZCB7CisJdW5zaWduZWQgbG9uZyB2YWw7CisJc3Ry
dWN0IHsKKwkJdW5zaWduZWQgbG9uZyB2ZWN0b3IgOiA4OworCQl1bnNpZ25lZCBsb25nIGRtICA6
IDM7CisJCXVuc2lnbmVkIGxvbmcgaWcgIDogNTM7CisJfTsKK307CisKKy8qaXBpIGNoZWNrIGV4
aXQgZGF0YSovCitzdHJ1Y3Qga3ZtX2lwaV9kYXRheworCXVuaW9uIGlhNjRfaXBpX2EgYWRkcjsK
Kwl1bmlvbiBpYTY0X2lwaV9kIGRhdGE7Cit9OworCisvKmdsb2JhbCBwdXJnZSBkYXRhKi8KK3N0
cnVjdCBrdm1fcHRjX2cgeworCXVuc2lnbmVkIGxvbmcgdmFkZHI7CisJdW5zaWduZWQgbG9uZyBy
cjsKKwl1bnNpZ25lZCBsb25nIHBzOworCXN0cnVjdCBrdm1fdmNwdSAqdmNwdTsKK307CisKKy8q
RXhpdCBjb250cm9sIGRhdGEgKi8KK3N0cnVjdCBleGl0X2N0bF9kYXRheworCXVpbnQzMl90IGV4
aXRfcmVhc29uOworCXVpbnQzMl90IHZtX3N0YXR1czsKKwl1bmlvbiB7CisJCXN0cnVjdCBrdm1f
bW1pb19yZXEJaW9yZXE7CisJCXN0cnVjdCBrdm1fcGFsX2NhbGwJcGFsX2RhdGE7CisJCXN0cnVj
dCBrdm1fc2FsX2NhbGwJc2FsX2RhdGE7CisJCXN0cnVjdCBrdm1fc3dpdGNoX3JyNglycl9kYXRh
OworCQlzdHJ1Y3Qga3ZtX2lwaV9kYXRhCWlwaV9kYXRhOworCQlzdHJ1Y3Qga3ZtX3B0Y19nCXB0
Y19nX2RhdGE7CisJfSB1OworfTsKKwordW5pb24gcHRlX2ZsYWdzIHsKKwl1bnNpZ25lZCBsb25n
IHZhbDsKKwlzdHJ1Y3QgeworCQl1bnNpZ25lZCBsb25nIHAgICAgOiAgMTsgLyowICAgICAgKi8K
KwkJdW5zaWduZWQgbG9uZyAgICAgIDogIDE7IC8qIDEgICAgICovCisJCXVuc2lnbmVkIGxvbmcg
bWEgICA6ICAzOyAvKiAyLTQgICAqLworCQl1bnNpZ25lZCBsb25nIGEgICAgOiAgMTsgLyogNSAg
ICAgKi8KKwkJdW5zaWduZWQgbG9uZyBkICAgIDogIDE7IC8qIDYgICAgICovCisJCXVuc2lnbmVk
IGxvbmcgcGwgICA6ICAyOyAvKiA3LTggICAqLworCQl1bnNpZ25lZCBsb25nIGFyICAgOiAgMzsg
LyogOS0xMSAgKi8KKwkJdW5zaWduZWQgbG9uZyBwcG4gIDogMzg7IC8qIDEyLTQ5ICovCisJCXVu
c2lnbmVkIGxvbmcgICAgICA6ICAyOyAvKiA1MC01MSAqLworCQl1bnNpZ25lZCBsb25nIGVkICAg
OiAgMTsgLyogNTIgICAgKi8KKwl9OworfTsKKwordW5pb24gaWE2NF9wdGEgeworCXVuc2lnbmVk
IGxvbmcgdmFsOworCXN0cnVjdCB7CisJCXVuc2lnbmVkIGxvbmcgdmUgOiAxOworCQl1bnNpZ25l
ZCBsb25nIHJlc2VydmVkMCA6IDE7CisJCXVuc2lnbmVkIGxvbmcgc2l6ZSA6IDY7CisJCXVuc2ln
bmVkIGxvbmcgdmYgOiAxOworCQl1bnNpZ25lZCBsb25nIHJlc2VydmVkMSA6IDY7CisJCXVuc2ln
bmVkIGxvbmcgYmFzZSA6IDQ5OworCX07Cit9OworCitzdHJ1Y3QgdGhhc2hfY2IgeworCS8qIFRI
QVNIIGJhc2UgaW5mb3JtYXRpb24gKi8KKwlzdHJ1Y3QgdGhhc2hfZGF0YQkqaGFzaDsgLyogaGFz
aCB0YWJsZSBwb2ludGVyICovCisJdW5pb24gaWE2NF9wdGEJCXB0YTsKKwlpbnQgICAgICAgICAg
IG51bTsKK307CisKK3N0cnVjdCBrdm1fdmNwdV9zdGF0IHsKK307CisKK3N0cnVjdCBrdm1fdmNw
dV9hcmNoIHsKKwlpbnQgbGF1bmNoZWQ7CisJaW50IGxhc3RfZXhpdDsKKwlpbnQgbGFzdF9ydW5f
Y3B1OworCWludCB2bW1fdHJfc2xvdDsKKwlpbnQgdm1fdHJfc2xvdDsKKworI2RlZmluZSBWQ1BV
X01QX1NUQVRFX1JVTk5BQkxFICAgICAgICAgIDAKKyNkZWZpbmUgVkNQVV9NUF9TVEFURV9VTklO
SVRJQUxJWkVEICAgICAxCisjZGVmaW5lIFZDUFVfTVBfU1RBVEVfSU5JVF9SRUNFSVZFRCAgICAg
MgorI2RlZmluZSBWQ1BVX01QX1NUQVRFX0hBTFRFRCAgICAgICAgICAgIDMKKwlpbnQgbXBfc3Rh
dGU7CisKKyNkZWZpbmUgTUFYX1BUQ19HX05VTQkJCTMKKwlpbnQgcHRjX2dfY291bnQ7CisJc3Ry
dWN0IGt2bV9wdGNfZyBwdGNfZ19kYXRhW01BWF9QVENfR19OVU1dOworCisJLypoYWx0IHRpbWVy
IHRvIHdha2UgdXAgc2xlZXB5IHZjcHVzKi8KKwlzdHJ1Y3QgaHJ0aW1lciBobHRfdGltZXI7CisJ
bG9uZyBodF9hY3RpdmU7CisKKwlzdHJ1Y3Qga3ZtX2xhcGljICphcGljOyAgICAvKiBrZXJuZWwg
aXJxY2hpcCBjb250ZXh0ICovCisJc3RydWN0IHZwZCAqdnBkOworCisJLyogRXhpdCBkYXRhIGZv
ciB2bW1fdHJhbnNpdGlvbiovCisJc3RydWN0IGV4aXRfY3RsX2RhdGEgZXhpdF9kYXRhOworCisJ
Y3B1bWFza190IGNhY2hlX2NvaGVyZW50X21hcDsKKworCXVuc2lnbmVkIGxvbmcgdm1tX3JyOwor
CXVuc2lnbmVkIGxvbmcgaG9zdF9ycjY7CisJdW5zaWduZWQgbG9uZyBwc2JpdHNbOF07CisJdW5z
aWduZWQgbG9uZyBjcl9paXBhOworCXVuc2lnbmVkIGxvbmcgY3JfaXNyOworCXVuc2lnbmVkIGxv
bmcgdnNhX2Jhc2U7CisJdW5zaWduZWQgbG9uZyBkaXJ0eV9sb2dfbG9ja19wYTsKKwl1bnNpZ25l
ZCBsb25nIF9fZ3A7CisJLyogVFIgYW5kIFRDLiAgKi8KKwlzdHJ1Y3QgdGhhc2hfZGF0YSBpdHJz
W05JVFJTXTsKKwlzdHJ1Y3QgdGhhc2hfZGF0YSBkdHJzW05EVFJTXTsKKwkvKiBCaXQgaXMgc2V0
IGlmIHRoZXJlIGlzIGEgdHIvdGMgZm9yIHRoZSByZWdpb24uICAqLworCXVuc2lnbmVkIGNoYXIg
aXRyX3JlZ2lvbnM7CisJdW5zaWduZWQgY2hhciBkdHJfcmVnaW9uczsKKwl1bnNpZ25lZCBjaGFy
IHRjX3JlZ2lvbnM7CisJLyogcHVyZ2UgYWxsICovCisJdW5zaWduZWQgbG9uZyBwdGNlX2Jhc2U7
CisJdW5zaWduZWQgbG9uZyBwdGNlX2NvdW50WzJdOworCXVuc2lnbmVkIGxvbmcgcHRjZV9zdHJp
ZGVbMl07CisJLyogaXRjL2l0bSAqLworCXVuc2lnbmVkIGxvbmcgbGFzdF9pdGM7CisJbG9uZyBp
dGNfb2Zmc2V0OworCXVuc2lnbmVkIGxvbmcgaXRjX2NoZWNrOworCXVuc2lnbmVkIGxvbmcgdGlt
ZXJfY2hlY2s7CisJdW5zaWduZWQgbG9uZyB0aW1lcl9wZW5kaW5nOworCisJdW5zaWduZWQgbG9u
ZyB2cnJbOF07CisJdW5zaWduZWQgbG9uZyBpYnJbOF07CisJdW5zaWduZWQgbG9uZyBkYnJbOF07
CisJdW5zaWduZWQgbG9uZyBpbnN2Y1s0XTsJCS8qIEludGVycnVwdCBpbiBzZXJ2aWNlLiAgKi8K
Kwl1bnNpZ25lZCBsb25nIHh0cDsKKworCXVuc2lnbmVkIGxvbmcgbWV0YXBoeXNpY2FsX3JyMDsg
LyogZnJvbSBrdm1fYXJjaCAoc28gaXMgcGlubmVkKSAqLworCXVuc2lnbmVkIGxvbmcgbWV0YXBo
eXNpY2FsX3JyNDsJLyogZnJvbSBrdm1fYXJjaCAoc28gaXMgcGlubmVkKSAqLworCXVuc2lnbmVk
IGxvbmcgbWV0YXBoeXNpY2FsX3NhdmVkX3JyMDsgLyogZnJvbSBrdm1fYXJjaCAgICAgICAgICAq
LworCXVuc2lnbmVkIGxvbmcgbWV0YXBoeXNpY2FsX3NhdmVkX3JyNDsgLyogZnJvbSBrdm1fYXJj
aCAgICAgICAgICAqLworCXVuc2lnbmVkIGxvbmcgZnBfcHNyOyAgICAgICAvKnVzZWQgZm9yIGxh
enkgZmxvYXQgcmVnaXN0ZXIgKi8KKwl1bnNpZ25lZCBsb25nIHNhdmVkX2dwOworCS8qZm9yIHBo
eWNpYWwgIGVtdWxhdGlvbiAqLworCWludCBtb2RlX2ZsYWdzOworCXN0cnVjdCB0aGFzaF9jYiB2
dGxiOworCXN0cnVjdCB0aGFzaF9jYiB2aHB0OworCWNoYXIgaXJxX2NoZWNrOworCWNoYXIgaXJx
X25ld19wZW5kaW5nOworCisJdW5zaWduZWQgbG9uZyBvcGNvZGU7CisJdW5zaWduZWQgbG9uZyBj
YXVzZTsKKwl1bmlvbiBjb250ZXh0IGhvc3Q7CisJdW5pb24gY29udGV4dCBndWVzdDsKK307CisK
K3N0cnVjdCBrdm1fdm1fc3RhdCB7CisJdTY0IHJlbW90ZV90bGJfZmx1c2g7Cit9OworCitzdHJ1
Y3Qga3ZtX3NhbF9kYXRhIHsKKwl1bnNpZ25lZCBsb25nIGJvb3RfaXA7CisJdW5zaWduZWQgbG9u
ZyBib290X2dwOworfTsKKworc3RydWN0IGt2bV9hcmNoIHsKKwl1bnNpZ25lZCBsb25nCXZtX2Jh
c2U7CisJdW5zaWduZWQgbG9uZwltZXRhcGh5c2ljYWxfcnIwOworCXVuc2lnbmVkIGxvbmcJbWV0
YXBoeXNpY2FsX3JyNDsKKwl1bnNpZ25lZCBsb25nCXZtbV9pbml0X3JyOworCXVuc2lnbmVkIGxv
bmcJdmhwdF9iYXNlOworCXVuc2lnbmVkIGxvbmcJdnRsYl9iYXNlOworCXVuc2lnbmVkIGxvbmcg
CXZwZF9iYXNlOworCXNwaW5sb2NrX3QgZGlydHlfbG9nX2xvY2s7CisJc3RydWN0IGt2bV9pb2Fw
aWMgKnZpb2FwaWM7CisJc3RydWN0IGt2bV92bV9zdGF0IHN0YXQ7CisJc3RydWN0IGt2bV9zYWxf
ZGF0YSByZHZfc2FsX2RhdGE7Cit9OworCit1bmlvbiBjcHVpZDNfdCB7CisJdTY0IHZhbHVlOwor
CXN0cnVjdCB7CisJCXU2NCBudW1iZXIgOiA4OworCQl1NjQgcmV2aXNpb24gOiA4OworCQl1NjQg
bW9kZWwgOiA4OworCQl1NjQgZmFtaWx5IDogODsKKwkJdTY0IGFyY2hyZXYgOiA4OworCQl1NjQg
cnYgOiAyNDsKKwl9OworfTsKKworc3RydWN0IGt2bV9wdF9yZWdzIHsKKwkvKiBUaGUgZm9sbG93
aW5nIHJlZ2lzdGVycyBhcmUgc2F2ZWQgYnkgU0FWRV9NSU46ICovCisJdW5zaWduZWQgbG9uZyBi
NjsgIC8qIHNjcmF0Y2ggKi8KKwl1bnNpZ25lZCBsb25nIGI3OyAgLyogc2NyYXRjaCAqLworCisJ
dW5zaWduZWQgbG9uZyBhcl9jc2Q7IC8qIHVzZWQgYnkgY21wOHhjaGcxNiAoc2NyYXRjaCkgKi8K
Kwl1bnNpZ25lZCBsb25nIGFyX3NzZDsgLyogcmVzZXJ2ZWQgZm9yIGZ1dHVyZSB1c2UgKHNjcmF0
Y2gpICovCisKKwl1bnNpZ25lZCBsb25nIHI4OyAgLyogc2NyYXRjaCAocmV0dXJuIHZhbHVlIHJl
Z2lzdGVyIDApICovCisJdW5zaWduZWQgbG9uZyByOTsgIC8qIHNjcmF0Y2ggKHJldHVybiB2YWx1
ZSByZWdpc3RlciAxKSAqLworCXVuc2lnbmVkIGxvbmcgcjEwOyAvKiBzY3JhdGNoIChyZXR1cm4g
dmFsdWUgcmVnaXN0ZXIgMikgKi8KKwl1bnNpZ25lZCBsb25nIHIxMTsgLyogc2NyYXRjaCAocmV0
dXJuIHZhbHVlIHJlZ2lzdGVyIDMpICovCisKKwl1bnNpZ25lZCBsb25nIGNyX2lwc3I7IC8qIGlu
dGVycnVwdGVkIHRhc2sncyBwc3IgKi8KKwl1bnNpZ25lZCBsb25nIGNyX2lpcDsgIC8qIGludGVy
cnVwdGVkIHRhc2sncyBpbnN0cnVjdGlvbiBwb2ludGVyICovCisJdW5zaWduZWQgbG9uZyBjcl9p
ZnM7ICAvKiBpbnRlcnJ1cHRlZCB0YXNrJ3MgZnVuY3Rpb24gc3RhdGUgKi8KKworCXVuc2lnbmVk
IGxvbmcgYXJfdW5hdDsgLyogaW50ZXJydXB0ZWQgdGFzaydzIE5hVCByZWdpc3RlciAocHJlc2Vy
dmVkKSAqLworCXVuc2lnbmVkIGxvbmcgYXJfcGZzOyAgLyogcHJldiBmdW5jdGlvbiBzdGF0ZSAg
Ki8KKwl1bnNpZ25lZCBsb25nIGFyX3JzYzsgIC8qIFJTRSBjb25maWd1cmF0aW9uICovCisJLyog
VGhlIGZvbGxvd2luZyB0d28gYXJlIHZhbGlkIG9ubHkgaWYgY3JfaXBzci5jcGwgPiAwOiAqLwor
CXVuc2lnbmVkIGxvbmcgYXJfcm5hdDsgIC8qIFJTRSBOYVQgKi8KKwl1bnNpZ25lZCBsb25nIGFy
X2JzcHN0b3JlOyAvKiBSU0UgYnNwc3RvcmUgKi8KKworCXVuc2lnbmVkIGxvbmcgcHI7ICAvKiA2
NCBwcmVkaWNhdGUgcmVnaXN0ZXJzICgxIGJpdCBlYWNoKSAqLworCXVuc2lnbmVkIGxvbmcgYjA7
ICAvKiByZXR1cm4gcG9pbnRlciAoYnApICovCisJdW5zaWduZWQgbG9uZyBsb2FkcnM7ICAvKiBz
aXplIG9mIGRpcnR5IHBhcnRpdGlvbiA8PCAxNiAqLworCisJdW5zaWduZWQgbG9uZyByMTsgIC8q
IHRoZSBncCBwb2ludGVyICovCisJdW5zaWduZWQgbG9uZyByMTI7IC8qIGludGVycnVwdGVkIHRh
c2sncyBtZW1vcnkgc3RhY2sgcG9pbnRlciAqLworCXVuc2lnbmVkIGxvbmcgcjEzOyAvKiB0aHJl
YWQgcG9pbnRlciAqLworCisJdW5zaWduZWQgbG9uZyBhcl9mcHNyOyAgLyogZmxvYXRpbmcgcG9p
bnQgc3RhdHVzIChwcmVzZXJ2ZWQpICovCisJdW5zaWduZWQgbG9uZyByMTU7ICAvKiBzY3JhdGNo
ICovCisKKwkvKiBUaGUgcmVtYWluaW5nIHJlZ2lzdGVycyBhcmUgTk9UIHNhdmVkIGZvciBzeXN0
ZW0gY2FsbHMuICAqLworCXVuc2lnbmVkIGxvbmcgcjE0OyAgLyogc2NyYXRjaCAqLworCXVuc2ln
bmVkIGxvbmcgcjI7ICAvKiBzY3JhdGNoICovCisJdW5zaWduZWQgbG9uZyByMzsgIC8qIHNjcmF0
Y2ggKi8KKwl1bnNpZ25lZCBsb25nIHIxNjsgIC8qIHNjcmF0Y2ggKi8KKwl1bnNpZ25lZCBsb25n
IHIxNzsgIC8qIHNjcmF0Y2ggKi8KKwl1bnNpZ25lZCBsb25nIHIxODsgIC8qIHNjcmF0Y2ggKi8K
Kwl1bnNpZ25lZCBsb25nIHIxOTsgIC8qIHNjcmF0Y2ggKi8KKwl1bnNpZ25lZCBsb25nIHIyMDsg
IC8qIHNjcmF0Y2ggKi8KKwl1bnNpZ25lZCBsb25nIHIyMTsgIC8qIHNjcmF0Y2ggKi8KKwl1bnNp
Z25lZCBsb25nIHIyMjsgIC8qIHNjcmF0Y2ggKi8KKwl1bnNpZ25lZCBsb25nIHIyMzsgIC8qIHNj
cmF0Y2ggKi8KKwl1bnNpZ25lZCBsb25nIHIyNDsgIC8qIHNjcmF0Y2ggKi8KKwl1bnNpZ25lZCBs
b25nIHIyNTsgIC8qIHNjcmF0Y2ggKi8KKwl1bnNpZ25lZCBsb25nIHIyNjsgIC8qIHNjcmF0Y2gg
Ki8KKwl1bnNpZ25lZCBsb25nIHIyNzsgIC8qIHNjcmF0Y2ggKi8KKwl1bnNpZ25lZCBsb25nIHIy
ODsgIC8qIHNjcmF0Y2ggKi8KKwl1bnNpZ25lZCBsb25nIHIyOTsgIC8qIHNjcmF0Y2ggKi8KKwl1
bnNpZ25lZCBsb25nIHIzMDsgIC8qIHNjcmF0Y2ggKi8KKwl1bnNpZ25lZCBsb25nIHIzMTsgIC8q
IHNjcmF0Y2ggKi8KKwl1bnNpZ25lZCBsb25nIGFyX2NjdjsgIC8qIGNvbXBhcmUvZXhjaGFuZ2Ug
dmFsdWUgKHNjcmF0Y2gpICovCisKKwkvKgorCSAqIEZsb2F0aW5nIHBvaW50IHJlZ2lzdGVycyB0
aGF0IHRoZSBrZXJuZWwgY29uc2lkZXJzIHNjcmF0Y2g6CisJICovCisJc3RydWN0IGlhNjRfZnBy
ZWcgZjY7ICAvKiBzY3JhdGNoICovCisJc3RydWN0IGlhNjRfZnByZWcgZjc7ICAvKiBzY3JhdGNo
ICovCisJc3RydWN0IGlhNjRfZnByZWcgZjg7ICAvKiBzY3JhdGNoICovCisJc3RydWN0IGlhNjRf
ZnByZWcgZjk7ICAvKiBzY3JhdGNoICovCisJc3RydWN0IGlhNjRfZnByZWcgZjEwOyAgLyogc2Ny
YXRjaCAqLworCXN0cnVjdCBpYTY0X2ZwcmVnIGYxMTsgIC8qIHNjcmF0Y2ggKi8KKworCXVuc2ln
bmVkIGxvbmcgcjQ7ICAvKiBwcmVzZXJ2ZWQgKi8KKwl1bnNpZ25lZCBsb25nIHI1OyAgLyogcHJl
c2VydmVkICovCisJdW5zaWduZWQgbG9uZyByNjsgIC8qIHByZXNlcnZlZCAqLworCXVuc2lnbmVk
IGxvbmcgcjc7ICAvKiBwcmVzZXJ2ZWQgKi8KKwl1bnNpZ25lZCBsb25nIGVtbF91bmF0OyAgICAv
KiB1c2VkIGZvciBlbXVsYXRpbmcgaW5zdHJ1Y3Rpb24gKi8KKwl1bnNpZ25lZCBsb25nIHBhZDA7
ICAgICAvKiBhbGlnbm1lbnQgcGFkICovCit9OworCitzdGF0aWMgaW5saW5lIHN0cnVjdCBrdm1f
cHRfcmVncyAqdmNwdV9yZWdzKHN0cnVjdCBrdm1fdmNwdSAqdikKK3sKKwlyZXR1cm4gKHN0cnVj
dCBrdm1fcHRfcmVncyAqKSAoKHVuc2lnbmVkIGxvbmcpIHYgKyBJQTY0X1NUS19PRkZTRVQpIC0g
MTsKK30KKwordHlwZWRlZiBpbnQga3ZtX3ZtbV9lbnRyeSh2b2lkKTsKK3R5cGVkZWYgdm9pZCBr
dm1fdHJhbXBfZW50cnkodW5pb24gY29udGV4dCAqaG9zdCwgdW5pb24gY29udGV4dCAqZ3Vlc3Qp
OworCitzdHJ1Y3Qga3ZtX3ZtbV9pbmZveworCXN0cnVjdCBtb2R1bGUJKm1vZHVsZTsKKwlrdm1f
dm1tX2VudHJ5IAkqdm1tX2VudHJ5OworCWt2bV90cmFtcF9lbnRyeSAqdHJhbXBfZW50cnk7CisJ
dW5zaWduZWQgbG9uZyAJdm1tX2l2dDsKK307CisKK2ludCBrdm1faGlnaGVzdF9wZW5kaW5nX2ly
cShzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpOworaW50IGt2bV9lbXVsYXRlX2hhbHQoc3RydWN0IGt2
bV92Y3B1ICp2Y3B1KTsKK2ludCBrdm1fcGFsX2VtdWwoc3RydWN0IGt2bV92Y3B1ICp2Y3B1LCBz
dHJ1Y3Qga3ZtX3J1biAqa3ZtX3J1bik7Cit2b2lkIGt2bV9zYWxfZW11bChzdHJ1Y3Qga3ZtX3Zj
cHUgKnZjcHUpOworCisjZW5kaWYKZGlmZiAtLWdpdCBhL2luY2x1ZGUvYXNtLWlhNjQva3ZtX3Bh
cmEuaCBiL2luY2x1ZGUvYXNtLWlhNjQva3ZtX3BhcmEuaApuZXcgZmlsZSBtb2RlIDEwMDY0NApp
bmRleCAwMDAwMDAwLi45Zjk3OTZiCi0tLSAvZGV2L251bGwKKysrIGIvaW5jbHVkZS9hc20taWE2
NC9rdm1fcGFyYS5oCkBAIC0wLDAgKzEsMjkgQEAKKyNpZm5kZWYgX19JQTY0X0tWTV9QQVJBX0gK
KyNkZWZpbmUgX19JQTY0X0tWTV9QQVJBX0gKKworLyoKKyAqIGFzbS1pYTY0L2t2bV9wYXJhLmgK
KyAqCisgKiBDb3B5cmlnaHQgKEMpIDIwMDcgWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56aGFuZ0Bp
bnRlbC5jb20+CisgKgorICogVGhpcyBwcm9ncmFtIGlzIGZyZWUgc29mdHdhcmU7IHlvdSBjYW4g
cmVkaXN0cmlidXRlIGl0IGFuZC9vciBtb2RpZnkgaXQKKyAqIHVuZGVyIHRoZSB0ZXJtcyBhbmQg
Y29uZGl0aW9ucyBvZiB0aGUgR05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2UsCisgKiB2ZXJzaW9u
IDIsIGFzIHB1Ymxpc2hlZCBieSB0aGUgRnJlZSBTb2Z0d2FyZSBGb3VuZGF0aW9uLgorICoKKyAq
IFRoaXMgcHJvZ3JhbSBpcyBkaXN0cmlidXRlZCBpbiB0aGUgaG9wZSBpdCB3aWxsIGJlIHVzZWZ1
bCwgYnV0IFdJVEhPVVQKKyAqIEFOWSBXQVJSQU5UWTsgd2l0aG91dCBldmVuIHRoZSBpbXBsaWVk
IHdhcnJhbnR5IG9mIE1FUkNIQU5UQUJJTElUWSBvcgorICogRklUTkVTUyBGT1IgQSBQQVJUSUNV
TEFSIFBVUlBPU0UuICBTZWUgdGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlIGZvcgorICog
bW9yZSBkZXRhaWxzLgorICoKKyAqIFlvdSBzaG91bGQgaGF2ZSByZWNlaXZlZCBhIGNvcHkgb2Yg
dGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlIGFsb25nIHdpdGgKKyAqIHRoaXMgcHJvZ3Jh
bTsgaWYgbm90LCB3cml0ZSB0byB0aGUgRnJlZSBTb2Z0d2FyZSBGb3VuZGF0aW9uLCBJbmMuLCA1
OSBUZW1wbGUKKyAqIFBsYWNlIC0gU3VpdGUgMzMwLCBCb3N0b24sIE1BIDAyMTExLTEzMDcgVVNB
LgorICoKKyAqLworCitzdGF0aWMgaW5saW5lIHVuc2lnbmVkIGludCBrdm1fYXJjaF9wYXJhX2Zl
YXR1cmVzKHZvaWQpCit7CisJcmV0dXJuIDA7Cit9CisKKyNlbmRpZgotLSAKMS41LjIKCg==

------_=_NextPart_001_01C893E5.477AAB0B--
