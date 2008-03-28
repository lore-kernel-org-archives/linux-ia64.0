From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Fri, 28 Mar 2008 09:59:09 +0000
Subject: [03/15][PATCH] kvm/ia64: Add header files for kvm/ia64.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCFF7EFD@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C890BA.5E632DFF"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C890BA.5E632DFF
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From cf64ba3c5464b7da6c6fb2871b8424a08ade3ab2 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Fri, 28 Mar 2008 09:48:10 +0800
Subject: [PATCH] kvm/ia64: Add header files for kvm/ia64.

Three header files are added:
asm-ia64/kvm.h
asm-ia64/kvm_host.h
asm-ia64/kvm_para.h
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 include/asm-ia64/kvm.h      |  205 +++++++++++++++++
 include/asm-ia64/kvm_host.h |  530
+++++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/kvm_para.h |   29 +++
 3 files changed, 764 insertions(+), 0 deletions(-)
 create mode 100644 include/asm-ia64/kvm.h
 create mode 100644 include/asm-ia64/kvm_host.h
 create mode 100644 include/asm-ia64/kvm_para.h

diff --git a/include/asm-ia64/kvm.h b/include/asm-ia64/kvm.h
new file mode 100644
index 0000000..8c70dd6
--- /dev/null
+++ b/include/asm-ia64/kvm.h
@@ -0,0 +1,205 @@
+#ifndef __ASM_KVM_IA64_H
+#define __ASM_KVM_IA64_H
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
+typedef union context {
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
+} context_t;
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
index 0000000..522bde0
--- /dev/null
+++ b/include/asm-ia64/kvm_host.h
@@ -0,0 +1,530 @@
+/* -*-  Mode:C; c-basic-offset:4; tab-width:4; indent-tabs-mode:nil -*-
*/
+/*
+ * ia64.h: used for kvm module, and hold ia64-specific sections.
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
+typedef struct kvm_mmio_req mmio_req_t;
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
+		mmio_req_t		ioreq;
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
+struct kvm_vcpu_stat {
+};
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
+	spinlock_t dirty_log_lock;
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

------_=_NextPart_001_01C890BA.5E632DFF
Content-Type: application/octet-stream;
	name="0003-kvm-ia64-Add-header-files-for-kvm-ia64.patch"
Content-Transfer-Encoding: base64
Content-Description: 0003-kvm-ia64-Add-header-files-for-kvm-ia64.patch
Content-Disposition: attachment;
	filename="0003-kvm-ia64-Add-header-files-for-kvm-ia64.patch"

RnJvbSBjZjY0YmEzYzU0NjRiN2RhNmM2ZmIyODcxYjg0MjRhMDhhZGUzYWIyIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogRnJpLCAyOCBNYXIgMjAwOCAwOTo0ODoxMCArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IGt2bS9pYTY0OiBBZGQgaGVhZGVyIGZpbGVzIGZvciBrdm0vaWE2NC4KClRocmVlIGhlYWRlciBm
aWxlcyBhcmUgYWRkZWQ6CmFzbS1pYTY0L2t2bS5oCmFzbS1pYTY0L2t2bV9ob3N0LmgKYXNtLWlh
NjQva3ZtX3BhcmEuaApTaWduZWQtb2ZmLWJ5OiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5n
QGludGVsLmNvbT4KLS0tCiBpbmNsdWRlL2FzbS1pYTY0L2t2bS5oICAgICAgfCAgMjA1ICsrKysr
KysrKysrKysrKysrCiBpbmNsdWRlL2FzbS1pYTY0L2t2bV9ob3N0LmggfCAgNTMwICsrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysKIGluY2x1ZGUvYXNtLWlhNjQva3Zt
X3BhcmEuaCB8ICAgMjkgKysrCiAzIGZpbGVzIGNoYW5nZWQsIDc2NCBpbnNlcnRpb25zKCspLCAw
IGRlbGV0aW9ucygtKQogY3JlYXRlIG1vZGUgMTAwNjQ0IGluY2x1ZGUvYXNtLWlhNjQva3ZtLmgK
IGNyZWF0ZSBtb2RlIDEwMDY0NCBpbmNsdWRlL2FzbS1pYTY0L2t2bV9ob3N0LmgKIGNyZWF0ZSBt
b2RlIDEwMDY0NCBpbmNsdWRlL2FzbS1pYTY0L2t2bV9wYXJhLmgKCmRpZmYgLS1naXQgYS9pbmNs
dWRlL2FzbS1pYTY0L2t2bS5oIGIvaW5jbHVkZS9hc20taWE2NC9rdm0uaApuZXcgZmlsZSBtb2Rl
IDEwMDY0NAppbmRleCAwMDAwMDAwLi44YzcwZGQ2Ci0tLSAvZGV2L251bGwKKysrIGIvaW5jbHVk
ZS9hc20taWE2NC9rdm0uaApAQCAtMCwwICsxLDIwNSBAQAorI2lmbmRlZiBfX0FTTV9LVk1fSUE2
NF9ICisjZGVmaW5lIF9fQVNNX0tWTV9JQTY0X0gKKworLyoKKyAqIGFzbS1pYTY0L2t2bS5oOiBr
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
U0laRQk4KjEwMjQKKwordHlwZWRlZiB1bmlvbiBjb250ZXh0IHsKKwkvKiA4SyBzaXplICovCisJ
Y2hhcglkdW1teVtLVk1fQ09OVEVYVF9TSVpFXTsKKwlzdHJ1Y3QgeworCQl1bnNpZ25lZCBsb25n
ICAgICAgIHBzcjsKKwkJdW5zaWduZWQgbG9uZyAgICAgICBwcjsKKwkJdW5zaWduZWQgbG9uZyAg
ICAgICBjYWxsZXJfdW5hdDsKKwkJdW5zaWduZWQgbG9uZyAgICAgICBwYWQ7CisJCXVuc2lnbmVk
IGxvbmcgICAgICAgZ3JbMzJdOworCQl1bnNpZ25lZCBsb25nICAgICAgIGFyWzEyOF07CisJCXVu
c2lnbmVkIGxvbmcgICAgICAgYnJbOF07CisJCXVuc2lnbmVkIGxvbmcgICAgICAgY3JbMTI4XTsK
KwkJdW5zaWduZWQgbG9uZyAgICAgICBycls4XTsKKwkJdW5zaWduZWQgbG9uZyAgICAgICBpYnJb
OF07CisJCXVuc2lnbmVkIGxvbmcgICAgICAgZGJyWzhdOworCQl1bnNpZ25lZCBsb25nICAgICAg
IHBrcls4XTsKKwkJc3RydWN0IGlhNjRfZnByZWcgICBmclsxMjhdOworCX07Cit9IGNvbnRleHRf
dDsKKwordHlwZWRlZiBzdHJ1Y3QgdGhhc2hfZGF0YSB7CisJdW5pb24geworCQlzdHJ1Y3Qgewor
CQkJdW5zaWduZWQgbG9uZyBwICAgIDogIDE7IC8qIDAgKi8KKwkJCXVuc2lnbmVkIGxvbmcgcnYx
ICA6ICAxOyAvKiAxICovCisJCQl1bnNpZ25lZCBsb25nIG1hICAgOiAgMzsgLyogMi00ICovCisJ
CQl1bnNpZ25lZCBsb25nIGEgICAgOiAgMTsgLyogNSAqLworCQkJdW5zaWduZWQgbG9uZyBkICAg
IDogIDE7IC8qIDYgKi8KKwkJCXVuc2lnbmVkIGxvbmcgcGwgICA6ICAyOyAvKiA3LTggKi8KKwkJ
CXVuc2lnbmVkIGxvbmcgYXIgICA6ICAzOyAvKiA5LTExICovCisJCQl1bnNpZ25lZCBsb25nIHBw
biAgOiAzODsgLyogMTItNDkgKi8KKwkJCXVuc2lnbmVkIGxvbmcgcnYyICA6ICAyOyAvKiA1MC01
MSAqLworCQkJdW5zaWduZWQgbG9uZyBlZCAgIDogIDE7IC8qIDUyICovCisJCQl1bnNpZ25lZCBs
b25nIGlnMSAgOiAxMTsgLyogNTMtNjMgKi8KKwkJfTsKKwkJc3RydWN0IHsKKwkJCXVuc2lnbmVk
IGxvbmcgX19ydjEgOiA1MzsgICAgIC8qIDAtNTIgKi8KKwkJCXVuc2lnbmVkIGxvbmcgY29udGln
dW91cyA6IDE7IC8qNTMgKi8KKwkJCXVuc2lnbmVkIGxvbmcgdGMgOiAxOyAgICAgICAgIC8qIDU0
IFRSIG9yIFRDICovCisJCQl1bnNpZ25lZCBsb25nIGNsIDogMTsKKwkJCS8qIDU1IEkgc2lkZSBv
ciBEIHNpZGUgY2FjaGUgbGluZSAqLworCQkJdW5zaWduZWQgbG9uZyBsZW4gIDogIDQ7ICAgICAg
LyogNTYtNTkgKi8KKwkJCXVuc2lnbmVkIGxvbmcgaW8gIDogMTsJLyogNjAgZW50cnkgaXMgZm9y
IGlvIG9yIG5vdCAqLworCQkJdW5zaWduZWQgbG9uZyBub21hcCA6IDE7CisJCQkvKiA2MSBlbnRy
eSBjYW5uJ3QgYmUgaW5zZXJ0ZWQgaW50byBtYWNoaW5lIFRMQi4qLworCQkJdW5zaWduZWQgbG9u
ZyBjaGVja2VkIDogMTsKKwkJCS8qIDYyIGZvciBWVExCL1ZIUFQgc2FuaXR5IGNoZWNrICovCisJ
CQl1bnNpZ25lZCBsb25nIGludmFsaWQgOiAxOworCQkJLyogNjMgaW52YWxpZCBlbnRyeSAqLwor
CQl9OworCQl1bnNpZ25lZCBsb25nIHBhZ2VfZmxhZ3M7CisJfTsgICAgICAgICAgICAgICAgICAv
KiBzYW1lIGZvciBWSFBUIGFuZCBUTEIgKi8KKworCXVuaW9uIHsKKwkJc3RydWN0IHsKKwkJCXVu
c2lnbmVkIGxvbmcgcnYzICA6ICAyOworCQkJdW5zaWduZWQgbG9uZyBwcyAgIDogIDY7CisJCQl1
bnNpZ25lZCBsb25nIGtleSAgOiAyNDsKKwkJCXVuc2lnbmVkIGxvbmcgcnY0ICA6IDMyOworCQl9
OworCQl1bnNpZ25lZCBsb25nIGl0aXI7CisJfTsKKwl1bmlvbiB7CisJCXN0cnVjdCB7CisJCQl1
bnNpZ25lZCBsb25nIGlnMiAgOiAgMTI7CisJCQl1bnNpZ25lZCBsb25nIHZwbiAgOiAgNDk7CisJ
CQl1bnNpZ25lZCBsb25nIHZybiAgOiAgIDM7CisJCX07CisJCXVuc2lnbmVkIGxvbmcgaWZhOwor
CQl1bnNpZ25lZCBsb25nIHZhZHI7CisJCXN0cnVjdCB7CisJCQl1bnNpZ25lZCBsb25nIHRhZyAg
OiAgNjM7CisJCQl1bnNpZ25lZCBsb25nIHRpICAgOiAgMTsKKwkJfTsKKwkJdW5zaWduZWQgbG9u
ZyBldGFnOworCX07CisJdW5pb24geworCQlzdHJ1Y3QgdGhhc2hfZGF0YSAqbmV4dDsKKwkJdW5z
aWduZWQgbG9uZyByaWQ7CisJCXVuc2lnbmVkIGxvbmcgZ3BhZGRyOworCX07Cit9IHRoYXNoX2Rh
dGFfdDsKKworI2RlZmluZQlOSVRSUwk4CisjZGVmaW5lIE5EVFJTCTgKKworc3RydWN0IHNhdmVk
X3ZwZCB7CisJdW5zaWduZWQgbG9uZyAgdmhwaTsKKwl1bnNpZ25lZCBsb25nICB2Z3JbMTZdOwor
CXVuc2lnbmVkIGxvbmcgIHZiZ3JbMTZdOworCXVuc2lnbmVkIGxvbmcgIHZuYXQ7CisJdW5zaWdu
ZWQgbG9uZyAgdmJuYXQ7CisJdW5zaWduZWQgbG9uZyAgdmNwdWlkWzVdOworCXVuc2lnbmVkIGxv
bmcgIHZwc3I7CisJdW5zaWduZWQgbG9uZyAgdnByOworCXVuc2lnbmVkIGxvbmcgIHZjclsxMjhd
OworfTsKKworc3RydWN0IGt2bV9yZWdzIHsKKwljaGFyICpzYXZlZF9ndWVzdDsKKwljaGFyICpz
YXZlZF9zdGFjazsKKwlzdHJ1Y3Qgc2F2ZWRfdnBkIHZwZDsKKwkvKkFyY2gtcmVncyovCisJaW50
IG1wX3N0YXRlOworCXVuc2lnbmVkIGxvbmcgdm1tX3JyOworCS8qIFRSIGFuZCBUQy4gICovCisJ
c3RydWN0IHRoYXNoX2RhdGEgaXRyc1tOSVRSU107CisJc3RydWN0IHRoYXNoX2RhdGEgZHRyc1tO
RFRSU107CisJLyogQml0IGlzIHNldCBpZiB0aGVyZSBpcyBhIHRyL3RjIGZvciB0aGUgcmVnaW9u
LiAgKi8KKwl1bnNpZ25lZCBjaGFyIGl0cl9yZWdpb25zOworCXVuc2lnbmVkIGNoYXIgZHRyX3Jl
Z2lvbnM7CisJdW5zaWduZWQgY2hhciB0Y19yZWdpb25zOworCisJY2hhciBpcnFfY2hlY2s7CisJ
dW5zaWduZWQgbG9uZyBzYXZlZF9pdGM7CisJdW5zaWduZWQgbG9uZyBpdGNfY2hlY2s7CisJdW5z
aWduZWQgbG9uZyB0aW1lcl9jaGVjazsKKwl1bnNpZ25lZCBsb25nIHRpbWVyX3BlbmRpbmc7CisJ
dW5zaWduZWQgbG9uZyBsYXN0X2l0YzsKKworCXVuc2lnbmVkIGxvbmcgdnJyWzhdOworCXVuc2ln
bmVkIGxvbmcgaWJyWzhdOworCXVuc2lnbmVkIGxvbmcgZGJyWzhdOworCXVuc2lnbmVkIGxvbmcg
aW5zdmNbNF07CQkvKiBJbnRlcnJ1cHQgaW4gc2VydmljZS4gICovCisJdW5zaWduZWQgbG9uZyB4
dHA7CisKKwl1bnNpZ25lZCBsb25nIG1ldGFwaHlzaWNhbF9ycjA7IC8qIGZyb20ga3ZtX2FyY2gg
KHNvIGlzIHBpbm5lZCkgKi8KKwl1bnNpZ25lZCBsb25nIG1ldGFwaHlzaWNhbF9ycjQ7CS8qIGZy
b20ga3ZtX2FyY2ggKHNvIGlzIHBpbm5lZCkgKi8KKwl1bnNpZ25lZCBsb25nIG1ldGFwaHlzaWNh
bF9zYXZlZF9ycjA7IC8qIGZyb20ga3ZtX2FyY2ggICAgICAgICAgKi8KKwl1bnNpZ25lZCBsb25n
IG1ldGFwaHlzaWNhbF9zYXZlZF9ycjQ7IC8qIGZyb20ga3ZtX2FyY2ggICAgICAgICAgKi8KKwl1
bnNpZ25lZCBsb25nIGZwX3BzcjsgICAgICAgLyp1c2VkIGZvciBsYXp5IGZsb2F0IHJlZ2lzdGVy
ICovCisJdW5zaWduZWQgbG9uZyBzYXZlZF9ncDsKKwkvKmZvciBwaHljaWFsICBlbXVsYXRpb24g
Ki8KK307CisKK3N0cnVjdCBrdm1fc3JlZ3MgeworfTsKKworc3RydWN0IGt2bV9mcHUgeworfTsK
KworI2VuZGlmCmRpZmYgLS1naXQgYS9pbmNsdWRlL2FzbS1pYTY0L2t2bV9ob3N0LmggYi9pbmNs
dWRlL2FzbS1pYTY0L2t2bV9ob3N0LmgKbmV3IGZpbGUgbW9kZSAxMDA2NDQKaW5kZXggMDAwMDAw
MC4uNTIyYmRlMAotLS0gL2Rldi9udWxsCisrKyBiL2luY2x1ZGUvYXNtLWlhNjQva3ZtX2hvc3Qu
aApAQCAtMCwwICsxLDUzMCBAQAorLyogLSotICBNb2RlOkM7IGMtYmFzaWMtb2Zmc2V0OjQ7IHRh
Yi13aWR0aDo0OyBpbmRlbnQtdGFicy1tb2RlOm5pbCAtKi0gKi8KKy8qCisgKiBpYTY0Lmg6IHVz
ZWQgZm9yIGt2bSBtb2R1bGUsIGFuZCBob2xkIGlhNjQtc3BlY2lmaWMgc2VjdGlvbnMuCisgKgor
ICogQ29weXJpZ2h0IChDKSAyMDA3LCBJbnRlbCBDb3Jwb3JhdGlvbi4KKyAqCisgKiBYaWFudGFv
IFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNvbT4KKyAqCisgKiBUaGlzIHByb2dyYW0gaXMg
ZnJlZSBzb2Z0d2FyZTsgeW91IGNhbiByZWRpc3RyaWJ1dGUgaXQgYW5kL29yIG1vZGlmeSBpdAor
ICogdW5kZXIgdGhlIHRlcm1zIGFuZCBjb25kaXRpb25zIG9mIHRoZSBHTlUgR2VuZXJhbCBQdWJs
aWMgTGljZW5zZSwKKyAqIHZlcnNpb24gMiwgYXMgcHVibGlzaGVkIGJ5IHRoZSBGcmVlIFNvZnR3
YXJlIEZvdW5kYXRpb24uCisgKgorICogVGhpcyBwcm9ncmFtIGlzIGRpc3RyaWJ1dGVkIGluIHRo
ZSBob3BlIGl0IHdpbGwgYmUgdXNlZnVsLCBidXQgV0lUSE9VVAorICogQU5ZIFdBUlJBTlRZOyB3
aXRob3V0IGV2ZW4gdGhlIGltcGxpZWQgd2FycmFudHkgb2YgTUVSQ0hBTlRBQklMSVRZIG9yCisg
KiBGSVRORVNTIEZPUiBBIFBBUlRJQ1VMQVIgUFVSUE9TRS4gIFNlZSB0aGUgR05VIEdlbmVyYWwg
UHVibGljIExpY2Vuc2UgZm9yCisgKiBtb3JlIGRldGFpbHMuCisgKgorICogWW91IHNob3VsZCBo
YXZlIHJlY2VpdmVkIGEgY29weSBvZiB0aGUgR05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2UgYWxv
bmcgd2l0aAorICogdGhpcyBwcm9ncmFtOyBpZiBub3QsIHdyaXRlIHRvIHRoZSBGcmVlIFNvZnR3
YXJlIEZvdW5kYXRpb24sIEluYy4sIDU5IFRlbXBsZQorICogUGxhY2UgLSBTdWl0ZSAzMzAsIEJv
c3RvbiwgTUEgMDIxMTEtMTMwNyBVU0EuCisgKgorICovCisKKyNpZm5kZWYgX19BU01fS1ZNX0hP
U1RfSAorI2RlZmluZSBfX0FTTV9LVk1fSE9TVF9ICisKKworI2luY2x1ZGUgPGxpbnV4L3R5cGVz
Lmg+CisjaW5jbHVkZSA8bGludXgvbW0uaD4KKyNpbmNsdWRlIDxsaW51eC9rdm0uaD4KKyNpbmNs
dWRlIDxsaW51eC9rdm1fcGFyYS5oPgorI2luY2x1ZGUgPGxpbnV4L2t2bV90eXBlcy5oPgorCisj
aW5jbHVkZSA8YXNtL3BhbC5oPgorI2luY2x1ZGUgPGFzbS9zYWwuaD4KKworI2RlZmluZSBLVk1f
TUFYX1ZDUFVTIDQKKyNkZWZpbmUgS1ZNX01FTU9SWV9TTE9UUyAzMgorLyogbWVtb3J5IHNsb3Rz
IHRoYXQgZG9lcyBub3QgZXhwb3NlZCB0byB1c2Vyc3BhY2UgKi8KKyNkZWZpbmUgS1ZNX1BSSVZB
VEVfTUVNX1NMT1RTIDQKKworCisvKiBkZWZpbmUgZXhpdCByZWFzb25zIGZyb20gdm1tIHRvIGt2
bSovCisjZGVmaW5lIEVYSVRfUkVBU09OX1ZNX1BBTklDCQkwCisjZGVmaW5lIEVYSVRfUkVBU09O
X01NSU9fSU5TVFJVQ1RJT04JMQorI2RlZmluZSBFWElUX1JFQVNPTl9QQUxfQ0FMTAkJMgorI2Rl
ZmluZSBFWElUX1JFQVNPTl9TQUxfQ0FMTAkJMworI2RlZmluZSBFWElUX1JFQVNPTl9TV0lUQ0hf
UlI2CQk0CisjZGVmaW5lIEVYSVRfUkVBU09OX1ZNX0RFU1RST1kJCTUKKyNkZWZpbmUgRVhJVF9S
RUFTT05fRVhURVJOQUxfSU5URVJSVVBUCTYKKyNkZWZpbmUgRVhJVF9SRUFTT05fSVBJCQkJNwor
I2RlZmluZSBFWElUX1JFQVNPTl9QVENfRwkJOAorCisvKkRlZmluZSB2bW0gYWRkcmVzcyBzcGFj
ZSBhbmQgdm0gZGF0YSBzcGFjZS4qLworI2RlZmluZSBLVk1fVk1NX1NJWkUgKDE2VUw8PDIwKQor
I2RlZmluZSBLVk1fVk1NX1NISUZUIDI0CisjZGVmaW5lIEtWTV9WTU1fQkFTRSAweEQwMDAwMDAw
MDAwMDAwMDBVTAorI2RlZmluZSBWTU1fU0laRSAoOFVMPDwyMCkKKworLyoKKyAqIERlZmluZSB2
bV9idWZmZXIsIHVzZWQgYnkgUEFMIFNlcnZpY2VzLCBiYXNlIGFkZHJlc3MuCisgKiBOb3RlOiB2
bWJ1ZmZlciBpcyBpbiB0aGUgVk1NLUJMT0NLLCB0aGUgc2l6ZSBtdXN0IGJlIDwgOE0KKyAqLwor
I2RlZmluZSBLVk1fVk1fQlVGRkVSX0JBU0UgKEtWTV9WTU1fQkFTRSArIFZNTV9TSVpFKQorI2Rl
ZmluZSBLVk1fVk1fQlVGRkVSX1NJWkUgKDhVTDw8MjApCisKKy8qRGVmaW5lIFZpcnR1YWwgbWFj
aGluZSBkYXRhIGxheW91dC4qLworI2RlZmluZSBLVk1fVk1fREFUQV9TSElGVCAgMjQKKyNkZWZp
bmUgS1ZNX1ZNX0RBVEFfU0laRSAoMVVMIDw8IEtWTV9WTV9EQVRBX1NISUZUKQorI2RlZmluZSBL
Vk1fVk1fREFUQV9CQVNFIChLVk1fVk1NX0JBU0UgKyBLVk1fVk1NX1NJWkUpCisKKworI2RlZmlu
ZSBLVk1fUDJNX0JBU0UgICAgS1ZNX1ZNX0RBVEFfQkFTRQorI2RlZmluZSBLVk1fUDJNX09GUyAg
ICAgMAorI2RlZmluZSBLVk1fUDJNX1NJWkUgICAgKDhVTCA8PCAyMCkKKworI2RlZmluZSBLVk1f
VkhQVF9CQVNFICAgKEtWTV9QMk1fQkFTRSArIEtWTV9QMk1fU0laRSkKKyNkZWZpbmUgS1ZNX1ZI
UFRfT0ZTICAgIEtWTV9QMk1fU0laRQorI2RlZmluZSBLVk1fVkhQVF9CTE9DS19TSVpFICAgKDJV
TCA8PCAyMCkKKyNkZWZpbmUgVkhQVF9TSElGVCAgICAgIDE4CisjZGVmaW5lIFZIUFRfU0laRSAg
ICAgICAoMVVMIDw8IFZIUFRfU0hJRlQpCisjZGVmaW5lIFZIUFRfTlVNX0VOVFJJRVMgKDE8PChW
SFBUX1NISUZULTUpKQorCisjZGVmaW5lIEtWTV9WVExCX0JBU0UgICAoS1ZNX1ZIUFRfQkFTRStL
Vk1fVkhQVF9CTE9DS19TSVpFKQorI2RlZmluZSBLVk1fVlRMQl9PRlMgICAgKEtWTV9WSFBUX09G
UytLVk1fVkhQVF9CTE9DS19TSVpFKQorI2RlZmluZSBLVk1fVlRMQl9CTE9DS19TSVpFICAgKDFV
TDw8MjApCisjZGVmaW5lIFZUTEJfU0hJRlQgICAgICAxNworI2RlZmluZSBWVExCX1NJWkUgICAg
ICAgKDFVTDw8VlRMQl9TSElGVCkKKyNkZWZpbmUgVlRMQl9OVU1fRU5UUklFUyAoMTw8KFZUTEJf
U0hJRlQtNSkpCisKKyNkZWZpbmUgS1ZNX1ZQRF9CQVNFICAgKEtWTV9WVExCX0JBU0UrS1ZNX1ZU
TEJfQkxPQ0tfU0laRSkKKyNkZWZpbmUgS1ZNX1ZQRF9PRlMgICAgKEtWTV9WVExCX09GUytLVk1f
VlRMQl9CTE9DS19TSVpFKQorI2RlZmluZSBLVk1fVlBEX0JMT0NLX1NJWkUgICAoMlVMPDwyMCkK
KyNkZWZpbmUgVlBEX1NISUZUICAgICAgIDE2CisjZGVmaW5lIFZQRF9TSVpFICAgICAgICAoMVVM
PDxWUERfU0hJRlQpCisKKyNkZWZpbmUgS1ZNX1ZDUFVfQkFTRSAgIChLVk1fVlBEX0JBU0UrS1ZN
X1ZQRF9CTE9DS19TSVpFKQorI2RlZmluZSBLVk1fVkNQVV9PRlMgICAgKEtWTV9WUERfT0ZTK0tW
TV9WUERfQkxPQ0tfU0laRSkKKyNkZWZpbmUgS1ZNX1ZDUFVfQkxPQ0tfU0laRSAgICgyVUw8PDIw
KQorI2RlZmluZSBWQ1BVX1NISUZUIDE4CisjZGVmaW5lIFZDUFVfU0laRSAoMVVMPDxWQ1BVX1NI
SUZUKQorI2RlZmluZSBNQVhfVkNQVV9OVU0gS1ZNX1ZDUFVfQkxPQ0tfU0laRS9WQ1BVX1NJWkUK
KworI2RlZmluZSBLVk1fVk1fQkFTRSAgICAgKEtWTV9WQ1BVX0JBU0UrS1ZNX1ZDUFVfQkxPQ0tf
U0laRSkKKyNkZWZpbmUgS1ZNX1ZNX09GUyAgICAgIChLVk1fVkNQVV9PRlMrS1ZNX1ZDUFVfQkxP
Q0tfU0laRSkKKyNkZWZpbmUgS1ZNX1ZNX0JMT0NLX1NJWkUgICAgICgxVUw8PDE5KQorCisjZGVm
aW5lIEtWTV9NRU1fRElSVFlfTE9HX0JBU0UgKEtWTV9WTV9CQVNFK0tWTV9WTV9CTE9DS19TSVpF
KQorI2RlZmluZSBLVk1fTUVNX0RJUlRZX0xPR19PRlMgIChLVk1fVk1fT0ZTK0tWTV9WTV9CTE9D
S19TSVpFKQorI2RlZmluZSBLVk1fTUVNX0RJUlRZX0xPR19TSVpFICgxVUw8PDE5KQorCisvKiBH
ZXQgdnBkLCB2aHB0LCB0bGIsIHZjcHUsIGJhc2UqLworI2RlZmluZSBWUERfQUREUihuKSAoS1ZN
X1ZQRF9CQVNFK24qVlBEX1NJWkUpCisjZGVmaW5lIFZIUFRfQUREUihuKSAoS1ZNX1ZIUFRfQkFT
RStuKlZIUFRfU0laRSkKKyNkZWZpbmUgVlRMQl9BRERSKG4pIChLVk1fVlRMQl9CQVNFK24qVlRM
Ql9TSVpFKQorI2RlZmluZSBWQ1BVX0FERFIobikgKEtWTV9WQ1BVX0JBU0UrbipWQ1BVX1NJWkUp
CisKKy8qSU8gc2VjdGlvbiBkZWZpbml0aW9ucyovCisjZGVmaW5lIElPUkVRX1JFQUQgICAgICAx
CisjZGVmaW5lIElPUkVRX1dSSVRFICAgICAwCisKKyNkZWZpbmUgU1RBVEVfSU9SRVFfTk9ORSAg
ICAgICAgMAorI2RlZmluZSBTVEFURV9JT1JFUV9SRUFEWSAgICAgICAxCisjZGVmaW5lIFNUQVRF
X0lPUkVRX0lOUFJPQ0VTUyAgIDIKKyNkZWZpbmUgU1RBVEVfSU9SRVNQX1JFQURZICAgICAgMwor
CisvKkd1ZXN0IFBoeXNpY2FsIGFkZHJlc3MgbGF5b3V0LiovCisjZGVmaW5lIEdQRk5fTUVNICAg
ICAgICAoMFVMIDw8IDYwKSAvKiBHdWVzdCBwZm4gaXMgbm9ybWFsIG1lbSAqLworI2RlZmluZSBH
UEZOX0ZSQU1FX0JVRkZFUiAgICgxVUwgPDwgNjApIC8qIFZHQSBmcmFtZWJ1ZmZlciAqLworI2Rl
ZmluZSBHUEZOX0xPV19NTUlPICAgICAgICgyVUwgPDwgNjApIC8qIExvdyBNTUlPIHJhbmdlICov
CisjZGVmaW5lIEdQRk5fUElCICAgICAgICAoM1VMIDw8IDYwKSAvKiBQSUIgYmFzZSAqLworI2Rl
ZmluZSBHUEZOX0lPU0FQSUMgICAgICAgICg0VUwgPDwgNjApIC8qIElPU0FQSUMgYmFzZSAqLwor
I2RlZmluZSBHUEZOX0xFR0FDWV9JTyAgICAgICg1VUwgPDwgNjApIC8qIExlZ2FjeSBJL08gYmFz
ZSAqLworI2RlZmluZSBHUEZOX0dGVyAgICAgICAgKDZVTCA8PCA2MCkgLyogR3Vlc3QgRmlybXdh
cmUgKi8KKyNkZWZpbmUgR1BGTl9ISUdIX01NSU8gICAgICAoN1VMIDw8IDYwKSAvKiBIaWdoIE1N
SU8gcmFuZ2UgKi8KKworI2RlZmluZSBHUEZOX0lPX01BU0sgICAgICAgICg3VUwgPDwgNjApIC8q
IEd1ZXN0IHBmbiBpcyBJL08gdHlwZSAqLworI2RlZmluZSBHUEZOX0lOVl9NQVNLICAgICAgICgx
VUwgPDwgNjMpIC8qIEd1ZXN0IHBmbiBpcyBpbnZhbGlkICovCisjZGVmaW5lIElOVkFMSURfTUZO
ICAgICAgICh+MFVMKQorI2RlZmluZSBNRU1fRyAgICgxVUwgPDwgMzApCisjZGVmaW5lIE1FTV9N
ICAgKDFVTCA8PCAyMCkKKyNkZWZpbmUgTU1JT19TVEFSVCAgICAgICAoMyAqIE1FTV9HKQorI2Rl
ZmluZSBNTUlPX1NJWkUgICAgICAgICg1MTIgKiBNRU1fTSkKKyNkZWZpbmUgVkdBX0lPX1NUQVJU
ICAgICAweEEwMDAwVUwKKyNkZWZpbmUgVkdBX0lPX1NJWkUgICAgICAweDIwMDAwCisjZGVmaW5l
IExFR0FDWV9JT19TVEFSVCAgKE1NSU9fU1RBUlQgKyBNTUlPX1NJWkUpCisjZGVmaW5lIExFR0FD
WV9JT19TSVpFICAgKDY0Kk1FTV9NKQorI2RlZmluZSBJT19TQVBJQ19TVEFSVCAgIDB4ZmVjMDAw
MDBVTAorI2RlZmluZSBJT19TQVBJQ19TSVpFICAgIDB4MTAwMDAwCisjZGVmaW5lIFBJQl9TVEFS
VCAweGZlZTAwMDAwVUwKKyNkZWZpbmUgUElCX1NJWkUgMHgyMDAwMDAKKyNkZWZpbmUgR0ZXX1NU
QVJUICAgICAgICAoNCpNRU1fRy0xNipNRU1fTSkKKyNkZWZpbmUgR0ZXX1NJWkUgICAgICAgICAo
MTYqTUVNX00pCisKKy8qRGVsaXZlciBtb2RlLCBkZWZpbmVkIGZvciBpb2FwaWMuYyovCisjZGVm
aW5lIGRlc3RfRml4ZWQgSU9TQVBJQ19GSVhFRAorI2RlZmluZSBkZXN0X0xvd2VzdFByaW8gSU9T
QVBJQ19MT1dFU1RfUFJJT1JJVFkKKworI2RlZmluZSBOTUlfVkVDVE9SICAgICAgCQkyCisjZGVm
aW5lIEV4dElOVF9WRUNUT1IgICAgICAgCQkwCisjZGVmaW5lIE5VTExfVkVDVE9SICAgICAJCS0x
CisjZGVmaW5lIElBNjRfU1BVUklPVVNfSU5UX1ZFQ1RPUiAgICAJMHgwZgorCisjZGVmaW5lIFZD
UFVfTElEKHYpICgoKHU2NCkodiktPnZjcHVfaWQpPDwyNCkKKworLyoKKyAqRGVsaXZlcnkgbW9k
ZQorICovCisjZGVmaW5lIFNBUElDX0RFTElWX1NISUZUICAgICAgOAorI2RlZmluZSBTQVBJQ19G
SVhFRCAgICAgICAgICAgIDB4MAorI2RlZmluZSBTQVBJQ19MT1dFU1RfUFJJT1JJVFkgIDB4MQor
I2RlZmluZSBTQVBJQ19QTUkgICAgICAgICAgICAgIDB4MgorI2RlZmluZSBTQVBJQ19OTUkgICAg
ICAgICAgICAgIDB4NAorI2RlZmluZSBTQVBJQ19JTklUICAgICAgICAgICAgIDB4NQorI2RlZmlu
ZSBTQVBJQ19FWFRJTlQgICAgICAgICAgIDB4NworCisvKgorICogdmNwdS0+cmVxdWVzdHMgYml0
IG1lbWJlcnMgZm9yIGFyY2gKKyAqLworI2RlZmluZSBLVk1fUkVRX1BUQ19HCQkzMgorI2RlZmlu
ZSBLVk1fUkVRX1JFU1VNRQkJMzMKKworI2RlZmluZSBLVk1fUEFHRVNfUEVSX0hQQUdFCTEKKwor
c3RydWN0IGt2bTsKK3N0cnVjdCBrdm1fdmNwdTsKK3N0cnVjdCBrdm1fZ3Vlc3RfZGVidWd7Cit9
OworCitzdHJ1Y3Qga3ZtX21taW9fcmVxIHsKKwl1aW50NjRfdCBhZGRyOyAgICAgICAgICAvKiAg
cGh5c2ljYWwgYWRkcmVzcwkJKi8KKwl1aW50NjRfdCBzaXplOyAgICAgICAgICAvKiAgc2l6ZSBp
biBieXRlcwkJKi8KKwl1aW50NjRfdCBkYXRhOyAgICAgICAgICAvKiAgZGF0YSAob3IgcGFkZHIg
b2YgZGF0YSkgICAgICovCisJdWludDhfdCBzdGF0ZTo0OworCXVpbnQ4X3QgZGlyOjE7ICAgICAg
ICAgIC8qICAxPXJlYWQsIDA9d3JpdGUgICAgICAgICAgICAgKi8KK307Cit0eXBlZGVmIHN0cnVj
dCBrdm1fbW1pb19yZXEgbW1pb19yZXFfdDsKKworLypQYWwgZGF0YSBzdHJ1Y3QgKi8KK3R5cGVk
ZWYgc3RydWN0IHBhbF9jYWxseworCS8qSW4gYXJlYSovCisJdWludDY0X3QgZ3IyODsKKwl1aW50
NjRfdCBncjI5OworCXVpbnQ2NF90IGdyMzA7CisJdWludDY0X3QgZ3IzMTsKKwkvKk91dCBhcmVh
Ki8KKwlzdHJ1Y3QgaWE2NF9wYWxfcmV0dmFsIHJldDsKK30gcGFsX2NhbGxfdDsKKworLyogU2Fs
IGRhdGEgc3RydWN0dXJlICovCit0eXBlZGVmIHN0cnVjdCBzYWxfY2FsbHsKKwkvKkluIGFyZWEq
LworCXVpbnQ2NF90IGluMDsKKwl1aW50NjRfdCBpbjE7CisJdWludDY0X3QgaW4yOworCXVpbnQ2
NF90IGluMzsKKwl1aW50NjRfdCBpbjQ7CisJdWludDY0X3QgaW41OworCXVpbnQ2NF90IGluNjsK
Kwl1aW50NjRfdCBpbjc7CisJLypPdXIgYXJlYSovCisJc3RydWN0IHNhbF9yZXRfdmFsdWVzIHJl
dDsKK30gc2FsX2NhbGxfdDsKKworLypHdWVzdCBjaGFuZ2UgcnI2Ki8KK3R5cGVkZWYgc3RydWN0
IHN3aXRjaF9ycjYgeworCXVpbnQ2NF90IG9sZF9ycjsKKwl1aW50NjRfdCBuZXdfcnI7Cit9IHN3
aXRjaF9ycjZfdDsKKwordHlwZWRlZiB1bmlvbnsKKwl1bnNpZ25lZCBsb25nIHZhbDsKKwlzdHJ1
Y3QgeworCQl1bnNpZ25lZCBsb25nIHJ2ICA6IDM7CisJCXVuc2lnbmVkIGxvbmcgaXIgIDogMTsK
KwkJdW5zaWduZWQgbG9uZyBlaWQgOiA4OworCQl1bnNpZ25lZCBsb25nIGlkICA6IDg7CisJCXVu
c2lnbmVkIGxvbmcgaWJfYmFzZSA6IDQ0OworCX07Cit9IGlhNjRfaXBpX2E7CisKK3R5cGVkZWYg
dW5pb257CisJdW5zaWduZWQgbG9uZyB2YWw7CisJc3RydWN0IHsKKwkJdW5zaWduZWQgbG9uZyB2
ZWN0b3IgOiA4OworCQl1bnNpZ25lZCBsb25nIGRtICA6IDM7CisJCXVuc2lnbmVkIGxvbmcgaWcg
IDogNTM7CisJfTsKK30gaWE2NF9pcGlfZDsKKworLyppcGkgY2hlY2sgZXhpdCBkYXRhKi8KK3R5
cGVkZWYgc3RydWN0IGlwaV9kYXRheworCWlhNjRfaXBpX2EgYWRkcjsKKwlpYTY0X2lwaV9kIGRh
dGE7Cit9IGlwaV9kYXRhX3Q7CisKKy8qZ2xvYmFsIHB1cmdlIGRhdGEqLwordHlwZWRlZiBzdHJ1
Y3Qga3ZtX3B0Y19nIHsKKwl1bnNpZ25lZCBsb25nIHZhZGRyOworCXVuc2lnbmVkIGxvbmcgcnI7
CisJdW5zaWduZWQgbG9uZyBwczsKKwlzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHU7Cit9IHB0Y19nX3Q7
CisKKy8qRXhpdCBjb250cm9sIGRhdGEgKi8KK3N0cnVjdCBleGl0X2N0bF9kYXRheworCXVpbnQz
Ml90IGV4aXRfcmVhc29uOworCXVpbnQzMl90IHZtX3N0YXR1czsKKwl1bmlvbiB7CisJCW1taW9f
cmVxX3QJCWlvcmVxOworCQlwYWxfY2FsbF90CXBhbF9kYXRhOworCQlzYWxfY2FsbF90CXNhbF9k
YXRhOworCQlzd2l0Y2hfcnI2X3QJcnJfZGF0YTsKKwkJaXBpX2RhdGFfdAlpcGlfZGF0YTsKKwkJ
cHRjX2dfdAkJcHRjX2dfZGF0YTsKKwl9IHU7Cit9OworCit1bmlvbiBwdGVfZmxhZ3MgeworCXN0
cnVjdCB7CisJCXVuc2lnbmVkIGxvbmcgcCAgICA6ICAxOyAvKjAgICAgICAqLworCQl1bnNpZ25l
ZCBsb25nICAgICAgOiAgMTsgLyogMSAgICAgKi8KKwkJdW5zaWduZWQgbG9uZyBtYSAgIDogIDM7
IC8qIDItNCAgICovCisJCXVuc2lnbmVkIGxvbmcgYSAgICA6ICAxOyAvKiA1ICAgICAqLworCQl1
bnNpZ25lZCBsb25nIGQgICAgOiAgMTsgLyogNiAgICAgKi8KKwkJdW5zaWduZWQgbG9uZyBwbCAg
IDogIDI7IC8qIDctOCAgICovCisJCXVuc2lnbmVkIGxvbmcgYXIgICA6ICAzOyAvKiA5LTExICAq
LworCQl1bnNpZ25lZCBsb25nIHBwbiAgOiAzODsgLyogMTItNDkgKi8KKwkJdW5zaWduZWQgbG9u
ZyAgICAgIDogIDI7IC8qIDUwLTUxICovCisJCXVuc2lnbmVkIGxvbmcgZWQgICA6ICAxOyAvKiA1
MiAgICAqLworCX07CisJdW5zaWduZWQgbG9uZyB2YWw7Cit9OworCit0eXBlZGVmIHVuaW9uIHsK
Kwl1bnNpZ25lZCBsb25nIHZhbDsKKwlzdHJ1Y3QgeworCQl1bnNpZ25lZCBsb25nIHZlIDogMTsK
KwkJdW5zaWduZWQgbG9uZyByZXNlcnZlZDAgOiAxOworCQl1bnNpZ25lZCBsb25nIHNpemUgOiA2
OworCQl1bnNpZ25lZCBsb25nIHZmIDogMTsKKwkJdW5zaWduZWQgbG9uZyByZXNlcnZlZDEgOiA2
OworCQl1bnNpZ25lZCBsb25nIGJhc2UgOiA0OTsKKwl9OworfSBpYTY0X3B0YTsKKwordHlwZWRl
ZiBzdHJ1Y3QgdGhhc2hfY2IgeworCS8qIFRIQVNIIGJhc2UgaW5mb3JtYXRpb24gKi8KKwl0aGFz
aF9kYXRhX3QgICpoYXNoOyAvKiBoYXNoIHRhYmxlIHBvaW50ZXIsIGFsaWduZWQgYXQgdGhhc2hf
c3ouKi8KKwlpYTY0X3B0YSAgICAgIHB0YTsKKwlpbnQgICAgICAgICAgIG51bTsKK30gdGhhc2hf
Y2JfdDsKKworc3RydWN0IGt2bV92Y3B1X3N0YXQgeworfTsKK3N0cnVjdCBrdm1fdmNwdV9hcmNo
IHsKKwlpbnQgbGF1bmNoZWQ7CisJaW50IGxhc3RfZXhpdDsKKwlpbnQgbGFzdF9ydW5fY3B1Owor
CWludCB2bW1fdHJfc2xvdDsKKwlpbnQgdm1fdHJfc2xvdDsKKworI2RlZmluZSBWQ1BVX01QX1NU
QVRFX1JVTk5BQkxFICAgICAgICAgIDAKKyNkZWZpbmUgVkNQVV9NUF9TVEFURV9VTklOSVRJQUxJ
WkVEICAgICAxCisjZGVmaW5lIFZDUFVfTVBfU1RBVEVfSU5JVF9SRUNFSVZFRCAgICAgMgorI2Rl
ZmluZSBWQ1BVX01QX1NUQVRFX0hBTFRFRCAgICAgICAgICAgIDMKKwlpbnQgbXBfc3RhdGU7CisK
KyNkZWZpbmUgTUFYX1BUQ19HX05VTQkJCTMKKwlpbnQgcHRjX2dfY291bnQ7CisJc3RydWN0IGt2
bV9wdGNfZyBwdGNfZ19kYXRhW01BWF9QVENfR19OVU1dOworCisJLypoYWx0IHRpbWVyIHRvIHdh
a2UgdXAgc2xlZXB5IHZjcHVzKi8KKwlzdHJ1Y3QgaHJ0aW1lciBobHRfdGltZXI7CisJbG9uZyBo
dF9hY3RpdmU7CisKKwlzdHJ1Y3Qga3ZtX2xhcGljICphcGljOyAgICAvKiBrZXJuZWwgaXJxY2hp
cCBjb250ZXh0ICovCisJc3RydWN0IHZwZCAqdnBkOworCisJLyogRXhpdCBkYXRhIGZvciB2bW1f
dHJhbnNpdGlvbiovCisJc3RydWN0IGV4aXRfY3RsX2RhdGEgZXhpdF9kYXRhOworCisJY3B1bWFz
a190IGNhY2hlX2NvaGVyZW50X21hcDsKKworCXVuc2lnbmVkIGxvbmcgdm1tX3JyOworCXVuc2ln
bmVkIGxvbmcgaG9zdF9ycjY7CisJdW5zaWduZWQgbG9uZyBwc2JpdHNbOF07CisJdW5zaWduZWQg
bG9uZyBjcl9paXBhOworCXVuc2lnbmVkIGxvbmcgY3JfaXNyOworCXVuc2lnbmVkIGxvbmcgdnNh
X2Jhc2U7CisJdW5zaWduZWQgbG9uZyBkaXJ0eV9sb2dfbG9ja19wYTsKKwl1bnNpZ25lZCBsb25n
IF9fZ3A7CisJLyogVFIgYW5kIFRDLiAgKi8KKwl0aGFzaF9kYXRhX3QgaXRyc1tOSVRSU107CisJ
dGhhc2hfZGF0YV90IGR0cnNbTkRUUlNdOworCS8qIEJpdCBpcyBzZXQgaWYgdGhlcmUgaXMgYSB0
ci90YyBmb3IgdGhlIHJlZ2lvbi4gICovCisJdW5zaWduZWQgY2hhciBpdHJfcmVnaW9uczsKKwl1
bnNpZ25lZCBjaGFyIGR0cl9yZWdpb25zOworCXVuc2lnbmVkIGNoYXIgdGNfcmVnaW9uczsKKwkv
KiBwdXJnZSBhbGwgKi8KKwl1bnNpZ25lZCBsb25nIHB0Y2VfYmFzZTsKKwl1bnNpZ25lZCBsb25n
IHB0Y2VfY291bnRbMl07CisJdW5zaWduZWQgbG9uZyBwdGNlX3N0cmlkZVsyXTsKKwkvKiBpdGMv
aXRtICovCisJdW5zaWduZWQgbG9uZyBsYXN0X2l0YzsKKwlsb25nIGl0Y19vZmZzZXQ7CisJdW5z
aWduZWQgbG9uZyBpdGNfY2hlY2s7CisJdW5zaWduZWQgbG9uZyB0aW1lcl9jaGVjazsKKwl1bnNp
Z25lZCBsb25nIHRpbWVyX3BlbmRpbmc7CisKKwl1bnNpZ25lZCBsb25nIHZycls4XTsKKwl1bnNp
Z25lZCBsb25nIGlicls4XTsKKwl1bnNpZ25lZCBsb25nIGRicls4XTsKKwl1bnNpZ25lZCBsb25n
IGluc3ZjWzRdOwkJLyogSW50ZXJydXB0IGluIHNlcnZpY2UuICAqLworCXVuc2lnbmVkIGxvbmcg
eHRwOworCisJdW5zaWduZWQgbG9uZyBtZXRhcGh5c2ljYWxfcnIwOyAvKiBmcm9tIGt2bV9hcmNo
IChzbyBpcyBwaW5uZWQpICovCisJdW5zaWduZWQgbG9uZyBtZXRhcGh5c2ljYWxfcnI0OwkvKiBm
cm9tIGt2bV9hcmNoIChzbyBpcyBwaW5uZWQpICovCisJdW5zaWduZWQgbG9uZyBtZXRhcGh5c2lj
YWxfc2F2ZWRfcnIwOyAvKiBmcm9tIGt2bV9hcmNoICAgICAgICAgICovCisJdW5zaWduZWQgbG9u
ZyBtZXRhcGh5c2ljYWxfc2F2ZWRfcnI0OyAvKiBmcm9tIGt2bV9hcmNoICAgICAgICAgICovCisJ
dW5zaWduZWQgbG9uZyBmcF9wc3I7ICAgICAgIC8qdXNlZCBmb3IgbGF6eSBmbG9hdCByZWdpc3Rl
ciAqLworCXVuc2lnbmVkIGxvbmcgc2F2ZWRfZ3A7CisJLypmb3IgcGh5Y2lhbCAgZW11bGF0aW9u
ICovCisJaW50IG1vZGVfZmxhZ3M7CisJdGhhc2hfY2JfdCB2dGxiOworCXRoYXNoX2NiX3Qgdmhw
dDsKKwljaGFyIGlycV9jaGVjazsKKwljaGFyIGlycV9uZXdfcGVuZGluZzsKKworCXVuc2lnbmVk
IGxvbmcgb3Bjb2RlOworCXVuc2lnbmVkIGxvbmcgY2F1c2U7CisJY29udGV4dF90IGhvc3Q7CisJ
Y29udGV4dF90IGd1ZXN0OworCit9OworCitzdHJ1Y3Qga3ZtX3ZtX3N0YXQgeworCXU2NCByZW1v
dGVfdGxiX2ZsdXNoOworfTsKKworc3RydWN0IGt2bV9zYWxfZGF0YSB7CisJdW5zaWduZWQgbG9u
ZyBib290X2lwOworCXVuc2lnbmVkIGxvbmcgYm9vdF9ncDsKK307CisKK3N0cnVjdCBrdm1fYXJj
aCB7CisJdW5zaWduZWQgbG9uZwl2bV9iYXNlOworCXVuc2lnbmVkIGxvbmcJbWV0YXBoeXNpY2Fs
X3JyMDsKKwl1bnNpZ25lZCBsb25nCW1ldGFwaHlzaWNhbF9ycjQ7CisJdW5zaWduZWQgbG9uZwl2
bW1faW5pdF9ycjsKKwl1bnNpZ25lZCBsb25nCXZocHRfYmFzZTsKKwl1bnNpZ25lZCBsb25nCXZ0
bGJfYmFzZTsKKwl1bnNpZ25lZCBsb25nIAl2cGRfYmFzZTsKKwlzcGlubG9ja190IGRpcnR5X2xv
Z19sb2NrOworCXN0cnVjdCBrdm1faW9hcGljICp2aW9hcGljOworCXN0cnVjdCBrdm1fdm1fc3Rh
dCBzdGF0OworCXN0cnVjdCBrdm1fc2FsX2RhdGEgcmR2X3NhbF9kYXRhOworfTsKKwordHlwZWRl
ZiB1bmlvbiB7CisJdTY0IHZhbHVlOworCXN0cnVjdCB7CisJCXU2NCBudW1iZXIgOiA4OworCQl1
NjQgcmV2aXNpb24gOiA4OworCQl1NjQgbW9kZWwgOiA4OworCQl1NjQgZmFtaWx5IDogODsKKwkJ
dTY0IGFyY2hyZXYgOiA4OworCQl1NjQgcnYgOiAyNDsKKwl9OworfSBjcHVpZDNfdDsKKworc3Ry
dWN0IGt2bV9wdF9yZWdzIHsKKyAgICAvKiBUaGUgZm9sbG93aW5nIHJlZ2lzdGVycyBhcmUgc2F2
ZWQgYnkgU0FWRV9NSU46ICovCisgICAgdW5zaWduZWQgbG9uZyBiNjsgIC8qIHNjcmF0Y2ggKi8K
KyAgICB1bnNpZ25lZCBsb25nIGI3OyAgLyogc2NyYXRjaCAqLworCisgICAgdW5zaWduZWQgbG9u
ZyBhcl9jc2Q7IC8qIHVzZWQgYnkgY21wOHhjaGcxNiAoc2NyYXRjaCkgKi8KKyAgICB1bnNpZ25l
ZCBsb25nIGFyX3NzZDsgLyogcmVzZXJ2ZWQgZm9yIGZ1dHVyZSB1c2UgKHNjcmF0Y2gpICovCisK
KyAgICB1bnNpZ25lZCBsb25nIHI4OyAgLyogc2NyYXRjaCAocmV0dXJuIHZhbHVlIHJlZ2lzdGVy
IDApICovCisgICAgdW5zaWduZWQgbG9uZyByOTsgIC8qIHNjcmF0Y2ggKHJldHVybiB2YWx1ZSBy
ZWdpc3RlciAxKSAqLworICAgIHVuc2lnbmVkIGxvbmcgcjEwOyAvKiBzY3JhdGNoIChyZXR1cm4g
dmFsdWUgcmVnaXN0ZXIgMikgKi8KKyAgICB1bnNpZ25lZCBsb25nIHIxMTsgLyogc2NyYXRjaCAo
cmV0dXJuIHZhbHVlIHJlZ2lzdGVyIDMpICovCisKKyAgICB1bnNpZ25lZCBsb25nIGNyX2lwc3I7
IC8qIGludGVycnVwdGVkIHRhc2sncyBwc3IgKi8KKyAgICB1bnNpZ25lZCBsb25nIGNyX2lpcDsg
IC8qIGludGVycnVwdGVkIHRhc2sncyBpbnN0cnVjdGlvbiBwb2ludGVyICovCisgICAgdW5zaWdu
ZWQgbG9uZyBjcl9pZnM7ICAvKiBpbnRlcnJ1cHRlZCB0YXNrJ3MgZnVuY3Rpb24gc3RhdGUgKi8K
KworICAgIHVuc2lnbmVkIGxvbmcgYXJfdW5hdDsgLyogaW50ZXJydXB0ZWQgdGFzaydzIE5hVCBy
ZWdpc3RlciAocHJlc2VydmVkKSAqLworICAgIHVuc2lnbmVkIGxvbmcgYXJfcGZzOyAgLyogcHJl
diBmdW5jdGlvbiBzdGF0ZSAgKi8KKyAgICB1bnNpZ25lZCBsb25nIGFyX3JzYzsgIC8qIFJTRSBj
b25maWd1cmF0aW9uICovCisgICAgLyogVGhlIGZvbGxvd2luZyB0d28gYXJlIHZhbGlkIG9ubHkg
aWYgY3JfaXBzci5jcGwgPiAwOiAqLworICAgIHVuc2lnbmVkIGxvbmcgYXJfcm5hdDsgIC8qIFJT
RSBOYVQgKi8KKyAgICB1bnNpZ25lZCBsb25nIGFyX2JzcHN0b3JlOyAvKiBSU0UgYnNwc3RvcmUg
Ki8KKworICAgIHVuc2lnbmVkIGxvbmcgcHI7ICAvKiA2NCBwcmVkaWNhdGUgcmVnaXN0ZXJzICgx
IGJpdCBlYWNoKSAqLworICAgIHVuc2lnbmVkIGxvbmcgYjA7ICAvKiByZXR1cm4gcG9pbnRlciAo
YnApICovCisgICAgdW5zaWduZWQgbG9uZyBsb2FkcnM7ICAvKiBzaXplIG9mIGRpcnR5IHBhcnRp
dGlvbiA8PCAxNiAqLworCisgICAgdW5zaWduZWQgbG9uZyByMTsgIC8qIHRoZSBncCBwb2ludGVy
ICovCisgICAgdW5zaWduZWQgbG9uZyByMTI7IC8qIGludGVycnVwdGVkIHRhc2sncyBtZW1vcnkg
c3RhY2sgcG9pbnRlciAqLworICAgIHVuc2lnbmVkIGxvbmcgcjEzOyAvKiB0aHJlYWQgcG9pbnRl
ciAqLworCisgICAgdW5zaWduZWQgbG9uZyBhcl9mcHNyOyAgLyogZmxvYXRpbmcgcG9pbnQgc3Rh
dHVzIChwcmVzZXJ2ZWQpICovCisgICAgdW5zaWduZWQgbG9uZyByMTU7ICAvKiBzY3JhdGNoICov
CisKKyAvKiBUaGUgcmVtYWluaW5nIHJlZ2lzdGVycyBhcmUgTk9UIHNhdmVkIGZvciBzeXN0ZW0g
Y2FsbHMuICAqLworCisgICAgdW5zaWduZWQgbG9uZyByMTQ7ICAvKiBzY3JhdGNoICovCisgICAg
dW5zaWduZWQgbG9uZyByMjsgIC8qIHNjcmF0Y2ggKi8KKyAgICB1bnNpZ25lZCBsb25nIHIzOyAg
Lyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxvbmcgcjE2OyAgLyogc2NyYXRjaCAqLworICAg
IHVuc2lnbmVkIGxvbmcgcjE3OyAgLyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxvbmcgcjE4
OyAgLyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxvbmcgcjE5OyAgLyogc2NyYXRjaCAqLwor
ICAgIHVuc2lnbmVkIGxvbmcgcjIwOyAgLyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxvbmcg
cjIxOyAgLyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxvbmcgcjIyOyAgLyogc2NyYXRjaCAq
LworICAgIHVuc2lnbmVkIGxvbmcgcjIzOyAgLyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxv
bmcgcjI0OyAgLyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxvbmcgcjI1OyAgLyogc2NyYXRj
aCAqLworICAgIHVuc2lnbmVkIGxvbmcgcjI2OyAgLyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVk
IGxvbmcgcjI3OyAgLyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxvbmcgcjI4OyAgLyogc2Ny
YXRjaCAqLworICAgIHVuc2lnbmVkIGxvbmcgcjI5OyAgLyogc2NyYXRjaCAqLworICAgIHVuc2ln
bmVkIGxvbmcgcjMwOyAgLyogc2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxvbmcgcjMxOyAgLyog
c2NyYXRjaCAqLworICAgIHVuc2lnbmVkIGxvbmcgYXJfY2N2OyAgLyogY29tcGFyZS9leGNoYW5n
ZSB2YWx1ZSAoc2NyYXRjaCkgKi8KKworCisgICAgLyoKKyAgICAgKiBGbG9hdGluZyBwb2ludCBy
ZWdpc3RlcnMgdGhhdCB0aGUga2VybmVsIGNvbnNpZGVycyBzY3JhdGNoOgorICAgICAqLworICAg
IHN0cnVjdCBpYTY0X2ZwcmVnIGY2OyAgLyogc2NyYXRjaCAqLworICAgIHN0cnVjdCBpYTY0X2Zw
cmVnIGY3OyAgLyogc2NyYXRjaCAqLworICAgIHN0cnVjdCBpYTY0X2ZwcmVnIGY4OyAgLyogc2Ny
YXRjaCAqLworICAgIHN0cnVjdCBpYTY0X2ZwcmVnIGY5OyAgLyogc2NyYXRjaCAqLworICAgIHN0
cnVjdCBpYTY0X2ZwcmVnIGYxMDsgIC8qIHNjcmF0Y2ggKi8KKyAgICBzdHJ1Y3QgaWE2NF9mcHJl
ZyBmMTE7ICAvKiBzY3JhdGNoICovCisKKyAgICB1bnNpZ25lZCBsb25nIHI0OyAgLyogcHJlc2Vy
dmVkICovCisgICAgdW5zaWduZWQgbG9uZyByNTsgIC8qIHByZXNlcnZlZCAqLworICAgIHVuc2ln
bmVkIGxvbmcgcjY7ICAvKiBwcmVzZXJ2ZWQgKi8KKyAgICB1bnNpZ25lZCBsb25nIHI3OyAgLyog
cHJlc2VydmVkICovCisgICAgdW5zaWduZWQgbG9uZyBlbWxfdW5hdDsgICAgLyogdXNlZCBmb3Ig
ZW11bGF0aW5nIGluc3RydWN0aW9uICovCisgICAgdW5zaWduZWQgbG9uZyBwYWQwOyAgICAgLyog
YWxpZ25tZW50IHBhZCAqLworCit9OworCitzdGF0aWMgaW5saW5lIHN0cnVjdCBrdm1fcHRfcmVn
cyAqdmNwdV9yZWdzKHN0cnVjdCBrdm1fdmNwdSAqdikKK3sKKwlyZXR1cm4gKHN0cnVjdCBrdm1f
cHRfcmVncyAqKSAoKHVuc2lnbmVkIGxvbmcpIHYgKyBJQTY0X1NUS19PRkZTRVQpIC0gMTsKK30K
KwordHlwZWRlZiBpbnQga3ZtX3ZtbV9lbnRyeSh2b2lkKTsKK3R5cGVkZWYgdm9pZCBrdm1fdHJh
bXBfZW50cnkoY29udGV4dF90ICpob3N0LCBjb250ZXh0X3QgKmd1ZXN0KTsKKworc3RydWN0IGt2
bV92bW1faW5mb3sKKwlzdHJ1Y3QgbW9kdWxlCSptb2R1bGU7CisJa3ZtX3ZtbV9lbnRyeSAJKnZt
bV9lbnRyeTsKKwlrdm1fdHJhbXBfZW50cnkgKnRyYW1wX2VudHJ5OworCXVuc2lnbmVkIGxvbmcg
CXZtbV9pdnQ7Cit9OworCitpbnQga3ZtX2hpZ2hlc3RfcGVuZGluZ19pcnEoc3RydWN0IGt2bV92
Y3B1ICp2Y3B1KTsKK2ludCBrdm1fZW11bGF0ZV9oYWx0KHN0cnVjdCBrdm1fdmNwdSAqdmNwdSk7
CitpbnQga3ZtX3BhbF9lbXVsKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwgc3RydWN0IGt2bV9ydW4g
Kmt2bV9ydW4pOwordm9pZCBrdm1fc2FsX2VtdWwoc3RydWN0IGt2bV92Y3B1ICp2Y3B1KTsKKwor
I2VuZGlmCmRpZmYgLS1naXQgYS9pbmNsdWRlL2FzbS1pYTY0L2t2bV9wYXJhLmggYi9pbmNsdWRl
L2FzbS1pYTY0L2t2bV9wYXJhLmgKbmV3IGZpbGUgbW9kZSAxMDA2NDQKaW5kZXggMDAwMDAwMC4u
OWY5Nzk2YgotLS0gL2Rldi9udWxsCisrKyBiL2luY2x1ZGUvYXNtLWlhNjQva3ZtX3BhcmEuaApA
QCAtMCwwICsxLDI5IEBACisjaWZuZGVmIF9fSUE2NF9LVk1fUEFSQV9ICisjZGVmaW5lIF9fSUE2
NF9LVk1fUEFSQV9ICisKKy8qCisgKiBhc20taWE2NC9rdm1fcGFyYS5oCisgKgorICogQ29weXJp
Z2h0IChDKSAyMDA3IFhpYW50YW8gWmhhbmcgPHhpYW50YW8uemhhbmdAaW50ZWwuY29tPgorICoK
KyAqIFRoaXMgcHJvZ3JhbSBpcyBmcmVlIHNvZnR3YXJlOyB5b3UgY2FuIHJlZGlzdHJpYnV0ZSBp
dCBhbmQvb3IgbW9kaWZ5IGl0CisgKiB1bmRlciB0aGUgdGVybXMgYW5kIGNvbmRpdGlvbnMgb2Yg
dGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlLAorICogdmVyc2lvbiAyLCBhcyBwdWJsaXNo
ZWQgYnkgdGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlvbi4KKyAqCisgKiBUaGlzIHByb2dyYW0g
aXMgZGlzdHJpYnV0ZWQgaW4gdGhlIGhvcGUgaXQgd2lsbCBiZSB1c2VmdWwsIGJ1dCBXSVRIT1VU
CisgKiBBTlkgV0FSUkFOVFk7IHdpdGhvdXQgZXZlbiB0aGUgaW1wbGllZCB3YXJyYW50eSBvZiBN
RVJDSEFOVEFCSUxJVFkgb3IKKyAqIEZJVE5FU1MgRk9SIEEgUEFSVElDVUxBUiBQVVJQT1NFLiAg
U2VlIHRoZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSBmb3IKKyAqIG1vcmUgZGV0YWlscy4K
KyAqCisgKiBZb3Ugc2hvdWxkIGhhdmUgcmVjZWl2ZWQgYSBjb3B5IG9mIHRoZSBHTlUgR2VuZXJh
bCBQdWJsaWMgTGljZW5zZSBhbG9uZyB3aXRoCisgKiB0aGlzIHByb2dyYW07IGlmIG5vdCwgd3Jp
dGUgdG8gdGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlvbiwgSW5jLiwgNTkgVGVtcGxlCisgKiBQ
bGFjZSAtIFN1aXRlIDMzMCwgQm9zdG9uLCBNQSAwMjExMS0xMzA3IFVTQS4KKyAqCisgKi8KKwor
c3RhdGljIGlubGluZSB1bnNpZ25lZCBpbnQga3ZtX2FyY2hfcGFyYV9mZWF0dXJlcyh2b2lkKQor
eworCXJldHVybiAwOworfQorCisjZW5kaWYKLS0gCjEuNS4yCgo=

------_=_NextPart_001_01C890BA.5E632DFF--
