From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Tue, 01 Apr 2008 10:46:53 +0000
Subject: [08/18][PATCH] KVM:IA64 : Add TLB virtulization support. V9
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC01048727@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C893E5.B32697C7"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C893E5.B32697C7
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 2d624a8e44bb284224820cd61fe2f0975c029fda Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Tue, 1 Apr 2008 14:50:59 +0800
Subject: [PATCH] KVM:IA64 : Add TLB virtulization support.

vtlb.c includes tlb/VHPT virtulization.
Signed-off-by: Anthony Xu <anthony.xu@intel.com>
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/vtlb.c |  636
++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 636 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/vtlb.c

diff --git a/arch/ia64/kvm/vtlb.c b/arch/ia64/kvm/vtlb.c
new file mode 100644
index 0000000..def4576
--- /dev/null
+++ b/arch/ia64/kvm/vtlb.c
@@ -0,0 +1,636 @@
+/*
+ * vtlb.c: guest virtual tlb handling module.
+ * Copyright (c) 2004, Intel Corporation.
+ *  Yaozu Dong (Eddie Dong) <Eddie.dong@intel.com>
+ *  Xuefei Xu (Anthony Xu) <anthony.xu@intel.com>
+ *
+ * Copyright (c) 2007, Intel Corporation.
+ *  Xuefei Xu (Anthony Xu) <anthony.xu@intel.com>
+ *  Xiantao Zhang <xiantao.zhang@intel.com>
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
+#include "vcpu.h"
+
+#include <linux/rwsem.h>
+
+#include <asm/tlb.h>
+
+/*
+ * Check to see if the address rid:va is translated by the TLB
+ */
+
+static int __is_tr_translated(struct thash_data *trp, u64 rid, u64 va)
+{
+	return ((trp->p) && (trp->rid =3D=3D rid)
+				&& ((va-trp->vadr) < PSIZE(trp->ps)));
+}
+
+/*
+ * Only for GUEST TR format.
+ */
+static int __is_tr_overlap(struct thash_data *trp, u64 rid, u64 sva,
u64 eva)
+{
+	u64 sa1, ea1;
+
+	if (!trp->p || trp->rid !=3D rid)
+		return 0;
+
+	sa1 =3D trp->vadr;
+	ea1 =3D sa1 + PSIZE(trp->ps) - 1;
+	eva -=3D 1;
+	if ((sva > ea1) || (sa1 > eva))
+		return 0;
+	else
+		return 1;
+
+}
+
+void machine_tlb_purge(u64 va, u64 ps)
+{
+	ia64_ptcl(va, ps << 2);
+}
+
+void local_flush_tlb_all(void)
+{
+	int i, j;
+	unsigned long flags, count0, count1;
+	unsigned long stride0, stride1, addr;
+
+	addr    =3D current_vcpu->arch.ptce_base;
+	count0  =3D current_vcpu->arch.ptce_count[0];
+	count1  =3D current_vcpu->arch.ptce_count[1];
+	stride0 =3D current_vcpu->arch.ptce_stride[0];
+	stride1 =3D current_vcpu->arch.ptce_stride[1];
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
+	ia64_srlz_i();          /* srlz.i implies srlz.d */
+}
+
+int vhpt_enabled(struct kvm_vcpu *vcpu, u64 vadr, enum vhpt_ref ref)
+{
+	union ia64_rr    vrr;
+	union ia64_pta   vpta;
+	struct  ia64_psr   vpsr;
+
+	vpsr =3D *(struct ia64_psr *)&VCPU(vcpu, vpsr);
+	vrr.val =3D vcpu_get_rr(vcpu, vadr);
+	vpta.val =3D vcpu_get_pta(vcpu);
+
+	if (vrr.ve & vpta.ve) {
+		switch (ref) {
+		case DATA_REF:
+		case NA_REF:
+			return vpsr.dt;
+		case INST_REF:
+			return vpsr.dt && vpsr.it && vpsr.ic;
+		case RSE_REF:
+			return vpsr.dt && vpsr.rt;
+
+		}
+	}
+	return 0;
+}
+
+struct thash_data *vsa_thash(union ia64_pta vpta, u64 va, u64 vrr, u64
*tag)
+{
+	u64 index, pfn, rid, pfn_bits;
+
+	pfn_bits =3D vpta.size - 5 - 8;
+	pfn =3D REGION_OFFSET(va) >> _REGION_PAGE_SIZE(vrr);
+	rid =3D _REGION_ID(vrr);
+	index =3D ((rid & 0xff) << pfn_bits)|(pfn & ((1UL << pfn_bits) -
1));
+	*tag =3D ((rid >> 8) & 0xffff) | ((pfn >> pfn_bits) << 16);
+
+	return (struct thash_data *)((vpta.base << PTA_BASE_SHIFT) +
+				(index << 5));
+}
+
+struct thash_data *__vtr_lookup(struct kvm_vcpu *vcpu, u64 va, int
type)
+{
+
+	struct thash_data *trp;
+	int  i;
+	u64 rid;
+
+	rid =3D vcpu_get_rr(vcpu, va);
+	rid =3D rid & RR_RID_MASK;;
+	if (type =3D=3D D_TLB) {
+		if (vcpu_quick_region_check(vcpu->arch.dtr_regions, va))
{
+			for (trp =3D (struct thash_data
*)&vcpu->arch.dtrs, i =3D 0;
+						i < NDTRS; i++, trp++) {
+				if (__is_tr_translated(trp, rid, va))
+					return trp;
+			}
+		}
+	} else {
+		if (vcpu_quick_region_check(vcpu->arch.itr_regions, va))
{
+			for (trp =3D (struct thash_data
*)&vcpu->arch.itrs, i =3D 0;
+					i < NITRS; i++, trp++) {
+				if (__is_tr_translated(trp, rid, va))
+					return trp;
+			}
+		}
+	}
+
+	return NULL;
+}
+
+static void vhpt_insert(u64 pte, u64 itir, u64 ifa, u64 gpte)
+{
+	union ia64_rr rr;
+	struct thash_data *head;
+	unsigned long ps, gpaddr;
+
+	ps =3D itir_ps(itir);
+
+	gpaddr =3D ((gpte & _PAGE_PPN_MASK) >> ps << ps) |
+		(ifa & ((1UL << ps) - 1));
+
+	rr.val =3D ia64_get_rr(ifa);
+	head =3D (struct thash_data *)ia64_thash(ifa);
+	head->etag =3D INVALID_TI_TAG;
+	ia64_mf();
+	head->page_flags =3D pte & ~PAGE_FLAGS_RV_MASK;
+	head->itir =3D rr.ps << 2;
+	head->etag =3D ia64_ttag(ifa);
+	head->gpaddr =3D gpaddr;
+}
+
+void mark_pages_dirty(struct kvm_vcpu *v, u64 pte, u64 ps)
+{
+	u64 i, dirty_pages =3D 1;
+	u64 base_gfn =3D (pte&_PAGE_PPN_MASK) >> PAGE_SHIFT;
+	spinlock_t *lock =3D __kvm_va(v->arch.dirty_log_lock_pa);
+	void *dirty_bitmap =3D (void *)v - (KVM_VCPU_OFS + v->vcpu_id *
VCPU_SIZE)
+						+ KVM_MEM_DIRTY_LOG_OFS;
+	dirty_pages <<=3D ps <=3D PAGE_SHIFT ? 0 : ps - PAGE_SHIFT;
+
+	vmm_spin_lock(lock);
+	for (i =3D 0; i < dirty_pages; i++) {
+		/* avoid RMW */
+		if (!test_bit(base_gfn + i, dirty_bitmap))
+			set_bit(base_gfn + i , dirty_bitmap);
+	}
+	vmm_spin_unlock(lock);
+}
+
+void thash_vhpt_insert(struct kvm_vcpu *v, u64 pte, u64 itir, u64 va,
int type)
+{
+	u64 phy_pte, psr;
+	union ia64_rr mrr;
+
+	mrr.val =3D ia64_get_rr(va);
+	phy_pte =3D translate_phy_pte(&pte, itir, va);
+
+	if (itir_ps(itir) >=3D mrr.ps) {
+		vhpt_insert(phy_pte, itir, va, pte);
+	} else {
+		phy_pte  &=3D ~PAGE_FLAGS_RV_MASK;
+		psr =3D ia64_clear_ic();
+		ia64_itc(type, va, phy_pte, itir_ps(itir));
+		ia64_set_psr(psr);
+	}
+
+	if (!(pte&VTLB_PTE_IO))
+		mark_pages_dirty(v, pte, itir_ps(itir));
+}
+
+/*
+ *   vhpt lookup
+ */
+struct thash_data *vhpt_lookup(u64 va)
+{
+	struct thash_data *head;
+	u64 tag;
+
+	head =3D (struct thash_data *)ia64_thash(va);
+	tag =3D ia64_ttag(va);
+	if (head->etag =3D=3D tag)
+		return head;
+	return NULL;
+}
+
+u64 guest_vhpt_lookup(u64 iha, u64 *pte)
+{
+	u64 ret;
+	struct thash_data *data;
+
+	data =3D __vtr_lookup(current_vcpu, iha, D_TLB);
+	if (data !=3D NULL)
+		thash_vhpt_insert(current_vcpu, data->page_flags,
+			data->itir, iha, D_TLB);
+
+	asm volatile ("rsm psr.ic|psr.i;;"
+			"srlz.d;;"
+			"ld8.s r9=3D[%1];;"
+			"tnat.nz p6,p7=3Dr9;;"
+			"(p6) mov %0=3D1;"
+			"(p6) mov r9=3Dr0;"
+			"(p7) extr.u r9=3Dr9,0,53;;"
+			"(p7) mov %0=3Dr0;"
+			"(p7) st8 [%2]=3Dr9;;"
+			"ssm psr.ic;;"
+			"srlz.d;;"
+			/* "ssm psr.i;;" Once interrupts in vmm open,
need fix*/
+			: "=3Dr"(ret) : "r"(iha), "r"(pte):"memory");
+
+	return ret;
+}
+
+/*
+ *  purge software guest tlb
+ */
+
+static void vtlb_purge(struct kvm_vcpu *v, u64 va, u64 ps)
+{
+	struct thash_data *cur;
+	u64 start, curadr, size, psbits, tag, rr_ps, num;
+	union ia64_rr vrr;
+	struct thash_cb *hcb =3D &v->arch.vtlb;
+
+	vrr.val =3D vcpu_get_rr(v, va);
+	psbits =3D VMX(v, psbits[(va >> 61)]);
+	start =3D va & ~((1UL << ps) - 1);
+	while (psbits) {
+		curadr =3D start;
+		rr_ps =3D __ffs(psbits);
+		psbits &=3D ~(1UL << rr_ps);
+		num =3D 1UL << ((ps < rr_ps) ? 0 : (ps - rr_ps));
+		size =3D PSIZE(rr_ps);
+		vrr.ps =3D rr_ps;
+		while (num) {
+			cur =3D vsa_thash(hcb->pta, curadr, vrr.val,
&tag);
+			if (cur->etag =3D=3D tag && cur->ps =3D=3D rr_ps)
+				cur->etag =3D INVALID_TI_TAG;
+			curadr +=3D size;
+			num--;
+		}
+	}
+}
+
+
+/*
+ *  purge VHPT and machine TLB
+ */
+static void vhpt_purge(struct kvm_vcpu *v, u64 va, u64 ps)
+{
+	struct thash_data *cur;
+	u64 start, size, tag, num;
+	union ia64_rr rr;
+
+	start =3D va & ~((1UL << ps) - 1);
+	rr.val =3D ia64_get_rr(va);
+	size =3D PSIZE(rr.ps);
+	num =3D 1UL << ((ps < rr.ps) ? 0 : (ps - rr.ps));
+	while (num) {
+		cur =3D (struct thash_data *)ia64_thash(start);
+		tag =3D ia64_ttag(start);
+		if (cur->etag =3D=3D tag)
+			cur->etag =3D INVALID_TI_TAG;
+		start +=3D size;
+		num--;
+	}
+	machine_tlb_purge(va, ps);
+}
+
+/*
+ * Insert an entry into hash TLB or VHPT.
+ * NOTES:
+ *  1: When inserting VHPT to thash, "va" is a must covered
+ *  address by the inserted machine VHPT entry.
+ *  2: The format of entry is always in TLB.
+ *  3: The caller need to make sure the new entry will not overlap
+ *     with any existed entry.
+ */
+void vtlb_insert(struct kvm_vcpu *v, u64 pte, u64 itir, u64 va)
+{
+	struct thash_data *head;
+	union ia64_rr vrr;
+	u64 tag;
+	struct thash_cb *hcb =3D &v->arch.vtlb;
+
+	vrr.val =3D vcpu_get_rr(v, va);
+	vrr.ps =3D itir_ps(itir);
+	VMX(v, psbits[va >> 61]) |=3D (1UL << vrr.ps);
+	head =3D vsa_thash(hcb->pta, va, vrr.val, &tag);
+	head->page_flags =3D pte;
+	head->itir =3D itir;
+	head->etag =3D tag;
+}
+
+int vtr_find_overlap(struct kvm_vcpu *vcpu, u64 va, u64 ps, int type)
+{
+	struct thash_data  *trp;
+	int  i;
+	u64 end, rid;
+
+	rid =3D vcpu_get_rr(vcpu, va);
+	rid =3D rid & RR_RID_MASK;
+	end =3D va + PSIZE(ps);
+	if (type =3D=3D D_TLB) {
+		if (vcpu_quick_region_check(vcpu->arch.dtr_regions, va))
{
+			for (trp =3D (struct thash_data
*)&vcpu->arch.dtrs, i =3D 0;
+					i < NDTRS; i++, trp++) {
+				if (__is_tr_overlap(trp, rid, va, end))
+					return i;
+			}
+		}
+	} else {
+		if (vcpu_quick_region_check(vcpu->arch.itr_regions, va))
{
+			for (trp =3D (struct thash_data
*)&vcpu->arch.itrs, i =3D 0;
+					i < NITRS; i++, trp++) {
+				if (__is_tr_overlap(trp, rid, va, end))
+					return i;
+			}
+		}
+	}
+	return -1;
+}
+
+/*
+ * Purge entries in VTLB and VHPT
+ */
+void thash_purge_entries(struct kvm_vcpu *v, u64 va, u64 ps)
+{
+	if (vcpu_quick_region_check(v->arch.tc_regions, va))
+		vtlb_purge(v, va, ps);
+	vhpt_purge(v, va, ps);
+}
+
+void thash_purge_entries_remote(struct kvm_vcpu *v, u64 va, u64 ps)
+{
+	u64 old_va =3D va;
+	va =3D REGION_OFFSET(va);
+	if (vcpu_quick_region_check(v->arch.tc_regions, old_va))
+		vtlb_purge(v, va, ps);
+	vhpt_purge(v, va, ps);
+}
+
+u64 translate_phy_pte(u64 *pte, u64 itir, u64 va)
+{
+	u64 ps, ps_mask, paddr, maddr;
+	union pte_flags phy_pte;
+
+	ps =3D itir_ps(itir);
+	ps_mask =3D ~((1UL << ps) - 1);
+	phy_pte.val =3D *pte;
+	paddr =3D *pte;
+	paddr =3D ((paddr & _PAGE_PPN_MASK) & ps_mask) | (va & ~ps_mask);
+	maddr =3D kvm_lookup_mpa(paddr >> PAGE_SHIFT);
+	if (maddr & GPFN_IO_MASK) {
+		*pte |=3D VTLB_PTE_IO;
+		return -1;
+	}
+	maddr =3D ((maddr & _PAGE_PPN_MASK) & PAGE_MASK) |
+					(paddr & ~PAGE_MASK);
+	phy_pte.ppn =3D maddr >> ARCH_PAGE_SHIFT;
+	return phy_pte.val;
+}
+
+/*
+ * Purge overlap TCs and then insert the new entry to emulate itc ops.
+ *    Notes: Only TC entry can purge and insert.
+ *    1 indicates this is MMIO
+ */
+int thash_purge_and_insert(struct kvm_vcpu *v, u64 pte, u64 itir,
+						u64 ifa, int type)
+{
+	u64 ps;
+	u64 phy_pte;
+	union ia64_rr vrr, mrr;
+	int ret =3D 0;
+
+	ps =3D itir_ps(itir);
+	vrr.val =3D vcpu_get_rr(v, ifa);
+	mrr.val =3D ia64_get_rr(ifa);
+
+	phy_pte =3D translate_phy_pte(&pte, itir, ifa);
+
+	/* Ensure WB attribute if pte is related to a normal mem page,
+	 * which is required by vga acceleration since qemu maps shared
+	 * vram buffer with WB.
+	 */
+	if (!(pte & VTLB_PTE_IO) && ((pte & _PAGE_MA_MASK) !=3D
_PAGE_MA_NAT)) {
+		pte &=3D ~_PAGE_MA_MASK;
+		phy_pte &=3D ~_PAGE_MA_MASK;
+	}
+
+	if (pte & VTLB_PTE_IO)
+		ret =3D 1;
+
+	vtlb_purge(v, ifa, ps);
+	vhpt_purge(v, ifa, ps);
+
+	if (ps =3D=3D mrr.ps) {
+		if (!(pte&VTLB_PTE_IO)) {
+			vhpt_insert(phy_pte, itir, ifa, pte);
+		} else {
+			vtlb_insert(v, pte, itir, ifa);
+			vcpu_quick_region_set(VMX(v, tc_regions), ifa);
+		}
+	} else if (ps > mrr.ps) {
+		vtlb_insert(v, pte, itir, ifa);
+		vcpu_quick_region_set(VMX(v, tc_regions), ifa);
+		if (!(pte&VTLB_PTE_IO))
+			vhpt_insert(phy_pte, itir, ifa, pte);
+	} else {
+		u64 psr;
+		phy_pte  &=3D ~PAGE_FLAGS_RV_MASK;
+		psr =3D ia64_clear_ic();
+		ia64_itc(type, ifa, phy_pte, ps);
+		ia64_set_psr(psr);
+	}
+	if (!(pte&VTLB_PTE_IO))
+		mark_pages_dirty(v, pte, ps);
+
+	return ret;
+}
+
+/*
+ * Purge all TCs or VHPT entries including those in Hash table.
+ *
+ */
+
+void thash_purge_all(struct kvm_vcpu *v)
+{
+	int i;
+	struct thash_data *head;
+	struct thash_cb  *vtlb, *vhpt;
+	vtlb =3D &v->arch.vtlb;
+	vhpt =3D &v->arch.vhpt;
+
+	for (i =3D 0; i < 8; i++)
+		VMX(v, psbits[i]) =3D 0;
+
+	head =3D vtlb->hash;
+	for (i =3D 0; i < vtlb->num; i++) {
+		head->page_flags =3D 0;
+		head->etag =3D INVALID_TI_TAG;
+		head->itir =3D 0;
+		head->next =3D 0;
+		head++;
+	};
+
+	head =3D vhpt->hash;
+	for (i =3D 0; i < vhpt->num; i++) {
+		head->page_flags =3D 0;
+		head->etag =3D INVALID_TI_TAG;
+		head->itir =3D 0;
+		head->next =3D 0;
+		head++;
+	};
+
+	local_flush_tlb_all();
+}
+
+
+/*
+ * Lookup the hash table and its collision chain to find an entry
+ * covering this address rid:va or the entry.
+ *
+ * INPUT:
+ *  in: TLB format for both VHPT & TLB.
+ */
+
+struct thash_data *vtlb_lookup(struct kvm_vcpu *v, u64 va, int is_data)
+{
+	struct thash_data  *cch;
+	u64    psbits, ps, tag;
+	union ia64_rr vrr;
+
+	struct thash_cb *hcb =3D &v->arch.vtlb;
+
+	cch =3D __vtr_lookup(v, va, is_data);;
+	if (cch)
+		return cch;
+
+	if (vcpu_quick_region_check(v->arch.tc_regions, va) =3D=3D 0)
+		return NULL;
+
+	psbits =3D VMX(v, psbits[(va >> 61)]);
+	vrr.val =3D vcpu_get_rr(v, va);
+	while (psbits) {
+		ps =3D __ffs(psbits);
+		psbits &=3D ~(1UL << ps);
+		vrr.ps =3D ps;
+		cch =3D vsa_thash(hcb->pta, va, vrr.val, &tag);
+		if (cch->etag =3D=3D tag && cch->ps =3D=3D ps)
+			return cch;
+	}
+
+	return NULL;
+}
+
+
+/*
+ * Initialize internal control data before service.
+ */
+void thash_init(struct thash_cb *hcb, u64 sz)
+{
+	int i;
+	struct thash_data *head;
+
+	hcb->pta.val =3D (unsigned long)hcb->hash;
+	hcb->pta.vf =3D 1;
+	hcb->pta.ve =3D 1;
+	hcb->pta.size =3D sz;
+	head =3D hcb->hash;
+	for (i =3D 0; i < hcb->num; i++) {
+		head->page_flags =3D 0;
+		head->itir =3D 0;
+		head->etag =3D INVALID_TI_TAG;
+		head->next =3D 0;
+		head++;
+	}
+}
+
+u64 kvm_lookup_mpa(u64 gpfn)
+{
+	u64 *base =3D (u64 *) KVM_P2M_BASE;
+	return *(base + gpfn);
+}
+
+u64 kvm_gpa_to_mpa(u64 gpa)
+{
+	u64 pte =3D kvm_lookup_mpa(gpa >> PAGE_SHIFT);
+	return (pte >> PAGE_SHIFT << PAGE_SHIFT) | (gpa & ~PAGE_MASK);
+}
+
+
+/*
+ * Fetch guest bundle code.
+ * INPUT:
+ *  gip: guest ip
+ *  pbundle: used to return fetched bundle.
+ */
+int fetch_code(struct kvm_vcpu *vcpu, u64 gip, IA64_BUNDLE *pbundle)
+{
+	u64     gpip =3D 0;   /* guest physical IP*/
+	u64     *vpa;
+	struct thash_data    *tlb;
+	u64     maddr;
+
+	if (!(VCPU(vcpu, vpsr) & IA64_PSR_IT)) {
+		/* I-side physical mode */
+		gpip =3D gip;
+	} else {
+		tlb =3D vtlb_lookup(vcpu, gip, I_TLB);
+		if (tlb)
+			gpip =3D (tlb->ppn >> (tlb->ps - 12) << tlb->ps) |
+				(gip & (PSIZE(tlb->ps) - 1));
+	}
+	if (gpip) {
+		maddr =3D kvm_gpa_to_mpa(gpip);
+	} else {
+		tlb =3D vhpt_lookup(gip);
+		if (tlb =3D=3D NULL) {
+			ia64_ptcl(gip, ARCH_PAGE_SHIFT << 2);
+			return IA64_FAULT;
+		}
+		maddr =3D (tlb->ppn >> (tlb->ps - 12) << tlb->ps)
+					| (gip & (PSIZE(tlb->ps) - 1));
+	}
+	vpa =3D (u64 *)__kvm_va(maddr);
+
+	pbundle->i64[0] =3D *vpa++;
+	pbundle->i64[1] =3D *vpa;
+
+	return IA64_NO_FAULT;
+}
+
+
+void kvm_init_vhpt(struct kvm_vcpu *v)
+{
+	v->arch.vhpt.num =3D VHPT_NUM_ENTRIES;
+	thash_init(&v->arch.vhpt, VHPT_SHIFT);
+	ia64_set_pta(v->arch.vhpt.pta.val);
+	/*Enable VHPT here?*/
+}
+
+void kvm_init_vtlb(struct kvm_vcpu *v)
+{
+	v->arch.vtlb.num =3D VTLB_NUM_ENTRIES;
+	thash_init(&v->arch.vtlb, VTLB_SHIFT);
+}
--=20
1.5.2

------_=_NextPart_001_01C893E5.B32697C7
Content-Type: application/octet-stream;
	name="0008-KVM-IA64-Add-TLB-virtulization-support.patch"
Content-Transfer-Encoding: base64
Content-Description: 0008-KVM-IA64-Add-TLB-virtulization-support.patch
Content-Disposition: attachment;
	filename="0008-KVM-IA64-Add-TLB-virtulization-support.patch"

RnJvbSAyZDYyNGE4ZTQ0YmIyODQyMjQ4MjBjZDYxZmUyZjA5NzVjMDI5ZmRhIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAxIEFwciAyMDA4IDE0OjUwOjU5ICswODAwClN1YmplY3Q6IFtQQVRDSF0g
S1ZNOklBNjQgOiBBZGQgVExCIHZpcnR1bGl6YXRpb24gc3VwcG9ydC4KCnZ0bGIuYyBpbmNsdWRl
cyB0bGIvVkhQVCB2aXJ0dWxpemF0aW9uLgpTaWduZWQtb2ZmLWJ5OiBBbnRob255IFh1IDxhbnRo
b255Lnh1QGludGVsLmNvbT4KU2lnbmVkLW9mZi1ieTogWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56
aGFuZ0BpbnRlbC5jb20+Ci0tLQogYXJjaC9pYTY0L2t2bS92dGxiLmMgfCAgNjM2ICsrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrCiAxIGZpbGVzIGNoYW5n
ZWQsIDYzNiBpbnNlcnRpb25zKCspLCAwIGRlbGV0aW9ucygtKQogY3JlYXRlIG1vZGUgMTAwNjQ0
IGFyY2gvaWE2NC9rdm0vdnRsYi5jCgpkaWZmIC0tZ2l0IGEvYXJjaC9pYTY0L2t2bS92dGxiLmMg
Yi9hcmNoL2lhNjQva3ZtL3Z0bGIuYwpuZXcgZmlsZSBtb2RlIDEwMDY0NAppbmRleCAwMDAwMDAw
Li5kZWY0NTc2Ci0tLSAvZGV2L251bGwKKysrIGIvYXJjaC9pYTY0L2t2bS92dGxiLmMKQEAgLTAs
MCArMSw2MzYgQEAKKy8qCisgKiB2dGxiLmM6IGd1ZXN0IHZpcnR1YWwgdGxiIGhhbmRsaW5nIG1v
ZHVsZS4KKyAqIENvcHlyaWdodCAoYykgMjAwNCwgSW50ZWwgQ29ycG9yYXRpb24uCisgKiAgWWFv
enUgRG9uZyAoRWRkaWUgRG9uZykgPEVkZGllLmRvbmdAaW50ZWwuY29tPgorICogIFh1ZWZlaSBY
dSAoQW50aG9ueSBYdSkgPGFudGhvbnkueHVAaW50ZWwuY29tPgorICoKKyAqIENvcHlyaWdodCAo
YykgMjAwNywgSW50ZWwgQ29ycG9yYXRpb24uCisgKiAgWHVlZmVpIFh1IChBbnRob255IFh1KSA8
YW50aG9ueS54dUBpbnRlbC5jb20+CisgKiAgWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56aGFuZ0Bp
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
LgorICoKKyAqLworCisjaW5jbHVkZSAidmNwdS5oIgorCisjaW5jbHVkZSA8bGludXgvcndzZW0u
aD4KKworI2luY2x1ZGUgPGFzbS90bGIuaD4KKworLyoKKyAqIENoZWNrIHRvIHNlZSBpZiB0aGUg
YWRkcmVzcyByaWQ6dmEgaXMgdHJhbnNsYXRlZCBieSB0aGUgVExCCisgKi8KKworc3RhdGljIGlu
dCBfX2lzX3RyX3RyYW5zbGF0ZWQoc3RydWN0IHRoYXNoX2RhdGEgKnRycCwgdTY0IHJpZCwgdTY0
IHZhKQoreworCXJldHVybiAoKHRycC0+cCkgJiYgKHRycC0+cmlkID09IHJpZCkKKwkJCQkmJiAo
KHZhLXRycC0+dmFkcikgPCBQU0laRSh0cnAtPnBzKSkpOworfQorCisvKgorICogT25seSBmb3Ig
R1VFU1QgVFIgZm9ybWF0LgorICovCitzdGF0aWMgaW50IF9faXNfdHJfb3ZlcmxhcChzdHJ1Y3Qg
dGhhc2hfZGF0YSAqdHJwLCB1NjQgcmlkLCB1NjQgc3ZhLCB1NjQgZXZhKQoreworCXU2NCBzYTEs
IGVhMTsKKworCWlmICghdHJwLT5wIHx8IHRycC0+cmlkICE9IHJpZCkKKwkJcmV0dXJuIDA7CisK
KwlzYTEgPSB0cnAtPnZhZHI7CisJZWExID0gc2ExICsgUFNJWkUodHJwLT5wcykgLSAxOworCWV2
YSAtPSAxOworCWlmICgoc3ZhID4gZWExKSB8fCAoc2ExID4gZXZhKSkKKwkJcmV0dXJuIDA7CisJ
ZWxzZQorCQlyZXR1cm4gMTsKKworfQorCit2b2lkIG1hY2hpbmVfdGxiX3B1cmdlKHU2NCB2YSwg
dTY0IHBzKQoreworCWlhNjRfcHRjbCh2YSwgcHMgPDwgMik7Cit9CisKK3ZvaWQgbG9jYWxfZmx1
c2hfdGxiX2FsbCh2b2lkKQoreworCWludCBpLCBqOworCXVuc2lnbmVkIGxvbmcgZmxhZ3MsIGNv
dW50MCwgY291bnQxOworCXVuc2lnbmVkIGxvbmcgc3RyaWRlMCwgc3RyaWRlMSwgYWRkcjsKKwor
CWFkZHIgICAgPSBjdXJyZW50X3ZjcHUtPmFyY2gucHRjZV9iYXNlOworCWNvdW50MCAgPSBjdXJy
ZW50X3ZjcHUtPmFyY2gucHRjZV9jb3VudFswXTsKKwljb3VudDEgID0gY3VycmVudF92Y3B1LT5h
cmNoLnB0Y2VfY291bnRbMV07CisJc3RyaWRlMCA9IGN1cnJlbnRfdmNwdS0+YXJjaC5wdGNlX3N0
cmlkZVswXTsKKwlzdHJpZGUxID0gY3VycmVudF92Y3B1LT5hcmNoLnB0Y2Vfc3RyaWRlWzFdOwor
CisJbG9jYWxfaXJxX3NhdmUoZmxhZ3MpOworCWZvciAoaSA9IDA7IGkgPCBjb3VudDA7ICsraSkg
eworCQlmb3IgKGogPSAwOyBqIDwgY291bnQxOyArK2opIHsKKwkJCWlhNjRfcHRjZShhZGRyKTsK
KwkJCWFkZHIgKz0gc3RyaWRlMTsKKwkJfQorCQlhZGRyICs9IHN0cmlkZTA7CisJfQorCWxvY2Fs
X2lycV9yZXN0b3JlKGZsYWdzKTsKKwlpYTY0X3NybHpfaSgpOyAgICAgICAgICAvKiBzcmx6Lmkg
aW1wbGllcyBzcmx6LmQgKi8KK30KKworaW50IHZocHRfZW5hYmxlZChzdHJ1Y3Qga3ZtX3ZjcHUg
KnZjcHUsIHU2NCB2YWRyLCBlbnVtIHZocHRfcmVmIHJlZikKK3sKKwl1bmlvbiBpYTY0X3JyICAg
IHZycjsKKwl1bmlvbiBpYTY0X3B0YSAgIHZwdGE7CisJc3RydWN0ICBpYTY0X3BzciAgIHZwc3I7
CisKKwl2cHNyID0gKihzdHJ1Y3QgaWE2NF9wc3IgKikmVkNQVSh2Y3B1LCB2cHNyKTsKKwl2cnIu
dmFsID0gdmNwdV9nZXRfcnIodmNwdSwgdmFkcik7CisJdnB0YS52YWwgPSB2Y3B1X2dldF9wdGEo
dmNwdSk7CisKKwlpZiAodnJyLnZlICYgdnB0YS52ZSkgeworCQlzd2l0Y2ggKHJlZikgeworCQlj
YXNlIERBVEFfUkVGOgorCQljYXNlIE5BX1JFRjoKKwkJCXJldHVybiB2cHNyLmR0OworCQljYXNl
IElOU1RfUkVGOgorCQkJcmV0dXJuIHZwc3IuZHQgJiYgdnBzci5pdCAmJiB2cHNyLmljOworCQlj
YXNlIFJTRV9SRUY6CisJCQlyZXR1cm4gdnBzci5kdCAmJiB2cHNyLnJ0OworCisJCX0KKwl9CisJ
cmV0dXJuIDA7Cit9CisKK3N0cnVjdCB0aGFzaF9kYXRhICp2c2FfdGhhc2godW5pb24gaWE2NF9w
dGEgdnB0YSwgdTY0IHZhLCB1NjQgdnJyLCB1NjQgKnRhZykKK3sKKwl1NjQgaW5kZXgsIHBmbiwg
cmlkLCBwZm5fYml0czsKKworCXBmbl9iaXRzID0gdnB0YS5zaXplIC0gNSAtIDg7CisJcGZuID0g
UkVHSU9OX09GRlNFVCh2YSkgPj4gX1JFR0lPTl9QQUdFX1NJWkUodnJyKTsKKwlyaWQgPSBfUkVH
SU9OX0lEKHZycik7CisJaW5kZXggPSAoKHJpZCAmIDB4ZmYpIDw8IHBmbl9iaXRzKXwocGZuICYg
KCgxVUwgPDwgcGZuX2JpdHMpIC0gMSkpOworCSp0YWcgPSAoKHJpZCA+PiA4KSAmIDB4ZmZmZikg
fCAoKHBmbiA+PiBwZm5fYml0cykgPDwgMTYpOworCisJcmV0dXJuIChzdHJ1Y3QgdGhhc2hfZGF0
YSAqKSgodnB0YS5iYXNlIDw8IFBUQV9CQVNFX1NISUZUKSArCisJCQkJKGluZGV4IDw8IDUpKTsK
K30KKworc3RydWN0IHRoYXNoX2RhdGEgKl9fdnRyX2xvb2t1cChzdHJ1Y3Qga3ZtX3ZjcHUgKnZj
cHUsIHU2NCB2YSwgaW50IHR5cGUpCit7CisKKwlzdHJ1Y3QgdGhhc2hfZGF0YSAqdHJwOworCWlu
dCAgaTsKKwl1NjQgcmlkOworCisJcmlkID0gdmNwdV9nZXRfcnIodmNwdSwgdmEpOworCXJpZCA9
IHJpZCAmIFJSX1JJRF9NQVNLOzsKKwlpZiAodHlwZSA9PSBEX1RMQikgeworCQlpZiAodmNwdV9x
dWlja19yZWdpb25fY2hlY2sodmNwdS0+YXJjaC5kdHJfcmVnaW9ucywgdmEpKSB7CisJCQlmb3Ig
KHRycCA9IChzdHJ1Y3QgdGhhc2hfZGF0YSAqKSZ2Y3B1LT5hcmNoLmR0cnMsIGkgPSAwOworCQkJ
CQkJaSA8IE5EVFJTOyBpKyssIHRycCsrKSB7CisJCQkJaWYgKF9faXNfdHJfdHJhbnNsYXRlZCh0
cnAsIHJpZCwgdmEpKQorCQkJCQlyZXR1cm4gdHJwOworCQkJfQorCQl9CisJfSBlbHNlIHsKKwkJ
aWYgKHZjcHVfcXVpY2tfcmVnaW9uX2NoZWNrKHZjcHUtPmFyY2guaXRyX3JlZ2lvbnMsIHZhKSkg
eworCQkJZm9yICh0cnAgPSAoc3RydWN0IHRoYXNoX2RhdGEgKikmdmNwdS0+YXJjaC5pdHJzLCBp
ID0gMDsKKwkJCQkJaSA8IE5JVFJTOyBpKyssIHRycCsrKSB7CisJCQkJaWYgKF9faXNfdHJfdHJh
bnNsYXRlZCh0cnAsIHJpZCwgdmEpKQorCQkJCQlyZXR1cm4gdHJwOworCQkJfQorCQl9CisJfQor
CisJcmV0dXJuIE5VTEw7Cit9CisKK3N0YXRpYyB2b2lkIHZocHRfaW5zZXJ0KHU2NCBwdGUsIHU2
NCBpdGlyLCB1NjQgaWZhLCB1NjQgZ3B0ZSkKK3sKKwl1bmlvbiBpYTY0X3JyIHJyOworCXN0cnVj
dCB0aGFzaF9kYXRhICpoZWFkOworCXVuc2lnbmVkIGxvbmcgcHMsIGdwYWRkcjsKKworCXBzID0g
aXRpcl9wcyhpdGlyKTsKKworCWdwYWRkciA9ICgoZ3B0ZSAmIF9QQUdFX1BQTl9NQVNLKSA+PiBw
cyA8PCBwcykgfAorCQkoaWZhICYgKCgxVUwgPDwgcHMpIC0gMSkpOworCisJcnIudmFsID0gaWE2
NF9nZXRfcnIoaWZhKTsKKwloZWFkID0gKHN0cnVjdCB0aGFzaF9kYXRhICopaWE2NF90aGFzaChp
ZmEpOworCWhlYWQtPmV0YWcgPSBJTlZBTElEX1RJX1RBRzsKKwlpYTY0X21mKCk7CisJaGVhZC0+
cGFnZV9mbGFncyA9IHB0ZSAmIH5QQUdFX0ZMQUdTX1JWX01BU0s7CisJaGVhZC0+aXRpciA9IHJy
LnBzIDw8IDI7CisJaGVhZC0+ZXRhZyA9IGlhNjRfdHRhZyhpZmEpOworCWhlYWQtPmdwYWRkciA9
IGdwYWRkcjsKK30KKwordm9pZCBtYXJrX3BhZ2VzX2RpcnR5KHN0cnVjdCBrdm1fdmNwdSAqdiwg
dTY0IHB0ZSwgdTY0IHBzKQoreworCXU2NCBpLCBkaXJ0eV9wYWdlcyA9IDE7CisJdTY0IGJhc2Vf
Z2ZuID0gKHB0ZSZfUEFHRV9QUE5fTUFTSykgPj4gUEFHRV9TSElGVDsKKwlzcGlubG9ja190ICps
b2NrID0gX19rdm1fdmEodi0+YXJjaC5kaXJ0eV9sb2dfbG9ja19wYSk7CisJdm9pZCAqZGlydHlf
Yml0bWFwID0gKHZvaWQgKil2IC0gKEtWTV9WQ1BVX09GUyArIHYtPnZjcHVfaWQgKiBWQ1BVX1NJ
WkUpCisJCQkJCQkrIEtWTV9NRU1fRElSVFlfTE9HX09GUzsKKwlkaXJ0eV9wYWdlcyA8PD0gcHMg
PD0gUEFHRV9TSElGVCA/IDAgOiBwcyAtIFBBR0VfU0hJRlQ7CisKKwl2bW1fc3Bpbl9sb2NrKGxv
Y2spOworCWZvciAoaSA9IDA7IGkgPCBkaXJ0eV9wYWdlczsgaSsrKSB7CisJCS8qIGF2b2lkIFJN
VyAqLworCQlpZiAoIXRlc3RfYml0KGJhc2VfZ2ZuICsgaSwgZGlydHlfYml0bWFwKSkKKwkJCXNl
dF9iaXQoYmFzZV9nZm4gKyBpICwgZGlydHlfYml0bWFwKTsKKwl9CisJdm1tX3NwaW5fdW5sb2Nr
KGxvY2spOworfQorCit2b2lkIHRoYXNoX3ZocHRfaW5zZXJ0KHN0cnVjdCBrdm1fdmNwdSAqdiwg
dTY0IHB0ZSwgdTY0IGl0aXIsIHU2NCB2YSwgaW50IHR5cGUpCit7CisJdTY0IHBoeV9wdGUsIHBz
cjsKKwl1bmlvbiBpYTY0X3JyIG1ycjsKKworCW1yci52YWwgPSBpYTY0X2dldF9ycih2YSk7CisJ
cGh5X3B0ZSA9IHRyYW5zbGF0ZV9waHlfcHRlKCZwdGUsIGl0aXIsIHZhKTsKKworCWlmIChpdGly
X3BzKGl0aXIpID49IG1yci5wcykgeworCQl2aHB0X2luc2VydChwaHlfcHRlLCBpdGlyLCB2YSwg
cHRlKTsKKwl9IGVsc2UgeworCQlwaHlfcHRlICAmPSB+UEFHRV9GTEFHU19SVl9NQVNLOworCQlw
c3IgPSBpYTY0X2NsZWFyX2ljKCk7CisJCWlhNjRfaXRjKHR5cGUsIHZhLCBwaHlfcHRlLCBpdGly
X3BzKGl0aXIpKTsKKwkJaWE2NF9zZXRfcHNyKHBzcik7CisJfQorCisJaWYgKCEocHRlJlZUTEJf
UFRFX0lPKSkKKwkJbWFya19wYWdlc19kaXJ0eSh2LCBwdGUsIGl0aXJfcHMoaXRpcikpOworfQor
CisvKgorICogICB2aHB0IGxvb2t1cAorICovCitzdHJ1Y3QgdGhhc2hfZGF0YSAqdmhwdF9sb29r
dXAodTY0IHZhKQoreworCXN0cnVjdCB0aGFzaF9kYXRhICpoZWFkOworCXU2NCB0YWc7CisKKwlo
ZWFkID0gKHN0cnVjdCB0aGFzaF9kYXRhICopaWE2NF90aGFzaCh2YSk7CisJdGFnID0gaWE2NF90
dGFnKHZhKTsKKwlpZiAoaGVhZC0+ZXRhZyA9PSB0YWcpCisJCXJldHVybiBoZWFkOworCXJldHVy
biBOVUxMOworfQorCit1NjQgZ3Vlc3RfdmhwdF9sb29rdXAodTY0IGloYSwgdTY0ICpwdGUpCit7
CisJdTY0IHJldDsKKwlzdHJ1Y3QgdGhhc2hfZGF0YSAqZGF0YTsKKworCWRhdGEgPSBfX3Z0cl9s
b29rdXAoY3VycmVudF92Y3B1LCBpaGEsIERfVExCKTsKKwlpZiAoZGF0YSAhPSBOVUxMKQorCQl0
aGFzaF92aHB0X2luc2VydChjdXJyZW50X3ZjcHUsIGRhdGEtPnBhZ2VfZmxhZ3MsCisJCQlkYXRh
LT5pdGlyLCBpaGEsIERfVExCKTsKKworCWFzbSB2b2xhdGlsZSAoInJzbSBwc3IuaWN8cHNyLmk7
OyIKKwkJCSJzcmx6LmQ7OyIKKwkJCSJsZDgucyByOT1bJTFdOzsiCisJCQkidG5hdC5ueiBwNixw
Nz1yOTs7IgorCQkJIihwNikgbW92ICUwPTE7IgorCQkJIihwNikgbW92IHI5PXIwOyIKKwkJCSIo
cDcpIGV4dHIudSByOT1yOSwwLDUzOzsiCisJCQkiKHA3KSBtb3YgJTA9cjA7IgorCQkJIihwNykg
c3Q4IFslMl09cjk7OyIKKwkJCSJzc20gcHNyLmljOzsiCisJCQkic3Jsei5kOzsiCisJCQkvKiAi
c3NtIHBzci5pOzsiIE9uY2UgaW50ZXJydXB0cyBpbiB2bW0gb3BlbiwgbmVlZCBmaXgqLworCQkJ
OiAiPXIiKHJldCkgOiAiciIoaWhhKSwgInIiKHB0ZSk6Im1lbW9yeSIpOworCisJcmV0dXJuIHJl
dDsKK30KKworLyoKKyAqICBwdXJnZSBzb2Z0d2FyZSBndWVzdCB0bGIKKyAqLworCitzdGF0aWMg
dm9pZCB2dGxiX3B1cmdlKHN0cnVjdCBrdm1fdmNwdSAqdiwgdTY0IHZhLCB1NjQgcHMpCit7CisJ
c3RydWN0IHRoYXNoX2RhdGEgKmN1cjsKKwl1NjQgc3RhcnQsIGN1cmFkciwgc2l6ZSwgcHNiaXRz
LCB0YWcsIHJyX3BzLCBudW07CisJdW5pb24gaWE2NF9yciB2cnI7CisJc3RydWN0IHRoYXNoX2Ni
ICpoY2IgPSAmdi0+YXJjaC52dGxiOworCisJdnJyLnZhbCA9IHZjcHVfZ2V0X3JyKHYsIHZhKTsK
Kwlwc2JpdHMgPSBWTVgodiwgcHNiaXRzWyh2YSA+PiA2MSldKTsKKwlzdGFydCA9IHZhICYgfigo
MVVMIDw8IHBzKSAtIDEpOworCXdoaWxlIChwc2JpdHMpIHsKKwkJY3VyYWRyID0gc3RhcnQ7CisJ
CXJyX3BzID0gX19mZnMocHNiaXRzKTsKKwkJcHNiaXRzICY9IH4oMVVMIDw8IHJyX3BzKTsKKwkJ
bnVtID0gMVVMIDw8ICgocHMgPCBycl9wcykgPyAwIDogKHBzIC0gcnJfcHMpKTsKKwkJc2l6ZSA9
IFBTSVpFKHJyX3BzKTsKKwkJdnJyLnBzID0gcnJfcHM7CisJCXdoaWxlIChudW0pIHsKKwkJCWN1
ciA9IHZzYV90aGFzaChoY2ItPnB0YSwgY3VyYWRyLCB2cnIudmFsLCAmdGFnKTsKKwkJCWlmIChj
dXItPmV0YWcgPT0gdGFnICYmIGN1ci0+cHMgPT0gcnJfcHMpCisJCQkJY3VyLT5ldGFnID0gSU5W
QUxJRF9USV9UQUc7CisJCQljdXJhZHIgKz0gc2l6ZTsKKwkJCW51bS0tOworCQl9CisJfQorfQor
CisKKy8qCisgKiAgcHVyZ2UgVkhQVCBhbmQgbWFjaGluZSBUTEIKKyAqLworc3RhdGljIHZvaWQg
dmhwdF9wdXJnZShzdHJ1Y3Qga3ZtX3ZjcHUgKnYsIHU2NCB2YSwgdTY0IHBzKQoreworCXN0cnVj
dCB0aGFzaF9kYXRhICpjdXI7CisJdTY0IHN0YXJ0LCBzaXplLCB0YWcsIG51bTsKKwl1bmlvbiBp
YTY0X3JyIHJyOworCisJc3RhcnQgPSB2YSAmIH4oKDFVTCA8PCBwcykgLSAxKTsKKwlyci52YWwg
PSBpYTY0X2dldF9ycih2YSk7CisJc2l6ZSA9IFBTSVpFKHJyLnBzKTsKKwludW0gPSAxVUwgPDwg
KChwcyA8IHJyLnBzKSA/IDAgOiAocHMgLSByci5wcykpOworCXdoaWxlIChudW0pIHsKKwkJY3Vy
ID0gKHN0cnVjdCB0aGFzaF9kYXRhICopaWE2NF90aGFzaChzdGFydCk7CisJCXRhZyA9IGlhNjRf
dHRhZyhzdGFydCk7CisJCWlmIChjdXItPmV0YWcgPT0gdGFnKQorCQkJY3VyLT5ldGFnID0gSU5W
QUxJRF9USV9UQUc7CisJCXN0YXJ0ICs9IHNpemU7CisJCW51bS0tOworCX0KKwltYWNoaW5lX3Rs
Yl9wdXJnZSh2YSwgcHMpOworfQorCisvKgorICogSW5zZXJ0IGFuIGVudHJ5IGludG8gaGFzaCBU
TEIgb3IgVkhQVC4KKyAqIE5PVEVTOgorICogIDE6IFdoZW4gaW5zZXJ0aW5nIFZIUFQgdG8gdGhh
c2gsICJ2YSIgaXMgYSBtdXN0IGNvdmVyZWQKKyAqICBhZGRyZXNzIGJ5IHRoZSBpbnNlcnRlZCBt
YWNoaW5lIFZIUFQgZW50cnkuCisgKiAgMjogVGhlIGZvcm1hdCBvZiBlbnRyeSBpcyBhbHdheXMg
aW4gVExCLgorICogIDM6IFRoZSBjYWxsZXIgbmVlZCB0byBtYWtlIHN1cmUgdGhlIG5ldyBlbnRy
eSB3aWxsIG5vdCBvdmVybGFwCisgKiAgICAgd2l0aCBhbnkgZXhpc3RlZCBlbnRyeS4KKyAqLwor
dm9pZCB2dGxiX2luc2VydChzdHJ1Y3Qga3ZtX3ZjcHUgKnYsIHU2NCBwdGUsIHU2NCBpdGlyLCB1
NjQgdmEpCit7CisJc3RydWN0IHRoYXNoX2RhdGEgKmhlYWQ7CisJdW5pb24gaWE2NF9yciB2cnI7
CisJdTY0IHRhZzsKKwlzdHJ1Y3QgdGhhc2hfY2IgKmhjYiA9ICZ2LT5hcmNoLnZ0bGI7CisKKwl2
cnIudmFsID0gdmNwdV9nZXRfcnIodiwgdmEpOworCXZyci5wcyA9IGl0aXJfcHMoaXRpcik7CisJ
Vk1YKHYsIHBzYml0c1t2YSA+PiA2MV0pIHw9ICgxVUwgPDwgdnJyLnBzKTsKKwloZWFkID0gdnNh
X3RoYXNoKGhjYi0+cHRhLCB2YSwgdnJyLnZhbCwgJnRhZyk7CisJaGVhZC0+cGFnZV9mbGFncyA9
IHB0ZTsKKwloZWFkLT5pdGlyID0gaXRpcjsKKwloZWFkLT5ldGFnID0gdGFnOworfQorCitpbnQg
dnRyX2ZpbmRfb3ZlcmxhcChzdHJ1Y3Qga3ZtX3ZjcHUgKnZjcHUsIHU2NCB2YSwgdTY0IHBzLCBp
bnQgdHlwZSkKK3sKKwlzdHJ1Y3QgdGhhc2hfZGF0YSAgKnRycDsKKwlpbnQgIGk7CisJdTY0IGVu
ZCwgcmlkOworCisJcmlkID0gdmNwdV9nZXRfcnIodmNwdSwgdmEpOworCXJpZCA9IHJpZCAmIFJS
X1JJRF9NQVNLOworCWVuZCA9IHZhICsgUFNJWkUocHMpOworCWlmICh0eXBlID09IERfVExCKSB7
CisJCWlmICh2Y3B1X3F1aWNrX3JlZ2lvbl9jaGVjayh2Y3B1LT5hcmNoLmR0cl9yZWdpb25zLCB2
YSkpIHsKKwkJCWZvciAodHJwID0gKHN0cnVjdCB0aGFzaF9kYXRhICopJnZjcHUtPmFyY2guZHRy
cywgaSA9IDA7CisJCQkJCWkgPCBORFRSUzsgaSsrLCB0cnArKykgeworCQkJCWlmIChfX2lzX3Ry
X292ZXJsYXAodHJwLCByaWQsIHZhLCBlbmQpKQorCQkJCQlyZXR1cm4gaTsKKwkJCX0KKwkJfQor
CX0gZWxzZSB7CisJCWlmICh2Y3B1X3F1aWNrX3JlZ2lvbl9jaGVjayh2Y3B1LT5hcmNoLml0cl9y
ZWdpb25zLCB2YSkpIHsKKwkJCWZvciAodHJwID0gKHN0cnVjdCB0aGFzaF9kYXRhICopJnZjcHUt
PmFyY2guaXRycywgaSA9IDA7CisJCQkJCWkgPCBOSVRSUzsgaSsrLCB0cnArKykgeworCQkJCWlm
IChfX2lzX3RyX292ZXJsYXAodHJwLCByaWQsIHZhLCBlbmQpKQorCQkJCQlyZXR1cm4gaTsKKwkJ
CX0KKwkJfQorCX0KKwlyZXR1cm4gLTE7Cit9CisKKy8qCisgKiBQdXJnZSBlbnRyaWVzIGluIFZU
TEIgYW5kIFZIUFQKKyAqLwordm9pZCB0aGFzaF9wdXJnZV9lbnRyaWVzKHN0cnVjdCBrdm1fdmNw
dSAqdiwgdTY0IHZhLCB1NjQgcHMpCit7CisJaWYgKHZjcHVfcXVpY2tfcmVnaW9uX2NoZWNrKHYt
PmFyY2gudGNfcmVnaW9ucywgdmEpKQorCQl2dGxiX3B1cmdlKHYsIHZhLCBwcyk7CisJdmhwdF9w
dXJnZSh2LCB2YSwgcHMpOworfQorCit2b2lkIHRoYXNoX3B1cmdlX2VudHJpZXNfcmVtb3RlKHN0
cnVjdCBrdm1fdmNwdSAqdiwgdTY0IHZhLCB1NjQgcHMpCit7CisJdTY0IG9sZF92YSA9IHZhOwor
CXZhID0gUkVHSU9OX09GRlNFVCh2YSk7CisJaWYgKHZjcHVfcXVpY2tfcmVnaW9uX2NoZWNrKHYt
PmFyY2gudGNfcmVnaW9ucywgb2xkX3ZhKSkKKwkJdnRsYl9wdXJnZSh2LCB2YSwgcHMpOworCXZo
cHRfcHVyZ2UodiwgdmEsIHBzKTsKK30KKwordTY0IHRyYW5zbGF0ZV9waHlfcHRlKHU2NCAqcHRl
LCB1NjQgaXRpciwgdTY0IHZhKQoreworCXU2NCBwcywgcHNfbWFzaywgcGFkZHIsIG1hZGRyOwor
CXVuaW9uIHB0ZV9mbGFncyBwaHlfcHRlOworCisJcHMgPSBpdGlyX3BzKGl0aXIpOworCXBzX21h
c2sgPSB+KCgxVUwgPDwgcHMpIC0gMSk7CisJcGh5X3B0ZS52YWwgPSAqcHRlOworCXBhZGRyID0g
KnB0ZTsKKwlwYWRkciA9ICgocGFkZHIgJiBfUEFHRV9QUE5fTUFTSykgJiBwc19tYXNrKSB8ICh2
YSAmIH5wc19tYXNrKTsKKwltYWRkciA9IGt2bV9sb29rdXBfbXBhKHBhZGRyID4+IFBBR0VfU0hJ
RlQpOworCWlmIChtYWRkciAmIEdQRk5fSU9fTUFTSykgeworCQkqcHRlIHw9IFZUTEJfUFRFX0lP
OworCQlyZXR1cm4gLTE7CisJfQorCW1hZGRyID0gKChtYWRkciAmIF9QQUdFX1BQTl9NQVNLKSAm
IFBBR0VfTUFTSykgfAorCQkJCQkocGFkZHIgJiB+UEFHRV9NQVNLKTsKKwlwaHlfcHRlLnBwbiA9
IG1hZGRyID4+IEFSQ0hfUEFHRV9TSElGVDsKKwlyZXR1cm4gcGh5X3B0ZS52YWw7Cit9CisKKy8q
CisgKiBQdXJnZSBvdmVybGFwIFRDcyBhbmQgdGhlbiBpbnNlcnQgdGhlIG5ldyBlbnRyeSB0byBl
bXVsYXRlIGl0YyBvcHMuCisgKiAgICBOb3RlczogT25seSBUQyBlbnRyeSBjYW4gcHVyZ2UgYW5k
IGluc2VydC4KKyAqICAgIDEgaW5kaWNhdGVzIHRoaXMgaXMgTU1JTworICovCitpbnQgdGhhc2hf
cHVyZ2VfYW5kX2luc2VydChzdHJ1Y3Qga3ZtX3ZjcHUgKnYsIHU2NCBwdGUsIHU2NCBpdGlyLAor
CQkJCQkJdTY0IGlmYSwgaW50IHR5cGUpCit7CisJdTY0IHBzOworCXU2NCBwaHlfcHRlOworCXVu
aW9uIGlhNjRfcnIgdnJyLCBtcnI7CisJaW50IHJldCA9IDA7CisKKwlwcyA9IGl0aXJfcHMoaXRp
cik7CisJdnJyLnZhbCA9IHZjcHVfZ2V0X3JyKHYsIGlmYSk7CisJbXJyLnZhbCA9IGlhNjRfZ2V0
X3JyKGlmYSk7CisKKwlwaHlfcHRlID0gdHJhbnNsYXRlX3BoeV9wdGUoJnB0ZSwgaXRpciwgaWZh
KTsKKworCS8qIEVuc3VyZSBXQiBhdHRyaWJ1dGUgaWYgcHRlIGlzIHJlbGF0ZWQgdG8gYSBub3Jt
YWwgbWVtIHBhZ2UsCisJICogd2hpY2ggaXMgcmVxdWlyZWQgYnkgdmdhIGFjY2VsZXJhdGlvbiBz
aW5jZSBxZW11IG1hcHMgc2hhcmVkCisJICogdnJhbSBidWZmZXIgd2l0aCBXQi4KKwkgKi8KKwlp
ZiAoIShwdGUgJiBWVExCX1BURV9JTykgJiYgKChwdGUgJiBfUEFHRV9NQV9NQVNLKSAhPSBfUEFH
RV9NQV9OQVQpKSB7CisJCXB0ZSAmPSB+X1BBR0VfTUFfTUFTSzsKKwkJcGh5X3B0ZSAmPSB+X1BB
R0VfTUFfTUFTSzsKKwl9CisKKwlpZiAocHRlICYgVlRMQl9QVEVfSU8pCisJCXJldCA9IDE7CisK
Kwl2dGxiX3B1cmdlKHYsIGlmYSwgcHMpOworCXZocHRfcHVyZ2UodiwgaWZhLCBwcyk7CisKKwlp
ZiAocHMgPT0gbXJyLnBzKSB7CisJCWlmICghKHB0ZSZWVExCX1BURV9JTykpIHsKKwkJCXZocHRf
aW5zZXJ0KHBoeV9wdGUsIGl0aXIsIGlmYSwgcHRlKTsKKwkJfSBlbHNlIHsKKwkJCXZ0bGJfaW5z
ZXJ0KHYsIHB0ZSwgaXRpciwgaWZhKTsKKwkJCXZjcHVfcXVpY2tfcmVnaW9uX3NldChWTVgodiwg
dGNfcmVnaW9ucyksIGlmYSk7CisJCX0KKwl9IGVsc2UgaWYgKHBzID4gbXJyLnBzKSB7CisJCXZ0
bGJfaW5zZXJ0KHYsIHB0ZSwgaXRpciwgaWZhKTsKKwkJdmNwdV9xdWlja19yZWdpb25fc2V0KFZN
WCh2LCB0Y19yZWdpb25zKSwgaWZhKTsKKwkJaWYgKCEocHRlJlZUTEJfUFRFX0lPKSkKKwkJCXZo
cHRfaW5zZXJ0KHBoeV9wdGUsIGl0aXIsIGlmYSwgcHRlKTsKKwl9IGVsc2UgeworCQl1NjQgcHNy
OworCQlwaHlfcHRlICAmPSB+UEFHRV9GTEFHU19SVl9NQVNLOworCQlwc3IgPSBpYTY0X2NsZWFy
X2ljKCk7CisJCWlhNjRfaXRjKHR5cGUsIGlmYSwgcGh5X3B0ZSwgcHMpOworCQlpYTY0X3NldF9w
c3IocHNyKTsKKwl9CisJaWYgKCEocHRlJlZUTEJfUFRFX0lPKSkKKwkJbWFya19wYWdlc19kaXJ0
eSh2LCBwdGUsIHBzKTsKKworCXJldHVybiByZXQ7Cit9CisKKy8qCisgKiBQdXJnZSBhbGwgVENz
IG9yIFZIUFQgZW50cmllcyBpbmNsdWRpbmcgdGhvc2UgaW4gSGFzaCB0YWJsZS4KKyAqCisgKi8K
Kwordm9pZCB0aGFzaF9wdXJnZV9hbGwoc3RydWN0IGt2bV92Y3B1ICp2KQoreworCWludCBpOwor
CXN0cnVjdCB0aGFzaF9kYXRhICpoZWFkOworCXN0cnVjdCB0aGFzaF9jYiAgKnZ0bGIsICp2aHB0
OworCXZ0bGIgPSAmdi0+YXJjaC52dGxiOworCXZocHQgPSAmdi0+YXJjaC52aHB0OworCisJZm9y
IChpID0gMDsgaSA8IDg7IGkrKykKKwkJVk1YKHYsIHBzYml0c1tpXSkgPSAwOworCisJaGVhZCA9
IHZ0bGItPmhhc2g7CisJZm9yIChpID0gMDsgaSA8IHZ0bGItPm51bTsgaSsrKSB7CisJCWhlYWQt
PnBhZ2VfZmxhZ3MgPSAwOworCQloZWFkLT5ldGFnID0gSU5WQUxJRF9USV9UQUc7CisJCWhlYWQt
Pml0aXIgPSAwOworCQloZWFkLT5uZXh0ID0gMDsKKwkJaGVhZCsrOworCX07CisKKwloZWFkID0g
dmhwdC0+aGFzaDsKKwlmb3IgKGkgPSAwOyBpIDwgdmhwdC0+bnVtOyBpKyspIHsKKwkJaGVhZC0+
cGFnZV9mbGFncyA9IDA7CisJCWhlYWQtPmV0YWcgPSBJTlZBTElEX1RJX1RBRzsKKwkJaGVhZC0+
aXRpciA9IDA7CisJCWhlYWQtPm5leHQgPSAwOworCQloZWFkKys7CisJfTsKKworCWxvY2FsX2Zs
dXNoX3RsYl9hbGwoKTsKK30KKworCisvKgorICogTG9va3VwIHRoZSBoYXNoIHRhYmxlIGFuZCBp
dHMgY29sbGlzaW9uIGNoYWluIHRvIGZpbmQgYW4gZW50cnkKKyAqIGNvdmVyaW5nIHRoaXMgYWRk
cmVzcyByaWQ6dmEgb3IgdGhlIGVudHJ5LgorICoKKyAqIElOUFVUOgorICogIGluOiBUTEIgZm9y
bWF0IGZvciBib3RoIFZIUFQgJiBUTEIuCisgKi8KKworc3RydWN0IHRoYXNoX2RhdGEgKnZ0bGJf
bG9va3VwKHN0cnVjdCBrdm1fdmNwdSAqdiwgdTY0IHZhLCBpbnQgaXNfZGF0YSkKK3sKKwlzdHJ1
Y3QgdGhhc2hfZGF0YSAgKmNjaDsKKwl1NjQgICAgcHNiaXRzLCBwcywgdGFnOworCXVuaW9uIGlh
NjRfcnIgdnJyOworCisJc3RydWN0IHRoYXNoX2NiICpoY2IgPSAmdi0+YXJjaC52dGxiOworCisJ
Y2NoID0gX192dHJfbG9va3VwKHYsIHZhLCBpc19kYXRhKTs7CisJaWYgKGNjaCkKKwkJcmV0dXJu
IGNjaDsKKworCWlmICh2Y3B1X3F1aWNrX3JlZ2lvbl9jaGVjayh2LT5hcmNoLnRjX3JlZ2lvbnMs
IHZhKSA9PSAwKQorCQlyZXR1cm4gTlVMTDsKKworCXBzYml0cyA9IFZNWCh2LCBwc2JpdHNbKHZh
ID4+IDYxKV0pOworCXZyci52YWwgPSB2Y3B1X2dldF9ycih2LCB2YSk7CisJd2hpbGUgKHBzYml0
cykgeworCQlwcyA9IF9fZmZzKHBzYml0cyk7CisJCXBzYml0cyAmPSB+KDFVTCA8PCBwcyk7CisJ
CXZyci5wcyA9IHBzOworCQljY2ggPSB2c2FfdGhhc2goaGNiLT5wdGEsIHZhLCB2cnIudmFsLCAm
dGFnKTsKKwkJaWYgKGNjaC0+ZXRhZyA9PSB0YWcgJiYgY2NoLT5wcyA9PSBwcykKKwkJCXJldHVy
biBjY2g7CisJfQorCisJcmV0dXJuIE5VTEw7Cit9CisKKworLyoKKyAqIEluaXRpYWxpemUgaW50
ZXJuYWwgY29udHJvbCBkYXRhIGJlZm9yZSBzZXJ2aWNlLgorICovCit2b2lkIHRoYXNoX2luaXQo
c3RydWN0IHRoYXNoX2NiICpoY2IsIHU2NCBzeikKK3sKKwlpbnQgaTsKKwlzdHJ1Y3QgdGhhc2hf
ZGF0YSAqaGVhZDsKKworCWhjYi0+cHRhLnZhbCA9ICh1bnNpZ25lZCBsb25nKWhjYi0+aGFzaDsK
KwloY2ItPnB0YS52ZiA9IDE7CisJaGNiLT5wdGEudmUgPSAxOworCWhjYi0+cHRhLnNpemUgPSBz
ejsKKwloZWFkID0gaGNiLT5oYXNoOworCWZvciAoaSA9IDA7IGkgPCBoY2ItPm51bTsgaSsrKSB7
CisJCWhlYWQtPnBhZ2VfZmxhZ3MgPSAwOworCQloZWFkLT5pdGlyID0gMDsKKwkJaGVhZC0+ZXRh
ZyA9IElOVkFMSURfVElfVEFHOworCQloZWFkLT5uZXh0ID0gMDsKKwkJaGVhZCsrOworCX0KK30K
KwordTY0IGt2bV9sb29rdXBfbXBhKHU2NCBncGZuKQoreworCXU2NCAqYmFzZSA9ICh1NjQgKikg
S1ZNX1AyTV9CQVNFOworCXJldHVybiAqKGJhc2UgKyBncGZuKTsKK30KKwordTY0IGt2bV9ncGFf
dG9fbXBhKHU2NCBncGEpCit7CisJdTY0IHB0ZSA9IGt2bV9sb29rdXBfbXBhKGdwYSA+PiBQQUdF
X1NISUZUKTsKKwlyZXR1cm4gKHB0ZSA+PiBQQUdFX1NISUZUIDw8IFBBR0VfU0hJRlQpIHwgKGdw
YSAmIH5QQUdFX01BU0spOworfQorCisKKy8qCisgKiBGZXRjaCBndWVzdCBidW5kbGUgY29kZS4K
KyAqIElOUFVUOgorICogIGdpcDogZ3Vlc3QgaXAKKyAqICBwYnVuZGxlOiB1c2VkIHRvIHJldHVy
biBmZXRjaGVkIGJ1bmRsZS4KKyAqLworaW50IGZldGNoX2NvZGUoc3RydWN0IGt2bV92Y3B1ICp2
Y3B1LCB1NjQgZ2lwLCBJQTY0X0JVTkRMRSAqcGJ1bmRsZSkKK3sKKwl1NjQgICAgIGdwaXAgPSAw
OyAgIC8qIGd1ZXN0IHBoeXNpY2FsIElQKi8KKwl1NjQgICAgICp2cGE7CisJc3RydWN0IHRoYXNo
X2RhdGEgICAgKnRsYjsKKwl1NjQgICAgIG1hZGRyOworCisJaWYgKCEoVkNQVSh2Y3B1LCB2cHNy
KSAmIElBNjRfUFNSX0lUKSkgeworCQkvKiBJLXNpZGUgcGh5c2ljYWwgbW9kZSAqLworCQlncGlw
ID0gZ2lwOworCX0gZWxzZSB7CisJCXRsYiA9IHZ0bGJfbG9va3VwKHZjcHUsIGdpcCwgSV9UTEIp
OworCQlpZiAodGxiKQorCQkJZ3BpcCA9ICh0bGItPnBwbiA+PiAodGxiLT5wcyAtIDEyKSA8PCB0
bGItPnBzKSB8CisJCQkJKGdpcCAmIChQU0laRSh0bGItPnBzKSAtIDEpKTsKKwl9CisJaWYgKGdw
aXApIHsKKwkJbWFkZHIgPSBrdm1fZ3BhX3RvX21wYShncGlwKTsKKwl9IGVsc2UgeworCQl0bGIg
PSB2aHB0X2xvb2t1cChnaXApOworCQlpZiAodGxiID09IE5VTEwpIHsKKwkJCWlhNjRfcHRjbChn
aXAsIEFSQ0hfUEFHRV9TSElGVCA8PCAyKTsKKwkJCXJldHVybiBJQTY0X0ZBVUxUOworCQl9CisJ
CW1hZGRyID0gKHRsYi0+cHBuID4+ICh0bGItPnBzIC0gMTIpIDw8IHRsYi0+cHMpCisJCQkJCXwg
KGdpcCAmIChQU0laRSh0bGItPnBzKSAtIDEpKTsKKwl9CisJdnBhID0gKHU2NCAqKV9fa3ZtX3Zh
KG1hZGRyKTsKKworCXBidW5kbGUtPmk2NFswXSA9ICp2cGErKzsKKwlwYnVuZGxlLT5pNjRbMV0g
PSAqdnBhOworCisJcmV0dXJuIElBNjRfTk9fRkFVTFQ7Cit9CisKKwordm9pZCBrdm1faW5pdF92
aHB0KHN0cnVjdCBrdm1fdmNwdSAqdikKK3sKKwl2LT5hcmNoLnZocHQubnVtID0gVkhQVF9OVU1f
RU5UUklFUzsKKwl0aGFzaF9pbml0KCZ2LT5hcmNoLnZocHQsIFZIUFRfU0hJRlQpOworCWlhNjRf
c2V0X3B0YSh2LT5hcmNoLnZocHQucHRhLnZhbCk7CisJLypFbmFibGUgVkhQVCBoZXJlPyovCit9
CisKK3ZvaWQga3ZtX2luaXRfdnRsYihzdHJ1Y3Qga3ZtX3ZjcHUgKnYpCit7CisJdi0+YXJjaC52
dGxiLm51bSA9IFZUTEJfTlVNX0VOVFJJRVM7CisJdGhhc2hfaW5pdCgmdi0+YXJjaC52dGxiLCBW
VExCX1NISUZUKTsKK30KLS0gCjEuNS4yCgo=

------_=_NextPart_001_01C893E5.B32697C7--
