From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 10:29:04 +0000
Subject: [PATCH][06]Add kvm arch-specific core code for kvm/ia64.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCD31FC9@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C863F4.1AACE3C7"
List-Id: <linux-ia64.vger.kernel.org>
To: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: kvm-devel@lists.sourceforge.net, kvm-ia64-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C863F4.1AACE3C7
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 15:40:12 +0800
Subject: [PATCH] kvm/ia64: Add kvm arch-specific core code for kvm/ia64.

kvm_ia64.c is added to handle ia64-specific core logic.
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/kvm_ia64.c | 1596
++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 1596 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/kvm_ia64.c

diff --git a/arch/ia64/kvm/kvm_ia64.c b/arch/ia64/kvm/kvm_ia64.c
new file mode 100644
index 0000000..f1a0a93
--- /dev/null
+++ b/arch/ia64/kvm/kvm_ia64.c
@@ -0,0 +1,1596 @@
+/*
+ * kvm_ia64.c: Basic KVM suppport On Itanium series processors
+ *
+ *
+ * 	Copyright (C) 2007, Intel Corporation.
+ *  	Xiantao Zhang  (xiantao.zhang@intel.com)
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
+#include <linux/module.h>
+#include <linux/vmalloc.h>
+#include <linux/errno.h>
+#include <linux/percpu.h>
+#include <linux/gfp.h>
+#include <linux/fs.h>
+#include <linux/smp.h>
+#include <linux/kvm_host.h>
+#include <linux/kvm.h>
+#include <linux/bitops.h>
+#include <linux/hrtimer.h>
+
+#include <asm/pgtable.h>
+#include <asm/gcc_intrin.h>
+#include <asm/pal.h>
+#include <asm/uaccess.h>
+#include <asm/cacheflush.h>
+#include <asm/div64.h>
+#include <asm/tlb.h>
+
+#include "ia64_regs.h"
+#include "misc.h"
+#include "vti.h"
+#include "iodev.h"
+#include "ioapic.h"
+#include "lapic.h"
+
+static unsigned long kvm_vmm_base;
+static unsigned long kvm_vsa_base;
+static unsigned long kvm_vm_buffer;
+static unsigned long kvm_vm_buffer_size;
+unsigned long kvm_vmm_gp;
+
+static long vp_env_info;
+
+static struct kvm_vmm_info *kvm_vmm_info;
+
+static DEFINE_PER_CPU(struct kvm_vcpu *, last_vcpu);
+
+struct kvm_stats_debugfs_item debugfs_entries[] =3D {
+	{ NULL }
+};
+
+
+struct fdesc{
+    unsigned long ip;
+    unsigned long gp;
+};
+
+static void kvm_flush_icache(unsigned long start, unsigned long len)
+{
+	int l;
+
+	for (l =3D 0; l < (len + 32); l +=3D 32)
+		ia64_fc(start + l);
+
+	ia64_sync_i();
+	ia64_srlz_i();
+}
+
+static void kvm_flush_tlb_all(void)
+{
+	unsigned long i, j, count0, count1, stride0, stride1, addr;
+	long flags;
+
+	addr    =3D local_cpu_data->ptce_base;
+	count0  =3D local_cpu_data->ptce_count[0];
+	count1  =3D local_cpu_data->ptce_count[1];
+	stride0 =3D local_cpu_data->ptce_stride[0];
+	stride1 =3D local_cpu_data->ptce_stride[1];
+
+	local_irq_save(flags);
+	for (i =3D 0; i < count0; ++i) {
+		for (j =3D 0; j < count1; ++j) {
+			ia64_ptce(addr);
+			addr +=3D stride1;
+		}
+		addr +=3D stride0;
+	}
+	local_irq_restore(flags);
+	ia64_srlz_i();			/* srlz.i implies srlz.d */
+}
+
+long ia64_pal_vp_create(u64 *vpd, u64 *host_iva, u64 *opt_handler)
+{
+	struct ia64_pal_retval iprv;
+
+	PAL_CALL_STK(iprv, PAL_VP_CREATE, (u64)vpd, (u64)host_iva,
+			(u64)opt_handler);
+
+	return iprv.status;
+}
+
+static  DEFINE_SPINLOCK(vp_lock);
+
+void kvm_arch_hardware_enable(void *garbage)
+{
+	long  status;
+	long  tmp_base;
+	unsigned long pte;
+	unsigned long saved_psr;
+
+	pte =3D pte_val(mk_pte_phys(__pa(kvm_vmm_base),
+				PAGE_KERNEL));
+	local_irq_save(saved_psr);
+	ia64_itr_entry(0x3, KVM_VMM_BASE,
+			pte, KVM_VMM_SHIFT);
+	local_irq_restore(saved_psr);
+
+	spin_lock(&vp_lock);
+	status =3D ia64_pal_vp_init_env(kvm_vsa_base ?
+				VP_INIT_ENV : VP_INIT_ENV_INITALIZE,
+			__pa(kvm_vm_buffer), KVM_VM_BUFFER_BASE,
&tmp_base);
+	if (status !=3D 0) {
+		printk(KERN_WARNING"kvm:Failed to Enable VT
Support!!!!\n");
+		return ;
+	}
+
+	if (!kvm_vsa_base) {
+		kvm_vsa_base =3D tmp_base;
+		printk(KERN_INFO"kvm:kvm_vsa_base:0x%lx\n",
kvm_vsa_base);
+	}
+	spin_unlock(&vp_lock);
+	ia64_ptr_entry(0x3, KVM_VMM_BASE, KVM_VMM_SHIFT);
+}
+
+void kvm_arch_hardware_disable(void *garbage)
+{
+
+	long status;
+	unsigned long pte;
+	unsigned long saved_psr;
+	unsigned long host_iva =3D ia64_getreg(_IA64_REG_CR_IVA);
+
+	pte =3D pte_val(mk_pte_phys(__pa(kvm_vmm_base),
+				PAGE_KERNEL));
+
+	local_irq_save(saved_psr);
+	ia64_itr_entry(0x3, KVM_VMM_BASE,
+			pte, KVM_VMM_SHIFT);
+	local_irq_restore(saved_psr);
+
+	status =3D ia64_pal_vp_exit_env(host_iva);
+	if (status)
+		printk(KERN_DEBUG"kvm: Failed to disable VT support!
:%ld\n",
+				status);
+	ia64_ptr_entry(0x3, KVM_VMM_BASE, KVM_VMM_SHIFT);
+}
+
+void kvm_arch_check_processor_compat(void *rtn)
+{
+	*(int *)rtn =3D 0;
+}
+
+int kvm_dev_ioctl_check_extension(long ext)
+{
+
+	int r;
+
+	switch (ext) {
+	case KVM_CAP_IRQCHIP:
+	case KVM_CAP_USER_MEMORY:
+
+		r =3D 1;
+		break;
+	default:
+		r =3D 0;
+	}
+	return r;
+
+}
+
+static struct kvm_io_device *vcpu_find_mmio_dev(struct kvm_vcpu *vcpu,
+					gpa_t addr)
+{
+	struct kvm_io_device *dev;
+
+	dev =3D kvm_io_bus_find_dev(&vcpu->kvm->mmio_bus, addr);
+
+	return dev;
+}
+
+static int handle_vm_error(struct kvm_vcpu *vcpu, struct kvm_run
*kvm_run)
+{
+	kvm_run->exit_reason =3D KVM_EXIT_UNKNOWN;
+	kvm_run->hw.hardware_exit_reason =3D 1;
+	return 0;
+}
+
+static int handle_mmio(struct kvm_vcpu *vcpu, struct kvm_run *kvm_run)
+{
+	ioreq_t *p;
+	struct kvm_io_device *mmio_dev;
+
+	p =3D kvm_get_vcpu_ioreq(vcpu);
+
+	if ((p->addr & PAGE_MASK) =3D=3D IOAPIC_DEFAULT_BASE_ADDRESS)
+		goto mmio;
+	vcpu->mmio_needed =3D 1;
+	vcpu->mmio_phys_addr =3D kvm_run->mmio.phys_addr =3D p->addr;
+	vcpu->mmio_size =3D kvm_run->mmio.len =3D p->size;
+	vcpu->mmio_is_write =3D kvm_run->mmio.is_write =3D !p->dir;
+
+	if (vcpu->mmio_is_write)
+		memcpy(vcpu->mmio_data, &p->data, p->size);
+	memcpy(kvm_run->mmio.data, &p->data, p->size);
+	kvm_run->exit_reason =3D KVM_EXIT_MMIO;
+	return 0;
+mmio:
+	mmio_dev =3D vcpu_find_mmio_dev(vcpu, p->addr);
+	if (mmio_dev) {
+		if (!p->dir)
+			kvm_iodevice_write(mmio_dev, p->addr, p->size,
+						&p->data);
+		else
+			kvm_iodevice_read(mmio_dev, p->addr, p->size,
+						&p->data);
+
+	} else
+		printk(KERN_ERR"kvm: No iodevice found !\n");
+	p->state =3D STATE_IORESP_READY;
+
+	return 1;
+}
+
+static int handle_pal_call(struct kvm_vcpu *vcpu, struct kvm_run
*kvm_run)
+{
+	struct exit_ctl_data *p;
+
+	p =3D kvm_get_exit_data(vcpu);
+
+	if (p->exit_reason =3D=3D EXIT_REASON_PAL_CALL)
+		return kvm_pal_emul(vcpu, kvm_run);
+	else {
+		kvm_run->exit_reason =3D KVM_EXIT_UNKNOWN;
+		kvm_run->hw.hardware_exit_reason =3D 2;
+		return 0;
+	}
+}
+
+static int handle_sal_call(struct kvm_vcpu *vcpu, struct kvm_run
*kvm_run)
+{
+	struct exit_ctl_data *p;
+
+	p =3D kvm_get_exit_data(vcpu);
+
+	if (p->exit_reason =3D=3D EXIT_REASON_SAL_CALL) {
+		kvm_sal_emul(vcpu);
+		return 1;
+	} else {
+		kvm_run->exit_reason =3D KVM_EXIT_UNKNOWN;
+		kvm_run->hw.hardware_exit_reason =3D 3;
+		return 0;
+	}
+
+}
+
+/*
+ *  offset: address offset to IPI space.
+ *  value:  deliver value.
+ */
+static void vcpu_deliver_ipi(struct kvm_vcpu *vcpu, uint64_t dm,
+				uint64_t vector)
+{
+	switch (dm) {
+	case SAPIC_FIXED:
+		kvm_apic_set_irq(vcpu, vector, 0);
+		break;
+	case SAPIC_NMI:
+		kvm_apic_set_irq(vcpu, 2, 0);
+		break;
+	case SAPIC_EXTINT:
+		kvm_apic_set_irq(vcpu, 0, 0);
+		break;
+	case SAPIC_INIT:
+	case SAPIC_PMI:
+	default:
+		printk(KERN_ERR"kvm:Unimplemented Deliver reserved
IPI!\n");
+		break;
+	}
+}
+
+static struct kvm_vcpu *lid_to_vcpu(struct kvm *kvm, unsigned long id,
+			unsigned long eid)
+{
+	ia64_lid_t lid;
+	int i;
+
+	for (i =3D 0; i < KVM_MAX_VCPUS; i++) {
+		if (kvm->vcpus[i]) {
+			lid.val =3D VCPU_LID(kvm->vcpus[i]);
+			if (lid.id =3D=3D id && lid.eid =3D=3D eid)
+				return kvm->vcpus[i];
+		}
+	}
+
+	return NULL;
+}
+
+static int handle_ipi(struct kvm_vcpu *vcpu, struct kvm_run *kvm_run)
+{
+	struct exit_ctl_data *p =3D kvm_get_exit_data(vcpu);
+	struct kvm_vcpu *target_vcpu;
+	struct kvm_pt_regs *regs;
+	ia64_ipi_a addr =3D p->u.ipi_data.addr;
+	ia64_ipi_d data =3D p->u.ipi_data.data;
+
+	target_vcpu =3D lid_to_vcpu(vcpu->kvm, addr.id, addr.eid);
+	if (!target_vcpu)
+		return handle_vm_error(vcpu, kvm_run);
+
+	if (!target_vcpu->arch.launched) {
+		regs =3D vcpu_regs(target_vcpu);
+
+		regs->cr_iip =3D vcpu->kvm->arch.rdv_sal_data.boot_ip;
+		regs->r1 =3D vcpu->kvm->arch.rdv_sal_data.boot_gp;
+
+		target_vcpu->arch.mp_state =3D VCPU_MP_STATE_RUNNABLE;
+		if (waitqueue_active(&target_vcpu->wq))
+			wake_up_interruptible(&target_vcpu->wq);
+	} else {
+		vcpu_deliver_ipi(target_vcpu, data.dm, data.vector);
+		if (target_vcpu !=3D vcpu)
+			kvm_vcpu_kick(target_vcpu);
+	}
+
+	return 1;
+}
+
+struct call_data {
+	struct kvm_ptc_g ptc_g_data;
+	struct kvm_vcpu *vcpu;
+};
+
+static void vcpu_global_purge(void *info)
+{
+	struct call_data *p =3D (struct call_data *)info;
+	struct kvm_vcpu *vcpu =3D p->vcpu;
+
+	if (test_bit(KVM_REQ_FLUSH_ALL, &vcpu->requests))
+		return;
+
+	set_bit(KVM_REQ_PTC_G, &vcpu->requests);
+	if (vcpu->arch.ptc_g_count < MAX_PTC_G_NUM) {
+		vcpu->arch.ptc_g_data[vcpu->arch.ptc_g_count++] =3D
+							p->ptc_g_data;
+	} else {
+		clear_bit(KVM_REQ_PTC_G, &vcpu->requests);
+		vcpu->arch.ptc_g_count =3D 0;
+		set_bit(KVM_REQ_FLUSH_ALL, &vcpu->requests);
+	}
+}
+
+static int handle_global_purge(struct kvm_vcpu *vcpu, struct kvm_run
*kvm_run)
+{
+	struct exit_ctl_data *p =3D kvm_get_exit_data(vcpu);
+	struct kvm *kvm =3D vcpu->kvm;
+	struct call_data call_data;
+	int i;
+	call_data.ptc_g_data =3D p->u.ptc_g_data;
+
+	for (i =3D 0; i < KVM_MAX_VCPUS; i++) {
+		if (!kvm->vcpus[i] || kvm->vcpus[i]->arch.mp_state =3D=3D
+
VCPU_MP_STATE_UNINITIALIZED ||
+					vcpu =3D=3D kvm->vcpus[i])
+			continue;
+
+		if (waitqueue_active(&kvm->vcpus[i]->wq)) {
+			wake_up_interruptible(&kvm->vcpus[i]->wq);
+		}
+
+		if (kvm->vcpus[i]->cpu !=3D -1) {
+			call_data.vcpu =3D kvm->vcpus[i];
+			smp_call_function_single(kvm->vcpus[i]->cpu,
+					vcpu_global_purge, &call_data,
0, 1);
+		} else
+			printk(KERN_WARNING"kvm: Uninit vcpu received
ipi!\n");
+
+	}
+	return 1;
+}
+
+static int handle_switch_rr6(struct kvm_vcpu *vcpu, struct kvm_run
*kvm_run)
+{
+	return 1;
+}
+
+int kvm_emulate_halt(struct kvm_vcpu *vcpu)
+{
+
+	ktime_t kt;
+	long itc_diff;
+	unsigned long vcpu_now_itc;
+
+	unsigned long expires;
+	struct hrtimer *p_ht =3D &vcpu->arch.hlt_timer;
+	unsigned long cyc_per_usec =3D local_cpu_data->cyc_per_usec;
+	struct vpd *vpd =3D to_host(vcpu->kvm, vcpu->arch.vpd);
+
+	vcpu_now_itc =3D ia64_get_itc() + vcpu->arch.itc_offset;
+
+	if (time_after(vcpu_now_itc, vpd->itm)) {
+		vcpu->arch.timer_check =3D 1;
+		return 1;
+	}
+	itc_diff =3D vpd->itm - vcpu_now_itc;
+	if (itc_diff < 0)
+		itc_diff =3D -itc_diff;
+
+	expires =3D div64_64(itc_diff, cyc_per_usec);
+	kt =3D ktime_set(0, 1000 * expires);
+	vcpu->arch.ht_active =3D 1;
+	hrtimer_start(p_ht, kt, HRTIMER_MODE_ABS);
+
+	if (irqchip_in_kernel(vcpu->kvm)) {
+		vcpu->arch.mp_state =3D VCPU_MP_STATE_HALTED;
+		kvm_vcpu_block(vcpu);
+		hrtimer_cancel(p_ht);
+		vcpu->arch.ht_active =3D 0;
+
+		if (vcpu->arch.mp_state !=3D VCPU_MP_STATE_RUNNABLE)
+			return -EINTR;
+		return 1;
+	} else {
+		printk(KERN_ERR"kvm: Unsupported userspace halt!");
+		return 0;
+	}
+}
+
+static int handle_vm_shutdown(struct kvm_vcpu *vcpu,
+		struct kvm_run *kvm_run)
+{
+	kvm_run->exit_reason =3D KVM_EXIT_SHUTDOWN;
+	return 0;
+}
+
+static int handle_external_interrupt(struct kvm_vcpu *vcpu,
+		struct kvm_run *kvm_run)
+{
+	return 1;
+}
+
+static int (*kvm_vti_exit_handlers[])(struct kvm_vcpu *vcpu,
+		struct kvm_run *kvm_run) =3D {
+	[EXIT_REASON_VM_PANIC]              =3D handle_vm_error,
+	[EXIT_REASON_MMIO_INSTRUCTION]      =3D handle_mmio,
+	[EXIT_REASON_PAL_CALL]              =3D handle_pal_call,
+	[EXIT_REASON_SAL_CALL]              =3D handle_sal_call,
+	[EXIT_REASON_SWITCH_RR6]            =3D handle_switch_rr6,
+	[EXIT_REASON_VM_DESTROY]            =3D handle_vm_shutdown,
+	[EXIT_REASON_EXTERNAL_INTERRUPT]    =3D handle_external_interrupt,
+	[EXIT_REASON_IPI]		    =3D handle_ipi,
+	[EXIT_REASON_PTC_G]		    =3D handle_global_purge,
+
+};
+
+static const int kvm_vti_max_exit_handlers =3D
+
sizeof(kvm_vti_exit_handlers)/sizeof(*kvm_vti_exit_handlers);
+
+static void kvm_prepare_guest_switch(struct kvm_vcpu *vcpu)
+{
+}
+
+static uint32_t kvm_get_exit_reason(struct kvm_vcpu *vcpu)
+{
+	struct exit_ctl_data *p_exit_data;
+
+	p_exit_data =3D kvm_get_exit_data(vcpu);
+	return p_exit_data->exit_reason;
+}
+
+/*
+ * The guest has exited.  See if we can fix it or if we need userspace
+ * assistance.
+ */
+static int kvm_handle_exit(struct kvm_run *kvm_run, struct kvm_vcpu
*vcpu)
+{
+	u32 exit_reason =3D kvm_get_exit_reason(vcpu);
+	vcpu->arch.last_exit =3D exit_reason;
+
+	if (exit_reason < kvm_vti_max_exit_handlers
+			&& kvm_vti_exit_handlers[exit_reason])
+		return kvm_vti_exit_handlers[exit_reason](vcpu,
kvm_run);
+	else {
+		kvm_run->exit_reason =3D KVM_EXIT_UNKNOWN;
+		kvm_run->hw.hardware_exit_reason =3D exit_reason;
+	}
+	return 0;
+}
+
+static inline void vti_set_rr6(unsigned long rr6)
+{
+	ia64_set_rr(RR6, rr6);
+	ia64_srlz_i();
+}
+
+/*Ensure no TR entries in slot 6 and slot 7 before getting called.*/
+static void kvm_insert_vmm_mapping(struct kvm_vcpu *vcpu)
+{
+	unsigned long pte;
+	struct kvm *kvm =3D vcpu->kvm;
+
+	/*Insert a pair of tr to map vmm*/
+	pte =3D pte_val(mk_pte_phys(__pa(kvm_vmm_base), PAGE_KERNEL));
+	ia64_itr_entry(0x3, KVM_VMM_BASE, pte, KVM_VMM_SHIFT);
+
+	/*Insert a pairt of tr to map data of vm*/
+	pte =3D pte_val(mk_pte_phys(__pa(kvm->arch.vm_base),
PAGE_KERNEL));
+	ia64_itr_entry(0x3, KVM_VM_DATA_BASE,
+					pte, KVM_VM_DATA_SHIFT);
+
+}
+
+static void kvm_purge_vmm_mapping(void)
+{
+
+	unsigned long ps;
+
+	/*Purge itr and dtr in slot 6.*/
+	ps =3D KVM_VMM_SHIFT;
+	ia64_ptr_entry(0x3, KVM_VMM_BASE, ps);
+
+	/*Purge itr and dtr in slot 7.*/
+	ps =3D KVM_VM_DATA_SHIFT;
+	ia64_ptr_entry(0x3, KVM_VM_DATA_BASE, ps);
+
+}
+
+static void kvm_vcpu_pre_transition(struct kvm_vcpu *vcpu)
+{
+	int cpu =3D smp_processor_id();
+
+	if (vcpu->arch.last_run_cpu !=3D cpu ||
+			per_cpu(last_vcpu, cpu) !=3D vcpu) {
+		per_cpu(last_vcpu, cpu) =3D vcpu;
+		vcpu->arch.last_run_cpu =3D cpu;
+		kvm_flush_tlb_all();
+	}
+
+	vcpu->arch.host_rr6 =3D ia64_get_rr(RR6);
+	vti_set_rr6(vcpu->arch.vmm_rr);
+	kvm_insert_vmm_mapping(vcpu);
+}
+static void kvm_vcpu_post_transition(struct kvm_vcpu *vcpu)
+{
+	kvm_purge_vmm_mapping();
+	vti_set_rr6(vcpu->arch.host_rr6);
+}
+
+void vti_vcpu_run(struct kvm_vcpu *vcpu, struct kvm_run *kvm_run)
+{
+	context_t *host_ctx, *guest_ctx;
+
+	/*Get host and guest context with guest address space.*/
+	host_ctx =3D kvm_get_host_context(vcpu);
+	guest_ctx =3D kvm_get_guest_context(vcpu);
+
+	kvm_vcpu_pre_transition(vcpu);
+	kvm_vmm_info->tramp_entry(host_ctx, guest_ctx);
+	kvm_vcpu_post_transition(vcpu);
+}
+
+static int __vcpu_run(struct kvm_vcpu *vcpu, struct kvm_run *kvm_run)
+{
+	int r;
+
+again:
+	preempt_disable();
+
+	kvm_prepare_guest_switch(vcpu);
+	local_irq_disable();
+
+	if (signal_pending(current)) {
+		local_irq_enable();
+		preempt_enable();
+		r =3D -EINTR;
+		kvm_run->exit_reason =3D KVM_EXIT_INTR;
+		goto out;
+	}
+
+	vcpu->guest_mode =3D 1;
+	kvm_guest_enter();
+
+	vti_vcpu_run(vcpu, kvm_run);
+
+	vcpu->arch.launched =3D 1;
+	vcpu->guest_mode =3D 0;
+	local_irq_enable();
+
+	/*
+	 * We must have an instruction between local_irq_enable() and
+	 * kvm_guest_exit(), so the timer interrupt isn't delayed by
+	 * the interrupt shadow.  The stat.exits increment will do
nicely.
+	 * But we need to prevent reordering, hence this barrier():
+	 */
+	barrier();
+
+	kvm_guest_exit();
+
+	preempt_enable();
+
+	r =3D kvm_handle_exit(kvm_run, vcpu);
+
+	if (r > 0) {
+		if (!need_resched())
+			goto again;
+	}
+
+out:
+	if (r > 0) {
+		kvm_resched(vcpu);
+		goto again;
+	}
+
+	return r;
+}
+
+static void kvm_set_mmio_data(struct kvm_vcpu *vcpu)
+{
+	ioreq_t *p =3D kvm_get_vcpu_ioreq(vcpu);
+	if (!vcpu->mmio_is_write)
+		memcpy(&p->data, vcpu->mmio_data, 8);
+	p->state =3D STATE_IORESP_READY;
+}
+
+int kvm_arch_vcpu_ioctl_run(struct kvm_vcpu *vcpu, struct kvm_run
*kvm_run)
+{
+	int r;
+	sigset_t sigsaved;
+
+	vcpu_load(vcpu);
+
+	if (unlikely(vcpu->arch.mp_state =3D=3D
VCPU_MP_STATE_UNINITIALIZED)) {
+		kvm_vcpu_block(vcpu);
+		vcpu_put(vcpu);
+		return -EAGAIN;
+	}
+
+	if (vcpu->sigset_active)
+		sigprocmask(SIG_SETMASK, &vcpu->sigset, &sigsaved);
+
+	if (vcpu->mmio_needed) {
+		memcpy(vcpu->mmio_data, kvm_run->mmio.data, 8);
+		kvm_set_mmio_data(vcpu);
+		vcpu->mmio_read_completed =3D 1;
+		vcpu->mmio_needed =3D 0;
+	}
+	r =3D __vcpu_run(vcpu, kvm_run);
+
+	if (vcpu->sigset_active)
+		sigprocmask(SIG_SETMASK, &sigsaved, NULL);
+
+	vcpu_put(vcpu);
+	return r;
+}
+
+/*
+ * Allocate 16M memory for every vm to hold its specific data.
+ * Its memory map is defined in kvm_host.h.
+ */
+static struct kvm *kvm_alloc_kvm(void)
+{
+
+	struct kvm *kvm;
+	uint64_t  vm_base;
+
+	vm_base =3D __get_free_pages(GFP_KERNEL,
get_order(KVM_VM_DATA_SIZE));
+
+	if (!vm_base)
+		return ERR_PTR(-ENOMEM);
+	printk(KERN_DEBUG"kvm:vm data base address:0x%lx\n", vm_base);
+
+	/* Zero all pages before use! */
+	memset((void *)vm_base, 0, KVM_VM_DATA_SIZE);
+
+	kvm =3D (struct kvm *)(vm_base + KVM_VM_OFS);
+	kvm->arch.vm_base =3D vm_base;
+
+	return kvm;
+}
+
+typedef struct kvm_io_range {
+	unsigned long start;
+	unsigned long size;
+	unsigned long type;
+} kvm_io_range_t;
+
+static const kvm_io_range_t io_ranges[] =3D {
+	{VGA_IO_START, VGA_IO_SIZE, GPFN_FRAME_BUFFER},
+	{MMIO_START, MMIO_SIZE, GPFN_LOW_MMIO},
+	{LEGACY_IO_START, LEGACY_IO_SIZE, GPFN_LEGACY_IO},
+	{IO_SAPIC_START, IO_SAPIC_SIZE, GPFN_IOSAPIC},
+	{PIB_START, PIB_SIZE, GPFN_PIB},
+};
+
+static void kvm_build_io_pmt(struct kvm *kvm)
+{
+	unsigned long i, j;
+
+	/* Mark I/O ranges */
+	for (i =3D 0; i < (sizeof(io_ranges) / sizeof(kvm_io_range_t));
i++) {
+		for (j =3D io_ranges[i].start;
+				j < io_ranges[i].start +
io_ranges[i].size;
+				j +=3D PAGE_SIZE)
+			kvm_set_pmt_entry(kvm, j >> PAGE_SHIFT,
+					io_ranges[i].type, 0);
+	}
+
+}
+
+/*Use unused rids to virtualize guest rid.*/
+#define GUEST_PHYSICAL_RR0	0x1739
+#define GUEST_PHYSICAL_RR4	0x2739
+#define VMM_INIT_RR		0x1660
+
+static void kvm_init_vm(struct kvm *kvm)
+{
+	long vm_base;
+
+	BUG_ON(!kvm);
+
+	kvm->arch.metaphysical_rr0 =3D GUEST_PHYSICAL_RR0;
+	kvm->arch.metaphysical_rr4 =3D GUEST_PHYSICAL_RR4;
+	kvm->arch.vmm_init_rr =3D VMM_INIT_RR;
+
+	vm_base =3D kvm->arch.vm_base;
+	if (vm_base) {
+		kvm->arch.vhpt_base =3D vm_base + KVM_VHPT_OFS;
+		kvm->arch.vtlb_base =3D vm_base + KVM_VTLB_OFS;
+		kvm->arch.vpd_base  =3D vm_base + KVM_VPD_OFS;
+	}
+
+	/*
+	 *Fill P2M entries for MMIO/IO ranges
+	 */
+	kvm_build_io_pmt(kvm);
+
+}
+
+struct  kvm *kvm_arch_create_vm(void)
+{
+	struct kvm *kvm =3D kvm_alloc_kvm();
+
+	if (IS_ERR(kvm))
+		return ERR_PTR(-ENOMEM);
+	kvm_init_vm(kvm);
+
+	return kvm;
+
+}
+
+static int kvm_vm_ioctl_get_irqchip(struct kvm *kvm,
+					struct kvm_irqchip *chip)
+{
+	int r;
+
+	r =3D 0;
+	switch (chip->chip_id) {
+	case KVM_IRQCHIP_IOAPIC:
+		memcpy(&chip->chip.ioapic, ioapic_irqchip(kvm),
+				sizeof(struct kvm_ioapic_state));
+		break;
+	default:
+		r =3D -EINVAL;
+		break;
+	}
+	return r;
+}
+
+static int kvm_vm_ioctl_set_irqchip(struct kvm *kvm, struct kvm_irqchip
*chip)
+{
+	int r;
+
+	r =3D 0;
+	switch (chip->chip_id) {
+	case KVM_IRQCHIP_IOAPIC:
+		memcpy(ioapic_irqchip(kvm),
+				&chip->chip.ioapic,
+				sizeof(struct kvm_ioapic_state));
+		break;
+	default:
+		r =3D -EINVAL;
+		break;
+	}
+	return r;
+}
+
+int kvm_arch_vcpu_ioctl_set_regs(struct kvm_vcpu *vcpu, struct kvm_regs
*regs)
+{
+	printk(KERN_WARNING"Doesn't support it yet!!\n");
+	return 0;
+}
+
+long kvm_arch_vm_ioctl(struct file *filp,
+		unsigned int ioctl, unsigned long arg)
+{
+	struct kvm *kvm =3D filp->private_data;
+	void __user *argp =3D (void __user *)arg;
+	int r =3D -EINVAL;
+
+	switch (ioctl) {
+	case KVM_SET_MEMORY_REGION: {
+		struct kvm_memory_region kvm_mem;
+		struct kvm_userspace_memory_region kvm_userspace_mem;
+
+		r =3D -EFAULT;
+		if (copy_from_user(&kvm_mem, argp, sizeof kvm_mem))
+			goto out;
+		kvm_userspace_mem.slot =3D kvm_mem.slot;
+		kvm_userspace_mem.flags =3D kvm_mem.flags;
+		kvm_userspace_mem.guest_phys_addr =3D
+					kvm_mem.guest_phys_addr;
+		kvm_userspace_mem.memory_size =3D kvm_mem.memory_size;
+		r =3D kvm_vm_ioctl_set_memory_region(kvm,
+					&kvm_userspace_mem, 0);
+		if (r)
+			goto out;
+		break;
+		}
+	case KVM_CREATE_IRQCHIP:
+		r =3D -EFAULT;
+		r =3D kvm_ioapic_init(kvm);
+		if (r)
+			goto out;
+		break;
+	case KVM_IRQ_LINE: {
+		struct kvm_irq_level irq_event;
+
+		r =3D -EFAULT;
+		if (copy_from_user(&irq_event, argp, sizeof irq_event))
+			goto out;
+		if (irqchip_in_kernel(kvm)) {
+			mutex_lock(&kvm->lock);
+			kvm_ioapic_set_irq(kvm->arch.vioapic,
+						irq_event.irq,
+						irq_event.level);
+			mutex_unlock(&kvm->lock);
+			r =3D 0;
+		}
+		break;
+		}
+	case KVM_GET_IRQCHIP: {
+		/* 0: PIC master, 1: PIC slave, 2: IOAPIC */
+		struct kvm_irqchip chip;
+
+		r =3D -EFAULT;
+		if (copy_from_user(&chip, argp, sizeof chip))
+				goto out;
+		r =3D -ENXIO;
+		if (!irqchip_in_kernel(kvm))
+			goto out;
+		r =3D kvm_vm_ioctl_get_irqchip(kvm, &chip);
+		if (r)
+			goto out;
+		r =3D -EFAULT;
+		if (copy_to_user(argp, &chip, sizeof chip))
+				goto out;
+		r =3D 0;
+		break;
+		}
+	case KVM_SET_IRQCHIP: {
+		/* 0: PIC master, 1: PIC slave, 2: IOAPIC */
+		struct kvm_irqchip chip;
+
+		r =3D -EFAULT;
+		if (copy_from_user(&chip, argp, sizeof chip))
+				goto out;
+		r =3D -ENXIO;
+		if (!irqchip_in_kernel(kvm))
+			goto out;
+		r =3D kvm_vm_ioctl_set_irqchip(kvm, &chip);
+		if (r)
+			goto out;
+		r =3D 0;
+		break;
+		}
+	default:
+		;
+	}
+out:
+	return r;
+}
+
+int kvm_arch_vcpu_ioctl_set_sregs(struct kvm_vcpu *vcpu,
+		struct kvm_sregs *sregs)
+{
+	printk(KERN_WARNING"kvm:kvm_arch_vcpu_ioctl_set_sregs
called!!\n");
+	return 0;
+}
+
+int kvm_arch_vcpu_ioctl_get_sregs(struct kvm_vcpu *vcpu,
+		struct kvm_sregs *sregs)
+{
+	printk(KERN_WARNING"kvm:kvm_arch_vcpu_ioctl_get_sregs
called!!\n");
+	return 0;
+
+}
+int kvm_arch_vcpu_ioctl_translate(struct kvm_vcpu *vcpu,
+		struct kvm_translation *tr)
+{
+	printk(KERN_WARNING"kvm:kvm_arch_vcpu_ioctl_translate
called!!\n");
+
+	return 0;
+}
+
+static int kvm_alloc_vmm_area(void)
+{
+	if (!kvm_vmm_base && (kvm_vm_buffer_size < KVM_VM_BUFFER_SIZE))
{
+		kvm_vmm_base =3D __get_free_pages(GFP_KERNEL,
+				get_order(KVM_VMM_SIZE));
+		if (!kvm_vmm_base)
+			return -ENOMEM;
+
+		memset((void *)kvm_vmm_base, 0, KVM_VMM_SIZE);
+		kvm_vm_buffer =3D kvm_vmm_base + VMM_SIZE;
+
+		printk(KERN_DEBUG"kvm:kvm_vmm_base:0x%lx,
vm_buffer:0x%lx\n",
+				kvm_vmm_base, kvm_vm_buffer);
+	}
+
+	return 0;
+}
+
+static void kvm_free_vmm_area(void)
+{
+	if (kvm_vmm_base) {
+		/*Zero this area before free to avoid bits leak!!*/
+		memset((void *)kvm_vmm_base, 0, KVM_VMM_SIZE);
+		free_pages(kvm_vmm_base, get_order(KVM_VMM_SIZE));
+		kvm_vmm_base  =3D 0;
+		kvm_vm_buffer =3D 0;
+		kvm_vsa_base =3D 0;
+	}
+}
+
+/*
+ * Make sure that a cpu that is being hot-unplugged does not have any
vcpus
+ * cached on it. Leave it as blank for IA64.
+ */
+void decache_vcpus_on_cpu(int cpu)
+{
+}
+
+static void vti_vcpu_load(struct kvm_vcpu *vcpu, int cpu)
+{
+}
+
+static int vti_init_vpd(struct kvm_vcpu *vcpu)
+{
+	int i;
+	cpuid3_t cpuid3;
+	struct vpd *vpd =3D to_host(vcpu->kvm, vcpu->arch.vpd);
+
+	if (IS_ERR(vpd))
+		return PTR_ERR(vpd);
+
+	/* CPUID init */
+	for (i =3D 0; i < 5; i++)
+		vpd->vcpuid[i] =3D ia64_get_cpuid(i);
+
+	/* Limit the CPUID number to 5 */
+	cpuid3.value =3D vpd->vcpuid[3];
+	cpuid3.number =3D 4;	/* 5 - 1 */
+	vpd->vcpuid[3] =3D cpuid3.value;
+
+	/*Set vac and vdc fields*/
+	vpd->vac.a_from_int_cr =3D 1;
+	vpd->vac.a_to_int_cr =3D 1;
+	vpd->vac.a_from_psr =3D 1;
+	vpd->vac.a_from_cpuid =3D 1;
+	vpd->vac.a_cover =3D 1;
+	vpd->vac.a_bsw =3D 1;
+	vpd->vac.a_int =3D 1;
+	vpd->vdc.d_vmsw =3D 1;
+
+	/*Set virtual buffer*/
+	vpd->virt_env_vaddr =3D KVM_VM_BUFFER_BASE;
+
+	return 0;
+}
+
+static int vti_create_vp(struct kvm_vcpu *vcpu)
+{
+	long ret;
+	vpd_t *vpd =3D vcpu->arch.vpd;
+	unsigned long  vmm_ivt;
+
+	vmm_ivt =3D kvm_vmm_info->vmm_ivt;
+
+	printk(KERN_DEBUG "kvm: vcpu:%p,ivt: 0x%lx\n", vcpu, vmm_ivt);
+
+	ret =3D ia64_pal_vp_create((u64 *)vpd, (u64 *)vmm_ivt, 0);
+
+	if (ret) {
+		printk(KERN_ERR"kvm: ia64_pal_vp_create failed!\n");
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static void init_ptce_info(struct kvm_vcpu *vcpu)
+{
+	ia64_ptce_info_t ptce =3D {0};
+
+	ia64_get_ptce(&ptce);
+	vcpu->arch.ptce_base =3D ptce.base;
+	vcpu->arch.ptce_count[0] =3D ptce.count[0];
+	vcpu->arch.ptce_count[1] =3D ptce.count[1];
+	vcpu->arch.ptce_stride[0] =3D ptce.stride[0];
+	vcpu->arch.ptce_stride[1] =3D ptce.stride[1];
+}
+
+static int kvm_migrate_hlt_timer(struct kvm_vcpu *vcpu)
+{
+	struct hrtimer *p_ht =3D &vcpu->arch.hlt_timer;
+
+	if (hrtimer_cancel(p_ht))
+		hrtimer_start(p_ht, p_ht->expires, HRTIMER_MODE_ABS);
+}
+
+static enum hrtimer_restart hlt_timer_fn(struct hrtimer *data)
+{
+	struct kvm_vcpu *vcpu;
+	wait_queue_head_t *q;
+
+	vcpu  =3D container_of(data, struct kvm_vcpu, arch.hlt_timer);
+	if (vcpu->arch.mp_state !=3D VCPU_MP_STATE_HALTED)
+		goto out;
+
+	q =3D &vcpu->wq;
+	if (waitqueue_active(q)) {
+		vcpu->arch.mp_state =3D VCPU_MP_STATE_RUNNABLE;
+		wake_up_interruptible(q);
+	}
+out:
+	vcpu->arch.timer_check =3D 1;
+	return HRTIMER_NORESTART;
+}
+
+#define PALE_RESET_ENTRY    0x80000000ffffffb0UL
+
+int kvm_arch_vcpu_init(struct kvm_vcpu *vcpu)
+{
+	struct page *page;
+	int r;
+	struct kvm *kvm =3D vcpu->kvm;
+	struct kvm_pt_regs *regs =3D vcpu_regs(vcpu);
+
+	context_t *p_ctx =3D &vcpu->arch.guest;
+	struct kvm_vcpu *vmm_vcpu =3D to_guest(vcpu->kvm, vcpu);
+
+	/*Init vcpu context for first run.*/
+	if (IS_ERR(vmm_vcpu))
+		return PTR_ERR(vmm_vcpu);
+
+	page =3D alloc_page(GFP_KERNEL | __GFP_ZERO);
+	if (!page) {
+		r =3D -ENOMEM;
+		goto fail;
+	}
+
+	if (vcpu->vcpu_id =3D=3D 0) {
+		vcpu->arch.mp_state =3D VCPU_MP_STATE_RUNNABLE;
+		regs->cr_iip =3D PALE_RESET_ENTRY;
+	}
+
+	else
+		vcpu->arch.mp_state =3D VCPU_MP_STATE_UNINITIALIZED;
+	/*FIXME:Need to removed it later!!\n*/
+	vcpu->arch.apic =3D kzalloc(sizeof(struct kvm_lapic), GFP_KERNEL);
+	vcpu->arch.apic->vcpu =3D vcpu;
+
+	p_ctx->gr[1] =3D 0;
+	p_ctx->gr[12] =3D (unsigned long)((char *)vmm_vcpu +
IA64_STK_OFFSET);
+	p_ctx->gr[13] =3D (unsigned long)vmm_vcpu;
+	p_ctx->psr =3D 0x1008522000UL;
+	p_ctx->ar[40] =3D FPSR_DEFAULT; /*fpsr*/
+	p_ctx->caller_unat =3D 0;
+	p_ctx->pr =3D 0x0;
+	p_ctx->ar[36] =3D 0x0; /*unat*/
+	p_ctx->ar[19] =3D 0x0; /*rnat*/
+	p_ctx->ar[18] =3D (unsigned long)vmm_vcpu +
+				((sizeof(struct kvm_vcpu)+15) & ~15);
+	p_ctx->ar[64] =3D 0x0; /*pfs*/
+	p_ctx->cr[0] =3D 0x7e04UL;
+	p_ctx->cr[2] =3D (unsigned long)kvm_vmm_info->vmm_ivt;
+	p_ctx->cr[8] =3D 0x3c;
+
+	/*Initilize region register*/
+	p_ctx->rr[0] =3D 0x30;
+	p_ctx->rr[1] =3D 0x30;
+	p_ctx->rr[2] =3D 0x30;
+	p_ctx->rr[3] =3D 0x30;
+	p_ctx->rr[4] =3D 0x30;
+	p_ctx->rr[5] =3D 0x30;
+	p_ctx->rr[7] =3D 0x30;
+
+	/*Initilize branch register 0*/
+	p_ctx->br[0] =3D *(unsigned long *)kvm_vmm_info->vmm_entry;
+
+	vcpu->arch.vmm_rr =3D kvm->arch.vmm_init_rr;
+	vcpu->arch.metaphysical_rr0 =3D kvm->arch.metaphysical_rr0;
+	vcpu->arch.metaphysical_rr4 =3D kvm->arch.metaphysical_rr4;
+
+	hrtimer_init(&vcpu->arch.hlt_timer, CLOCK_MONOTONIC,
HRTIMER_MODE_ABS);
+	vcpu->arch.hlt_timer.function =3D hlt_timer_fn;
+
+	vcpu->arch.vpd =3D (vpd_t *)VPD_ADDR(vcpu->vcpu_id);
+	vcpu->arch.vsa_base =3D kvm_vsa_base;
+	vcpu->arch.__gp =3D kvm_vmm_gp;
+	vcpu->arch.vhpt.hash =3D (thash_data_t *)VHPT_ADDR(vcpu->vcpu_id);
+	vcpu->arch.vtlb.hash =3D (thash_data_t *)VTLB_ADDR(vcpu->vcpu_id);
+	init_ptce_info(vcpu);
+
+	return 0;
+fail:
+	return r;
+}
+
+static int vti_vcpu_setup(struct kvm_vcpu *vcpu, int id)
+{
+	unsigned long psr;
+	int r;
+
+	local_irq_save(psr);
+	kvm_insert_vmm_mapping(vcpu);
+
+	r =3D kvm_vcpu_init(vcpu, vcpu->kvm, id);
+	if (r)
+		goto fail;
+
+	r =3D vti_init_vpd(vcpu);
+	if (r) {
+		printk(KERN_DEBUG"kvm: vpd init error!!\n");
+		goto uninit;
+	}
+
+	r =3D vti_create_vp(vcpu);
+	if (r)
+		goto uninit;
+
+	kvm_purge_vmm_mapping();
+	local_irq_restore(psr);
+
+	return 0;
+uninit:
+	kvm_vcpu_uninit(vcpu);
+fail:
+	return r;
+}
+
+struct kvm_vcpu *kvm_arch_vcpu_create(struct kvm *kvm,
+		unsigned int id)
+{
+	struct kvm_vcpu *vcpu;
+	unsigned long vm_base =3D kvm->arch.vm_base;
+	int r;
+	int cpu;
+
+	r =3D -ENOMEM;
+	if (!vm_base) {
+		printk(KERN_ERR"kvm: Create vcpu[%d] error!\n", id);
+		goto fail;
+	}
+	vcpu =3D (struct kvm_vcpu *)(vm_base + KVM_VCPU_OFS + VCPU_SIZE *
id);
+	vcpu->kvm =3D kvm;
+
+	cpu =3D get_cpu();
+	vti_vcpu_load(vcpu, cpu);
+	r =3D vti_vcpu_setup(vcpu, id);
+	put_cpu();
+
+	if (r) {
+		printk(KERN_DEBUG"kvm: vcpu_setup error!!\n");
+		goto fail;
+	}
+
+	return vcpu;
+fail:
+	return ERR_PTR(r);
+}
+
+int kvm_arch_vcpu_setup(struct kvm_vcpu *vcpu)
+{
+	return 0;
+}
+
+int kvm_arch_vcpu_ioctl_get_fpu(struct kvm_vcpu *vcpu, struct kvm_fpu
*fpu)
+{
+	printk(KERN_WARNING"kvm:IA64 doesn't need to export"
+			"fpu to userspace!\n");
+	return 0;
+}
+
+int kvm_arch_vcpu_ioctl_set_fpu(struct kvm_vcpu *vcpu, struct kvm_fpu
*fpu)
+{
+	printk(KERN_WARNING"kvm:IA64 doesn't need to export"
+					"fpu to userspace !\n");
+	return 0;
+}
+
+int kvm_arch_vcpu_ioctl_debug_guest(struct kvm_vcpu *vcpu,
+		struct kvm_debug_guest *dbg)
+{
+	printk(KERN_INFO"Not Implemented yet!\n");
+	return 0;
+}
+
+static void free_kvm(struct kvm *kvm)
+{
+	unsigned long vm_base =3D kvm->arch.vm_base;
+
+	if (vm_base) {
+		memset((void *)vm_base, 0, KVM_VM_DATA_SIZE);
+		free_pages(vm_base, get_order(KVM_VM_DATA_SIZE));
+	}
+
+}
+
+/*FIXME:Remove it once swapping ready!*/
+static void kvm_release_vm_pages(struct kvm *kvm)
+{
+	struct kvm_memory_slot *memslot;
+	int i, j;
+	unsigned long base_gfn;
+
+	for (i =3D 0; i < kvm->nmemslots; i++) {
+		memslot =3D &kvm->memslots[i];
+		base_gfn =3D memslot->base_gfn;
+
+		for (j =3D 0; j < memslot->npages; j++) {
+			if (memslot->rmap[j])
+				put_page((struct page
*)memslot->rmap[j]);
+		}
+	}
+}
+
+void kvm_arch_destroy_vm(struct kvm *kvm)
+{
+	kfree(kvm->arch.vioapic);
+	kvm_release_vm_pages(kvm);
+	kvm_free_physmem(kvm);
+	free_kvm(kvm);
+}
+
+void kvm_arch_vcpu_put(struct kvm_vcpu *vcpu)
+{
+	/*FIXME: To Implement!!*/
+}
+
+void kvm_arch_vcpu_load(struct kvm_vcpu *vcpu, int cpu)
+{
+	if (cpu !=3D vcpu->cpu) {
+		vcpu->cpu =3D cpu;
+		if (vcpu->arch.ht_active)
+			kvm_migrate_hlt_timer(vcpu);
+	}
+}
+
+int kvm_arch_vcpu_ioctl_get_regs(struct kvm_vcpu *vcpu, struct kvm_regs
*regs)
+{
+	printk(KERN_INFO"No need to implment on IA64!\n");
+	return 0;
+}
+
+void kvm_arch_vcpu_uninit(struct kvm_vcpu *vcpu)
+{
+
+	hrtimer_cancel(&vcpu->arch.hlt_timer);
+	kfree(vcpu->arch.apic);
+}
+
+
+long kvm_arch_vcpu_ioctl(struct file *filp,
+		unsigned int ioctl, unsigned long arg)
+{
+	return -EINVAL;
+}
+
+int kvm_arch_set_memory_region(struct kvm *kvm,
+		struct kvm_userspace_memory_region *mem,
+		struct kvm_memory_slot old,
+		int user_alloc)
+{
+	unsigned long i;
+	struct page *page;
+	int npages =3D mem->memory_size >> PAGE_SHIFT;
+	struct kvm_memory_slot *memslot =3D &kvm->memslots[mem->slot];
+	unsigned long base_gfn =3D memslot->base_gfn;
+
+	for (i =3D 0; i < npages; i++) {
+		page =3D gfn_to_page(kvm, base_gfn + i);
+		kvm_set_pmt_entry(kvm, base_gfn + i,
+				page_to_pfn(page) << PAGE_SHIFT,
+				_PAGE_AR_RWX|_PAGE_MA_WB);
+		memslot->rmap[i] =3D (unsigned long)page;
+	}
+
+	return 0;
+}
+
+
+long kvm_arch_dev_ioctl(struct file *filp,
+		unsigned int ioctl, unsigned long arg)
+{
+	return -EINVAL;
+}
+
+void kvm_arch_vcpu_destroy(struct kvm_vcpu *vcpu)
+{
+	kvm_vcpu_uninit(vcpu);
+}
+
+static int vti_cpu_has_kvm_support(void)
+{
+	long  avail =3D 1, status =3D 1, control =3D 1;
+	long ret;
+
+	ret =3D ia64_pal_proc_get_features(&avail, &status, &control, 0);
+	if (ret)
+		goto out;
+
+	if (!(avail & PAL_PROC_VM_BIT))
+		goto out;
+
+	printk(KERN_DEBUG"kvm: Hardware Supports VT\n");
+
+	ret =3D ia64_pal_vp_env_info(&kvm_vm_buffer_size, &vp_env_info);
+	if (ret)
+		goto out;
+	printk(KERN_DEBUG"kvm: vm buffer size:0x%lx\n",
kvm_vm_buffer_size);
+
+	if (!(vp_env_info & VP_OPCODE)) {
+		printk(KERN_WARNING"No opcode ability on hardware,\
+				vm_env_info:0x%lx\n",vp_env_info);
+	}
+
+	return 1;
+out:
+	return 0;
+}
+
+static int kvm_relocate_vmm(struct kvm_vmm_info *vmm_info,
+						struct module *module)
+{
+	unsigned long module_base;
+	unsigned long vmm_size;
+
+	unsigned long vmm_offset, func_offset, fdesc_offset;
+	struct fdesc *p_fdesc;
+
+	BUG_ON(!module);
+
+	if (!kvm_vmm_base) {
+		printk("kvm: kvm area didn't initilize yet!!\n");
+		return -EINVAL;
+	}
+
+	/*Calculate new position of relocated vmm module.*/
+	module_base =3D (unsigned long)module->module_core;
+	vmm_size =3D module->core_size;
+	if (unlikely(vmm_size > KVM_VMM_SIZE))
+		return -EFAULT;
+
+	memcpy((void *)kvm_vmm_base, (void *)module_base, vmm_size);
+	kvm_flush_icache(kvm_vmm_base, vmm_size);
+
+	/*Recalculate kvm_vmm_info based on new VMM*/
+	vmm_offset =3D vmm_info->vmm_ivt - module_base;
+	kvm_vmm_info->vmm_ivt =3D KVM_VMM_BASE + vmm_offset;
+	printk(KERN_DEBUG"kvm: Relocated VMM ivt base addr:%lx\n",
+			kvm_vmm_info->vmm_ivt);
+
+	fdesc_offset =3D (unsigned long)vmm_info->vmm_entry - module_base;
+	kvm_vmm_info->vmm_entry =3D (kvm_vmm_entry *)(KVM_VMM_BASE +
+							fdesc_offset);
+	func_offset =3D *(unsigned long *)vmm_info->vmm_entry -
module_base;
+	p_fdesc =3D (struct fdesc *)(kvm_vmm_base + fdesc_offset);
+	p_fdesc->ip =3D KVM_VMM_BASE + func_offset;
+	p_fdesc->gp =3D KVM_VMM_BASE+(p_fdesc->gp - module_base);
+
+	printk(KERN_DEBUG"Guest VMM init entry addr:%lx\n",
+			KVM_VMM_BASE+func_offset);
+
+	fdesc_offset =3D (unsigned long)vmm_info->tramp_entry -
module_base;
+	kvm_vmm_info->tramp_entry =3D (kvm_tramp_entry *)(KVM_VMM_BASE +
+			fdesc_offset);
+	func_offset =3D *(unsigned long *)vmm_info->tramp_entry -
module_base;
+	p_fdesc =3D (struct fdesc *)(kvm_vmm_base + fdesc_offset);
+	p_fdesc->ip =3D KVM_VMM_BASE + func_offset;
+	p_fdesc->gp =3D KVM_VMM_BASE + (p_fdesc->gp - module_base);
+
+	kvm_vmm_gp =3D p_fdesc->gp;
+
+	printk(KERN_DEBUG"kvm: vmm's fdesc:%p\n", p_fdesc);
+	printk(KERN_DEBUG"kvm: vmm_entry ip:%p\n",
kvm_vmm_info->vmm_entry);
+	printk(KERN_DEBUG"kvm: vmm trampoline entry ip:0x%lx\n",
+						KVM_VMM_BASE +
func_offset);
+
+	return 0;
+}
+
+int kvm_arch_init(void *opaque)
+{
+	int r;
+	struct kvm_vmm_info *vmm_info =3D (struct kvm_vmm_info *)opaque;
+
+	if (!vti_cpu_has_kvm_support()) {
+		printk(KERN_ERR "kvm: no hardware support\n");
+		r =3D -EOPNOTSUPP;
+		goto out;
+	}
+
+	if (kvm_vmm_info) {
+		printk(KERN_ERR "kvm: already loaded the other
module!\n");
+		r =3D -EEXIST;
+		goto out;
+	}
+
+	r =3D -ENOMEM;
+	kvm_vmm_info =3D kzalloc(sizeof(struct kvm_vmm_info), GFP_KERNEL);
+	if (!kvm_vmm_info)
+		goto out;
+
+	if (kvm_alloc_vmm_area())
+		goto out_free0;
+
+	r =3D kvm_relocate_vmm(vmm_info, vmm_info->module);
+	if (r)
+		goto out_free1;
+
+	return 0;
+
+out_free1:
+	kvm_free_vmm_area();
+out_free0:
+	kfree(kvm_vmm_info);
+out:
+	return r;
+}
+
+void kvm_arch_exit(void)
+{
+	kvm_free_vmm_area();
+	kfree(kvm_vmm_info);
+	kvm_vmm_info =3D NULL;
+}
+
+int kvm_vm_ioctl_get_dirty_log(struct kvm *kvm,
+		struct kvm_dirty_log *log)
+{
+	printk(KERN_WARNING"Need to implement later!\n");
+	return 0;
+}
+
+int kvm_arch_hardware_setup(void)
+{
+	return 0;
+}
+
+void kvm_arch_hardware_unsetup(void)
+{
+}
+
+static void vcpu_kick_intr(void *info)
+{
+#ifdef DEBUG
+	struct kvm_vcpu *vcpu =3D (struct kvm_vcpu *)info;
+	printk(KERN_DEBUG"vcpu_kick_intr %p \n", vcpu);
+#endif
+}
+
+void kvm_vcpu_kick(struct kvm_vcpu *vcpu)
+{
+	int ipi_pcpu =3D vcpu->cpu;
+
+	if (waitqueue_active(&vcpu->wq)) {
+		wake_up_interruptible(&vcpu->wq);
+	}
+	if (vcpu->guest_mode)
+		smp_call_function_single(ipi_pcpu, vcpu_kick_intr, vcpu,
0, 0);
+}
+
+int kvm_apic_set_irq(struct kvm_vcpu *vcpu, u8 vec, u8 trig)
+{
+
+	struct vpd *vpd =3D to_host(vcpu->kvm, vcpu->arch.vpd);
+
+	if (!test_and_set_bit(vec, &vpd->irr[0])) {
+		vcpu->arch.irq_new_pending =3D 1;
+		 if (vcpu->arch.mp_state =3D=3D VCPU_MP_STATE_RUNNABLE)
+			kvm_vcpu_kick(vcpu);
+		else if (vcpu->arch.mp_state =3D=3D VCPU_MP_STATE_HALTED) {
+			vcpu->arch.mp_state =3D VCPU_MP_STATE_RUNNABLE;
+			if (waitqueue_active(&vcpu->wq))
+				wake_up_interruptible(&vcpu->wq);
+		}
+		return 1;
+	}
+	return 0;
+}
+
+int kvm_apic_match_physical_addr(struct kvm_lapic *apic, u16 dest)
+{
+	return apic->vcpu->vcpu_id =3D=3D dest;
+}
+
+int kvm_apic_match_logical_addr(struct kvm_lapic *apic, u8 mda)
+{
+	return 0;
+}
+
+struct kvm_vcpu *kvm_get_lowest_prio_vcpu(struct kvm *kvm, u8 vector,
+				       unsigned long bitmap)
+{
+	struct kvm_vcpu *lvcpu =3D kvm->vcpus[0];
+	int i;
+
+	for (i =3D 1; i < KVM_MAX_VCPUS; i++) {
+		if (!kvm->vcpus[i])
+			continue;
+		if (lvcpu->arch.xtp > kvm->vcpus[i]->arch.xtp)
+			lvcpu =3D kvm->vcpus[i];
+	}
+
+	return lvcpu;
+}
+
+static int find_highest_bits(int *dat)
+{
+	u32  bits, bitnum;
+	int i;
+
+	/* loop for all 256 bits */
+	for (i =3D 7; i >=3D 0 ; i--) {
+		bits =3D dat[i];
+		if (bits) {
+			bitnum =3D fls(bits);
+			return i * 32 + bitnum - 1;
+		}
+	}
+
+	return -1;
+}
+
+int kvm_highest_pending_irq(struct kvm_vcpu *vcpu)
+{
+    struct vpd *vpd =3D to_host(vcpu->kvm, vcpu->arch.vpd);
+
+    if (vpd->irr[0] & (1UL << NMI_VECTOR))
+		return NMI_VECTOR;
+    if (vpd->irr[0] & (1UL << ExtINT_VECTOR))
+		return ExtINT_VECTOR;
+
+    return find_highest_bits((int *)&vpd->irr[0]);
+}
+
+int kvm_cpu_has_interrupt(struct kvm_vcpu *vcpu)
+{
+	if (kvm_highest_pending_irq(vcpu) !=3D -1)
+		return 1;
+	return 0;
+}
+
+gfn_t unalias_gfn(struct kvm *kvm, gfn_t gfn)
+{
+	return gfn;
+}
+
+int kvm_arch_vcpu_runnable(struct kvm_vcpu *vcpu)
+{
+	return vcpu->arch.mp_state =3D=3D VCPU_MP_STATE_RUNNABLE;
+}
+
--=20
1.5.1

------_=_NextPart_001_01C863F4.1AACE3C7
Content-Type: application/octet-stream;
	name="0006-kvm-ia64-Add-kvm-arch-specific-core-code-for-kvm-ia.patch"
Content-Transfer-Encoding: base64
Content-Description: 0006-kvm-ia64-Add-kvm-arch-specific-core-code-for-kvm-ia.patch
Content-Disposition: attachment;
	filename="0006-kvm-ia64-Add-kvm-arch-specific-core-code-for-kvm-ia.patch"

RnJvbSBmOGYyMWUxZjFmYTlkYTA3NjZlOWE2MjJjMjM2NTY4NGMxZDQxYTc0IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVGh1LCAzMSBKYW4gMjAwOCAxNTo0MDoxMiArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IGt2bS9pYTY0OiBBZGQga3ZtIGFyY2gtc3BlY2lmaWMgY29yZSBjb2RlIGZvciBrdm0vaWE2NC4K
Cmt2bV9pYTY0LmMgaXMgYWRkZWQgdG8gaGFuZGxlIGlhNjQtc3BlY2lmaWMgY29yZSBsb2dpYy4K
U2lnbmVkLW9mZi1ieTogWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56aGFuZ0BpbnRlbC5jb20+Ci0t
LQogYXJjaC9pYTY0L2t2bS9rdm1faWE2NC5jIHwgMTU5NiArKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrCiAxIGZpbGVzIGNoYW5nZWQsIDE1OTYgaW5zZXJ0aW9u
cygrKSwgMCBkZWxldGlvbnMoLSkKIGNyZWF0ZSBtb2RlIDEwMDY0NCBhcmNoL2lhNjQva3ZtL2t2
bV9pYTY0LmMKCmRpZmYgLS1naXQgYS9hcmNoL2lhNjQva3ZtL2t2bV9pYTY0LmMgYi9hcmNoL2lh
NjQva3ZtL2t2bV9pYTY0LmMKbmV3IGZpbGUgbW9kZSAxMDA2NDQKaW5kZXggMDAwMDAwMC4uZjFh
MGE5MwotLS0gL2Rldi9udWxsCisrKyBiL2FyY2gvaWE2NC9rdm0va3ZtX2lhNjQuYwpAQCAtMCww
ICsxLDE1OTYgQEAKKy8qCisgKiBrdm1faWE2NC5jOiBCYXNpYyBLVk0gc3VwcHBvcnQgT24gSXRh
bml1bSBzZXJpZXMgcHJvY2Vzc29ycworICoKKyAqCisgKiAJQ29weXJpZ2h0IChDKSAyMDA3LCBJ
bnRlbCBDb3Jwb3JhdGlvbi4KKyAqICAJWGlhbnRhbyBaaGFuZyAgKHhpYW50YW8uemhhbmdAaW50
ZWwuY29tKQorICoKKyAqIFRoaXMgcHJvZ3JhbSBpcyBmcmVlIHNvZnR3YXJlOyB5b3UgY2FuIHJl
ZGlzdHJpYnV0ZSBpdCBhbmQvb3IgbW9kaWZ5IGl0CisgKiB1bmRlciB0aGUgdGVybXMgYW5kIGNv
bmRpdGlvbnMgb2YgdGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlLAorICogdmVyc2lvbiAy
LCBhcyBwdWJsaXNoZWQgYnkgdGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlvbi4KKyAqCisgKiBU
aGlzIHByb2dyYW0gaXMgZGlzdHJpYnV0ZWQgaW4gdGhlIGhvcGUgaXQgd2lsbCBiZSB1c2VmdWws
IGJ1dCBXSVRIT1VUCisgKiBBTlkgV0FSUkFOVFk7IHdpdGhvdXQgZXZlbiB0aGUgaW1wbGllZCB3
YXJyYW50eSBvZiBNRVJDSEFOVEFCSUxJVFkgb3IKKyAqIEZJVE5FU1MgRk9SIEEgUEFSVElDVUxB
UiBQVVJQT1NFLiAgU2VlIHRoZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSBmb3IKKyAqIG1v
cmUgZGV0YWlscy4KKyAqCisgKiBZb3Ugc2hvdWxkIGhhdmUgcmVjZWl2ZWQgYSBjb3B5IG9mIHRo
ZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSBhbG9uZyB3aXRoCisgKiB0aGlzIHByb2dyYW07
IGlmIG5vdCwgd3JpdGUgdG8gdGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlvbiwgSW5jLiwgNTkg
VGVtcGxlCisgKiBQbGFjZSAtIFN1aXRlIDMzMCwgQm9zdG9uLCBNQSAwMjExMS0xMzA3IFVTQS4K
KyAqCisgKi8KKworI2luY2x1ZGUgPGxpbnV4L21vZHVsZS5oPgorI2luY2x1ZGUgPGxpbnV4L3Zt
YWxsb2MuaD4KKyNpbmNsdWRlIDxsaW51eC9lcnJuby5oPgorI2luY2x1ZGUgPGxpbnV4L3BlcmNw
dS5oPgorI2luY2x1ZGUgPGxpbnV4L2dmcC5oPgorI2luY2x1ZGUgPGxpbnV4L2ZzLmg+CisjaW5j
bHVkZSA8bGludXgvc21wLmg+CisjaW5jbHVkZSA8bGludXgva3ZtX2hvc3QuaD4KKyNpbmNsdWRl
IDxsaW51eC9rdm0uaD4KKyNpbmNsdWRlIDxsaW51eC9iaXRvcHMuaD4KKyNpbmNsdWRlIDxsaW51
eC9ocnRpbWVyLmg+CisKKyNpbmNsdWRlIDxhc20vcGd0YWJsZS5oPgorI2luY2x1ZGUgPGFzbS9n
Y2NfaW50cmluLmg+CisjaW5jbHVkZSA8YXNtL3BhbC5oPgorI2luY2x1ZGUgPGFzbS91YWNjZXNz
Lmg+CisjaW5jbHVkZSA8YXNtL2NhY2hlZmx1c2guaD4KKyNpbmNsdWRlIDxhc20vZGl2NjQuaD4K
KyNpbmNsdWRlIDxhc20vdGxiLmg+CisKKyNpbmNsdWRlICJpYTY0X3JlZ3MuaCIKKyNpbmNsdWRl
ICJtaXNjLmgiCisjaW5jbHVkZSAidnRpLmgiCisjaW5jbHVkZSAiaW9kZXYuaCIKKyNpbmNsdWRl
ICJpb2FwaWMuaCIKKyNpbmNsdWRlICJsYXBpYy5oIgorCitzdGF0aWMgdW5zaWduZWQgbG9uZyBr
dm1fdm1tX2Jhc2U7CitzdGF0aWMgdW5zaWduZWQgbG9uZyBrdm1fdnNhX2Jhc2U7CitzdGF0aWMg
dW5zaWduZWQgbG9uZyBrdm1fdm1fYnVmZmVyOworc3RhdGljIHVuc2lnbmVkIGxvbmcga3ZtX3Zt
X2J1ZmZlcl9zaXplOwordW5zaWduZWQgbG9uZyBrdm1fdm1tX2dwOworCitzdGF0aWMgbG9uZyB2
cF9lbnZfaW5mbzsKKworc3RhdGljIHN0cnVjdCBrdm1fdm1tX2luZm8gKmt2bV92bW1faW5mbzsK
Kworc3RhdGljIERFRklORV9QRVJfQ1BVKHN0cnVjdCBrdm1fdmNwdSAqLCBsYXN0X3ZjcHUpOwor
CitzdHJ1Y3Qga3ZtX3N0YXRzX2RlYnVnZnNfaXRlbSBkZWJ1Z2ZzX2VudHJpZXNbXSA9IHsKKwl7
IE5VTEwgfQorfTsKKworCitzdHJ1Y3QgZmRlc2N7CisgICAgdW5zaWduZWQgbG9uZyBpcDsKKyAg
ICB1bnNpZ25lZCBsb25nIGdwOworfTsKKworc3RhdGljIHZvaWQga3ZtX2ZsdXNoX2ljYWNoZSh1
bnNpZ25lZCBsb25nIHN0YXJ0LCB1bnNpZ25lZCBsb25nIGxlbikKK3sKKwlpbnQgbDsKKworCWZv
ciAobCA9IDA7IGwgPCAobGVuICsgMzIpOyBsICs9IDMyKQorCQlpYTY0X2ZjKHN0YXJ0ICsgbCk7
CisKKwlpYTY0X3N5bmNfaSgpOworCWlhNjRfc3Jsel9pKCk7Cit9CisKK3N0YXRpYyB2b2lkIGt2
bV9mbHVzaF90bGJfYWxsKHZvaWQpCit7CisJdW5zaWduZWQgbG9uZyBpLCBqLCBjb3VudDAsIGNv
dW50MSwgc3RyaWRlMCwgc3RyaWRlMSwgYWRkcjsKKwlsb25nIGZsYWdzOworCisJYWRkciAgICA9
IGxvY2FsX2NwdV9kYXRhLT5wdGNlX2Jhc2U7CisJY291bnQwICA9IGxvY2FsX2NwdV9kYXRhLT5w
dGNlX2NvdW50WzBdOworCWNvdW50MSAgPSBsb2NhbF9jcHVfZGF0YS0+cHRjZV9jb3VudFsxXTsK
KwlzdHJpZGUwID0gbG9jYWxfY3B1X2RhdGEtPnB0Y2Vfc3RyaWRlWzBdOworCXN0cmlkZTEgPSBs
b2NhbF9jcHVfZGF0YS0+cHRjZV9zdHJpZGVbMV07CisKKwlsb2NhbF9pcnFfc2F2ZShmbGFncyk7
CisJZm9yIChpID0gMDsgaSA8IGNvdW50MDsgKytpKSB7CisJCWZvciAoaiA9IDA7IGogPCBjb3Vu
dDE7ICsraikgeworCQkJaWE2NF9wdGNlKGFkZHIpOworCQkJYWRkciArPSBzdHJpZGUxOworCQl9
CisJCWFkZHIgKz0gc3RyaWRlMDsKKwl9CisJbG9jYWxfaXJxX3Jlc3RvcmUoZmxhZ3MpOworCWlh
NjRfc3Jsel9pKCk7CQkJLyogc3Jsei5pIGltcGxpZXMgc3Jsei5kICovCit9CisKK2xvbmcgaWE2
NF9wYWxfdnBfY3JlYXRlKHU2NCAqdnBkLCB1NjQgKmhvc3RfaXZhLCB1NjQgKm9wdF9oYW5kbGVy
KQoreworCXN0cnVjdCBpYTY0X3BhbF9yZXR2YWwgaXBydjsKKworCVBBTF9DQUxMX1NUSyhpcHJ2
LCBQQUxfVlBfQ1JFQVRFLCAodTY0KXZwZCwgKHU2NClob3N0X2l2YSwKKwkJCSh1NjQpb3B0X2hh
bmRsZXIpOworCisJcmV0dXJuIGlwcnYuc3RhdHVzOworfQorCitzdGF0aWMgIERFRklORV9TUElO
TE9DSyh2cF9sb2NrKTsKKwordm9pZCBrdm1fYXJjaF9oYXJkd2FyZV9lbmFibGUodm9pZCAqZ2Fy
YmFnZSkKK3sKKwlsb25nICBzdGF0dXM7CisJbG9uZyAgdG1wX2Jhc2U7CisJdW5zaWduZWQgbG9u
ZyBwdGU7CisJdW5zaWduZWQgbG9uZyBzYXZlZF9wc3I7CisKKwlwdGUgPSBwdGVfdmFsKG1rX3B0
ZV9waHlzKF9fcGEoa3ZtX3ZtbV9iYXNlKSwKKwkJCQlQQUdFX0tFUk5FTCkpOworCWxvY2FsX2ly
cV9zYXZlKHNhdmVkX3Bzcik7CisJaWE2NF9pdHJfZW50cnkoMHgzLCBLVk1fVk1NX0JBU0UsCisJ
CQlwdGUsIEtWTV9WTU1fU0hJRlQpOworCWxvY2FsX2lycV9yZXN0b3JlKHNhdmVkX3Bzcik7CisK
KwlzcGluX2xvY2soJnZwX2xvY2spOworCXN0YXR1cyA9IGlhNjRfcGFsX3ZwX2luaXRfZW52KGt2
bV92c2FfYmFzZSA/CisJCQkJVlBfSU5JVF9FTlYgOiBWUF9JTklUX0VOVl9JTklUQUxJWkUsCisJ
CQlfX3BhKGt2bV92bV9idWZmZXIpLCBLVk1fVk1fQlVGRkVSX0JBU0UsICZ0bXBfYmFzZSk7CisJ
aWYgKHN0YXR1cyAhPSAwKSB7CisJCXByaW50ayhLRVJOX1dBUk5JTkcia3ZtOkZhaWxlZCB0byBF
bmFibGUgVlQgU3VwcG9ydCEhISFcbiIpOworCQlyZXR1cm4gOworCX0KKworCWlmICgha3ZtX3Zz
YV9iYXNlKSB7CisJCWt2bV92c2FfYmFzZSA9IHRtcF9iYXNlOworCQlwcmludGsoS0VSTl9JTkZP
Imt2bTprdm1fdnNhX2Jhc2U6MHglbHhcbiIsIGt2bV92c2FfYmFzZSk7CisJfQorCXNwaW5fdW5s
b2NrKCZ2cF9sb2NrKTsKKwlpYTY0X3B0cl9lbnRyeSgweDMsIEtWTV9WTU1fQkFTRSwgS1ZNX1ZN
TV9TSElGVCk7Cit9CisKK3ZvaWQga3ZtX2FyY2hfaGFyZHdhcmVfZGlzYWJsZSh2b2lkICpnYXJi
YWdlKQoreworCisJbG9uZyBzdGF0dXM7CisJdW5zaWduZWQgbG9uZyBwdGU7CisJdW5zaWduZWQg
bG9uZyBzYXZlZF9wc3I7CisJdW5zaWduZWQgbG9uZyBob3N0X2l2YSA9IGlhNjRfZ2V0cmVnKF9J
QTY0X1JFR19DUl9JVkEpOworCisJcHRlID0gcHRlX3ZhbChta19wdGVfcGh5cyhfX3BhKGt2bV92
bW1fYmFzZSksCisJCQkJUEFHRV9LRVJORUwpKTsKKworCWxvY2FsX2lycV9zYXZlKHNhdmVkX3Bz
cik7CisJaWE2NF9pdHJfZW50cnkoMHgzLCBLVk1fVk1NX0JBU0UsCisJCQlwdGUsIEtWTV9WTU1f
U0hJRlQpOworCWxvY2FsX2lycV9yZXN0b3JlKHNhdmVkX3Bzcik7CisKKwlzdGF0dXMgPSBpYTY0
X3BhbF92cF9leGl0X2Vudihob3N0X2l2YSk7CisJaWYgKHN0YXR1cykKKwkJcHJpbnRrKEtFUk5f
REVCVUcia3ZtOiBGYWlsZWQgdG8gZGlzYWJsZSBWVCBzdXBwb3J0ISA6JWxkXG4iLAorCQkJCXN0
YXR1cyk7CisJaWE2NF9wdHJfZW50cnkoMHgzLCBLVk1fVk1NX0JBU0UsIEtWTV9WTU1fU0hJRlQp
OworfQorCit2b2lkIGt2bV9hcmNoX2NoZWNrX3Byb2Nlc3Nvcl9jb21wYXQodm9pZCAqcnRuKQor
eworCSooaW50ICopcnRuID0gMDsKK30KKworaW50IGt2bV9kZXZfaW9jdGxfY2hlY2tfZXh0ZW5z
aW9uKGxvbmcgZXh0KQoreworCisJaW50IHI7CisKKwlzd2l0Y2ggKGV4dCkgeworCWNhc2UgS1ZN
X0NBUF9JUlFDSElQOgorCWNhc2UgS1ZNX0NBUF9VU0VSX01FTU9SWToKKworCQlyID0gMTsKKwkJ
YnJlYWs7CisJZGVmYXVsdDoKKwkJciA9IDA7CisJfQorCXJldHVybiByOworCit9CisKK3N0YXRp
YyBzdHJ1Y3Qga3ZtX2lvX2RldmljZSAqdmNwdV9maW5kX21taW9fZGV2KHN0cnVjdCBrdm1fdmNw
dSAqdmNwdSwKKwkJCQkJZ3BhX3QgYWRkcikKK3sKKwlzdHJ1Y3Qga3ZtX2lvX2RldmljZSAqZGV2
OworCisJZGV2ID0ga3ZtX2lvX2J1c19maW5kX2RldigmdmNwdS0+a3ZtLT5tbWlvX2J1cywgYWRk
cik7CisKKwlyZXR1cm4gZGV2OworfQorCitzdGF0aWMgaW50IGhhbmRsZV92bV9lcnJvcihzdHJ1
Y3Qga3ZtX3ZjcHUgKnZjcHUsIHN0cnVjdCBrdm1fcnVuICprdm1fcnVuKQoreworCWt2bV9ydW4t
PmV4aXRfcmVhc29uID0gS1ZNX0VYSVRfVU5LTk9XTjsKKwlrdm1fcnVuLT5ody5oYXJkd2FyZV9l
eGl0X3JlYXNvbiA9IDE7CisJcmV0dXJuIDA7Cit9CisKK3N0YXRpYyBpbnQgaGFuZGxlX21taW8o
c3RydWN0IGt2bV92Y3B1ICp2Y3B1LCBzdHJ1Y3Qga3ZtX3J1biAqa3ZtX3J1bikKK3sKKwlpb3Jl
cV90ICpwOworCXN0cnVjdCBrdm1faW9fZGV2aWNlICptbWlvX2RldjsKKworCXAgPSBrdm1fZ2V0
X3ZjcHVfaW9yZXEodmNwdSk7CisKKwlpZiAoKHAtPmFkZHIgJiBQQUdFX01BU0spID09IElPQVBJ
Q19ERUZBVUxUX0JBU0VfQUREUkVTUykKKwkJZ290byBtbWlvOworCXZjcHUtPm1taW9fbmVlZGVk
ID0gMTsKKwl2Y3B1LT5tbWlvX3BoeXNfYWRkciA9IGt2bV9ydW4tPm1taW8ucGh5c19hZGRyID0g
cC0+YWRkcjsKKwl2Y3B1LT5tbWlvX3NpemUgPSBrdm1fcnVuLT5tbWlvLmxlbiA9IHAtPnNpemU7
CisJdmNwdS0+bW1pb19pc193cml0ZSA9IGt2bV9ydW4tPm1taW8uaXNfd3JpdGUgPSAhcC0+ZGly
OworCisJaWYgKHZjcHUtPm1taW9faXNfd3JpdGUpCisJCW1lbWNweSh2Y3B1LT5tbWlvX2RhdGEs
ICZwLT5kYXRhLCBwLT5zaXplKTsKKwltZW1jcHkoa3ZtX3J1bi0+bW1pby5kYXRhLCAmcC0+ZGF0
YSwgcC0+c2l6ZSk7CisJa3ZtX3J1bi0+ZXhpdF9yZWFzb24gPSBLVk1fRVhJVF9NTUlPOworCXJl
dHVybiAwOworbW1pbzoKKwltbWlvX2RldiA9IHZjcHVfZmluZF9tbWlvX2Rldih2Y3B1LCBwLT5h
ZGRyKTsKKwlpZiAobW1pb19kZXYpIHsKKwkJaWYgKCFwLT5kaXIpCisJCQlrdm1faW9kZXZpY2Vf
d3JpdGUobW1pb19kZXYsIHAtPmFkZHIsIHAtPnNpemUsCisJCQkJCQkmcC0+ZGF0YSk7CisJCWVs
c2UKKwkJCWt2bV9pb2RldmljZV9yZWFkKG1taW9fZGV2LCBwLT5hZGRyLCBwLT5zaXplLAorCQkJ
CQkJJnAtPmRhdGEpOworCisJfSBlbHNlCisJCXByaW50ayhLRVJOX0VSUiJrdm06IE5vIGlvZGV2
aWNlIGZvdW5kICFcbiIpOworCXAtPnN0YXRlID0gU1RBVEVfSU9SRVNQX1JFQURZOworCisJcmV0
dXJuIDE7Cit9CisKK3N0YXRpYyBpbnQgaGFuZGxlX3BhbF9jYWxsKHN0cnVjdCBrdm1fdmNwdSAq
dmNwdSwgc3RydWN0IGt2bV9ydW4gKmt2bV9ydW4pCit7CisJc3RydWN0IGV4aXRfY3RsX2RhdGEg
KnA7CisKKwlwID0ga3ZtX2dldF9leGl0X2RhdGEodmNwdSk7CisKKwlpZiAocC0+ZXhpdF9yZWFz
b24gPT0gRVhJVF9SRUFTT05fUEFMX0NBTEwpCisJCXJldHVybiBrdm1fcGFsX2VtdWwodmNwdSwg
a3ZtX3J1bik7CisJZWxzZSB7CisJCWt2bV9ydW4tPmV4aXRfcmVhc29uID0gS1ZNX0VYSVRfVU5L
Tk9XTjsKKwkJa3ZtX3J1bi0+aHcuaGFyZHdhcmVfZXhpdF9yZWFzb24gPSAyOworCQlyZXR1cm4g
MDsKKwl9Cit9CisKK3N0YXRpYyBpbnQgaGFuZGxlX3NhbF9jYWxsKHN0cnVjdCBrdm1fdmNwdSAq
dmNwdSwgc3RydWN0IGt2bV9ydW4gKmt2bV9ydW4pCit7CisJc3RydWN0IGV4aXRfY3RsX2RhdGEg
KnA7CisKKwlwID0ga3ZtX2dldF9leGl0X2RhdGEodmNwdSk7CisKKwlpZiAocC0+ZXhpdF9yZWFz
b24gPT0gRVhJVF9SRUFTT05fU0FMX0NBTEwpIHsKKwkJa3ZtX3NhbF9lbXVsKHZjcHUpOworCQly
ZXR1cm4gMTsKKwl9IGVsc2UgeworCQlrdm1fcnVuLT5leGl0X3JlYXNvbiA9IEtWTV9FWElUX1VO
S05PV047CisJCWt2bV9ydW4tPmh3LmhhcmR3YXJlX2V4aXRfcmVhc29uID0gMzsKKwkJcmV0dXJu
IDA7CisJfQorCit9CisKKy8qCisgKiAgb2Zmc2V0OiBhZGRyZXNzIG9mZnNldCB0byBJUEkgc3Bh
Y2UuCisgKiAgdmFsdWU6ICBkZWxpdmVyIHZhbHVlLgorICovCitzdGF0aWMgdm9pZCB2Y3B1X2Rl
bGl2ZXJfaXBpKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwgdWludDY0X3QgZG0sCisJCQkJdWludDY0
X3QgdmVjdG9yKQoreworCXN3aXRjaCAoZG0pIHsKKwljYXNlIFNBUElDX0ZJWEVEOgorCQlrdm1f
YXBpY19zZXRfaXJxKHZjcHUsIHZlY3RvciwgMCk7CisJCWJyZWFrOworCWNhc2UgU0FQSUNfTk1J
OgorCQlrdm1fYXBpY19zZXRfaXJxKHZjcHUsIDIsIDApOworCQlicmVhazsKKwljYXNlIFNBUElD
X0VYVElOVDoKKwkJa3ZtX2FwaWNfc2V0X2lycSh2Y3B1LCAwLCAwKTsKKwkJYnJlYWs7CisJY2Fz
ZSBTQVBJQ19JTklUOgorCWNhc2UgU0FQSUNfUE1JOgorCWRlZmF1bHQ6CisJCXByaW50ayhLRVJO
X0VSUiJrdm06VW5pbXBsZW1lbnRlZCBEZWxpdmVyIHJlc2VydmVkIElQSSFcbiIpOworCQlicmVh
azsKKwl9Cit9CisKK3N0YXRpYyBzdHJ1Y3Qga3ZtX3ZjcHUgKmxpZF90b192Y3B1KHN0cnVjdCBr
dm0gKmt2bSwgdW5zaWduZWQgbG9uZyBpZCwKKwkJCXVuc2lnbmVkIGxvbmcgZWlkKQoreworCWlh
NjRfbGlkX3QgbGlkOworCWludCBpOworCisJZm9yIChpID0gMDsgaSA8IEtWTV9NQVhfVkNQVVM7
IGkrKykgeworCQlpZiAoa3ZtLT52Y3B1c1tpXSkgeworCQkJbGlkLnZhbCA9IFZDUFVfTElEKGt2
bS0+dmNwdXNbaV0pOworCQkJaWYgKGxpZC5pZCA9PSBpZCAmJiBsaWQuZWlkID09IGVpZCkKKwkJ
CQlyZXR1cm4ga3ZtLT52Y3B1c1tpXTsKKwkJfQorCX0KKworCXJldHVybiBOVUxMOworfQorCitz
dGF0aWMgaW50IGhhbmRsZV9pcGkoc3RydWN0IGt2bV92Y3B1ICp2Y3B1LCBzdHJ1Y3Qga3ZtX3J1
biAqa3ZtX3J1bikKK3sKKwlzdHJ1Y3QgZXhpdF9jdGxfZGF0YSAqcCA9IGt2bV9nZXRfZXhpdF9k
YXRhKHZjcHUpOworCXN0cnVjdCBrdm1fdmNwdSAqdGFyZ2V0X3ZjcHU7CisJc3RydWN0IGt2bV9w
dF9yZWdzICpyZWdzOworCWlhNjRfaXBpX2EgYWRkciA9IHAtPnUuaXBpX2RhdGEuYWRkcjsKKwlp
YTY0X2lwaV9kIGRhdGEgPSBwLT51LmlwaV9kYXRhLmRhdGE7CisKKwl0YXJnZXRfdmNwdSA9IGxp
ZF90b192Y3B1KHZjcHUtPmt2bSwgYWRkci5pZCwgYWRkci5laWQpOworCWlmICghdGFyZ2V0X3Zj
cHUpCisJCXJldHVybiBoYW5kbGVfdm1fZXJyb3IodmNwdSwga3ZtX3J1bik7CisKKwlpZiAoIXRh
cmdldF92Y3B1LT5hcmNoLmxhdW5jaGVkKSB7CisJCXJlZ3MgPSB2Y3B1X3JlZ3ModGFyZ2V0X3Zj
cHUpOworCisJCXJlZ3MtPmNyX2lpcCA9IHZjcHUtPmt2bS0+YXJjaC5yZHZfc2FsX2RhdGEuYm9v
dF9pcDsKKwkJcmVncy0+cjEgPSB2Y3B1LT5rdm0tPmFyY2gucmR2X3NhbF9kYXRhLmJvb3RfZ3A7
CisKKwkJdGFyZ2V0X3ZjcHUtPmFyY2gubXBfc3RhdGUgPSBWQ1BVX01QX1NUQVRFX1JVTk5BQkxF
OworCQlpZiAod2FpdHF1ZXVlX2FjdGl2ZSgmdGFyZ2V0X3ZjcHUtPndxKSkKKwkJCXdha2VfdXBf
aW50ZXJydXB0aWJsZSgmdGFyZ2V0X3ZjcHUtPndxKTsKKwl9IGVsc2UgeworCQl2Y3B1X2RlbGl2
ZXJfaXBpKHRhcmdldF92Y3B1LCBkYXRhLmRtLCBkYXRhLnZlY3Rvcik7CisJCWlmICh0YXJnZXRf
dmNwdSAhPSB2Y3B1KQorCQkJa3ZtX3ZjcHVfa2ljayh0YXJnZXRfdmNwdSk7CisJfQorCisJcmV0
dXJuIDE7Cit9CisKK3N0cnVjdCBjYWxsX2RhdGEgeworCXN0cnVjdCBrdm1fcHRjX2cgcHRjX2df
ZGF0YTsKKwlzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHU7Cit9OworCitzdGF0aWMgdm9pZCB2Y3B1X2ds
b2JhbF9wdXJnZSh2b2lkICppbmZvKQoreworCXN0cnVjdCBjYWxsX2RhdGEgKnAgPSAoc3RydWN0
IGNhbGxfZGF0YSAqKWluZm87CisJc3RydWN0IGt2bV92Y3B1ICp2Y3B1ID0gcC0+dmNwdTsKKwor
CWlmICh0ZXN0X2JpdChLVk1fUkVRX0ZMVVNIX0FMTCwgJnZjcHUtPnJlcXVlc3RzKSkKKwkJcmV0
dXJuOworCisJc2V0X2JpdChLVk1fUkVRX1BUQ19HLCAmdmNwdS0+cmVxdWVzdHMpOworCWlmICh2
Y3B1LT5hcmNoLnB0Y19nX2NvdW50IDwgTUFYX1BUQ19HX05VTSkgeworCQl2Y3B1LT5hcmNoLnB0
Y19nX2RhdGFbdmNwdS0+YXJjaC5wdGNfZ19jb3VudCsrXSA9CisJCQkJCQkJcC0+cHRjX2dfZGF0
YTsKKwl9IGVsc2UgeworCQljbGVhcl9iaXQoS1ZNX1JFUV9QVENfRywgJnZjcHUtPnJlcXVlc3Rz
KTsKKwkJdmNwdS0+YXJjaC5wdGNfZ19jb3VudCA9IDA7CisJCXNldF9iaXQoS1ZNX1JFUV9GTFVT
SF9BTEwsICZ2Y3B1LT5yZXF1ZXN0cyk7CisJfQorfQorCitzdGF0aWMgaW50IGhhbmRsZV9nbG9i
YWxfcHVyZ2Uoc3RydWN0IGt2bV92Y3B1ICp2Y3B1LCBzdHJ1Y3Qga3ZtX3J1biAqa3ZtX3J1bikK
K3sKKwlzdHJ1Y3QgZXhpdF9jdGxfZGF0YSAqcCA9IGt2bV9nZXRfZXhpdF9kYXRhKHZjcHUpOwor
CXN0cnVjdCBrdm0gKmt2bSA9IHZjcHUtPmt2bTsKKwlzdHJ1Y3QgY2FsbF9kYXRhIGNhbGxfZGF0
YTsKKwlpbnQgaTsKKwljYWxsX2RhdGEucHRjX2dfZGF0YSA9IHAtPnUucHRjX2dfZGF0YTsKKwor
CWZvciAoaSA9IDA7IGkgPCBLVk1fTUFYX1ZDUFVTOyBpKyspIHsKKwkJaWYgKCFrdm0tPnZjcHVz
W2ldIHx8IGt2bS0+dmNwdXNbaV0tPmFyY2gubXBfc3RhdGUgPT0KKwkJCQkJCVZDUFVfTVBfU1RB
VEVfVU5JTklUSUFMSVpFRCB8fAorCQkJCQl2Y3B1ID09IGt2bS0+dmNwdXNbaV0pCisJCQljb250
aW51ZTsKKworCQlpZiAod2FpdHF1ZXVlX2FjdGl2ZSgma3ZtLT52Y3B1c1tpXS0+d3EpKSB7CisJ
CQl3YWtlX3VwX2ludGVycnVwdGlibGUoJmt2bS0+dmNwdXNbaV0tPndxKTsKKwkJfQorCisJCWlm
IChrdm0tPnZjcHVzW2ldLT5jcHUgIT0gLTEpIHsKKwkJCWNhbGxfZGF0YS52Y3B1ID0ga3ZtLT52
Y3B1c1tpXTsKKwkJCXNtcF9jYWxsX2Z1bmN0aW9uX3NpbmdsZShrdm0tPnZjcHVzW2ldLT5jcHUs
CisJCQkJCXZjcHVfZ2xvYmFsX3B1cmdlLCAmY2FsbF9kYXRhLCAwLCAxKTsKKwkJfSBlbHNlCisJ
CQlwcmludGsoS0VSTl9XQVJOSU5HImt2bTogVW5pbml0IHZjcHUgcmVjZWl2ZWQgaXBpIVxuIik7
CisKKwl9CisJcmV0dXJuIDE7Cit9CisKK3N0YXRpYyBpbnQgaGFuZGxlX3N3aXRjaF9ycjYoc3Ry
dWN0IGt2bV92Y3B1ICp2Y3B1LCBzdHJ1Y3Qga3ZtX3J1biAqa3ZtX3J1bikKK3sKKwlyZXR1cm4g
MTsKK30KKworaW50IGt2bV9lbXVsYXRlX2hhbHQoc3RydWN0IGt2bV92Y3B1ICp2Y3B1KQorewor
CisJa3RpbWVfdCBrdDsKKwlsb25nIGl0Y19kaWZmOworCXVuc2lnbmVkIGxvbmcgdmNwdV9ub3df
aXRjOworCisJdW5zaWduZWQgbG9uZyBleHBpcmVzOworCXN0cnVjdCBocnRpbWVyICpwX2h0ID0g
JnZjcHUtPmFyY2guaGx0X3RpbWVyOworCXVuc2lnbmVkIGxvbmcgY3ljX3Blcl91c2VjID0gbG9j
YWxfY3B1X2RhdGEtPmN5Y19wZXJfdXNlYzsKKwlzdHJ1Y3QgdnBkICp2cGQgPSB0b19ob3N0KHZj
cHUtPmt2bSwgdmNwdS0+YXJjaC52cGQpOworCisJdmNwdV9ub3dfaXRjID0gaWE2NF9nZXRfaXRj
KCkgKyB2Y3B1LT5hcmNoLml0Y19vZmZzZXQ7CisKKwlpZiAodGltZV9hZnRlcih2Y3B1X25vd19p
dGMsIHZwZC0+aXRtKSkgeworCQl2Y3B1LT5hcmNoLnRpbWVyX2NoZWNrID0gMTsKKwkJcmV0dXJu
IDE7CisJfQorCWl0Y19kaWZmID0gdnBkLT5pdG0gLSB2Y3B1X25vd19pdGM7CisJaWYgKGl0Y19k
aWZmIDwgMCkKKwkJaXRjX2RpZmYgPSAtaXRjX2RpZmY7CisKKwlleHBpcmVzID0gZGl2NjRfNjQo
aXRjX2RpZmYsIGN5Y19wZXJfdXNlYyk7CisJa3QgPSBrdGltZV9zZXQoMCwgMTAwMCAqIGV4cGly
ZXMpOworCXZjcHUtPmFyY2guaHRfYWN0aXZlID0gMTsKKwlocnRpbWVyX3N0YXJ0KHBfaHQsIGt0
LCBIUlRJTUVSX01PREVfQUJTKTsKKworCWlmIChpcnFjaGlwX2luX2tlcm5lbCh2Y3B1LT5rdm0p
KSB7CisJCXZjcHUtPmFyY2gubXBfc3RhdGUgPSBWQ1BVX01QX1NUQVRFX0hBTFRFRDsKKwkJa3Zt
X3ZjcHVfYmxvY2sodmNwdSk7CisJCWhydGltZXJfY2FuY2VsKHBfaHQpOworCQl2Y3B1LT5hcmNo
Lmh0X2FjdGl2ZSA9IDA7CisKKwkJaWYgKHZjcHUtPmFyY2gubXBfc3RhdGUgIT0gVkNQVV9NUF9T
VEFURV9SVU5OQUJMRSkKKwkJCXJldHVybiAtRUlOVFI7CisJCXJldHVybiAxOworCX0gZWxzZSB7
CisJCXByaW50ayhLRVJOX0VSUiJrdm06IFVuc3VwcG9ydGVkIHVzZXJzcGFjZSBoYWx0ISIpOwor
CQlyZXR1cm4gMDsKKwl9Cit9CisKK3N0YXRpYyBpbnQgaGFuZGxlX3ZtX3NodXRkb3duKHN0cnVj
dCBrdm1fdmNwdSAqdmNwdSwKKwkJc3RydWN0IGt2bV9ydW4gKmt2bV9ydW4pCit7CisJa3ZtX3J1
bi0+ZXhpdF9yZWFzb24gPSBLVk1fRVhJVF9TSFVURE9XTjsKKwlyZXR1cm4gMDsKK30KKworc3Rh
dGljIGludCBoYW5kbGVfZXh0ZXJuYWxfaW50ZXJydXB0KHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwK
KwkJc3RydWN0IGt2bV9ydW4gKmt2bV9ydW4pCit7CisJcmV0dXJuIDE7Cit9CisKK3N0YXRpYyBp
bnQgKCprdm1fdnRpX2V4aXRfaGFuZGxlcnNbXSkoc3RydWN0IGt2bV92Y3B1ICp2Y3B1LAorCQlz
dHJ1Y3Qga3ZtX3J1biAqa3ZtX3J1bikgPSB7CisJW0VYSVRfUkVBU09OX1ZNX1BBTklDXSAgICAg
ICAgICAgICAgPSBoYW5kbGVfdm1fZXJyb3IsCisJW0VYSVRfUkVBU09OX01NSU9fSU5TVFJVQ1RJ
T05dICAgICAgPSBoYW5kbGVfbW1pbywKKwlbRVhJVF9SRUFTT05fUEFMX0NBTExdICAgICAgICAg
ICAgICA9IGhhbmRsZV9wYWxfY2FsbCwKKwlbRVhJVF9SRUFTT05fU0FMX0NBTExdICAgICAgICAg
ICAgICA9IGhhbmRsZV9zYWxfY2FsbCwKKwlbRVhJVF9SRUFTT05fU1dJVENIX1JSNl0gICAgICAg
ICAgICA9IGhhbmRsZV9zd2l0Y2hfcnI2LAorCVtFWElUX1JFQVNPTl9WTV9ERVNUUk9ZXSAgICAg
ICAgICAgID0gaGFuZGxlX3ZtX3NodXRkb3duLAorCVtFWElUX1JFQVNPTl9FWFRFUk5BTF9JTlRF
UlJVUFRdICAgID0gaGFuZGxlX2V4dGVybmFsX2ludGVycnVwdCwKKwlbRVhJVF9SRUFTT05fSVBJ
XQkJICAgID0gaGFuZGxlX2lwaSwKKwlbRVhJVF9SRUFTT05fUFRDX0ddCQkgICAgPSBoYW5kbGVf
Z2xvYmFsX3B1cmdlLAorCit9OworCitzdGF0aWMgY29uc3QgaW50IGt2bV92dGlfbWF4X2V4aXRf
aGFuZGxlcnMgPQorCQlzaXplb2Yoa3ZtX3Z0aV9leGl0X2hhbmRsZXJzKS9zaXplb2YoKmt2bV92
dGlfZXhpdF9oYW5kbGVycyk7CisKK3N0YXRpYyB2b2lkIGt2bV9wcmVwYXJlX2d1ZXN0X3N3aXRj
aChzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7Cit9CisKK3N0YXRpYyB1aW50MzJfdCBrdm1fZ2V0
X2V4aXRfcmVhc29uKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSkKK3sKKwlzdHJ1Y3QgZXhpdF9jdGxf
ZGF0YSAqcF9leGl0X2RhdGE7CisKKwlwX2V4aXRfZGF0YSA9IGt2bV9nZXRfZXhpdF9kYXRhKHZj
cHUpOworCXJldHVybiBwX2V4aXRfZGF0YS0+ZXhpdF9yZWFzb247Cit9CisKKy8qCisgKiBUaGUg
Z3Vlc3QgaGFzIGV4aXRlZC4gIFNlZSBpZiB3ZSBjYW4gZml4IGl0IG9yIGlmIHdlIG5lZWQgdXNl
cnNwYWNlCisgKiBhc3Npc3RhbmNlLgorICovCitzdGF0aWMgaW50IGt2bV9oYW5kbGVfZXhpdChz
dHJ1Y3Qga3ZtX3J1biAqa3ZtX3J1biwgc3RydWN0IGt2bV92Y3B1ICp2Y3B1KQoreworCXUzMiBl
eGl0X3JlYXNvbiA9IGt2bV9nZXRfZXhpdF9yZWFzb24odmNwdSk7CisJdmNwdS0+YXJjaC5sYXN0
X2V4aXQgPSBleGl0X3JlYXNvbjsKKworCWlmIChleGl0X3JlYXNvbiA8IGt2bV92dGlfbWF4X2V4
aXRfaGFuZGxlcnMKKwkJCSYmIGt2bV92dGlfZXhpdF9oYW5kbGVyc1tleGl0X3JlYXNvbl0pCisJ
CXJldHVybiBrdm1fdnRpX2V4aXRfaGFuZGxlcnNbZXhpdF9yZWFzb25dKHZjcHUsIGt2bV9ydW4p
OworCWVsc2UgeworCQlrdm1fcnVuLT5leGl0X3JlYXNvbiA9IEtWTV9FWElUX1VOS05PV047CisJ
CWt2bV9ydW4tPmh3LmhhcmR3YXJlX2V4aXRfcmVhc29uID0gZXhpdF9yZWFzb247CisJfQorCXJl
dHVybiAwOworfQorCitzdGF0aWMgaW5saW5lIHZvaWQgdnRpX3NldF9ycjYodW5zaWduZWQgbG9u
ZyBycjYpCit7CisJaWE2NF9zZXRfcnIoUlI2LCBycjYpOworCWlhNjRfc3Jsel9pKCk7Cit9CisK
Ky8qRW5zdXJlIG5vIFRSIGVudHJpZXMgaW4gc2xvdCA2IGFuZCBzbG90IDcgYmVmb3JlIGdldHRp
bmcgY2FsbGVkLiovCitzdGF0aWMgdm9pZCBrdm1faW5zZXJ0X3ZtbV9tYXBwaW5nKHN0cnVjdCBr
dm1fdmNwdSAqdmNwdSkKK3sKKwl1bnNpZ25lZCBsb25nIHB0ZTsKKwlzdHJ1Y3Qga3ZtICprdm0g
PSB2Y3B1LT5rdm07CisKKwkvKkluc2VydCBhIHBhaXIgb2YgdHIgdG8gbWFwIHZtbSovCisJcHRl
ID0gcHRlX3ZhbChta19wdGVfcGh5cyhfX3BhKGt2bV92bW1fYmFzZSksIFBBR0VfS0VSTkVMKSk7
CisJaWE2NF9pdHJfZW50cnkoMHgzLCBLVk1fVk1NX0JBU0UsIHB0ZSwgS1ZNX1ZNTV9TSElGVCk7
CisKKwkvKkluc2VydCBhIHBhaXJ0IG9mIHRyIHRvIG1hcCBkYXRhIG9mIHZtKi8KKwlwdGUgPSBw
dGVfdmFsKG1rX3B0ZV9waHlzKF9fcGEoa3ZtLT5hcmNoLnZtX2Jhc2UpLCBQQUdFX0tFUk5FTCkp
OworCWlhNjRfaXRyX2VudHJ5KDB4MywgS1ZNX1ZNX0RBVEFfQkFTRSwKKwkJCQkJcHRlLCBLVk1f
Vk1fREFUQV9TSElGVCk7CisKK30KKworc3RhdGljIHZvaWQga3ZtX3B1cmdlX3ZtbV9tYXBwaW5n
KHZvaWQpCit7CisKKwl1bnNpZ25lZCBsb25nIHBzOworCisJLypQdXJnZSBpdHIgYW5kIGR0ciBp
biBzbG90IDYuKi8KKwlwcyA9IEtWTV9WTU1fU0hJRlQ7CisJaWE2NF9wdHJfZW50cnkoMHgzLCBL
Vk1fVk1NX0JBU0UsIHBzKTsKKworCS8qUHVyZ2UgaXRyIGFuZCBkdHIgaW4gc2xvdCA3LiovCisJ
cHMgPSBLVk1fVk1fREFUQV9TSElGVDsKKwlpYTY0X3B0cl9lbnRyeSgweDMsIEtWTV9WTV9EQVRB
X0JBU0UsIHBzKTsKKworfQorCitzdGF0aWMgdm9pZCBrdm1fdmNwdV9wcmVfdHJhbnNpdGlvbihz
dHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7CisJaW50IGNwdSA9IHNtcF9wcm9jZXNzb3JfaWQoKTsK
KworCWlmICh2Y3B1LT5hcmNoLmxhc3RfcnVuX2NwdSAhPSBjcHUgfHwKKwkJCXBlcl9jcHUobGFz
dF92Y3B1LCBjcHUpICE9IHZjcHUpIHsKKwkJcGVyX2NwdShsYXN0X3ZjcHUsIGNwdSkgPSB2Y3B1
OworCQl2Y3B1LT5hcmNoLmxhc3RfcnVuX2NwdSA9IGNwdTsKKwkJa3ZtX2ZsdXNoX3RsYl9hbGwo
KTsKKwl9CisKKwl2Y3B1LT5hcmNoLmhvc3RfcnI2ID0gaWE2NF9nZXRfcnIoUlI2KTsKKwl2dGlf
c2V0X3JyNih2Y3B1LT5hcmNoLnZtbV9ycik7CisJa3ZtX2luc2VydF92bW1fbWFwcGluZyh2Y3B1
KTsKK30KK3N0YXRpYyB2b2lkIGt2bV92Y3B1X3Bvc3RfdHJhbnNpdGlvbihzdHJ1Y3Qga3ZtX3Zj
cHUgKnZjcHUpCit7CisJa3ZtX3B1cmdlX3ZtbV9tYXBwaW5nKCk7CisJdnRpX3NldF9ycjYodmNw
dS0+YXJjaC5ob3N0X3JyNik7Cit9CisKK3ZvaWQgdnRpX3ZjcHVfcnVuKHN0cnVjdCBrdm1fdmNw
dSAqdmNwdSwgc3RydWN0IGt2bV9ydW4gKmt2bV9ydW4pCit7CisJY29udGV4dF90ICpob3N0X2N0
eCwgKmd1ZXN0X2N0eDsKKworCS8qR2V0IGhvc3QgYW5kIGd1ZXN0IGNvbnRleHQgd2l0aCBndWVz
dCBhZGRyZXNzIHNwYWNlLiovCisJaG9zdF9jdHggPSBrdm1fZ2V0X2hvc3RfY29udGV4dCh2Y3B1
KTsKKwlndWVzdF9jdHggPSBrdm1fZ2V0X2d1ZXN0X2NvbnRleHQodmNwdSk7CisKKwlrdm1fdmNw
dV9wcmVfdHJhbnNpdGlvbih2Y3B1KTsKKwlrdm1fdm1tX2luZm8tPnRyYW1wX2VudHJ5KGhvc3Rf
Y3R4LCBndWVzdF9jdHgpOworCWt2bV92Y3B1X3Bvc3RfdHJhbnNpdGlvbih2Y3B1KTsKK30KKwor
c3RhdGljIGludCBfX3ZjcHVfcnVuKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwgc3RydWN0IGt2bV9y
dW4gKmt2bV9ydW4pCit7CisJaW50IHI7CisKK2FnYWluOgorCXByZWVtcHRfZGlzYWJsZSgpOwor
CisJa3ZtX3ByZXBhcmVfZ3Vlc3Rfc3dpdGNoKHZjcHUpOworCWxvY2FsX2lycV9kaXNhYmxlKCk7
CisKKwlpZiAoc2lnbmFsX3BlbmRpbmcoY3VycmVudCkpIHsKKwkJbG9jYWxfaXJxX2VuYWJsZSgp
OworCQlwcmVlbXB0X2VuYWJsZSgpOworCQlyID0gLUVJTlRSOworCQlrdm1fcnVuLT5leGl0X3Jl
YXNvbiA9IEtWTV9FWElUX0lOVFI7CisJCWdvdG8gb3V0OworCX0KKworCXZjcHUtPmd1ZXN0X21v
ZGUgPSAxOworCWt2bV9ndWVzdF9lbnRlcigpOworCisJdnRpX3ZjcHVfcnVuKHZjcHUsIGt2bV9y
dW4pOworCisJdmNwdS0+YXJjaC5sYXVuY2hlZCA9IDE7CisJdmNwdS0+Z3Vlc3RfbW9kZSA9IDA7
CisJbG9jYWxfaXJxX2VuYWJsZSgpOworCisJLyoKKwkgKiBXZSBtdXN0IGhhdmUgYW4gaW5zdHJ1
Y3Rpb24gYmV0d2VlbiBsb2NhbF9pcnFfZW5hYmxlKCkgYW5kCisJICoga3ZtX2d1ZXN0X2V4aXQo
KSwgc28gdGhlIHRpbWVyIGludGVycnVwdCBpc24ndCBkZWxheWVkIGJ5CisJICogdGhlIGludGVy
cnVwdCBzaGFkb3cuICBUaGUgc3RhdC5leGl0cyBpbmNyZW1lbnQgd2lsbCBkbyBuaWNlbHkuCisJ
ICogQnV0IHdlIG5lZWQgdG8gcHJldmVudCByZW9yZGVyaW5nLCBoZW5jZSB0aGlzIGJhcnJpZXIo
KToKKwkgKi8KKwliYXJyaWVyKCk7CisKKwlrdm1fZ3Vlc3RfZXhpdCgpOworCisJcHJlZW1wdF9l
bmFibGUoKTsKKworCXIgPSBrdm1faGFuZGxlX2V4aXQoa3ZtX3J1biwgdmNwdSk7CisKKwlpZiAo
ciA+IDApIHsKKwkJaWYgKCFuZWVkX3Jlc2NoZWQoKSkKKwkJCWdvdG8gYWdhaW47CisJfQorCitv
dXQ6CisJaWYgKHIgPiAwKSB7CisJCWt2bV9yZXNjaGVkKHZjcHUpOworCQlnb3RvIGFnYWluOwor
CX0KKworCXJldHVybiByOworfQorCitzdGF0aWMgdm9pZCBrdm1fc2V0X21taW9fZGF0YShzdHJ1
Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7CisJaW9yZXFfdCAqcCA9IGt2bV9nZXRfdmNwdV9pb3JlcSh2
Y3B1KTsKKwlpZiAoIXZjcHUtPm1taW9faXNfd3JpdGUpCisJCW1lbWNweSgmcC0+ZGF0YSwgdmNw
dS0+bW1pb19kYXRhLCA4KTsKKwlwLT5zdGF0ZSA9IFNUQVRFX0lPUkVTUF9SRUFEWTsKK30KKwor
aW50IGt2bV9hcmNoX3ZjcHVfaW9jdGxfcnVuKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwgc3RydWN0
IGt2bV9ydW4gKmt2bV9ydW4pCit7CisJaW50IHI7CisJc2lnc2V0X3Qgc2lnc2F2ZWQ7CisKKwl2
Y3B1X2xvYWQodmNwdSk7CisKKwlpZiAodW5saWtlbHkodmNwdS0+YXJjaC5tcF9zdGF0ZSA9PSBW
Q1BVX01QX1NUQVRFX1VOSU5JVElBTElaRUQpKSB7CisJCWt2bV92Y3B1X2Jsb2NrKHZjcHUpOwor
CQl2Y3B1X3B1dCh2Y3B1KTsKKwkJcmV0dXJuIC1FQUdBSU47CisJfQorCisJaWYgKHZjcHUtPnNp
Z3NldF9hY3RpdmUpCisJCXNpZ3Byb2NtYXNrKFNJR19TRVRNQVNLLCAmdmNwdS0+c2lnc2V0LCAm
c2lnc2F2ZWQpOworCisJaWYgKHZjcHUtPm1taW9fbmVlZGVkKSB7CisJCW1lbWNweSh2Y3B1LT5t
bWlvX2RhdGEsIGt2bV9ydW4tPm1taW8uZGF0YSwgOCk7CisJCWt2bV9zZXRfbW1pb19kYXRhKHZj
cHUpOworCQl2Y3B1LT5tbWlvX3JlYWRfY29tcGxldGVkID0gMTsKKwkJdmNwdS0+bW1pb19uZWVk
ZWQgPSAwOworCX0KKwlyID0gX192Y3B1X3J1bih2Y3B1LCBrdm1fcnVuKTsKKworCWlmICh2Y3B1
LT5zaWdzZXRfYWN0aXZlKQorCQlzaWdwcm9jbWFzayhTSUdfU0VUTUFTSywgJnNpZ3NhdmVkLCBO
VUxMKTsKKworCXZjcHVfcHV0KHZjcHUpOworCXJldHVybiByOworfQorCisvKgorICogQWxsb2Nh
dGUgMTZNIG1lbW9yeSBmb3IgZXZlcnkgdm0gdG8gaG9sZCBpdHMgc3BlY2lmaWMgZGF0YS4KKyAq
IEl0cyBtZW1vcnkgbWFwIGlzIGRlZmluZWQgaW4ga3ZtX2hvc3QuaC4KKyAqLworc3RhdGljIHN0
cnVjdCBrdm0gKmt2bV9hbGxvY19rdm0odm9pZCkKK3sKKworCXN0cnVjdCBrdm0gKmt2bTsKKwl1
aW50NjRfdCAgdm1fYmFzZTsKKworCXZtX2Jhc2UgPSBfX2dldF9mcmVlX3BhZ2VzKEdGUF9LRVJO
RUwsIGdldF9vcmRlcihLVk1fVk1fREFUQV9TSVpFKSk7CisKKwlpZiAoIXZtX2Jhc2UpCisJCXJl
dHVybiBFUlJfUFRSKC1FTk9NRU0pOworCXByaW50ayhLRVJOX0RFQlVHImt2bTp2bSBkYXRhIGJh
c2UgYWRkcmVzczoweCVseFxuIiwgdm1fYmFzZSk7CisKKwkvKiBaZXJvIGFsbCBwYWdlcyBiZWZv
cmUgdXNlISAqLworCW1lbXNldCgodm9pZCAqKXZtX2Jhc2UsIDAsIEtWTV9WTV9EQVRBX1NJWkUp
OworCisJa3ZtID0gKHN0cnVjdCBrdm0gKikodm1fYmFzZSArIEtWTV9WTV9PRlMpOworCWt2bS0+
YXJjaC52bV9iYXNlID0gdm1fYmFzZTsKKworCXJldHVybiBrdm07Cit9CisKK3R5cGVkZWYgc3Ry
dWN0IGt2bV9pb19yYW5nZSB7CisJdW5zaWduZWQgbG9uZyBzdGFydDsKKwl1bnNpZ25lZCBsb25n
IHNpemU7CisJdW5zaWduZWQgbG9uZyB0eXBlOworfSBrdm1faW9fcmFuZ2VfdDsKKworc3RhdGlj
IGNvbnN0IGt2bV9pb19yYW5nZV90IGlvX3Jhbmdlc1tdID0geworCXtWR0FfSU9fU1RBUlQsIFZH
QV9JT19TSVpFLCBHUEZOX0ZSQU1FX0JVRkZFUn0sCisJe01NSU9fU1RBUlQsIE1NSU9fU0laRSwg
R1BGTl9MT1dfTU1JT30sCisJe0xFR0FDWV9JT19TVEFSVCwgTEVHQUNZX0lPX1NJWkUsIEdQRk5f
TEVHQUNZX0lPfSwKKwl7SU9fU0FQSUNfU1RBUlQsIElPX1NBUElDX1NJWkUsIEdQRk5fSU9TQVBJ
Q30sCisJe1BJQl9TVEFSVCwgUElCX1NJWkUsIEdQRk5fUElCfSwKK307CisKK3N0YXRpYyB2b2lk
IGt2bV9idWlsZF9pb19wbXQoc3RydWN0IGt2bSAqa3ZtKQoreworCXVuc2lnbmVkIGxvbmcgaSwg
ajsKKworCS8qIE1hcmsgSS9PIHJhbmdlcyAqLworCWZvciAoaSA9IDA7IGkgPCAoc2l6ZW9mKGlv
X3JhbmdlcykgLyBzaXplb2Yoa3ZtX2lvX3JhbmdlX3QpKTsgaSsrKSB7CisJCWZvciAoaiA9IGlv
X3Jhbmdlc1tpXS5zdGFydDsKKwkJCQlqIDwgaW9fcmFuZ2VzW2ldLnN0YXJ0ICsgaW9fcmFuZ2Vz
W2ldLnNpemU7CisJCQkJaiArPSBQQUdFX1NJWkUpCisJCQlrdm1fc2V0X3BtdF9lbnRyeShrdm0s
IGogPj4gUEFHRV9TSElGVCwKKwkJCQkJaW9fcmFuZ2VzW2ldLnR5cGUsIDApOworCX0KKworfQor
CisvKlVzZSB1bnVzZWQgcmlkcyB0byB2aXJ0dWFsaXplIGd1ZXN0IHJpZC4qLworI2RlZmluZSBH
VUVTVF9QSFlTSUNBTF9SUjAJMHgxNzM5CisjZGVmaW5lIEdVRVNUX1BIWVNJQ0FMX1JSNAkweDI3
MzkKKyNkZWZpbmUgVk1NX0lOSVRfUlIJCTB4MTY2MAorCitzdGF0aWMgdm9pZCBrdm1faW5pdF92
bShzdHJ1Y3Qga3ZtICprdm0pCit7CisJbG9uZyB2bV9iYXNlOworCisJQlVHX09OKCFrdm0pOwor
CisJa3ZtLT5hcmNoLm1ldGFwaHlzaWNhbF9ycjAgPSBHVUVTVF9QSFlTSUNBTF9SUjA7CisJa3Zt
LT5hcmNoLm1ldGFwaHlzaWNhbF9ycjQgPSBHVUVTVF9QSFlTSUNBTF9SUjQ7CisJa3ZtLT5hcmNo
LnZtbV9pbml0X3JyID0gVk1NX0lOSVRfUlI7CisKKwl2bV9iYXNlID0ga3ZtLT5hcmNoLnZtX2Jh
c2U7CisJaWYgKHZtX2Jhc2UpIHsKKwkJa3ZtLT5hcmNoLnZocHRfYmFzZSA9IHZtX2Jhc2UgKyBL
Vk1fVkhQVF9PRlM7CisJCWt2bS0+YXJjaC52dGxiX2Jhc2UgPSB2bV9iYXNlICsgS1ZNX1ZUTEJf
T0ZTOworCQlrdm0tPmFyY2gudnBkX2Jhc2UgID0gdm1fYmFzZSArIEtWTV9WUERfT0ZTOworCX0K
KworCS8qCisJICpGaWxsIFAyTSBlbnRyaWVzIGZvciBNTUlPL0lPIHJhbmdlcworCSAqLworCWt2
bV9idWlsZF9pb19wbXQoa3ZtKTsKKworfQorCitzdHJ1Y3QgIGt2bSAqa3ZtX2FyY2hfY3JlYXRl
X3ZtKHZvaWQpCit7CisJc3RydWN0IGt2bSAqa3ZtID0ga3ZtX2FsbG9jX2t2bSgpOworCisJaWYg
KElTX0VSUihrdm0pKQorCQlyZXR1cm4gRVJSX1BUUigtRU5PTUVNKTsKKwlrdm1faW5pdF92bShr
dm0pOworCisJcmV0dXJuIGt2bTsKKworfQorCitzdGF0aWMgaW50IGt2bV92bV9pb2N0bF9nZXRf
aXJxY2hpcChzdHJ1Y3Qga3ZtICprdm0sCisJCQkJCXN0cnVjdCBrdm1faXJxY2hpcCAqY2hpcCkK
K3sKKwlpbnQgcjsKKworCXIgPSAwOworCXN3aXRjaCAoY2hpcC0+Y2hpcF9pZCkgeworCWNhc2Ug
S1ZNX0lSUUNISVBfSU9BUElDOgorCQltZW1jcHkoJmNoaXAtPmNoaXAuaW9hcGljLCBpb2FwaWNf
aXJxY2hpcChrdm0pLAorCQkJCXNpemVvZihzdHJ1Y3Qga3ZtX2lvYXBpY19zdGF0ZSkpOworCQli
cmVhazsKKwlkZWZhdWx0OgorCQlyID0gLUVJTlZBTDsKKwkJYnJlYWs7CisJfQorCXJldHVybiBy
OworfQorCitzdGF0aWMgaW50IGt2bV92bV9pb2N0bF9zZXRfaXJxY2hpcChzdHJ1Y3Qga3ZtICpr
dm0sIHN0cnVjdCBrdm1faXJxY2hpcCAqY2hpcCkKK3sKKwlpbnQgcjsKKworCXIgPSAwOworCXN3
aXRjaCAoY2hpcC0+Y2hpcF9pZCkgeworCWNhc2UgS1ZNX0lSUUNISVBfSU9BUElDOgorCQltZW1j
cHkoaW9hcGljX2lycWNoaXAoa3ZtKSwKKwkJCQkmY2hpcC0+Y2hpcC5pb2FwaWMsCisJCQkJc2l6
ZW9mKHN0cnVjdCBrdm1faW9hcGljX3N0YXRlKSk7CisJCWJyZWFrOworCWRlZmF1bHQ6CisJCXIg
PSAtRUlOVkFMOworCQlicmVhazsKKwl9CisJcmV0dXJuIHI7Cit9CisKK2ludCBrdm1fYXJjaF92
Y3B1X2lvY3RsX3NldF9yZWdzKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwgc3RydWN0IGt2bV9yZWdz
ICpyZWdzKQoreworCXByaW50ayhLRVJOX1dBUk5JTkciRG9lc24ndCBzdXBwb3J0IGl0IHlldCEh
XG4iKTsKKwlyZXR1cm4gMDsKK30KKworbG9uZyBrdm1fYXJjaF92bV9pb2N0bChzdHJ1Y3QgZmls
ZSAqZmlscCwKKwkJdW5zaWduZWQgaW50IGlvY3RsLCB1bnNpZ25lZCBsb25nIGFyZykKK3sKKwlz
dHJ1Y3Qga3ZtICprdm0gPSBmaWxwLT5wcml2YXRlX2RhdGE7CisJdm9pZCBfX3VzZXIgKmFyZ3Ag
PSAodm9pZCBfX3VzZXIgKilhcmc7CisJaW50IHIgPSAtRUlOVkFMOworCisJc3dpdGNoIChpb2N0
bCkgeworCWNhc2UgS1ZNX1NFVF9NRU1PUllfUkVHSU9OOiB7CisJCXN0cnVjdCBrdm1fbWVtb3J5
X3JlZ2lvbiBrdm1fbWVtOworCQlzdHJ1Y3Qga3ZtX3VzZXJzcGFjZV9tZW1vcnlfcmVnaW9uIGt2
bV91c2Vyc3BhY2VfbWVtOworCisJCXIgPSAtRUZBVUxUOworCQlpZiAoY29weV9mcm9tX3VzZXIo
Jmt2bV9tZW0sIGFyZ3AsIHNpemVvZiBrdm1fbWVtKSkKKwkJCWdvdG8gb3V0OworCQlrdm1fdXNl
cnNwYWNlX21lbS5zbG90ID0ga3ZtX21lbS5zbG90OworCQlrdm1fdXNlcnNwYWNlX21lbS5mbGFn
cyA9IGt2bV9tZW0uZmxhZ3M7CisJCWt2bV91c2Vyc3BhY2VfbWVtLmd1ZXN0X3BoeXNfYWRkciA9
CisJCQkJCWt2bV9tZW0uZ3Vlc3RfcGh5c19hZGRyOworCQlrdm1fdXNlcnNwYWNlX21lbS5tZW1v
cnlfc2l6ZSA9IGt2bV9tZW0ubWVtb3J5X3NpemU7CisJCXIgPSBrdm1fdm1faW9jdGxfc2V0X21l
bW9yeV9yZWdpb24oa3ZtLAorCQkJCQkma3ZtX3VzZXJzcGFjZV9tZW0sIDApOworCQlpZiAocikK
KwkJCWdvdG8gb3V0OworCQlicmVhazsKKwkJfQorCWNhc2UgS1ZNX0NSRUFURV9JUlFDSElQOgor
CQlyID0gLUVGQVVMVDsKKwkJciA9IGt2bV9pb2FwaWNfaW5pdChrdm0pOworCQlpZiAocikKKwkJ
CWdvdG8gb3V0OworCQlicmVhazsKKwljYXNlIEtWTV9JUlFfTElORTogeworCQlzdHJ1Y3Qga3Zt
X2lycV9sZXZlbCBpcnFfZXZlbnQ7CisKKwkJciA9IC1FRkFVTFQ7CisJCWlmIChjb3B5X2Zyb21f
dXNlcigmaXJxX2V2ZW50LCBhcmdwLCBzaXplb2YgaXJxX2V2ZW50KSkKKwkJCWdvdG8gb3V0Owor
CQlpZiAoaXJxY2hpcF9pbl9rZXJuZWwoa3ZtKSkgeworCQkJbXV0ZXhfbG9jaygma3ZtLT5sb2Nr
KTsKKwkJCWt2bV9pb2FwaWNfc2V0X2lycShrdm0tPmFyY2gudmlvYXBpYywKKwkJCQkJCWlycV9l
dmVudC5pcnEsCisJCQkJCQlpcnFfZXZlbnQubGV2ZWwpOworCQkJbXV0ZXhfdW5sb2NrKCZrdm0t
PmxvY2spOworCQkJciA9IDA7CisJCX0KKwkJYnJlYWs7CisJCX0KKwljYXNlIEtWTV9HRVRfSVJR
Q0hJUDogeworCQkvKiAwOiBQSUMgbWFzdGVyLCAxOiBQSUMgc2xhdmUsIDI6IElPQVBJQyAqLwor
CQlzdHJ1Y3Qga3ZtX2lycWNoaXAgY2hpcDsKKworCQlyID0gLUVGQVVMVDsKKwkJaWYgKGNvcHlf
ZnJvbV91c2VyKCZjaGlwLCBhcmdwLCBzaXplb2YgY2hpcCkpCisJCQkJZ290byBvdXQ7CisJCXIg
PSAtRU5YSU87CisJCWlmICghaXJxY2hpcF9pbl9rZXJuZWwoa3ZtKSkKKwkJCWdvdG8gb3V0Owor
CQlyID0ga3ZtX3ZtX2lvY3RsX2dldF9pcnFjaGlwKGt2bSwgJmNoaXApOworCQlpZiAocikKKwkJ
CWdvdG8gb3V0OworCQlyID0gLUVGQVVMVDsKKwkJaWYgKGNvcHlfdG9fdXNlcihhcmdwLCAmY2hp
cCwgc2l6ZW9mIGNoaXApKQorCQkJCWdvdG8gb3V0OworCQlyID0gMDsKKwkJYnJlYWs7CisJCX0K
KwljYXNlIEtWTV9TRVRfSVJRQ0hJUDogeworCQkvKiAwOiBQSUMgbWFzdGVyLCAxOiBQSUMgc2xh
dmUsIDI6IElPQVBJQyAqLworCQlzdHJ1Y3Qga3ZtX2lycWNoaXAgY2hpcDsKKworCQlyID0gLUVG
QVVMVDsKKwkJaWYgKGNvcHlfZnJvbV91c2VyKCZjaGlwLCBhcmdwLCBzaXplb2YgY2hpcCkpCisJ
CQkJZ290byBvdXQ7CisJCXIgPSAtRU5YSU87CisJCWlmICghaXJxY2hpcF9pbl9rZXJuZWwoa3Zt
KSkKKwkJCWdvdG8gb3V0OworCQlyID0ga3ZtX3ZtX2lvY3RsX3NldF9pcnFjaGlwKGt2bSwgJmNo
aXApOworCQlpZiAocikKKwkJCWdvdG8gb3V0OworCQlyID0gMDsKKwkJYnJlYWs7CisJCX0KKwlk
ZWZhdWx0OgorCQk7CisJfQorb3V0OgorCXJldHVybiByOworfQorCitpbnQga3ZtX2FyY2hfdmNw
dV9pb2N0bF9zZXRfc3JlZ3Moc3RydWN0IGt2bV92Y3B1ICp2Y3B1LAorCQlzdHJ1Y3Qga3ZtX3Ny
ZWdzICpzcmVncykKK3sKKwlwcmludGsoS0VSTl9XQVJOSU5HImt2bTprdm1fYXJjaF92Y3B1X2lv
Y3RsX3NldF9zcmVncyBjYWxsZWQhIVxuIik7CisJcmV0dXJuIDA7Cit9CisKK2ludCBrdm1fYXJj
aF92Y3B1X2lvY3RsX2dldF9zcmVncyhzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUsCisJCXN0cnVjdCBr
dm1fc3JlZ3MgKnNyZWdzKQoreworCXByaW50ayhLRVJOX1dBUk5JTkcia3ZtOmt2bV9hcmNoX3Zj
cHVfaW9jdGxfZ2V0X3NyZWdzIGNhbGxlZCEhXG4iKTsKKwlyZXR1cm4gMDsKKworfQoraW50IGt2
bV9hcmNoX3ZjcHVfaW9jdGxfdHJhbnNsYXRlKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwKKwkJc3Ry
dWN0IGt2bV90cmFuc2xhdGlvbiAqdHIpCit7CisJcHJpbnRrKEtFUk5fV0FSTklORyJrdm06a3Zt
X2FyY2hfdmNwdV9pb2N0bF90cmFuc2xhdGUgY2FsbGVkISFcbiIpOworCisJcmV0dXJuIDA7Cit9
CisKK3N0YXRpYyBpbnQga3ZtX2FsbG9jX3ZtbV9hcmVhKHZvaWQpCit7CisJaWYgKCFrdm1fdm1t
X2Jhc2UgJiYgKGt2bV92bV9idWZmZXJfc2l6ZSA8IEtWTV9WTV9CVUZGRVJfU0laRSkpIHsKKwkJ
a3ZtX3ZtbV9iYXNlID0gX19nZXRfZnJlZV9wYWdlcyhHRlBfS0VSTkVMLAorCQkJCWdldF9vcmRl
cihLVk1fVk1NX1NJWkUpKTsKKwkJaWYgKCFrdm1fdm1tX2Jhc2UpCisJCQlyZXR1cm4gLUVOT01F
TTsKKworCQltZW1zZXQoKHZvaWQgKilrdm1fdm1tX2Jhc2UsIDAsIEtWTV9WTU1fU0laRSk7CisJ
CWt2bV92bV9idWZmZXIgPSBrdm1fdm1tX2Jhc2UgKyBWTU1fU0laRTsKKworCQlwcmludGsoS0VS
Tl9ERUJVRyJrdm06a3ZtX3ZtbV9iYXNlOjB4JWx4LCB2bV9idWZmZXI6MHglbHhcbiIsCisJCQkJ
a3ZtX3ZtbV9iYXNlLCBrdm1fdm1fYnVmZmVyKTsKKwl9CisKKwlyZXR1cm4gMDsKK30KKworc3Rh
dGljIHZvaWQga3ZtX2ZyZWVfdm1tX2FyZWEodm9pZCkKK3sKKwlpZiAoa3ZtX3ZtbV9iYXNlKSB7
CisJCS8qWmVybyB0aGlzIGFyZWEgYmVmb3JlIGZyZWUgdG8gYXZvaWQgYml0cyBsZWFrISEqLwor
CQltZW1zZXQoKHZvaWQgKilrdm1fdm1tX2Jhc2UsIDAsIEtWTV9WTU1fU0laRSk7CisJCWZyZWVf
cGFnZXMoa3ZtX3ZtbV9iYXNlLCBnZXRfb3JkZXIoS1ZNX1ZNTV9TSVpFKSk7CisJCWt2bV92bW1f
YmFzZSAgPSAwOworCQlrdm1fdm1fYnVmZmVyID0gMDsKKwkJa3ZtX3ZzYV9iYXNlID0gMDsKKwl9
Cit9CisKKy8qCisgKiBNYWtlIHN1cmUgdGhhdCBhIGNwdSB0aGF0IGlzIGJlaW5nIGhvdC11bnBs
dWdnZWQgZG9lcyBub3QgaGF2ZSBhbnkgdmNwdXMKKyAqIGNhY2hlZCBvbiBpdC4gTGVhdmUgaXQg
YXMgYmxhbmsgZm9yIElBNjQuCisgKi8KK3ZvaWQgZGVjYWNoZV92Y3B1c19vbl9jcHUoaW50IGNw
dSkKK3sKK30KKworc3RhdGljIHZvaWQgdnRpX3ZjcHVfbG9hZChzdHJ1Y3Qga3ZtX3ZjcHUgKnZj
cHUsIGludCBjcHUpCit7Cit9CisKK3N0YXRpYyBpbnQgdnRpX2luaXRfdnBkKHN0cnVjdCBrdm1f
dmNwdSAqdmNwdSkKK3sKKwlpbnQgaTsKKwljcHVpZDNfdCBjcHVpZDM7CisJc3RydWN0IHZwZCAq
dnBkID0gdG9faG9zdCh2Y3B1LT5rdm0sIHZjcHUtPmFyY2gudnBkKTsKKworCWlmIChJU19FUlIo
dnBkKSkKKwkJcmV0dXJuIFBUUl9FUlIodnBkKTsKKworCS8qIENQVUlEIGluaXQgKi8KKwlmb3Ig
KGkgPSAwOyBpIDwgNTsgaSsrKQorCQl2cGQtPnZjcHVpZFtpXSA9IGlhNjRfZ2V0X2NwdWlkKGkp
OworCisJLyogTGltaXQgdGhlIENQVUlEIG51bWJlciB0byA1ICovCisJY3B1aWQzLnZhbHVlID0g
dnBkLT52Y3B1aWRbM107CisJY3B1aWQzLm51bWJlciA9IDQ7CS8qIDUgLSAxICovCisJdnBkLT52
Y3B1aWRbM10gPSBjcHVpZDMudmFsdWU7CisKKwkvKlNldCB2YWMgYW5kIHZkYyBmaWVsZHMqLwor
CXZwZC0+dmFjLmFfZnJvbV9pbnRfY3IgPSAxOworCXZwZC0+dmFjLmFfdG9faW50X2NyID0gMTsK
Kwl2cGQtPnZhYy5hX2Zyb21fcHNyID0gMTsKKwl2cGQtPnZhYy5hX2Zyb21fY3B1aWQgPSAxOwor
CXZwZC0+dmFjLmFfY292ZXIgPSAxOworCXZwZC0+dmFjLmFfYnN3ID0gMTsKKwl2cGQtPnZhYy5h
X2ludCA9IDE7CisJdnBkLT52ZGMuZF92bXN3ID0gMTsKKworCS8qU2V0IHZpcnR1YWwgYnVmZmVy
Ki8KKwl2cGQtPnZpcnRfZW52X3ZhZGRyID0gS1ZNX1ZNX0JVRkZFUl9CQVNFOworCisJcmV0dXJu
IDA7Cit9CisKK3N0YXRpYyBpbnQgdnRpX2NyZWF0ZV92cChzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUp
Cit7CisJbG9uZyByZXQ7CisJdnBkX3QgKnZwZCA9IHZjcHUtPmFyY2gudnBkOworCXVuc2lnbmVk
IGxvbmcgIHZtbV9pdnQ7CisKKwl2bW1faXZ0ID0ga3ZtX3ZtbV9pbmZvLT52bW1faXZ0OworCisJ
cHJpbnRrKEtFUk5fREVCVUcgImt2bTogdmNwdTolcCxpdnQ6IDB4JWx4XG4iLCB2Y3B1LCB2bW1f
aXZ0KTsKKworCXJldCA9IGlhNjRfcGFsX3ZwX2NyZWF0ZSgodTY0ICopdnBkLCAodTY0ICopdm1t
X2l2dCwgMCk7CisKKwlpZiAocmV0KSB7CisJCXByaW50ayhLRVJOX0VSUiJrdm06IGlhNjRfcGFs
X3ZwX2NyZWF0ZSBmYWlsZWQhXG4iKTsKKwkJcmV0dXJuIC1FSU5WQUw7CisJfQorCXJldHVybiAw
OworfQorCitzdGF0aWMgdm9pZCBpbml0X3B0Y2VfaW5mbyhzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUp
Cit7CisJaWE2NF9wdGNlX2luZm9fdCBwdGNlID0gezB9OworCisJaWE2NF9nZXRfcHRjZSgmcHRj
ZSk7CisJdmNwdS0+YXJjaC5wdGNlX2Jhc2UgPSBwdGNlLmJhc2U7CisJdmNwdS0+YXJjaC5wdGNl
X2NvdW50WzBdID0gcHRjZS5jb3VudFswXTsKKwl2Y3B1LT5hcmNoLnB0Y2VfY291bnRbMV0gPSBw
dGNlLmNvdW50WzFdOworCXZjcHUtPmFyY2gucHRjZV9zdHJpZGVbMF0gPSBwdGNlLnN0cmlkZVsw
XTsKKwl2Y3B1LT5hcmNoLnB0Y2Vfc3RyaWRlWzFdID0gcHRjZS5zdHJpZGVbMV07Cit9CisKK3N0
YXRpYyBpbnQga3ZtX21pZ3JhdGVfaGx0X3RpbWVyKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSkKK3sK
KwlzdHJ1Y3QgaHJ0aW1lciAqcF9odCA9ICZ2Y3B1LT5hcmNoLmhsdF90aW1lcjsKKworCWlmICho
cnRpbWVyX2NhbmNlbChwX2h0KSkKKwkJaHJ0aW1lcl9zdGFydChwX2h0LCBwX2h0LT5leHBpcmVz
LCBIUlRJTUVSX01PREVfQUJTKTsKK30KKworc3RhdGljIGVudW0gaHJ0aW1lcl9yZXN0YXJ0IGhs
dF90aW1lcl9mbihzdHJ1Y3QgaHJ0aW1lciAqZGF0YSkKK3sKKwlzdHJ1Y3Qga3ZtX3ZjcHUgKnZj
cHU7CisJd2FpdF9xdWV1ZV9oZWFkX3QgKnE7CisKKwl2Y3B1ICA9IGNvbnRhaW5lcl9vZihkYXRh
LCBzdHJ1Y3Qga3ZtX3ZjcHUsIGFyY2guaGx0X3RpbWVyKTsKKwlpZiAodmNwdS0+YXJjaC5tcF9z
dGF0ZSAhPSBWQ1BVX01QX1NUQVRFX0hBTFRFRCkKKwkJZ290byBvdXQ7CisKKwlxID0gJnZjcHUt
PndxOworCWlmICh3YWl0cXVldWVfYWN0aXZlKHEpKSB7CisJCXZjcHUtPmFyY2gubXBfc3RhdGUg
PSBWQ1BVX01QX1NUQVRFX1JVTk5BQkxFOworCQl3YWtlX3VwX2ludGVycnVwdGlibGUocSk7CisJ
fQorb3V0OgorCXZjcHUtPmFyY2gudGltZXJfY2hlY2sgPSAxOworCXJldHVybiBIUlRJTUVSX05P
UkVTVEFSVDsKK30KKworI2RlZmluZSBQQUxFX1JFU0VUX0VOVFJZICAgIDB4ODAwMDAwMDBmZmZm
ZmZiMFVMCisKK2ludCBrdm1fYXJjaF92Y3B1X2luaXQoc3RydWN0IGt2bV92Y3B1ICp2Y3B1KQor
eworCXN0cnVjdCBwYWdlICpwYWdlOworCWludCByOworCXN0cnVjdCBrdm0gKmt2bSA9IHZjcHUt
Pmt2bTsKKwlzdHJ1Y3Qga3ZtX3B0X3JlZ3MgKnJlZ3MgPSB2Y3B1X3JlZ3ModmNwdSk7CisKKwlj
b250ZXh0X3QgKnBfY3R4ID0gJnZjcHUtPmFyY2guZ3Vlc3Q7CisJc3RydWN0IGt2bV92Y3B1ICp2
bW1fdmNwdSA9IHRvX2d1ZXN0KHZjcHUtPmt2bSwgdmNwdSk7CisKKwkvKkluaXQgdmNwdSBjb250
ZXh0IGZvciBmaXJzdCBydW4uKi8KKwlpZiAoSVNfRVJSKHZtbV92Y3B1KSkKKwkJcmV0dXJuIFBU
Ul9FUlIodm1tX3ZjcHUpOworCisJcGFnZSA9IGFsbG9jX3BhZ2UoR0ZQX0tFUk5FTCB8IF9fR0ZQ
X1pFUk8pOworCWlmICghcGFnZSkgeworCQlyID0gLUVOT01FTTsKKwkJZ290byBmYWlsOworCX0K
KworCWlmICh2Y3B1LT52Y3B1X2lkID09IDApIHsKKwkJdmNwdS0+YXJjaC5tcF9zdGF0ZSA9IFZD
UFVfTVBfU1RBVEVfUlVOTkFCTEU7CisJCXJlZ3MtPmNyX2lpcCA9IFBBTEVfUkVTRVRfRU5UUlk7
CisJfQorCisJZWxzZQorCQl2Y3B1LT5hcmNoLm1wX3N0YXRlID0gVkNQVV9NUF9TVEFURV9VTklO
SVRJQUxJWkVEOworCS8qRklYTUU6TmVlZCB0byByZW1vdmVkIGl0IGxhdGVyISFcbiovCisJdmNw
dS0+YXJjaC5hcGljID0ga3phbGxvYyhzaXplb2Yoc3RydWN0IGt2bV9sYXBpYyksIEdGUF9LRVJO
RUwpOworCXZjcHUtPmFyY2guYXBpYy0+dmNwdSA9IHZjcHU7CisKKwlwX2N0eC0+Z3JbMV0gPSAw
OworCXBfY3R4LT5nclsxMl0gPSAodW5zaWduZWQgbG9uZykoKGNoYXIgKil2bW1fdmNwdSArIElB
NjRfU1RLX09GRlNFVCk7CisJcF9jdHgtPmdyWzEzXSA9ICh1bnNpZ25lZCBsb25nKXZtbV92Y3B1
OworCXBfY3R4LT5wc3IgPSAweDEwMDg1MjIwMDBVTDsKKwlwX2N0eC0+YXJbNDBdID0gRlBTUl9E
RUZBVUxUOyAvKmZwc3IqLworCXBfY3R4LT5jYWxsZXJfdW5hdCA9IDA7CisJcF9jdHgtPnByID0g
MHgwOworCXBfY3R4LT5hclszNl0gPSAweDA7IC8qdW5hdCovCisJcF9jdHgtPmFyWzE5XSA9IDB4
MDsgLypybmF0Ki8KKwlwX2N0eC0+YXJbMThdID0gKHVuc2lnbmVkIGxvbmcpdm1tX3ZjcHUgKwor
CQkJCSgoc2l6ZW9mKHN0cnVjdCBrdm1fdmNwdSkrMTUpICYgfjE1KTsKKwlwX2N0eC0+YXJbNjRd
ID0gMHgwOyAvKnBmcyovCisJcF9jdHgtPmNyWzBdID0gMHg3ZTA0VUw7CisJcF9jdHgtPmNyWzJd
ID0gKHVuc2lnbmVkIGxvbmcpa3ZtX3ZtbV9pbmZvLT52bW1faXZ0OworCXBfY3R4LT5jcls4XSA9
IDB4M2M7CisKKwkvKkluaXRpbGl6ZSByZWdpb24gcmVnaXN0ZXIqLworCXBfY3R4LT5yclswXSA9
IDB4MzA7CisJcF9jdHgtPnJyWzFdID0gMHgzMDsKKwlwX2N0eC0+cnJbMl0gPSAweDMwOworCXBf
Y3R4LT5yclszXSA9IDB4MzA7CisJcF9jdHgtPnJyWzRdID0gMHgzMDsKKwlwX2N0eC0+cnJbNV0g
PSAweDMwOworCXBfY3R4LT5ycls3XSA9IDB4MzA7CisKKwkvKkluaXRpbGl6ZSBicmFuY2ggcmVn
aXN0ZXIgMCovCisJcF9jdHgtPmJyWzBdID0gKih1bnNpZ25lZCBsb25nICopa3ZtX3ZtbV9pbmZv
LT52bW1fZW50cnk7CisKKwl2Y3B1LT5hcmNoLnZtbV9yciA9IGt2bS0+YXJjaC52bW1faW5pdF9y
cjsKKwl2Y3B1LT5hcmNoLm1ldGFwaHlzaWNhbF9ycjAgPSBrdm0tPmFyY2gubWV0YXBoeXNpY2Fs
X3JyMDsKKwl2Y3B1LT5hcmNoLm1ldGFwaHlzaWNhbF9ycjQgPSBrdm0tPmFyY2gubWV0YXBoeXNp
Y2FsX3JyNDsKKworCWhydGltZXJfaW5pdCgmdmNwdS0+YXJjaC5obHRfdGltZXIsIENMT0NLX01P
Tk9UT05JQywgSFJUSU1FUl9NT0RFX0FCUyk7CisJdmNwdS0+YXJjaC5obHRfdGltZXIuZnVuY3Rp
b24gPSBobHRfdGltZXJfZm47CisKKwl2Y3B1LT5hcmNoLnZwZCA9ICh2cGRfdCAqKVZQRF9BRERS
KHZjcHUtPnZjcHVfaWQpOworCXZjcHUtPmFyY2gudnNhX2Jhc2UgPSBrdm1fdnNhX2Jhc2U7CisJ
dmNwdS0+YXJjaC5fX2dwID0ga3ZtX3ZtbV9ncDsKKwl2Y3B1LT5hcmNoLnZocHQuaGFzaCA9ICh0
aGFzaF9kYXRhX3QgKilWSFBUX0FERFIodmNwdS0+dmNwdV9pZCk7CisJdmNwdS0+YXJjaC52dGxi
Lmhhc2ggPSAodGhhc2hfZGF0YV90ICopVlRMQl9BRERSKHZjcHUtPnZjcHVfaWQpOworCWluaXRf
cHRjZV9pbmZvKHZjcHUpOworCisJcmV0dXJuIDA7CitmYWlsOgorCXJldHVybiByOworfQorCitz
dGF0aWMgaW50IHZ0aV92Y3B1X3NldHVwKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwgaW50IGlkKQor
eworCXVuc2lnbmVkIGxvbmcgcHNyOworCWludCByOworCisJbG9jYWxfaXJxX3NhdmUocHNyKTsK
Kwlrdm1faW5zZXJ0X3ZtbV9tYXBwaW5nKHZjcHUpOworCisJciA9IGt2bV92Y3B1X2luaXQodmNw
dSwgdmNwdS0+a3ZtLCBpZCk7CisJaWYgKHIpCisJCWdvdG8gZmFpbDsKKworCXIgPSB2dGlfaW5p
dF92cGQodmNwdSk7CisJaWYgKHIpIHsKKwkJcHJpbnRrKEtFUk5fREVCVUcia3ZtOiB2cGQgaW5p
dCBlcnJvciEhXG4iKTsKKwkJZ290byB1bmluaXQ7CisJfQorCisJciA9IHZ0aV9jcmVhdGVfdnAo
dmNwdSk7CisJaWYgKHIpCisJCWdvdG8gdW5pbml0OworCisJa3ZtX3B1cmdlX3ZtbV9tYXBwaW5n
KCk7CisJbG9jYWxfaXJxX3Jlc3RvcmUocHNyKTsKKworCXJldHVybiAwOwordW5pbml0OgorCWt2
bV92Y3B1X3VuaW5pdCh2Y3B1KTsKK2ZhaWw6CisJcmV0dXJuIHI7Cit9CisKK3N0cnVjdCBrdm1f
dmNwdSAqa3ZtX2FyY2hfdmNwdV9jcmVhdGUoc3RydWN0IGt2bSAqa3ZtLAorCQl1bnNpZ25lZCBp
bnQgaWQpCit7CisJc3RydWN0IGt2bV92Y3B1ICp2Y3B1OworCXVuc2lnbmVkIGxvbmcgdm1fYmFz
ZSA9IGt2bS0+YXJjaC52bV9iYXNlOworCWludCByOworCWludCBjcHU7CisKKwlyID0gLUVOT01F
TTsKKwlpZiAoIXZtX2Jhc2UpIHsKKwkJcHJpbnRrKEtFUk5fRVJSImt2bTogQ3JlYXRlIHZjcHVb
JWRdIGVycm9yIVxuIiwgaWQpOworCQlnb3RvIGZhaWw7CisJfQorCXZjcHUgPSAoc3RydWN0IGt2
bV92Y3B1ICopKHZtX2Jhc2UgKyBLVk1fVkNQVV9PRlMgKyBWQ1BVX1NJWkUgKiBpZCk7CisJdmNw
dS0+a3ZtID0ga3ZtOworCisJY3B1ID0gZ2V0X2NwdSgpOworCXZ0aV92Y3B1X2xvYWQodmNwdSwg
Y3B1KTsKKwlyID0gdnRpX3ZjcHVfc2V0dXAodmNwdSwgaWQpOworCXB1dF9jcHUoKTsKKworCWlm
IChyKSB7CisJCXByaW50ayhLRVJOX0RFQlVHImt2bTogdmNwdV9zZXR1cCBlcnJvciEhXG4iKTsK
KwkJZ290byBmYWlsOworCX0KKworCXJldHVybiB2Y3B1OworZmFpbDoKKwlyZXR1cm4gRVJSX1BU
UihyKTsKK30KKworaW50IGt2bV9hcmNoX3ZjcHVfc2V0dXAoc3RydWN0IGt2bV92Y3B1ICp2Y3B1
KQoreworCXJldHVybiAwOworfQorCitpbnQga3ZtX2FyY2hfdmNwdV9pb2N0bF9nZXRfZnB1KHN0
cnVjdCBrdm1fdmNwdSAqdmNwdSwgc3RydWN0IGt2bV9mcHUgKmZwdSkKK3sKKwlwcmludGsoS0VS
Tl9XQVJOSU5HImt2bTpJQTY0IGRvZXNuJ3QgbmVlZCB0byBleHBvcnQiCisJCQkiZnB1IHRvIHVz
ZXJzcGFjZSFcbiIpOworCXJldHVybiAwOworfQorCitpbnQga3ZtX2FyY2hfdmNwdV9pb2N0bF9z
ZXRfZnB1KHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwgc3RydWN0IGt2bV9mcHUgKmZwdSkKK3sKKwlw
cmludGsoS0VSTl9XQVJOSU5HImt2bTpJQTY0IGRvZXNuJ3QgbmVlZCB0byBleHBvcnQiCisJCQkJ
CSJmcHUgdG8gdXNlcnNwYWNlICFcbiIpOworCXJldHVybiAwOworfQorCitpbnQga3ZtX2FyY2hf
dmNwdV9pb2N0bF9kZWJ1Z19ndWVzdChzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUsCisJCXN0cnVjdCBr
dm1fZGVidWdfZ3Vlc3QgKmRiZykKK3sKKwlwcmludGsoS0VSTl9JTkZPIk5vdCBJbXBsZW1lbnRl
ZCB5ZXQhXG4iKTsKKwlyZXR1cm4gMDsKK30KKworc3RhdGljIHZvaWQgZnJlZV9rdm0oc3RydWN0
IGt2bSAqa3ZtKQoreworCXVuc2lnbmVkIGxvbmcgdm1fYmFzZSA9IGt2bS0+YXJjaC52bV9iYXNl
OworCisJaWYgKHZtX2Jhc2UpIHsKKwkJbWVtc2V0KCh2b2lkICopdm1fYmFzZSwgMCwgS1ZNX1ZN
X0RBVEFfU0laRSk7CisJCWZyZWVfcGFnZXModm1fYmFzZSwgZ2V0X29yZGVyKEtWTV9WTV9EQVRB
X1NJWkUpKTsKKwl9CisKK30KKworLypGSVhNRTpSZW1vdmUgaXQgb25jZSBzd2FwcGluZyByZWFk
eSEqLworc3RhdGljIHZvaWQga3ZtX3JlbGVhc2Vfdm1fcGFnZXMoc3RydWN0IGt2bSAqa3ZtKQor
eworCXN0cnVjdCBrdm1fbWVtb3J5X3Nsb3QgKm1lbXNsb3Q7CisJaW50IGksIGo7CisJdW5zaWdu
ZWQgbG9uZyBiYXNlX2dmbjsKKworCWZvciAoaSA9IDA7IGkgPCBrdm0tPm5tZW1zbG90czsgaSsr
KSB7CisJCW1lbXNsb3QgPSAma3ZtLT5tZW1zbG90c1tpXTsKKwkJYmFzZV9nZm4gPSBtZW1zbG90
LT5iYXNlX2dmbjsKKworCQlmb3IgKGogPSAwOyBqIDwgbWVtc2xvdC0+bnBhZ2VzOyBqKyspIHsK
KwkJCWlmIChtZW1zbG90LT5ybWFwW2pdKQorCQkJCXB1dF9wYWdlKChzdHJ1Y3QgcGFnZSAqKW1l
bXNsb3QtPnJtYXBbal0pOworCQl9CisJfQorfQorCit2b2lkIGt2bV9hcmNoX2Rlc3Ryb3lfdm0o
c3RydWN0IGt2bSAqa3ZtKQoreworCWtmcmVlKGt2bS0+YXJjaC52aW9hcGljKTsKKwlrdm1fcmVs
ZWFzZV92bV9wYWdlcyhrdm0pOworCWt2bV9mcmVlX3BoeXNtZW0oa3ZtKTsKKwlmcmVlX2t2bShr
dm0pOworfQorCit2b2lkIGt2bV9hcmNoX3ZjcHVfcHV0KHN0cnVjdCBrdm1fdmNwdSAqdmNwdSkK
K3sKKwkvKkZJWE1FOiBUbyBJbXBsZW1lbnQhISovCit9CisKK3ZvaWQga3ZtX2FyY2hfdmNwdV9s
b2FkKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwgaW50IGNwdSkKK3sKKwlpZiAoY3B1ICE9IHZjcHUt
PmNwdSkgeworCQl2Y3B1LT5jcHUgPSBjcHU7CisJCWlmICh2Y3B1LT5hcmNoLmh0X2FjdGl2ZSkK
KwkJCWt2bV9taWdyYXRlX2hsdF90aW1lcih2Y3B1KTsKKwl9Cit9CisKK2ludCBrdm1fYXJjaF92
Y3B1X2lvY3RsX2dldF9yZWdzKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwgc3RydWN0IGt2bV9yZWdz
ICpyZWdzKQoreworCXByaW50ayhLRVJOX0lORk8iTm8gbmVlZCB0byBpbXBsbWVudCBvbiBJQTY0
IVxuIik7CisJcmV0dXJuIDA7Cit9CisKK3ZvaWQga3ZtX2FyY2hfdmNwdV91bmluaXQoc3RydWN0
IGt2bV92Y3B1ICp2Y3B1KQoreworCisJaHJ0aW1lcl9jYW5jZWwoJnZjcHUtPmFyY2guaGx0X3Rp
bWVyKTsKKwlrZnJlZSh2Y3B1LT5hcmNoLmFwaWMpOworfQorCisKK2xvbmcga3ZtX2FyY2hfdmNw
dV9pb2N0bChzdHJ1Y3QgZmlsZSAqZmlscCwKKwkJdW5zaWduZWQgaW50IGlvY3RsLCB1bnNpZ25l
ZCBsb25nIGFyZykKK3sKKwlyZXR1cm4gLUVJTlZBTDsKK30KKworaW50IGt2bV9hcmNoX3NldF9t
ZW1vcnlfcmVnaW9uKHN0cnVjdCBrdm0gKmt2bSwKKwkJc3RydWN0IGt2bV91c2Vyc3BhY2VfbWVt
b3J5X3JlZ2lvbiAqbWVtLAorCQlzdHJ1Y3Qga3ZtX21lbW9yeV9zbG90IG9sZCwKKwkJaW50IHVz
ZXJfYWxsb2MpCit7CisJdW5zaWduZWQgbG9uZyBpOworCXN0cnVjdCBwYWdlICpwYWdlOworCWlu
dCBucGFnZXMgPSBtZW0tPm1lbW9yeV9zaXplID4+IFBBR0VfU0hJRlQ7CisJc3RydWN0IGt2bV9t
ZW1vcnlfc2xvdCAqbWVtc2xvdCA9ICZrdm0tPm1lbXNsb3RzW21lbS0+c2xvdF07CisJdW5zaWdu
ZWQgbG9uZyBiYXNlX2dmbiA9IG1lbXNsb3QtPmJhc2VfZ2ZuOworCisJZm9yIChpID0gMDsgaSA8
IG5wYWdlczsgaSsrKSB7CisJCXBhZ2UgPSBnZm5fdG9fcGFnZShrdm0sIGJhc2VfZ2ZuICsgaSk7
CisJCWt2bV9zZXRfcG10X2VudHJ5KGt2bSwgYmFzZV9nZm4gKyBpLAorCQkJCXBhZ2VfdG9fcGZu
KHBhZ2UpIDw8IFBBR0VfU0hJRlQsCisJCQkJX1BBR0VfQVJfUldYfF9QQUdFX01BX1dCKTsKKwkJ
bWVtc2xvdC0+cm1hcFtpXSA9ICh1bnNpZ25lZCBsb25nKXBhZ2U7CisJfQorCisJcmV0dXJuIDA7
Cit9CisKKworbG9uZyBrdm1fYXJjaF9kZXZfaW9jdGwoc3RydWN0IGZpbGUgKmZpbHAsCisJCXVu
c2lnbmVkIGludCBpb2N0bCwgdW5zaWduZWQgbG9uZyBhcmcpCit7CisJcmV0dXJuIC1FSU5WQUw7
Cit9CisKK3ZvaWQga3ZtX2FyY2hfdmNwdV9kZXN0cm95KHN0cnVjdCBrdm1fdmNwdSAqdmNwdSkK
K3sKKwlrdm1fdmNwdV91bmluaXQodmNwdSk7Cit9CisKK3N0YXRpYyBpbnQgdnRpX2NwdV9oYXNf
a3ZtX3N1cHBvcnQodm9pZCkKK3sKKwlsb25nICBhdmFpbCA9IDEsIHN0YXR1cyA9IDEsIGNvbnRy
b2wgPSAxOworCWxvbmcgcmV0OworCisJcmV0ID0gaWE2NF9wYWxfcHJvY19nZXRfZmVhdHVyZXMo
JmF2YWlsLCAmc3RhdHVzLCAmY29udHJvbCwgMCk7CisJaWYgKHJldCkKKwkJZ290byBvdXQ7CisK
KwlpZiAoIShhdmFpbCAmIFBBTF9QUk9DX1ZNX0JJVCkpCisJCWdvdG8gb3V0OworCisJcHJpbnRr
KEtFUk5fREVCVUcia3ZtOiBIYXJkd2FyZSBTdXBwb3J0cyBWVFxuIik7CisKKwlyZXQgPSBpYTY0
X3BhbF92cF9lbnZfaW5mbygma3ZtX3ZtX2J1ZmZlcl9zaXplLCAmdnBfZW52X2luZm8pOworCWlm
IChyZXQpCisJCWdvdG8gb3V0OworCXByaW50ayhLRVJOX0RFQlVHImt2bTogdm0gYnVmZmVyIHNp
emU6MHglbHhcbiIsIGt2bV92bV9idWZmZXJfc2l6ZSk7CisKKwlpZiAoISh2cF9lbnZfaW5mbyAm
IFZQX09QQ09ERSkpIHsKKwkJcHJpbnRrKEtFUk5fV0FSTklORyJObyBvcGNvZGUgYWJpbGl0eSBv
biBoYXJkd2FyZSxcCisJCQkJdm1fZW52X2luZm86MHglbHhcbiIsdnBfZW52X2luZm8pOworCX0K
KworCXJldHVybiAxOworb3V0OgorCXJldHVybiAwOworfQorCitzdGF0aWMgaW50IGt2bV9yZWxv
Y2F0ZV92bW0oc3RydWN0IGt2bV92bW1faW5mbyAqdm1tX2luZm8sCisJCQkJCQlzdHJ1Y3QgbW9k
dWxlICptb2R1bGUpCit7CisJdW5zaWduZWQgbG9uZyBtb2R1bGVfYmFzZTsKKwl1bnNpZ25lZCBs
b25nIHZtbV9zaXplOworCisJdW5zaWduZWQgbG9uZyB2bW1fb2Zmc2V0LCBmdW5jX29mZnNldCwg
ZmRlc2Nfb2Zmc2V0OworCXN0cnVjdCBmZGVzYyAqcF9mZGVzYzsKKworCUJVR19PTighbW9kdWxl
KTsKKworCWlmICgha3ZtX3ZtbV9iYXNlKSB7CisJCXByaW50aygia3ZtOiBrdm0gYXJlYSBkaWRu
J3QgaW5pdGlsaXplIHlldCEhXG4iKTsKKwkJcmV0dXJuIC1FSU5WQUw7CisJfQorCisJLypDYWxj
dWxhdGUgbmV3IHBvc2l0aW9uIG9mIHJlbG9jYXRlZCB2bW0gbW9kdWxlLiovCisJbW9kdWxlX2Jh
c2UgPSAodW5zaWduZWQgbG9uZyltb2R1bGUtPm1vZHVsZV9jb3JlOworCXZtbV9zaXplID0gbW9k
dWxlLT5jb3JlX3NpemU7CisJaWYgKHVubGlrZWx5KHZtbV9zaXplID4gS1ZNX1ZNTV9TSVpFKSkK
KwkJcmV0dXJuIC1FRkFVTFQ7CisKKwltZW1jcHkoKHZvaWQgKilrdm1fdm1tX2Jhc2UsICh2b2lk
ICopbW9kdWxlX2Jhc2UsIHZtbV9zaXplKTsKKwlrdm1fZmx1c2hfaWNhY2hlKGt2bV92bW1fYmFz
ZSwgdm1tX3NpemUpOworCisJLypSZWNhbGN1bGF0ZSBrdm1fdm1tX2luZm8gYmFzZWQgb24gbmV3
IFZNTSovCisJdm1tX29mZnNldCA9IHZtbV9pbmZvLT52bW1faXZ0IC0gbW9kdWxlX2Jhc2U7CisJ
a3ZtX3ZtbV9pbmZvLT52bW1faXZ0ID0gS1ZNX1ZNTV9CQVNFICsgdm1tX29mZnNldDsKKwlwcmlu
dGsoS0VSTl9ERUJVRyJrdm06IFJlbG9jYXRlZCBWTU0gaXZ0IGJhc2UgYWRkcjolbHhcbiIsCisJ
CQlrdm1fdm1tX2luZm8tPnZtbV9pdnQpOworCisJZmRlc2Nfb2Zmc2V0ID0gKHVuc2lnbmVkIGxv
bmcpdm1tX2luZm8tPnZtbV9lbnRyeSAtIG1vZHVsZV9iYXNlOworCWt2bV92bW1faW5mby0+dm1t
X2VudHJ5ID0gKGt2bV92bW1fZW50cnkgKikoS1ZNX1ZNTV9CQVNFICsKKwkJCQkJCQlmZGVzY19v
ZmZzZXQpOworCWZ1bmNfb2Zmc2V0ID0gKih1bnNpZ25lZCBsb25nICopdm1tX2luZm8tPnZtbV9l
bnRyeSAtIG1vZHVsZV9iYXNlOworCXBfZmRlc2MgPSAoc3RydWN0IGZkZXNjICopKGt2bV92bW1f
YmFzZSArIGZkZXNjX29mZnNldCk7CisJcF9mZGVzYy0+aXAgPSBLVk1fVk1NX0JBU0UgKyBmdW5j
X29mZnNldDsKKwlwX2ZkZXNjLT5ncCA9IEtWTV9WTU1fQkFTRSsocF9mZGVzYy0+Z3AgLSBtb2R1
bGVfYmFzZSk7CisKKwlwcmludGsoS0VSTl9ERUJVRyJHdWVzdCBWTU0gaW5pdCBlbnRyeSBhZGRy
OiVseFxuIiwKKwkJCUtWTV9WTU1fQkFTRStmdW5jX29mZnNldCk7CisKKwlmZGVzY19vZmZzZXQg
PSAodW5zaWduZWQgbG9uZyl2bW1faW5mby0+dHJhbXBfZW50cnkgLSBtb2R1bGVfYmFzZTsKKwlr
dm1fdm1tX2luZm8tPnRyYW1wX2VudHJ5ID0gKGt2bV90cmFtcF9lbnRyeSAqKShLVk1fVk1NX0JB
U0UgKworCQkJZmRlc2Nfb2Zmc2V0KTsKKwlmdW5jX29mZnNldCA9ICoodW5zaWduZWQgbG9uZyAq
KXZtbV9pbmZvLT50cmFtcF9lbnRyeSAtIG1vZHVsZV9iYXNlOworCXBfZmRlc2MgPSAoc3RydWN0
IGZkZXNjICopKGt2bV92bW1fYmFzZSArIGZkZXNjX29mZnNldCk7CisJcF9mZGVzYy0+aXAgPSBL
Vk1fVk1NX0JBU0UgKyBmdW5jX29mZnNldDsKKwlwX2ZkZXNjLT5ncCA9IEtWTV9WTU1fQkFTRSAr
IChwX2ZkZXNjLT5ncCAtIG1vZHVsZV9iYXNlKTsKKworCWt2bV92bW1fZ3AgPSBwX2ZkZXNjLT5n
cDsKKworCXByaW50ayhLRVJOX0RFQlVHImt2bTogdm1tJ3MgZmRlc2M6JXBcbiIsIHBfZmRlc2Mp
OworCXByaW50ayhLRVJOX0RFQlVHImt2bTogdm1tX2VudHJ5IGlwOiVwXG4iLCBrdm1fdm1tX2lu
Zm8tPnZtbV9lbnRyeSk7CisJcHJpbnRrKEtFUk5fREVCVUcia3ZtOiB2bW0gdHJhbXBvbGluZSBl
bnRyeSBpcDoweCVseFxuIiwKKwkJCQkJCUtWTV9WTU1fQkFTRSArIGZ1bmNfb2Zmc2V0KTsKKwor
CXJldHVybiAwOworfQorCitpbnQga3ZtX2FyY2hfaW5pdCh2b2lkICpvcGFxdWUpCit7CisJaW50
IHI7CisJc3RydWN0IGt2bV92bW1faW5mbyAqdm1tX2luZm8gPSAoc3RydWN0IGt2bV92bW1faW5m
byAqKW9wYXF1ZTsKKworCWlmICghdnRpX2NwdV9oYXNfa3ZtX3N1cHBvcnQoKSkgeworCQlwcmlu
dGsoS0VSTl9FUlIgImt2bTogbm8gaGFyZHdhcmUgc3VwcG9ydFxuIik7CisJCXIgPSAtRU9QTk9U
U1VQUDsKKwkJZ290byBvdXQ7CisJfQorCisJaWYgKGt2bV92bW1faW5mbykgeworCQlwcmludGso
S0VSTl9FUlIgImt2bTogYWxyZWFkeSBsb2FkZWQgdGhlIG90aGVyIG1vZHVsZSFcbiIpOworCQly
ID0gLUVFWElTVDsKKwkJZ290byBvdXQ7CisJfQorCisJciA9IC1FTk9NRU07CisJa3ZtX3ZtbV9p
bmZvID0ga3phbGxvYyhzaXplb2Yoc3RydWN0IGt2bV92bW1faW5mbyksIEdGUF9LRVJORUwpOwor
CWlmICgha3ZtX3ZtbV9pbmZvKQorCQlnb3RvIG91dDsKKworCWlmIChrdm1fYWxsb2Nfdm1tX2Fy
ZWEoKSkKKwkJZ290byBvdXRfZnJlZTA7CisKKwlyID0ga3ZtX3JlbG9jYXRlX3ZtbSh2bW1faW5m
bywgdm1tX2luZm8tPm1vZHVsZSk7CisJaWYgKHIpCisJCWdvdG8gb3V0X2ZyZWUxOworCisJcmV0
dXJuIDA7CisKK291dF9mcmVlMToKKwlrdm1fZnJlZV92bW1fYXJlYSgpOworb3V0X2ZyZWUwOgor
CWtmcmVlKGt2bV92bW1faW5mbyk7CitvdXQ6CisJcmV0dXJuIHI7Cit9CisKK3ZvaWQga3ZtX2Fy
Y2hfZXhpdCh2b2lkKQoreworCWt2bV9mcmVlX3ZtbV9hcmVhKCk7CisJa2ZyZWUoa3ZtX3ZtbV9p
bmZvKTsKKwlrdm1fdm1tX2luZm8gPSBOVUxMOworfQorCitpbnQga3ZtX3ZtX2lvY3RsX2dldF9k
aXJ0eV9sb2coc3RydWN0IGt2bSAqa3ZtLAorCQlzdHJ1Y3Qga3ZtX2RpcnR5X2xvZyAqbG9nKQor
eworCXByaW50ayhLRVJOX1dBUk5JTkciTmVlZCB0byBpbXBsZW1lbnQgbGF0ZXIhXG4iKTsKKwly
ZXR1cm4gMDsKK30KKworaW50IGt2bV9hcmNoX2hhcmR3YXJlX3NldHVwKHZvaWQpCit7CisJcmV0
dXJuIDA7Cit9CisKK3ZvaWQga3ZtX2FyY2hfaGFyZHdhcmVfdW5zZXR1cCh2b2lkKQoreworfQor
CitzdGF0aWMgdm9pZCB2Y3B1X2tpY2tfaW50cih2b2lkICppbmZvKQoreworI2lmZGVmIERFQlVH
CisJc3RydWN0IGt2bV92Y3B1ICp2Y3B1ID0gKHN0cnVjdCBrdm1fdmNwdSAqKWluZm87CisJcHJp
bnRrKEtFUk5fREVCVUcidmNwdV9raWNrX2ludHIgJXAgXG4iLCB2Y3B1KTsKKyNlbmRpZgorfQor
Cit2b2lkIGt2bV92Y3B1X2tpY2soc3RydWN0IGt2bV92Y3B1ICp2Y3B1KQoreworCWludCBpcGlf
cGNwdSA9IHZjcHUtPmNwdTsKKworCWlmICh3YWl0cXVldWVfYWN0aXZlKCZ2Y3B1LT53cSkpIHsK
KwkJd2FrZV91cF9pbnRlcnJ1cHRpYmxlKCZ2Y3B1LT53cSk7CisJfQorCWlmICh2Y3B1LT5ndWVz
dF9tb2RlKQorCQlzbXBfY2FsbF9mdW5jdGlvbl9zaW5nbGUoaXBpX3BjcHUsIHZjcHVfa2lja19p
bnRyLCB2Y3B1LCAwLCAwKTsKK30KKworaW50IGt2bV9hcGljX3NldF9pcnEoc3RydWN0IGt2bV92
Y3B1ICp2Y3B1LCB1OCB2ZWMsIHU4IHRyaWcpCit7CisKKwlzdHJ1Y3QgdnBkICp2cGQgPSB0b19o
b3N0KHZjcHUtPmt2bSwgdmNwdS0+YXJjaC52cGQpOworCisJaWYgKCF0ZXN0X2FuZF9zZXRfYml0
KHZlYywgJnZwZC0+aXJyWzBdKSkgeworCQl2Y3B1LT5hcmNoLmlycV9uZXdfcGVuZGluZyA9IDE7
CisJCSBpZiAodmNwdS0+YXJjaC5tcF9zdGF0ZSA9PSBWQ1BVX01QX1NUQVRFX1JVTk5BQkxFKQor
CQkJa3ZtX3ZjcHVfa2ljayh2Y3B1KTsKKwkJZWxzZSBpZiAodmNwdS0+YXJjaC5tcF9zdGF0ZSA9
PSBWQ1BVX01QX1NUQVRFX0hBTFRFRCkgeworCQkJdmNwdS0+YXJjaC5tcF9zdGF0ZSA9IFZDUFVf
TVBfU1RBVEVfUlVOTkFCTEU7CisJCQlpZiAod2FpdHF1ZXVlX2FjdGl2ZSgmdmNwdS0+d3EpKQor
CQkJCXdha2VfdXBfaW50ZXJydXB0aWJsZSgmdmNwdS0+d3EpOworCQl9CisJCXJldHVybiAxOwor
CX0KKwlyZXR1cm4gMDsKK30KKworaW50IGt2bV9hcGljX21hdGNoX3BoeXNpY2FsX2FkZHIoc3Ry
dWN0IGt2bV9sYXBpYyAqYXBpYywgdTE2IGRlc3QpCit7CisJcmV0dXJuIGFwaWMtPnZjcHUtPnZj
cHVfaWQgPT0gZGVzdDsKK30KKworaW50IGt2bV9hcGljX21hdGNoX2xvZ2ljYWxfYWRkcihzdHJ1
Y3Qga3ZtX2xhcGljICphcGljLCB1OCBtZGEpCit7CisJcmV0dXJuIDA7Cit9CisKK3N0cnVjdCBr
dm1fdmNwdSAqa3ZtX2dldF9sb3dlc3RfcHJpb192Y3B1KHN0cnVjdCBrdm0gKmt2bSwgdTggdmVj
dG9yLAorCQkJCSAgICAgICB1bnNpZ25lZCBsb25nIGJpdG1hcCkKK3sKKwlzdHJ1Y3Qga3ZtX3Zj
cHUgKmx2Y3B1ID0ga3ZtLT52Y3B1c1swXTsKKwlpbnQgaTsKKworCWZvciAoaSA9IDE7IGkgPCBL
Vk1fTUFYX1ZDUFVTOyBpKyspIHsKKwkJaWYgKCFrdm0tPnZjcHVzW2ldKQorCQkJY29udGludWU7
CisJCWlmIChsdmNwdS0+YXJjaC54dHAgPiBrdm0tPnZjcHVzW2ldLT5hcmNoLnh0cCkKKwkJCWx2
Y3B1ID0ga3ZtLT52Y3B1c1tpXTsKKwl9CisKKwlyZXR1cm4gbHZjcHU7Cit9CisKK3N0YXRpYyBp
bnQgZmluZF9oaWdoZXN0X2JpdHMoaW50ICpkYXQpCit7CisJdTMyICBiaXRzLCBiaXRudW07CisJ
aW50IGk7CisKKwkvKiBsb29wIGZvciBhbGwgMjU2IGJpdHMgKi8KKwlmb3IgKGkgPSA3OyBpID49
IDAgOyBpLS0pIHsKKwkJYml0cyA9IGRhdFtpXTsKKwkJaWYgKGJpdHMpIHsKKwkJCWJpdG51bSA9
IGZscyhiaXRzKTsKKwkJCXJldHVybiBpICogMzIgKyBiaXRudW0gLSAxOworCQl9CisJfQorCisJ
cmV0dXJuIC0xOworfQorCitpbnQga3ZtX2hpZ2hlc3RfcGVuZGluZ19pcnEoc3RydWN0IGt2bV92
Y3B1ICp2Y3B1KQoreworICAgIHN0cnVjdCB2cGQgKnZwZCA9IHRvX2hvc3QodmNwdS0+a3ZtLCB2
Y3B1LT5hcmNoLnZwZCk7CisKKyAgICBpZiAodnBkLT5pcnJbMF0gJiAoMVVMIDw8IE5NSV9WRUNU
T1IpKQorCQlyZXR1cm4gTk1JX1ZFQ1RPUjsKKyAgICBpZiAodnBkLT5pcnJbMF0gJiAoMVVMIDw8
IEV4dElOVF9WRUNUT1IpKQorCQlyZXR1cm4gRXh0SU5UX1ZFQ1RPUjsKKworICAgIHJldHVybiBm
aW5kX2hpZ2hlc3RfYml0cygoaW50ICopJnZwZC0+aXJyWzBdKTsKK30KKworaW50IGt2bV9jcHVf
aGFzX2ludGVycnVwdChzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUpCit7CisJaWYgKGt2bV9oaWdoZXN0
X3BlbmRpbmdfaXJxKHZjcHUpICE9IC0xKQorCQlyZXR1cm4gMTsKKwlyZXR1cm4gMDsKK30KKwor
Z2ZuX3QgdW5hbGlhc19nZm4oc3RydWN0IGt2bSAqa3ZtLCBnZm5fdCBnZm4pCit7CisJcmV0dXJu
IGdmbjsKK30KKworaW50IGt2bV9hcmNoX3ZjcHVfcnVubmFibGUoc3RydWN0IGt2bV92Y3B1ICp2
Y3B1KQoreworCXJldHVybiB2Y3B1LT5hcmNoLm1wX3N0YXRlID09IFZDUFVfTVBfU1RBVEVfUlVO
TkFCTEU7Cit9CisKLS0gCjEuNS4xCgo=

------_=_NextPart_001_01C863F4.1AACE3C7--
