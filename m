From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Mon, 31 Mar 2008 08:25:45 +0000
Subject: [03/15][PATCH] kvm/ia64: Add header files for kvm/ia64. V8
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC01048243@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C89308.D0EEC3B7"
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EFD@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EFD@pdsmsx415.ccr.corp.intel.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C89308.D0EEC3B7
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 03259a60f3c8104cd61f523f9ddeccce0e635782 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Fri, 28 Mar 2008 09:48:10 +0800
Subject: [PATCH] KVM: IA64: Add header files for kvm/ia64.

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

------_=_NextPart_001_01C89308.D0EEC3B7
Content-Type: application/octet-stream;
	name="0003-KVM-IA64-Add-header-files-for-kvm-ia64.patch"
Content-Transfer-Encoding: base64
Content-Description: 0003-KVM-IA64-Add-header-files-for-kvm-ia64.patch
Content-Disposition: attachment;
	filename="0003-KVM-IA64-Add-header-files-for-kvm-ia64.patch"

RnJvbSAwMzI1OWE2MGYzYzgxMDRjZDYxZjUyM2Y5ZGRlY2NjZTBlNjM1NzgyIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogRnJpLCAyOCBNYXIgMjAwOCAwOTo0ODoxMCArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IEtWTTogSUE2NDogQWRkIGhlYWRlciBmaWxlcyBmb3Iga3ZtL2lhNjQuCgpUaHJlZSBoZWFkZXIg
ZmlsZXMgYXJlIGFkZGVkOgphc20taWE2NC9rdm0uaAphc20taWE2NC9rdm1faG9zdC5oCmFzbS1p
YTY0L2t2bV9wYXJhLmgKU2lnbmVkLW9mZi1ieTogWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56aGFu
Z0BpbnRlbC5jb20+Ci0tLQogaW5jbHVkZS9hc20taWE2NC9rdm0uaCAgICAgIHwgIDIwNSArKysr
KysrKysrKysrKysrKwogaW5jbHVkZS9hc20taWE2NC9rdm1faG9zdC5oIHwgIDUzMCArKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrCiBpbmNsdWRlL2FzbS1pYTY0L2t2
bV9wYXJhLmggfCAgIDI5ICsrKwogMyBmaWxlcyBjaGFuZ2VkLCA3NjQgaW5zZXJ0aW9ucygrKSwg
MCBkZWxldGlvbnMoLSkKIGNyZWF0ZSBtb2RlIDEwMDY0NCBpbmNsdWRlL2FzbS1pYTY0L2t2bS5o
CiBjcmVhdGUgbW9kZSAxMDA2NDQgaW5jbHVkZS9hc20taWE2NC9rdm1faG9zdC5oCiBjcmVhdGUg
bW9kZSAxMDA2NDQgaW5jbHVkZS9hc20taWE2NC9rdm1fcGFyYS5oCgpkaWZmIC0tZ2l0IGEvaW5j
bHVkZS9hc20taWE2NC9rdm0uaCBiL2luY2x1ZGUvYXNtLWlhNjQva3ZtLmgKbmV3IGZpbGUgbW9k
ZSAxMDA2NDQKaW5kZXggMDAwMDAwMC4uOGM3MGRkNgotLS0gL2Rldi9udWxsCisrKyBiL2luY2x1
ZGUvYXNtLWlhNjQva3ZtLmgKQEAgLTAsMCArMSwyMDUgQEAKKyNpZm5kZWYgX19BU01fS1ZNX0lB
NjRfSAorI2RlZmluZSBfX0FTTV9LVk1fSUE2NF9ICisKKy8qCisgKiBhc20taWE2NC9rdm0uaDog
a3ZtIHN0cnVjdHVyZSBkZWZpbml0aW9ucyAgZm9yIGlhNjQKKyAqCisgKiBDb3B5cmlnaHQgKEMp
IDIwMDcgWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56aGFuZ0BpbnRlbC5jb20+CisgKgorICogVGhp
cyBwcm9ncmFtIGlzIGZyZWUgc29mdHdhcmU7IHlvdSBjYW4gcmVkaXN0cmlidXRlIGl0IGFuZC9v
ciBtb2RpZnkgaXQKKyAqIHVuZGVyIHRoZSB0ZXJtcyBhbmQgY29uZGl0aW9ucyBvZiB0aGUgR05V
IEdlbmVyYWwgUHVibGljIExpY2Vuc2UsCisgKiB2ZXJzaW9uIDIsIGFzIHB1Ymxpc2hlZCBieSB0
aGUgRnJlZSBTb2Z0d2FyZSBGb3VuZGF0aW9uLgorICoKKyAqIFRoaXMgcHJvZ3JhbSBpcyBkaXN0
cmlidXRlZCBpbiB0aGUgaG9wZSBpdCB3aWxsIGJlIHVzZWZ1bCwgYnV0IFdJVEhPVVQKKyAqIEFO
WSBXQVJSQU5UWTsgd2l0aG91dCBldmVuIHRoZSBpbXBsaWVkIHdhcnJhbnR5IG9mIE1FUkNIQU5U
QUJJTElUWSBvcgorICogRklUTkVTUyBGT1IgQSBQQVJUSUNVTEFSIFBVUlBPU0UuICBTZWUgdGhl
IEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlIGZvcgorICogbW9yZSBkZXRhaWxzLgorICoKKyAq
IFlvdSBzaG91bGQgaGF2ZSByZWNlaXZlZCBhIGNvcHkgb2YgdGhlIEdOVSBHZW5lcmFsIFB1Ymxp
YyBMaWNlbnNlIGFsb25nIHdpdGgKKyAqIHRoaXMgcHJvZ3JhbTsgaWYgbm90LCB3cml0ZSB0byB0
aGUgRnJlZSBTb2Z0d2FyZSBGb3VuZGF0aW9uLCBJbmMuLCA1OSBUZW1wbGUKKyAqIFBsYWNlIC0g
U3VpdGUgMzMwLCBCb3N0b24sIE1BIDAyMTExLTEzMDcgVVNBLgorICoKKyAqLworCisjaW5jbHVk
ZSA8YXNtL3R5cGVzLmg+CisjaW5jbHVkZSA8YXNtL2ZwdS5oPgorCisjaW5jbHVkZSA8bGludXgv
aW9jdGwuaD4KKworLyogQXJjaGl0ZWN0dXJhbCBpbnRlcnJ1cHQgbGluZSBjb3VudC4gKi8KKyNk
ZWZpbmUgS1ZNX05SX0lOVEVSUlVQVFMgMjU2CisKKyNkZWZpbmUgS1ZNX0lPQVBJQ19OVU1fUElO
UyAgMjQKKworc3RydWN0IGt2bV9pb2FwaWNfc3RhdGUgeworCV9fdTY0IGJhc2VfYWRkcmVzczsK
KwlfX3UzMiBpb3JlZ3NlbDsKKwlfX3UzMiBpZDsKKwlfX3UzMiBpcnI7CisJX191MzIgcGFkOwor
CXVuaW9uIHsKKwkJX191NjQgYml0czsKKwkJc3RydWN0IHsKKwkJCV9fdTggdmVjdG9yOworCQkJ
X191OCBkZWxpdmVyeV9tb2RlOjM7CisJCQlfX3U4IGRlc3RfbW9kZToxOworCQkJX191OCBkZWxp
dmVyeV9zdGF0dXM6MTsKKwkJCV9fdTggcG9sYXJpdHk6MTsKKwkJCV9fdTggcmVtb3RlX2lycjox
OworCQkJX191OCB0cmlnX21vZGU6MTsKKwkJCV9fdTggbWFzazoxOworCQkJX191OCByZXNlcnZl
Ojc7CisJCQlfX3U4IHJlc2VydmVkWzRdOworCQkJX191OCBkZXN0X2lkOworCQl9IGZpZWxkczsK
Kwl9IHJlZGlydGJsW0tWTV9JT0FQSUNfTlVNX1BJTlNdOworfTsKKworI2RlZmluZSBLVk1fSVJR
Q0hJUF9QSUNfTUFTVEVSICAgMAorI2RlZmluZSBLVk1fSVJRQ0hJUF9QSUNfU0xBVkUgICAgMQor
I2RlZmluZSBLVk1fSVJRQ0hJUF9JT0FQSUMgICAgICAgMgorCisjZGVmaW5lIEtWTV9DT05URVhU
X1NJWkUJOCoxMDI0CisKK3R5cGVkZWYgdW5pb24gY29udGV4dCB7CisJLyogOEsgc2l6ZSAqLwor
CWNoYXIJZHVtbXlbS1ZNX0NPTlRFWFRfU0laRV07CisJc3RydWN0IHsKKwkJdW5zaWduZWQgbG9u
ZyAgICAgICBwc3I7CisJCXVuc2lnbmVkIGxvbmcgICAgICAgcHI7CisJCXVuc2lnbmVkIGxvbmcg
ICAgICAgY2FsbGVyX3VuYXQ7CisJCXVuc2lnbmVkIGxvbmcgICAgICAgcGFkOworCQl1bnNpZ25l
ZCBsb25nICAgICAgIGdyWzMyXTsKKwkJdW5zaWduZWQgbG9uZyAgICAgICBhclsxMjhdOworCQl1
bnNpZ25lZCBsb25nICAgICAgIGJyWzhdOworCQl1bnNpZ25lZCBsb25nICAgICAgIGNyWzEyOF07
CisJCXVuc2lnbmVkIGxvbmcgICAgICAgcnJbOF07CisJCXVuc2lnbmVkIGxvbmcgICAgICAgaWJy
WzhdOworCQl1bnNpZ25lZCBsb25nICAgICAgIGRicls4XTsKKwkJdW5zaWduZWQgbG9uZyAgICAg
ICBwa3JbOF07CisJCXN0cnVjdCBpYTY0X2ZwcmVnICAgZnJbMTI4XTsKKwl9OworfSBjb250ZXh0
X3Q7CisKK3R5cGVkZWYgc3RydWN0IHRoYXNoX2RhdGEgeworCXVuaW9uIHsKKwkJc3RydWN0IHsK
KwkJCXVuc2lnbmVkIGxvbmcgcCAgICA6ICAxOyAvKiAwICovCisJCQl1bnNpZ25lZCBsb25nIHJ2
MSAgOiAgMTsgLyogMSAqLworCQkJdW5zaWduZWQgbG9uZyBtYSAgIDogIDM7IC8qIDItNCAqLwor
CQkJdW5zaWduZWQgbG9uZyBhICAgIDogIDE7IC8qIDUgKi8KKwkJCXVuc2lnbmVkIGxvbmcgZCAg
ICA6ICAxOyAvKiA2ICovCisJCQl1bnNpZ25lZCBsb25nIHBsICAgOiAgMjsgLyogNy04ICovCisJ
CQl1bnNpZ25lZCBsb25nIGFyICAgOiAgMzsgLyogOS0xMSAqLworCQkJdW5zaWduZWQgbG9uZyBw
cG4gIDogMzg7IC8qIDEyLTQ5ICovCisJCQl1bnNpZ25lZCBsb25nIHJ2MiAgOiAgMjsgLyogNTAt
NTEgKi8KKwkJCXVuc2lnbmVkIGxvbmcgZWQgICA6ICAxOyAvKiA1MiAqLworCQkJdW5zaWduZWQg
bG9uZyBpZzEgIDogMTE7IC8qIDUzLTYzICovCisJCX07CisJCXN0cnVjdCB7CisJCQl1bnNpZ25l
ZCBsb25nIF9fcnYxIDogNTM7ICAgICAvKiAwLTUyICovCisJCQl1bnNpZ25lZCBsb25nIGNvbnRp
Z3VvdXMgOiAxOyAvKjUzICovCisJCQl1bnNpZ25lZCBsb25nIHRjIDogMTsgICAgICAgICAvKiA1
NCBUUiBvciBUQyAqLworCQkJdW5zaWduZWQgbG9uZyBjbCA6IDE7CisJCQkvKiA1NSBJIHNpZGUg
b3IgRCBzaWRlIGNhY2hlIGxpbmUgKi8KKwkJCXVuc2lnbmVkIGxvbmcgbGVuICA6ICA0OyAgICAg
IC8qIDU2LTU5ICovCisJCQl1bnNpZ25lZCBsb25nIGlvICA6IDE7CS8qIDYwIGVudHJ5IGlzIGZv
ciBpbyBvciBub3QgKi8KKwkJCXVuc2lnbmVkIGxvbmcgbm9tYXAgOiAxOworCQkJLyogNjEgZW50
cnkgY2Fubid0IGJlIGluc2VydGVkIGludG8gbWFjaGluZSBUTEIuKi8KKwkJCXVuc2lnbmVkIGxv
bmcgY2hlY2tlZCA6IDE7CisJCQkvKiA2MiBmb3IgVlRMQi9WSFBUIHNhbml0eSBjaGVjayAqLwor
CQkJdW5zaWduZWQgbG9uZyBpbnZhbGlkIDogMTsKKwkJCS8qIDYzIGludmFsaWQgZW50cnkgKi8K
KwkJfTsKKwkJdW5zaWduZWQgbG9uZyBwYWdlX2ZsYWdzOworCX07ICAgICAgICAgICAgICAgICAg
Lyogc2FtZSBmb3IgVkhQVCBhbmQgVExCICovCisKKwl1bmlvbiB7CisJCXN0cnVjdCB7CisJCQl1
bnNpZ25lZCBsb25nIHJ2MyAgOiAgMjsKKwkJCXVuc2lnbmVkIGxvbmcgcHMgICA6ICA2OworCQkJ
dW5zaWduZWQgbG9uZyBrZXkgIDogMjQ7CisJCQl1bnNpZ25lZCBsb25nIHJ2NCAgOiAzMjsKKwkJ
fTsKKwkJdW5zaWduZWQgbG9uZyBpdGlyOworCX07CisJdW5pb24geworCQlzdHJ1Y3QgeworCQkJ
dW5zaWduZWQgbG9uZyBpZzIgIDogIDEyOworCQkJdW5zaWduZWQgbG9uZyB2cG4gIDogIDQ5Owor
CQkJdW5zaWduZWQgbG9uZyB2cm4gIDogICAzOworCQl9OworCQl1bnNpZ25lZCBsb25nIGlmYTsK
KwkJdW5zaWduZWQgbG9uZyB2YWRyOworCQlzdHJ1Y3QgeworCQkJdW5zaWduZWQgbG9uZyB0YWcg
IDogIDYzOworCQkJdW5zaWduZWQgbG9uZyB0aSAgIDogIDE7CisJCX07CisJCXVuc2lnbmVkIGxv
bmcgZXRhZzsKKwl9OworCXVuaW9uIHsKKwkJc3RydWN0IHRoYXNoX2RhdGEgKm5leHQ7CisJCXVu
c2lnbmVkIGxvbmcgcmlkOworCQl1bnNpZ25lZCBsb25nIGdwYWRkcjsKKwl9OworfSB0aGFzaF9k
YXRhX3Q7CisKKyNkZWZpbmUJTklUUlMJOAorI2RlZmluZSBORFRSUwk4CisKK3N0cnVjdCBzYXZl
ZF92cGQgeworCXVuc2lnbmVkIGxvbmcgIHZocGk7CisJdW5zaWduZWQgbG9uZyAgdmdyWzE2XTsK
Kwl1bnNpZ25lZCBsb25nICB2YmdyWzE2XTsKKwl1bnNpZ25lZCBsb25nICB2bmF0OworCXVuc2ln
bmVkIGxvbmcgIHZibmF0OworCXVuc2lnbmVkIGxvbmcgIHZjcHVpZFs1XTsKKwl1bnNpZ25lZCBs
b25nICB2cHNyOworCXVuc2lnbmVkIGxvbmcgIHZwcjsKKwl1bnNpZ25lZCBsb25nICB2Y3JbMTI4
XTsKK307CisKK3N0cnVjdCBrdm1fcmVncyB7CisJY2hhciAqc2F2ZWRfZ3Vlc3Q7CisJY2hhciAq
c2F2ZWRfc3RhY2s7CisJc3RydWN0IHNhdmVkX3ZwZCB2cGQ7CisJLypBcmNoLXJlZ3MqLworCWlu
dCBtcF9zdGF0ZTsKKwl1bnNpZ25lZCBsb25nIHZtbV9ycjsKKwkvKiBUUiBhbmQgVEMuICAqLwor
CXN0cnVjdCB0aGFzaF9kYXRhIGl0cnNbTklUUlNdOworCXN0cnVjdCB0aGFzaF9kYXRhIGR0cnNb
TkRUUlNdOworCS8qIEJpdCBpcyBzZXQgaWYgdGhlcmUgaXMgYSB0ci90YyBmb3IgdGhlIHJlZ2lv
bi4gICovCisJdW5zaWduZWQgY2hhciBpdHJfcmVnaW9uczsKKwl1bnNpZ25lZCBjaGFyIGR0cl9y
ZWdpb25zOworCXVuc2lnbmVkIGNoYXIgdGNfcmVnaW9uczsKKworCWNoYXIgaXJxX2NoZWNrOwor
CXVuc2lnbmVkIGxvbmcgc2F2ZWRfaXRjOworCXVuc2lnbmVkIGxvbmcgaXRjX2NoZWNrOworCXVu
c2lnbmVkIGxvbmcgdGltZXJfY2hlY2s7CisJdW5zaWduZWQgbG9uZyB0aW1lcl9wZW5kaW5nOwor
CXVuc2lnbmVkIGxvbmcgbGFzdF9pdGM7CisKKwl1bnNpZ25lZCBsb25nIHZycls4XTsKKwl1bnNp
Z25lZCBsb25nIGlicls4XTsKKwl1bnNpZ25lZCBsb25nIGRicls4XTsKKwl1bnNpZ25lZCBsb25n
IGluc3ZjWzRdOwkJLyogSW50ZXJydXB0IGluIHNlcnZpY2UuICAqLworCXVuc2lnbmVkIGxvbmcg
eHRwOworCisJdW5zaWduZWQgbG9uZyBtZXRhcGh5c2ljYWxfcnIwOyAvKiBmcm9tIGt2bV9hcmNo
IChzbyBpcyBwaW5uZWQpICovCisJdW5zaWduZWQgbG9uZyBtZXRhcGh5c2ljYWxfcnI0OwkvKiBm
cm9tIGt2bV9hcmNoIChzbyBpcyBwaW5uZWQpICovCisJdW5zaWduZWQgbG9uZyBtZXRhcGh5c2lj
YWxfc2F2ZWRfcnIwOyAvKiBmcm9tIGt2bV9hcmNoICAgICAgICAgICovCisJdW5zaWduZWQgbG9u
ZyBtZXRhcGh5c2ljYWxfc2F2ZWRfcnI0OyAvKiBmcm9tIGt2bV9hcmNoICAgICAgICAgICovCisJ
dW5zaWduZWQgbG9uZyBmcF9wc3I7ICAgICAgIC8qdXNlZCBmb3IgbGF6eSBmbG9hdCByZWdpc3Rl
ciAqLworCXVuc2lnbmVkIGxvbmcgc2F2ZWRfZ3A7CisJLypmb3IgcGh5Y2lhbCAgZW11bGF0aW9u
ICovCit9OworCitzdHJ1Y3Qga3ZtX3NyZWdzIHsKK307CisKK3N0cnVjdCBrdm1fZnB1IHsKK307
CisKKyNlbmRpZgpkaWZmIC0tZ2l0IGEvaW5jbHVkZS9hc20taWE2NC9rdm1faG9zdC5oIGIvaW5j
bHVkZS9hc20taWE2NC9rdm1faG9zdC5oCm5ldyBmaWxlIG1vZGUgMTAwNjQ0CmluZGV4IDAwMDAw
MDAuLjUyMmJkZTAKLS0tIC9kZXYvbnVsbAorKysgYi9pbmNsdWRlL2FzbS1pYTY0L2t2bV9ob3N0
LmgKQEAgLTAsMCArMSw1MzAgQEAKKy8qIC0qLSAgTW9kZTpDOyBjLWJhc2ljLW9mZnNldDo0OyB0
YWItd2lkdGg6NDsgaW5kZW50LXRhYnMtbW9kZTpuaWwgLSotICovCisvKgorICogaWE2NC5oOiB1
c2VkIGZvciBrdm0gbW9kdWxlLCBhbmQgaG9sZCBpYTY0LXNwZWNpZmljIHNlY3Rpb25zLgorICoK
KyAqIENvcHlyaWdodCAoQykgMjAwNywgSW50ZWwgQ29ycG9yYXRpb24uCisgKgorICogWGlhbnRh
byBaaGFuZyA8eGlhbnRhby56aGFuZ0BpbnRlbC5jb20+CisgKgorICogVGhpcyBwcm9ncmFtIGlz
IGZyZWUgc29mdHdhcmU7IHlvdSBjYW4gcmVkaXN0cmlidXRlIGl0IGFuZC9vciBtb2RpZnkgaXQK
KyAqIHVuZGVyIHRoZSB0ZXJtcyBhbmQgY29uZGl0aW9ucyBvZiB0aGUgR05VIEdlbmVyYWwgUHVi
bGljIExpY2Vuc2UsCisgKiB2ZXJzaW9uIDIsIGFzIHB1Ymxpc2hlZCBieSB0aGUgRnJlZSBTb2Z0
d2FyZSBGb3VuZGF0aW9uLgorICoKKyAqIFRoaXMgcHJvZ3JhbSBpcyBkaXN0cmlidXRlZCBpbiB0
aGUgaG9wZSBpdCB3aWxsIGJlIHVzZWZ1bCwgYnV0IFdJVEhPVVQKKyAqIEFOWSBXQVJSQU5UWTsg
d2l0aG91dCBldmVuIHRoZSBpbXBsaWVkIHdhcnJhbnR5IG9mIE1FUkNIQU5UQUJJTElUWSBvcgor
ICogRklUTkVTUyBGT1IgQSBQQVJUSUNVTEFSIFBVUlBPU0UuICBTZWUgdGhlIEdOVSBHZW5lcmFs
IFB1YmxpYyBMaWNlbnNlIGZvcgorICogbW9yZSBkZXRhaWxzLgorICoKKyAqIFlvdSBzaG91bGQg
aGF2ZSByZWNlaXZlZCBhIGNvcHkgb2YgdGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlIGFs
b25nIHdpdGgKKyAqIHRoaXMgcHJvZ3JhbTsgaWYgbm90LCB3cml0ZSB0byB0aGUgRnJlZSBTb2Z0
d2FyZSBGb3VuZGF0aW9uLCBJbmMuLCA1OSBUZW1wbGUKKyAqIFBsYWNlIC0gU3VpdGUgMzMwLCBC
b3N0b24sIE1BIDAyMTExLTEzMDcgVVNBLgorICoKKyAqLworCisjaWZuZGVmIF9fQVNNX0tWTV9I
T1NUX0gKKyNkZWZpbmUgX19BU01fS1ZNX0hPU1RfSAorCisKKyNpbmNsdWRlIDxsaW51eC90eXBl
cy5oPgorI2luY2x1ZGUgPGxpbnV4L21tLmg+CisjaW5jbHVkZSA8bGludXgva3ZtLmg+CisjaW5j
bHVkZSA8bGludXgva3ZtX3BhcmEuaD4KKyNpbmNsdWRlIDxsaW51eC9rdm1fdHlwZXMuaD4KKwor
I2luY2x1ZGUgPGFzbS9wYWwuaD4KKyNpbmNsdWRlIDxhc20vc2FsLmg+CisKKyNkZWZpbmUgS1ZN
X01BWF9WQ1BVUyA0CisjZGVmaW5lIEtWTV9NRU1PUllfU0xPVFMgMzIKKy8qIG1lbW9yeSBzbG90
cyB0aGF0IGRvZXMgbm90IGV4cG9zZWQgdG8gdXNlcnNwYWNlICovCisjZGVmaW5lIEtWTV9QUklW
QVRFX01FTV9TTE9UUyA0CisKKworLyogZGVmaW5lIGV4aXQgcmVhc29ucyBmcm9tIHZtbSB0byBr
dm0qLworI2RlZmluZSBFWElUX1JFQVNPTl9WTV9QQU5JQwkJMAorI2RlZmluZSBFWElUX1JFQVNP
Tl9NTUlPX0lOU1RSVUNUSU9OCTEKKyNkZWZpbmUgRVhJVF9SRUFTT05fUEFMX0NBTEwJCTIKKyNk
ZWZpbmUgRVhJVF9SRUFTT05fU0FMX0NBTEwJCTMKKyNkZWZpbmUgRVhJVF9SRUFTT05fU1dJVENI
X1JSNgkJNAorI2RlZmluZSBFWElUX1JFQVNPTl9WTV9ERVNUUk9ZCQk1CisjZGVmaW5lIEVYSVRf
UkVBU09OX0VYVEVSTkFMX0lOVEVSUlVQVAk2CisjZGVmaW5lIEVYSVRfUkVBU09OX0lQSQkJCTcK
KyNkZWZpbmUgRVhJVF9SRUFTT05fUFRDX0cJCTgKKworLypEZWZpbmUgdm1tIGFkZHJlc3Mgc3Bh
Y2UgYW5kIHZtIGRhdGEgc3BhY2UuKi8KKyNkZWZpbmUgS1ZNX1ZNTV9TSVpFICgxNlVMPDwyMCkK
KyNkZWZpbmUgS1ZNX1ZNTV9TSElGVCAyNAorI2RlZmluZSBLVk1fVk1NX0JBU0UgMHhEMDAwMDAw
MDAwMDAwMDAwVUwKKyNkZWZpbmUgVk1NX1NJWkUgKDhVTDw8MjApCisKKy8qCisgKiBEZWZpbmUg
dm1fYnVmZmVyLCB1c2VkIGJ5IFBBTCBTZXJ2aWNlcywgYmFzZSBhZGRyZXNzLgorICogTm90ZTog
dm1idWZmZXIgaXMgaW4gdGhlIFZNTS1CTE9DSywgdGhlIHNpemUgbXVzdCBiZSA8IDhNCisgKi8K
KyNkZWZpbmUgS1ZNX1ZNX0JVRkZFUl9CQVNFIChLVk1fVk1NX0JBU0UgKyBWTU1fU0laRSkKKyNk
ZWZpbmUgS1ZNX1ZNX0JVRkZFUl9TSVpFICg4VUw8PDIwKQorCisvKkRlZmluZSBWaXJ0dWFsIG1h
Y2hpbmUgZGF0YSBsYXlvdXQuKi8KKyNkZWZpbmUgS1ZNX1ZNX0RBVEFfU0hJRlQgIDI0CisjZGVm
aW5lIEtWTV9WTV9EQVRBX1NJWkUgKDFVTCA8PCBLVk1fVk1fREFUQV9TSElGVCkKKyNkZWZpbmUg
S1ZNX1ZNX0RBVEFfQkFTRSAoS1ZNX1ZNTV9CQVNFICsgS1ZNX1ZNTV9TSVpFKQorCisKKyNkZWZp
bmUgS1ZNX1AyTV9CQVNFICAgIEtWTV9WTV9EQVRBX0JBU0UKKyNkZWZpbmUgS1ZNX1AyTV9PRlMg
ICAgIDAKKyNkZWZpbmUgS1ZNX1AyTV9TSVpFICAgICg4VUwgPDwgMjApCisKKyNkZWZpbmUgS1ZN
X1ZIUFRfQkFTRSAgIChLVk1fUDJNX0JBU0UgKyBLVk1fUDJNX1NJWkUpCisjZGVmaW5lIEtWTV9W
SFBUX09GUyAgICBLVk1fUDJNX1NJWkUKKyNkZWZpbmUgS1ZNX1ZIUFRfQkxPQ0tfU0laRSAgICgy
VUwgPDwgMjApCisjZGVmaW5lIFZIUFRfU0hJRlQgICAgICAxOAorI2RlZmluZSBWSFBUX1NJWkUg
ICAgICAgKDFVTCA8PCBWSFBUX1NISUZUKQorI2RlZmluZSBWSFBUX05VTV9FTlRSSUVTICgxPDwo
VkhQVF9TSElGVC01KSkKKworI2RlZmluZSBLVk1fVlRMQl9CQVNFICAgKEtWTV9WSFBUX0JBU0Ur
S1ZNX1ZIUFRfQkxPQ0tfU0laRSkKKyNkZWZpbmUgS1ZNX1ZUTEJfT0ZTICAgIChLVk1fVkhQVF9P
RlMrS1ZNX1ZIUFRfQkxPQ0tfU0laRSkKKyNkZWZpbmUgS1ZNX1ZUTEJfQkxPQ0tfU0laRSAgICgx
VUw8PDIwKQorI2RlZmluZSBWVExCX1NISUZUICAgICAgMTcKKyNkZWZpbmUgVlRMQl9TSVpFICAg
ICAgICgxVUw8PFZUTEJfU0hJRlQpCisjZGVmaW5lIFZUTEJfTlVNX0VOVFJJRVMgKDE8PChWVExC
X1NISUZULTUpKQorCisjZGVmaW5lIEtWTV9WUERfQkFTRSAgIChLVk1fVlRMQl9CQVNFK0tWTV9W
VExCX0JMT0NLX1NJWkUpCisjZGVmaW5lIEtWTV9WUERfT0ZTICAgIChLVk1fVlRMQl9PRlMrS1ZN
X1ZUTEJfQkxPQ0tfU0laRSkKKyNkZWZpbmUgS1ZNX1ZQRF9CTE9DS19TSVpFICAgKDJVTDw8MjAp
CisjZGVmaW5lIFZQRF9TSElGVCAgICAgICAxNgorI2RlZmluZSBWUERfU0laRSAgICAgICAgKDFV
TDw8VlBEX1NISUZUKQorCisjZGVmaW5lIEtWTV9WQ1BVX0JBU0UgICAoS1ZNX1ZQRF9CQVNFK0tW
TV9WUERfQkxPQ0tfU0laRSkKKyNkZWZpbmUgS1ZNX1ZDUFVfT0ZTICAgIChLVk1fVlBEX09GUytL
Vk1fVlBEX0JMT0NLX1NJWkUpCisjZGVmaW5lIEtWTV9WQ1BVX0JMT0NLX1NJWkUgICAoMlVMPDwy
MCkKKyNkZWZpbmUgVkNQVV9TSElGVCAxOAorI2RlZmluZSBWQ1BVX1NJWkUgKDFVTDw8VkNQVV9T
SElGVCkKKyNkZWZpbmUgTUFYX1ZDUFVfTlVNIEtWTV9WQ1BVX0JMT0NLX1NJWkUvVkNQVV9TSVpF
CisKKyNkZWZpbmUgS1ZNX1ZNX0JBU0UgICAgIChLVk1fVkNQVV9CQVNFK0tWTV9WQ1BVX0JMT0NL
X1NJWkUpCisjZGVmaW5lIEtWTV9WTV9PRlMgICAgICAoS1ZNX1ZDUFVfT0ZTK0tWTV9WQ1BVX0JM
T0NLX1NJWkUpCisjZGVmaW5lIEtWTV9WTV9CTE9DS19TSVpFICAgICAoMVVMPDwxOSkKKworI2Rl
ZmluZSBLVk1fTUVNX0RJUlRZX0xPR19CQVNFIChLVk1fVk1fQkFTRStLVk1fVk1fQkxPQ0tfU0la
RSkKKyNkZWZpbmUgS1ZNX01FTV9ESVJUWV9MT0dfT0ZTICAoS1ZNX1ZNX09GUytLVk1fVk1fQkxP
Q0tfU0laRSkKKyNkZWZpbmUgS1ZNX01FTV9ESVJUWV9MT0dfU0laRSAoMVVMPDwxOSkKKworLyog
R2V0IHZwZCwgdmhwdCwgdGxiLCB2Y3B1LCBiYXNlKi8KKyNkZWZpbmUgVlBEX0FERFIobikgKEtW
TV9WUERfQkFTRStuKlZQRF9TSVpFKQorI2RlZmluZSBWSFBUX0FERFIobikgKEtWTV9WSFBUX0JB
U0UrbipWSFBUX1NJWkUpCisjZGVmaW5lIFZUTEJfQUREUihuKSAoS1ZNX1ZUTEJfQkFTRStuKlZU
TEJfU0laRSkKKyNkZWZpbmUgVkNQVV9BRERSKG4pIChLVk1fVkNQVV9CQVNFK24qVkNQVV9TSVpF
KQorCisvKklPIHNlY3Rpb24gZGVmaW5pdGlvbnMqLworI2RlZmluZSBJT1JFUV9SRUFEICAgICAg
MQorI2RlZmluZSBJT1JFUV9XUklURSAgICAgMAorCisjZGVmaW5lIFNUQVRFX0lPUkVRX05PTkUg
ICAgICAgIDAKKyNkZWZpbmUgU1RBVEVfSU9SRVFfUkVBRFkgICAgICAgMQorI2RlZmluZSBTVEFU
RV9JT1JFUV9JTlBST0NFU1MgICAyCisjZGVmaW5lIFNUQVRFX0lPUkVTUF9SRUFEWSAgICAgIDMK
KworLypHdWVzdCBQaHlzaWNhbCBhZGRyZXNzIGxheW91dC4qLworI2RlZmluZSBHUEZOX01FTSAg
ICAgICAgKDBVTCA8PCA2MCkgLyogR3Vlc3QgcGZuIGlzIG5vcm1hbCBtZW0gKi8KKyNkZWZpbmUg
R1BGTl9GUkFNRV9CVUZGRVIgICAoMVVMIDw8IDYwKSAvKiBWR0EgZnJhbWVidWZmZXIgKi8KKyNk
ZWZpbmUgR1BGTl9MT1dfTU1JTyAgICAgICAoMlVMIDw8IDYwKSAvKiBMb3cgTU1JTyByYW5nZSAq
LworI2RlZmluZSBHUEZOX1BJQiAgICAgICAgKDNVTCA8PCA2MCkgLyogUElCIGJhc2UgKi8KKyNk
ZWZpbmUgR1BGTl9JT1NBUElDICAgICAgICAoNFVMIDw8IDYwKSAvKiBJT1NBUElDIGJhc2UgKi8K
KyNkZWZpbmUgR1BGTl9MRUdBQ1lfSU8gICAgICAoNVVMIDw8IDYwKSAvKiBMZWdhY3kgSS9PIGJh
c2UgKi8KKyNkZWZpbmUgR1BGTl9HRlcgICAgICAgICg2VUwgPDwgNjApIC8qIEd1ZXN0IEZpcm13
YXJlICovCisjZGVmaW5lIEdQRk5fSElHSF9NTUlPICAgICAgKDdVTCA8PCA2MCkgLyogSGlnaCBN
TUlPIHJhbmdlICovCisKKyNkZWZpbmUgR1BGTl9JT19NQVNLICAgICAgICAoN1VMIDw8IDYwKSAv
KiBHdWVzdCBwZm4gaXMgSS9PIHR5cGUgKi8KKyNkZWZpbmUgR1BGTl9JTlZfTUFTSyAgICAgICAo
MVVMIDw8IDYzKSAvKiBHdWVzdCBwZm4gaXMgaW52YWxpZCAqLworI2RlZmluZSBJTlZBTElEX01G
TiAgICAgICAofjBVTCkKKyNkZWZpbmUgTUVNX0cgICAoMVVMIDw8IDMwKQorI2RlZmluZSBNRU1f
TSAgICgxVUwgPDwgMjApCisjZGVmaW5lIE1NSU9fU1RBUlQgICAgICAgKDMgKiBNRU1fRykKKyNk
ZWZpbmUgTU1JT19TSVpFICAgICAgICAoNTEyICogTUVNX00pCisjZGVmaW5lIFZHQV9JT19TVEFS
VCAgICAgMHhBMDAwMFVMCisjZGVmaW5lIFZHQV9JT19TSVpFICAgICAgMHgyMDAwMAorI2RlZmlu
ZSBMRUdBQ1lfSU9fU1RBUlQgIChNTUlPX1NUQVJUICsgTU1JT19TSVpFKQorI2RlZmluZSBMRUdB
Q1lfSU9fU0laRSAgICg2NCpNRU1fTSkKKyNkZWZpbmUgSU9fU0FQSUNfU1RBUlQgICAweGZlYzAw
MDAwVUwKKyNkZWZpbmUgSU9fU0FQSUNfU0laRSAgICAweDEwMDAwMAorI2RlZmluZSBQSUJfU1RB
UlQgMHhmZWUwMDAwMFVMCisjZGVmaW5lIFBJQl9TSVpFIDB4MjAwMDAwCisjZGVmaW5lIEdGV19T
VEFSVCAgICAgICAgKDQqTUVNX0ctMTYqTUVNX00pCisjZGVmaW5lIEdGV19TSVpFICAgICAgICAg
KDE2Kk1FTV9NKQorCisvKkRlbGl2ZXIgbW9kZSwgZGVmaW5lZCBmb3IgaW9hcGljLmMqLworI2Rl
ZmluZSBkZXN0X0ZpeGVkIElPU0FQSUNfRklYRUQKKyNkZWZpbmUgZGVzdF9Mb3dlc3RQcmlvIElP
U0FQSUNfTE9XRVNUX1BSSU9SSVRZCisKKyNkZWZpbmUgTk1JX1ZFQ1RPUiAgICAgIAkJMgorI2Rl
ZmluZSBFeHRJTlRfVkVDVE9SICAgICAgIAkJMAorI2RlZmluZSBOVUxMX1ZFQ1RPUiAgICAgCQkt
MQorI2RlZmluZSBJQTY0X1NQVVJJT1VTX0lOVF9WRUNUT1IgICAgCTB4MGYKKworI2RlZmluZSBW
Q1BVX0xJRCh2KSAoKCh1NjQpKHYpLT52Y3B1X2lkKTw8MjQpCisKKy8qCisgKkRlbGl2ZXJ5IG1v
ZGUKKyAqLworI2RlZmluZSBTQVBJQ19ERUxJVl9TSElGVCAgICAgIDgKKyNkZWZpbmUgU0FQSUNf
RklYRUQgICAgICAgICAgICAweDAKKyNkZWZpbmUgU0FQSUNfTE9XRVNUX1BSSU9SSVRZICAweDEK
KyNkZWZpbmUgU0FQSUNfUE1JICAgICAgICAgICAgICAweDIKKyNkZWZpbmUgU0FQSUNfTk1JICAg
ICAgICAgICAgICAweDQKKyNkZWZpbmUgU0FQSUNfSU5JVCAgICAgICAgICAgICAweDUKKyNkZWZp
bmUgU0FQSUNfRVhUSU5UICAgICAgICAgICAweDcKKworLyoKKyAqIHZjcHUtPnJlcXVlc3RzIGJp
dCBtZW1iZXJzIGZvciBhcmNoCisgKi8KKyNkZWZpbmUgS1ZNX1JFUV9QVENfRwkJMzIKKyNkZWZp
bmUgS1ZNX1JFUV9SRVNVTUUJCTMzCisKKyNkZWZpbmUgS1ZNX1BBR0VTX1BFUl9IUEFHRQkxCisK
K3N0cnVjdCBrdm07CitzdHJ1Y3Qga3ZtX3ZjcHU7CitzdHJ1Y3Qga3ZtX2d1ZXN0X2RlYnVnewor
fTsKKworc3RydWN0IGt2bV9tbWlvX3JlcSB7CisJdWludDY0X3QgYWRkcjsgICAgICAgICAgLyog
IHBoeXNpY2FsIGFkZHJlc3MJCSovCisJdWludDY0X3Qgc2l6ZTsgICAgICAgICAgLyogIHNpemUg
aW4gYnl0ZXMJCSovCisJdWludDY0X3QgZGF0YTsgICAgICAgICAgLyogIGRhdGEgKG9yIHBhZGRy
IG9mIGRhdGEpICAgICAqLworCXVpbnQ4X3Qgc3RhdGU6NDsKKwl1aW50OF90IGRpcjoxOyAgICAg
ICAgICAvKiAgMT1yZWFkLCAwPXdyaXRlICAgICAgICAgICAgICovCit9OwordHlwZWRlZiBzdHJ1
Y3Qga3ZtX21taW9fcmVxIG1taW9fcmVxX3Q7CisKKy8qUGFsIGRhdGEgc3RydWN0ICovCit0eXBl
ZGVmIHN0cnVjdCBwYWxfY2FsbHsKKwkvKkluIGFyZWEqLworCXVpbnQ2NF90IGdyMjg7CisJdWlu
dDY0X3QgZ3IyOTsKKwl1aW50NjRfdCBncjMwOworCXVpbnQ2NF90IGdyMzE7CisJLypPdXQgYXJl
YSovCisJc3RydWN0IGlhNjRfcGFsX3JldHZhbCByZXQ7Cit9IHBhbF9jYWxsX3Q7CisKKy8qIFNh
bCBkYXRhIHN0cnVjdHVyZSAqLwordHlwZWRlZiBzdHJ1Y3Qgc2FsX2NhbGx7CisJLypJbiBhcmVh
Ki8KKwl1aW50NjRfdCBpbjA7CisJdWludDY0X3QgaW4xOworCXVpbnQ2NF90IGluMjsKKwl1aW50
NjRfdCBpbjM7CisJdWludDY0X3QgaW40OworCXVpbnQ2NF90IGluNTsKKwl1aW50NjRfdCBpbjY7
CisJdWludDY0X3QgaW43OworCS8qT3VyIGFyZWEqLworCXN0cnVjdCBzYWxfcmV0X3ZhbHVlcyBy
ZXQ7Cit9IHNhbF9jYWxsX3Q7CisKKy8qR3Vlc3QgY2hhbmdlIHJyNiovCit0eXBlZGVmIHN0cnVj
dCBzd2l0Y2hfcnI2IHsKKwl1aW50NjRfdCBvbGRfcnI7CisJdWludDY0X3QgbmV3X3JyOworfSBz
d2l0Y2hfcnI2X3Q7CisKK3R5cGVkZWYgdW5pb257CisJdW5zaWduZWQgbG9uZyB2YWw7CisJc3Ry
dWN0IHsKKwkJdW5zaWduZWQgbG9uZyBydiAgOiAzOworCQl1bnNpZ25lZCBsb25nIGlyICA6IDE7
CisJCXVuc2lnbmVkIGxvbmcgZWlkIDogODsKKwkJdW5zaWduZWQgbG9uZyBpZCAgOiA4OworCQl1
bnNpZ25lZCBsb25nIGliX2Jhc2UgOiA0NDsKKwl9OworfSBpYTY0X2lwaV9hOworCit0eXBlZGVm
IHVuaW9ueworCXVuc2lnbmVkIGxvbmcgdmFsOworCXN0cnVjdCB7CisJCXVuc2lnbmVkIGxvbmcg
dmVjdG9yIDogODsKKwkJdW5zaWduZWQgbG9uZyBkbSAgOiAzOworCQl1bnNpZ25lZCBsb25nIGln
ICA6IDUzOworCX07Cit9IGlhNjRfaXBpX2Q7CisKKy8qaXBpIGNoZWNrIGV4aXQgZGF0YSovCit0
eXBlZGVmIHN0cnVjdCBpcGlfZGF0YXsKKwlpYTY0X2lwaV9hIGFkZHI7CisJaWE2NF9pcGlfZCBk
YXRhOworfSBpcGlfZGF0YV90OworCisvKmdsb2JhbCBwdXJnZSBkYXRhKi8KK3R5cGVkZWYgc3Ry
dWN0IGt2bV9wdGNfZyB7CisJdW5zaWduZWQgbG9uZyB2YWRkcjsKKwl1bnNpZ25lZCBsb25nIHJy
OworCXVuc2lnbmVkIGxvbmcgcHM7CisJc3RydWN0IGt2bV92Y3B1ICp2Y3B1OworfSBwdGNfZ190
OworCisvKkV4aXQgY29udHJvbCBkYXRhICovCitzdHJ1Y3QgZXhpdF9jdGxfZGF0YXsKKwl1aW50
MzJfdCBleGl0X3JlYXNvbjsKKwl1aW50MzJfdCB2bV9zdGF0dXM7CisJdW5pb24geworCQltbWlv
X3JlcV90CQlpb3JlcTsKKwkJcGFsX2NhbGxfdAlwYWxfZGF0YTsKKwkJc2FsX2NhbGxfdAlzYWxf
ZGF0YTsKKwkJc3dpdGNoX3JyNl90CXJyX2RhdGE7CisJCWlwaV9kYXRhX3QJaXBpX2RhdGE7CisJ
CXB0Y19nX3QJCXB0Y19nX2RhdGE7CisJfSB1OworfTsKKwordW5pb24gcHRlX2ZsYWdzIHsKKwlz
dHJ1Y3QgeworCQl1bnNpZ25lZCBsb25nIHAgICAgOiAgMTsgLyowICAgICAgKi8KKwkJdW5zaWdu
ZWQgbG9uZyAgICAgIDogIDE7IC8qIDEgICAgICovCisJCXVuc2lnbmVkIGxvbmcgbWEgICA6ICAz
OyAvKiAyLTQgICAqLworCQl1bnNpZ25lZCBsb25nIGEgICAgOiAgMTsgLyogNSAgICAgKi8KKwkJ
dW5zaWduZWQgbG9uZyBkICAgIDogIDE7IC8qIDYgICAgICovCisJCXVuc2lnbmVkIGxvbmcgcGwg
ICA6ICAyOyAvKiA3LTggICAqLworCQl1bnNpZ25lZCBsb25nIGFyICAgOiAgMzsgLyogOS0xMSAg
Ki8KKwkJdW5zaWduZWQgbG9uZyBwcG4gIDogMzg7IC8qIDEyLTQ5ICovCisJCXVuc2lnbmVkIGxv
bmcgICAgICA6ICAyOyAvKiA1MC01MSAqLworCQl1bnNpZ25lZCBsb25nIGVkICAgOiAgMTsgLyog
NTIgICAgKi8KKwl9OworCXVuc2lnbmVkIGxvbmcgdmFsOworfTsKKwordHlwZWRlZiB1bmlvbiB7
CisJdW5zaWduZWQgbG9uZyB2YWw7CisJc3RydWN0IHsKKwkJdW5zaWduZWQgbG9uZyB2ZSA6IDE7
CisJCXVuc2lnbmVkIGxvbmcgcmVzZXJ2ZWQwIDogMTsKKwkJdW5zaWduZWQgbG9uZyBzaXplIDog
NjsKKwkJdW5zaWduZWQgbG9uZyB2ZiA6IDE7CisJCXVuc2lnbmVkIGxvbmcgcmVzZXJ2ZWQxIDog
NjsKKwkJdW5zaWduZWQgbG9uZyBiYXNlIDogNDk7CisJfTsKK30gaWE2NF9wdGE7CisKK3R5cGVk
ZWYgc3RydWN0IHRoYXNoX2NiIHsKKwkvKiBUSEFTSCBiYXNlIGluZm9ybWF0aW9uICovCisJdGhh
c2hfZGF0YV90ICAqaGFzaDsgLyogaGFzaCB0YWJsZSBwb2ludGVyLCBhbGlnbmVkIGF0IHRoYXNo
X3N6LiovCisJaWE2NF9wdGEgICAgICBwdGE7CisJaW50ICAgICAgICAgICBudW07Cit9IHRoYXNo
X2NiX3Q7CisKK3N0cnVjdCBrdm1fdmNwdV9zdGF0IHsKK307CitzdHJ1Y3Qga3ZtX3ZjcHVfYXJj
aCB7CisJaW50IGxhdW5jaGVkOworCWludCBsYXN0X2V4aXQ7CisJaW50IGxhc3RfcnVuX2NwdTsK
KwlpbnQgdm1tX3RyX3Nsb3Q7CisJaW50IHZtX3RyX3Nsb3Q7CisKKyNkZWZpbmUgVkNQVV9NUF9T
VEFURV9SVU5OQUJMRSAgICAgICAgICAwCisjZGVmaW5lIFZDUFVfTVBfU1RBVEVfVU5JTklUSUFM
SVpFRCAgICAgMQorI2RlZmluZSBWQ1BVX01QX1NUQVRFX0lOSVRfUkVDRUlWRUQgICAgIDIKKyNk
ZWZpbmUgVkNQVV9NUF9TVEFURV9IQUxURUQgICAgICAgICAgICAzCisJaW50IG1wX3N0YXRlOwor
CisjZGVmaW5lIE1BWF9QVENfR19OVU0JCQkzCisJaW50IHB0Y19nX2NvdW50OworCXN0cnVjdCBr
dm1fcHRjX2cgcHRjX2dfZGF0YVtNQVhfUFRDX0dfTlVNXTsKKworCS8qaGFsdCB0aW1lciB0byB3
YWtlIHVwIHNsZWVweSB2Y3B1cyovCisJc3RydWN0IGhydGltZXIgaGx0X3RpbWVyOworCWxvbmcg
aHRfYWN0aXZlOworCisJc3RydWN0IGt2bV9sYXBpYyAqYXBpYzsgICAgLyoga2VybmVsIGlycWNo
aXAgY29udGV4dCAqLworCXN0cnVjdCB2cGQgKnZwZDsKKworCS8qIEV4aXQgZGF0YSBmb3Igdm1t
X3RyYW5zaXRpb24qLworCXN0cnVjdCBleGl0X2N0bF9kYXRhIGV4aXRfZGF0YTsKKworCWNwdW1h
c2tfdCBjYWNoZV9jb2hlcmVudF9tYXA7CisKKwl1bnNpZ25lZCBsb25nIHZtbV9ycjsKKwl1bnNp
Z25lZCBsb25nIGhvc3RfcnI2OworCXVuc2lnbmVkIGxvbmcgcHNiaXRzWzhdOworCXVuc2lnbmVk
IGxvbmcgY3JfaWlwYTsKKwl1bnNpZ25lZCBsb25nIGNyX2lzcjsKKwl1bnNpZ25lZCBsb25nIHZz
YV9iYXNlOworCXVuc2lnbmVkIGxvbmcgZGlydHlfbG9nX2xvY2tfcGE7CisJdW5zaWduZWQgbG9u
ZyBfX2dwOworCS8qIFRSIGFuZCBUQy4gICovCisJdGhhc2hfZGF0YV90IGl0cnNbTklUUlNdOwor
CXRoYXNoX2RhdGFfdCBkdHJzW05EVFJTXTsKKwkvKiBCaXQgaXMgc2V0IGlmIHRoZXJlIGlzIGEg
dHIvdGMgZm9yIHRoZSByZWdpb24uICAqLworCXVuc2lnbmVkIGNoYXIgaXRyX3JlZ2lvbnM7CisJ
dW5zaWduZWQgY2hhciBkdHJfcmVnaW9uczsKKwl1bnNpZ25lZCBjaGFyIHRjX3JlZ2lvbnM7CisJ
LyogcHVyZ2UgYWxsICovCisJdW5zaWduZWQgbG9uZyBwdGNlX2Jhc2U7CisJdW5zaWduZWQgbG9u
ZyBwdGNlX2NvdW50WzJdOworCXVuc2lnbmVkIGxvbmcgcHRjZV9zdHJpZGVbMl07CisJLyogaXRj
L2l0bSAqLworCXVuc2lnbmVkIGxvbmcgbGFzdF9pdGM7CisJbG9uZyBpdGNfb2Zmc2V0OworCXVu
c2lnbmVkIGxvbmcgaXRjX2NoZWNrOworCXVuc2lnbmVkIGxvbmcgdGltZXJfY2hlY2s7CisJdW5z
aWduZWQgbG9uZyB0aW1lcl9wZW5kaW5nOworCisJdW5zaWduZWQgbG9uZyB2cnJbOF07CisJdW5z
aWduZWQgbG9uZyBpYnJbOF07CisJdW5zaWduZWQgbG9uZyBkYnJbOF07CisJdW5zaWduZWQgbG9u
ZyBpbnN2Y1s0XTsJCS8qIEludGVycnVwdCBpbiBzZXJ2aWNlLiAgKi8KKwl1bnNpZ25lZCBsb25n
IHh0cDsKKworCXVuc2lnbmVkIGxvbmcgbWV0YXBoeXNpY2FsX3JyMDsgLyogZnJvbSBrdm1fYXJj
aCAoc28gaXMgcGlubmVkKSAqLworCXVuc2lnbmVkIGxvbmcgbWV0YXBoeXNpY2FsX3JyNDsJLyog
ZnJvbSBrdm1fYXJjaCAoc28gaXMgcGlubmVkKSAqLworCXVuc2lnbmVkIGxvbmcgbWV0YXBoeXNp
Y2FsX3NhdmVkX3JyMDsgLyogZnJvbSBrdm1fYXJjaCAgICAgICAgICAqLworCXVuc2lnbmVkIGxv
bmcgbWV0YXBoeXNpY2FsX3NhdmVkX3JyNDsgLyogZnJvbSBrdm1fYXJjaCAgICAgICAgICAqLwor
CXVuc2lnbmVkIGxvbmcgZnBfcHNyOyAgICAgICAvKnVzZWQgZm9yIGxhenkgZmxvYXQgcmVnaXN0
ZXIgKi8KKwl1bnNpZ25lZCBsb25nIHNhdmVkX2dwOworCS8qZm9yIHBoeWNpYWwgIGVtdWxhdGlv
biAqLworCWludCBtb2RlX2ZsYWdzOworCXRoYXNoX2NiX3QgdnRsYjsKKwl0aGFzaF9jYl90IHZo
cHQ7CisJY2hhciBpcnFfY2hlY2s7CisJY2hhciBpcnFfbmV3X3BlbmRpbmc7CisKKwl1bnNpZ25l
ZCBsb25nIG9wY29kZTsKKwl1bnNpZ25lZCBsb25nIGNhdXNlOworCWNvbnRleHRfdCBob3N0Owor
CWNvbnRleHRfdCBndWVzdDsKKworfTsKKworc3RydWN0IGt2bV92bV9zdGF0IHsKKwl1NjQgcmVt
b3RlX3RsYl9mbHVzaDsKK307CisKK3N0cnVjdCBrdm1fc2FsX2RhdGEgeworCXVuc2lnbmVkIGxv
bmcgYm9vdF9pcDsKKwl1bnNpZ25lZCBsb25nIGJvb3RfZ3A7Cit9OworCitzdHJ1Y3Qga3ZtX2Fy
Y2ggeworCXVuc2lnbmVkIGxvbmcJdm1fYmFzZTsKKwl1bnNpZ25lZCBsb25nCW1ldGFwaHlzaWNh
bF9ycjA7CisJdW5zaWduZWQgbG9uZwltZXRhcGh5c2ljYWxfcnI0OworCXVuc2lnbmVkIGxvbmcJ
dm1tX2luaXRfcnI7CisJdW5zaWduZWQgbG9uZwl2aHB0X2Jhc2U7CisJdW5zaWduZWQgbG9uZwl2
dGxiX2Jhc2U7CisJdW5zaWduZWQgbG9uZyAJdnBkX2Jhc2U7CisJc3BpbmxvY2tfdCBkaXJ0eV9s
b2dfbG9jazsKKwlzdHJ1Y3Qga3ZtX2lvYXBpYyAqdmlvYXBpYzsKKwlzdHJ1Y3Qga3ZtX3ZtX3N0
YXQgc3RhdDsKKwlzdHJ1Y3Qga3ZtX3NhbF9kYXRhIHJkdl9zYWxfZGF0YTsKK307CisKK3R5cGVk
ZWYgdW5pb24geworCXU2NCB2YWx1ZTsKKwlzdHJ1Y3QgeworCQl1NjQgbnVtYmVyIDogODsKKwkJ
dTY0IHJldmlzaW9uIDogODsKKwkJdTY0IG1vZGVsIDogODsKKwkJdTY0IGZhbWlseSA6IDg7CisJ
CXU2NCBhcmNocmV2IDogODsKKwkJdTY0IHJ2IDogMjQ7CisJfTsKK30gY3B1aWQzX3Q7CisKK3N0
cnVjdCBrdm1fcHRfcmVncyB7CisgICAgLyogVGhlIGZvbGxvd2luZyByZWdpc3RlcnMgYXJlIHNh
dmVkIGJ5IFNBVkVfTUlOOiAqLworICAgIHVuc2lnbmVkIGxvbmcgYjY7ICAvKiBzY3JhdGNoICov
CisgICAgdW5zaWduZWQgbG9uZyBiNzsgIC8qIHNjcmF0Y2ggKi8KKworICAgIHVuc2lnbmVkIGxv
bmcgYXJfY3NkOyAvKiB1c2VkIGJ5IGNtcDh4Y2hnMTYgKHNjcmF0Y2gpICovCisgICAgdW5zaWdu
ZWQgbG9uZyBhcl9zc2Q7IC8qIHJlc2VydmVkIGZvciBmdXR1cmUgdXNlIChzY3JhdGNoKSAqLwor
CisgICAgdW5zaWduZWQgbG9uZyByODsgIC8qIHNjcmF0Y2ggKHJldHVybiB2YWx1ZSByZWdpc3Rl
ciAwKSAqLworICAgIHVuc2lnbmVkIGxvbmcgcjk7ICAvKiBzY3JhdGNoIChyZXR1cm4gdmFsdWUg
cmVnaXN0ZXIgMSkgKi8KKyAgICB1bnNpZ25lZCBsb25nIHIxMDsgLyogc2NyYXRjaCAocmV0dXJu
IHZhbHVlIHJlZ2lzdGVyIDIpICovCisgICAgdW5zaWduZWQgbG9uZyByMTE7IC8qIHNjcmF0Y2gg
KHJldHVybiB2YWx1ZSByZWdpc3RlciAzKSAqLworCisgICAgdW5zaWduZWQgbG9uZyBjcl9pcHNy
OyAvKiBpbnRlcnJ1cHRlZCB0YXNrJ3MgcHNyICovCisgICAgdW5zaWduZWQgbG9uZyBjcl9paXA7
ICAvKiBpbnRlcnJ1cHRlZCB0YXNrJ3MgaW5zdHJ1Y3Rpb24gcG9pbnRlciAqLworICAgIHVuc2ln
bmVkIGxvbmcgY3JfaWZzOyAgLyogaW50ZXJydXB0ZWQgdGFzaydzIGZ1bmN0aW9uIHN0YXRlICov
CisKKyAgICB1bnNpZ25lZCBsb25nIGFyX3VuYXQ7IC8qIGludGVycnVwdGVkIHRhc2sncyBOYVQg
cmVnaXN0ZXIgKHByZXNlcnZlZCkgKi8KKyAgICB1bnNpZ25lZCBsb25nIGFyX3BmczsgIC8qIHBy
ZXYgZnVuY3Rpb24gc3RhdGUgICovCisgICAgdW5zaWduZWQgbG9uZyBhcl9yc2M7ICAvKiBSU0Ug
Y29uZmlndXJhdGlvbiAqLworICAgIC8qIFRoZSBmb2xsb3dpbmcgdHdvIGFyZSB2YWxpZCBvbmx5
IGlmIGNyX2lwc3IuY3BsID4gMDogKi8KKyAgICB1bnNpZ25lZCBsb25nIGFyX3JuYXQ7ICAvKiBS
U0UgTmFUICovCisgICAgdW5zaWduZWQgbG9uZyBhcl9ic3BzdG9yZTsgLyogUlNFIGJzcHN0b3Jl
ICovCisKKyAgICB1bnNpZ25lZCBsb25nIHByOyAgLyogNjQgcHJlZGljYXRlIHJlZ2lzdGVycyAo
MSBiaXQgZWFjaCkgKi8KKyAgICB1bnNpZ25lZCBsb25nIGIwOyAgLyogcmV0dXJuIHBvaW50ZXIg
KGJwKSAqLworICAgIHVuc2lnbmVkIGxvbmcgbG9hZHJzOyAgLyogc2l6ZSBvZiBkaXJ0eSBwYXJ0
aXRpb24gPDwgMTYgKi8KKworICAgIHVuc2lnbmVkIGxvbmcgcjE7ICAvKiB0aGUgZ3AgcG9pbnRl
ciAqLworICAgIHVuc2lnbmVkIGxvbmcgcjEyOyAvKiBpbnRlcnJ1cHRlZCB0YXNrJ3MgbWVtb3J5
IHN0YWNrIHBvaW50ZXIgKi8KKyAgICB1bnNpZ25lZCBsb25nIHIxMzsgLyogdGhyZWFkIHBvaW50
ZXIgKi8KKworICAgIHVuc2lnbmVkIGxvbmcgYXJfZnBzcjsgIC8qIGZsb2F0aW5nIHBvaW50IHN0
YXR1cyAocHJlc2VydmVkKSAqLworICAgIHVuc2lnbmVkIGxvbmcgcjE1OyAgLyogc2NyYXRjaCAq
LworCisgLyogVGhlIHJlbWFpbmluZyByZWdpc3RlcnMgYXJlIE5PVCBzYXZlZCBmb3Igc3lzdGVt
IGNhbGxzLiAgKi8KKworICAgIHVuc2lnbmVkIGxvbmcgcjE0OyAgLyogc2NyYXRjaCAqLworICAg
IHVuc2lnbmVkIGxvbmcgcjI7ICAvKiBzY3JhdGNoICovCisgICAgdW5zaWduZWQgbG9uZyByMzsg
IC8qIHNjcmF0Y2ggKi8KKyAgICB1bnNpZ25lZCBsb25nIHIxNjsgIC8qIHNjcmF0Y2ggKi8KKyAg
ICB1bnNpZ25lZCBsb25nIHIxNzsgIC8qIHNjcmF0Y2ggKi8KKyAgICB1bnNpZ25lZCBsb25nIHIx
ODsgIC8qIHNjcmF0Y2ggKi8KKyAgICB1bnNpZ25lZCBsb25nIHIxOTsgIC8qIHNjcmF0Y2ggKi8K
KyAgICB1bnNpZ25lZCBsb25nIHIyMDsgIC8qIHNjcmF0Y2ggKi8KKyAgICB1bnNpZ25lZCBsb25n
IHIyMTsgIC8qIHNjcmF0Y2ggKi8KKyAgICB1bnNpZ25lZCBsb25nIHIyMjsgIC8qIHNjcmF0Y2gg
Ki8KKyAgICB1bnNpZ25lZCBsb25nIHIyMzsgIC8qIHNjcmF0Y2ggKi8KKyAgICB1bnNpZ25lZCBs
b25nIHIyNDsgIC8qIHNjcmF0Y2ggKi8KKyAgICB1bnNpZ25lZCBsb25nIHIyNTsgIC8qIHNjcmF0
Y2ggKi8KKyAgICB1bnNpZ25lZCBsb25nIHIyNjsgIC8qIHNjcmF0Y2ggKi8KKyAgICB1bnNpZ25l
ZCBsb25nIHIyNzsgIC8qIHNjcmF0Y2ggKi8KKyAgICB1bnNpZ25lZCBsb25nIHIyODsgIC8qIHNj
cmF0Y2ggKi8KKyAgICB1bnNpZ25lZCBsb25nIHIyOTsgIC8qIHNjcmF0Y2ggKi8KKyAgICB1bnNp
Z25lZCBsb25nIHIzMDsgIC8qIHNjcmF0Y2ggKi8KKyAgICB1bnNpZ25lZCBsb25nIHIzMTsgIC8q
IHNjcmF0Y2ggKi8KKyAgICB1bnNpZ25lZCBsb25nIGFyX2NjdjsgIC8qIGNvbXBhcmUvZXhjaGFu
Z2UgdmFsdWUgKHNjcmF0Y2gpICovCisKKworICAgIC8qCisgICAgICogRmxvYXRpbmcgcG9pbnQg
cmVnaXN0ZXJzIHRoYXQgdGhlIGtlcm5lbCBjb25zaWRlcnMgc2NyYXRjaDoKKyAgICAgKi8KKyAg
ICBzdHJ1Y3QgaWE2NF9mcHJlZyBmNjsgIC8qIHNjcmF0Y2ggKi8KKyAgICBzdHJ1Y3QgaWE2NF9m
cHJlZyBmNzsgIC8qIHNjcmF0Y2ggKi8KKyAgICBzdHJ1Y3QgaWE2NF9mcHJlZyBmODsgIC8qIHNj
cmF0Y2ggKi8KKyAgICBzdHJ1Y3QgaWE2NF9mcHJlZyBmOTsgIC8qIHNjcmF0Y2ggKi8KKyAgICBz
dHJ1Y3QgaWE2NF9mcHJlZyBmMTA7ICAvKiBzY3JhdGNoICovCisgICAgc3RydWN0IGlhNjRfZnBy
ZWcgZjExOyAgLyogc2NyYXRjaCAqLworCisgICAgdW5zaWduZWQgbG9uZyByNDsgIC8qIHByZXNl
cnZlZCAqLworICAgIHVuc2lnbmVkIGxvbmcgcjU7ICAvKiBwcmVzZXJ2ZWQgKi8KKyAgICB1bnNp
Z25lZCBsb25nIHI2OyAgLyogcHJlc2VydmVkICovCisgICAgdW5zaWduZWQgbG9uZyByNzsgIC8q
IHByZXNlcnZlZCAqLworICAgIHVuc2lnbmVkIGxvbmcgZW1sX3VuYXQ7ICAgIC8qIHVzZWQgZm9y
IGVtdWxhdGluZyBpbnN0cnVjdGlvbiAqLworICAgIHVuc2lnbmVkIGxvbmcgcGFkMDsgICAgIC8q
IGFsaWdubWVudCBwYWQgKi8KKworfTsKKworc3RhdGljIGlubGluZSBzdHJ1Y3Qga3ZtX3B0X3Jl
Z3MgKnZjcHVfcmVncyhzdHJ1Y3Qga3ZtX3ZjcHUgKnYpCit7CisJcmV0dXJuIChzdHJ1Y3Qga3Zt
X3B0X3JlZ3MgKikgKCh1bnNpZ25lZCBsb25nKSB2ICsgSUE2NF9TVEtfT0ZGU0VUKSAtIDE7Cit9
CisKK3R5cGVkZWYgaW50IGt2bV92bW1fZW50cnkodm9pZCk7Cit0eXBlZGVmIHZvaWQga3ZtX3Ry
YW1wX2VudHJ5KGNvbnRleHRfdCAqaG9zdCwgY29udGV4dF90ICpndWVzdCk7CisKK3N0cnVjdCBr
dm1fdm1tX2luZm97CisJc3RydWN0IG1vZHVsZQkqbW9kdWxlOworCWt2bV92bW1fZW50cnkgCSp2
bW1fZW50cnk7CisJa3ZtX3RyYW1wX2VudHJ5ICp0cmFtcF9lbnRyeTsKKwl1bnNpZ25lZCBsb25n
IAl2bW1faXZ0OworfTsKKworaW50IGt2bV9oaWdoZXN0X3BlbmRpbmdfaXJxKHN0cnVjdCBrdm1f
dmNwdSAqdmNwdSk7CitpbnQga3ZtX2VtdWxhdGVfaGFsdChzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUp
OworaW50IGt2bV9wYWxfZW11bChzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUsIHN0cnVjdCBrdm1fcnVu
ICprdm1fcnVuKTsKK3ZvaWQga3ZtX3NhbF9lbXVsKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSk7CisK
KyNlbmRpZgpkaWZmIC0tZ2l0IGEvaW5jbHVkZS9hc20taWE2NC9rdm1fcGFyYS5oIGIvaW5jbHVk
ZS9hc20taWE2NC9rdm1fcGFyYS5oCm5ldyBmaWxlIG1vZGUgMTAwNjQ0CmluZGV4IDAwMDAwMDAu
LjlmOTc5NmIKLS0tIC9kZXYvbnVsbAorKysgYi9pbmNsdWRlL2FzbS1pYTY0L2t2bV9wYXJhLmgK
QEAgLTAsMCArMSwyOSBAQAorI2lmbmRlZiBfX0lBNjRfS1ZNX1BBUkFfSAorI2RlZmluZSBfX0lB
NjRfS1ZNX1BBUkFfSAorCisvKgorICogYXNtLWlhNjQva3ZtX3BhcmEuaAorICoKKyAqIENvcHly
aWdodCAoQykgMjAwNyBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNvbT4KKyAq
CisgKiBUaGlzIHByb2dyYW0gaXMgZnJlZSBzb2Z0d2FyZTsgeW91IGNhbiByZWRpc3RyaWJ1dGUg
aXQgYW5kL29yIG1vZGlmeSBpdAorICogdW5kZXIgdGhlIHRlcm1zIGFuZCBjb25kaXRpb25zIG9m
IHRoZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSwKKyAqIHZlcnNpb24gMiwgYXMgcHVibGlz
aGVkIGJ5IHRoZSBGcmVlIFNvZnR3YXJlIEZvdW5kYXRpb24uCisgKgorICogVGhpcyBwcm9ncmFt
IGlzIGRpc3RyaWJ1dGVkIGluIHRoZSBob3BlIGl0IHdpbGwgYmUgdXNlZnVsLCBidXQgV0lUSE9V
VAorICogQU5ZIFdBUlJBTlRZOyB3aXRob3V0IGV2ZW4gdGhlIGltcGxpZWQgd2FycmFudHkgb2Yg
TUVSQ0hBTlRBQklMSVRZIG9yCisgKiBGSVRORVNTIEZPUiBBIFBBUlRJQ1VMQVIgUFVSUE9TRS4g
IFNlZSB0aGUgR05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2UgZm9yCisgKiBtb3JlIGRldGFpbHMu
CisgKgorICogWW91IHNob3VsZCBoYXZlIHJlY2VpdmVkIGEgY29weSBvZiB0aGUgR05VIEdlbmVy
YWwgUHVibGljIExpY2Vuc2UgYWxvbmcgd2l0aAorICogdGhpcyBwcm9ncmFtOyBpZiBub3QsIHdy
aXRlIHRvIHRoZSBGcmVlIFNvZnR3YXJlIEZvdW5kYXRpb24sIEluYy4sIDU5IFRlbXBsZQorICog
UGxhY2UgLSBTdWl0ZSAzMzAsIEJvc3RvbiwgTUEgMDIxMTEtMTMwNyBVU0EuCisgKgorICovCisK
K3N0YXRpYyBpbmxpbmUgdW5zaWduZWQgaW50IGt2bV9hcmNoX3BhcmFfZmVhdHVyZXModm9pZCkK
K3sKKwlyZXR1cm4gMDsKK30KKworI2VuZGlmCi0tIAoxLjUuMgoK

------_=_NextPart_001_01C89308.D0EEC3B7--
