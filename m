From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Mon, 31 Mar 2008 08:27:48 +0000
Subject: [07/17][PATCH] kvm/ia64: Add TLB virtulization support.-V8
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC0104824B@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C89309.1A63141B"
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF9@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF9@pdsmsx415.ccr.corp.intel.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C89309.1A63141B
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 6b731c15afa8cec84f16408c421c286f1dd1b7d3 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Wed, 12 Mar 2008 13:45:40 +0800
Subject: [PATCH] KVM:IA64 : Add TLB virtulization support.

vtlb.c includes tlb/VHPT virtulization.
Signed-off-by: Anthony Xu <anthony.xu@intel.com>
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/vtlb.c |  631
++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 631 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/vtlb.c

diff --git a/arch/ia64/kvm/vtlb.c b/arch/ia64/kvm/vtlb.c
new file mode 100644
index 0000000..6e6ed25
--- /dev/null
+++ b/arch/ia64/kvm/vtlb.c
@@ -0,0 +1,631 @@
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
+/*
+ * Check to see if the address rid:va is translated by the TLB
+ */
+
+static int __is_tr_translated(thash_data_t *trp, u64 rid, u64 va)
+{
+	return ((trp->p) && (trp->rid =3D=3D rid)
+				&& ((va-trp->vadr) < PSIZE(trp->ps)));
+}
+
+/*
+ * Only for GUEST TR format.
+ */
+static int __is_tr_overlap(thash_data_t *trp, u64 rid, u64 sva, u64
eva)
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
+int vhpt_enabled(VCPU *vcpu, u64 vadr, vhpt_ref_t ref)
+{
+	ia64_rr    vrr;
+	ia64_pta   vpta;
+	ia64_psr   vpsr;
+
+	vpsr.val =3D VCPU(vcpu, vpsr);
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
+thash_data_t *vsa_thash(ia64_pta vpta, u64 va, u64 vrr, u64 *tag)
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
+	return (thash_data_t *)((vpta.base << PTA_BASE_SHIFT) + (index
<< 5));
+}
+
+thash_data_t *__vtr_lookup(VCPU *vcpu, u64 va, int type)
+{
+
+	thash_data_t  *trp;
+	int  i;
+	u64 rid;
+
+	rid =3D vcpu_get_rr(vcpu, va);
+	rid =3D rid & RR_RID_MASK;;
+	if (type =3D=3D D_TLB) {
+		if (vcpu_quick_region_check(vcpu->arch.dtr_regions, va))
{
+			for (trp =3D (thash_data_t *)&vcpu->arch.dtrs, i =3D
0;
+						i < NDTRS; i++, trp++) {
+				if (__is_tr_translated(trp, rid, va))
+					return trp;
+			}
+		}
+	} else {
+		if (vcpu_quick_region_check(vcpu->arch.itr_regions, va))
{
+			for (trp =3D (thash_data_t *)&vcpu->arch.itrs, i =3D
0;
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
+	ia64_rr rr;
+	thash_data_t *head;
+	unsigned long ps, gpaddr;
+
+	ps =3D itir_ps(itir);
+
+	gpaddr =3D ((gpte & _PAGE_PPN_MASK) >> ps << ps) |
+		(ifa & ((1UL << ps) - 1));
+
+	rr.val =3D ia64_get_rr(ifa);
+	head =3D (thash_data_t *)ia64_thash(ifa);
+	head->etag =3D INVALID_TI_TAG;
+	ia64_mf();
+	head->page_flags =3D pte & ~PAGE_FLAGS_RV_MASK;
+	head->itir =3D rr.ps << 2;
+	head->etag =3D ia64_ttag(ifa);
+	head->gpaddr =3D gpaddr;
+}
+
+void mark_pages_dirty(VCPU *v, u64 pte, u64 ps)
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
+void thash_vhpt_insert(VCPU *v, u64 pte, u64 itir, u64 va, int type)
+{
+	u64 phy_pte, psr;
+	ia64_rr mrr;
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
+thash_data_t *vhpt_lookup(u64 va)
+{
+	thash_data_t *head;
+	u64 tag;
+
+	head =3D (thash_data_t *)ia64_thash(va);
+	tag =3D ia64_ttag(va);
+	if (head->etag =3D=3D tag)
+		return head;
+	return NULL;
+}
+
+u64 guest_vhpt_lookup(u64 iha, u64 *pte)
+{
+	u64 ret;
+	thash_data_t *data;
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
+static void vtlb_purge(VCPU *v, u64 va, u64 ps)
+{
+	thash_data_t *cur;
+	u64 start, curadr, size, psbits, tag, rr_ps, num;
+	ia64_rr vrr;
+	thash_cb_t *hcb =3D &v->arch.vtlb;
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
+static void vhpt_purge(VCPU *v, u64 va, u64 ps)
+{
+	thash_data_t *cur;
+	u64 start, size, tag, num;
+	ia64_rr rr;
+
+	start =3D va & ~((1UL << ps) - 1);
+	rr.val =3D ia64_get_rr(va);
+	size =3D PSIZE(rr.ps);
+	num =3D 1UL << ((ps < rr.ps) ? 0 : (ps - rr.ps));
+	while (num) {
+		cur =3D (thash_data_t *)ia64_thash(start);
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
+void vtlb_insert(VCPU *v, u64 pte, u64 itir, u64 va)
+{
+	thash_data_t *head;
+	ia64_rr vrr;
+	u64 tag;
+	thash_cb_t *hcb =3D &v->arch.vtlb;
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
+int vtr_find_overlap(VCPU *vcpu, u64 va, u64 ps, int type)
+{
+	thash_data_t  *trp;
+	int  i;
+	u64 end, rid;
+
+	rid =3D vcpu_get_rr(vcpu, va);
+	rid =3D rid & RR_RID_MASK;
+	end =3D va + PSIZE(ps);
+	if (type =3D=3D D_TLB) {
+		if (vcpu_quick_region_check(vcpu->arch.dtr_regions, va))
{
+			for (trp =3D (thash_data_t *)&vcpu->arch.dtrs, i =3D
0;
+					i < NDTRS; i++, trp++) {
+				if (__is_tr_overlap(trp, rid, va, end))
+					return i;
+			}
+		}
+	} else {
+		if (vcpu_quick_region_check(vcpu->arch.itr_regions, va))
{
+			for (trp =3D (thash_data_t *)&vcpu->arch.itrs, i =3D
0;
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
+void thash_purge_entries(VCPU *v, u64 va, u64 ps)
+{
+	if (vcpu_quick_region_check(v->arch.tc_regions, va))
+		vtlb_purge(v, va, ps);
+	vhpt_purge(v, va, ps);
+}
+
+void thash_purge_entries_remote(VCPU *v, u64 va, u64 ps)
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
+int thash_purge_and_insert(VCPU *v, u64 pte, u64 itir, u64 ifa, int
type)
+{
+	u64 ps;
+	u64 phy_pte;
+	ia64_rr vrr, mrr;
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
+void thash_purge_all(VCPU *v)
+{
+	int i;
+	thash_data_t *head;
+	thash_cb_t  *vtlb, *vhpt;
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
+thash_data_t *vtlb_lookup(VCPU *v, u64 va, int is_data)
+{
+	thash_data_t  *cch;
+	u64     psbits, ps, tag;
+	ia64_rr vrr;
+
+	thash_cb_t *hcb =3D &v->arch.vtlb;
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
+void thash_init(thash_cb_t *hcb, u64 sz)
+{
+	int i;
+	thash_data_t *head;
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
+int fetch_code(VCPU *vcpu, u64 gip, IA64_BUNDLE *pbundle)
+{
+	u64     gpip =3D 0;   /* guest physical IP*/
+	u64     *vpa;
+	thash_data_t    *tlb;
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
+void kvm_init_vhpt(VCPU *v)
+{
+	v->arch.vhpt.num =3D VHPT_NUM_ENTRIES;
+	thash_init(&v->arch.vhpt, VHPT_SHIFT);
+	ia64_set_pta(v->arch.vhpt.pta.val);
+	/*Enable VHPT here?*/
+}
+
+void kvm_init_vtlb(VCPU *v)
+{
+	v->arch.vtlb.num =3D VTLB_NUM_ENTRIES;
+	thash_init(&v->arch.vtlb, VTLB_SHIFT);
+}
--=20
1.5.2

------_=_NextPart_001_01C89309.1A63141B
Content-Type: application/octet-stream;
	name="0007-KVM-IA64-Add-TLB-virtulization-support.patch"
Content-Transfer-Encoding: base64
Content-Description: 0007-KVM-IA64-Add-TLB-virtulization-support.patch
Content-Disposition: attachment;
	filename="0007-KVM-IA64-Add-TLB-virtulization-support.patch"

RnJvbSA2YjczMWMxNWFmYThjZWM4NGYxNjQwOGM0MjFjMjg2ZjFkZDFiN2QzIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogV2VkLCAxMiBNYXIgMjAwOCAxMzo0NTo0MCArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IEtWTTpJQTY0IDogQWRkIFRMQiB2aXJ0dWxpemF0aW9uIHN1cHBvcnQuCgp2dGxiLmMgaW5jbHVk
ZXMgdGxiL1ZIUFQgdmlydHVsaXphdGlvbi4KU2lnbmVkLW9mZi1ieTogQW50aG9ueSBYdSA8YW50
aG9ueS54dUBpbnRlbC5jb20+ClNpZ25lZC1vZmYtYnk6IFhpYW50YW8gWmhhbmcgPHhpYW50YW8u
emhhbmdAaW50ZWwuY29tPgotLS0KIGFyY2gvaWE2NC9rdm0vdnRsYi5jIHwgIDYzMSArKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKwogMSBmaWxlcyBjaGFu
Z2VkLCA2MzEgaW5zZXJ0aW9ucygrKSwgMCBkZWxldGlvbnMoLSkKIGNyZWF0ZSBtb2RlIDEwMDY0
NCBhcmNoL2lhNjQva3ZtL3Z0bGIuYwoKZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9rdm0vdnRsYi5j
IGIvYXJjaC9pYTY0L2t2bS92dGxiLmMKbmV3IGZpbGUgbW9kZSAxMDA2NDQKaW5kZXggMDAwMDAw
MC4uNmU2ZWQyNQotLS0gL2Rldi9udWxsCisrKyBiL2FyY2gvaWE2NC9rdm0vdnRsYi5jCkBAIC0w
LDAgKzEsNjMxIEBACisvKgorICogdnRsYi5jOiBndWVzdCB2aXJ0dWFsIHRsYiBoYW5kbGluZyBt
b2R1bGUuCisgKiBDb3B5cmlnaHQgKGMpIDIwMDQsIEludGVsIENvcnBvcmF0aW9uLgorICogIFlh
b3p1IERvbmcgKEVkZGllIERvbmcpIDxFZGRpZS5kb25nQGludGVsLmNvbT4KKyAqICBYdWVmZWkg
WHUgKEFudGhvbnkgWHUpIDxhbnRob255Lnh1QGludGVsLmNvbT4KKyAqCisgKiBDb3B5cmlnaHQg
KGMpIDIwMDcsIEludGVsIENvcnBvcmF0aW9uLgorICogIFh1ZWZlaSBYdSAoQW50aG9ueSBYdSkg
PGFudGhvbnkueHVAaW50ZWwuY29tPgorICogIFhpYW50YW8gWmhhbmcgPHhpYW50YW8uemhhbmdA
aW50ZWwuY29tPgorICoKKyAqIFRoaXMgcHJvZ3JhbSBpcyBmcmVlIHNvZnR3YXJlOyB5b3UgY2Fu
IHJlZGlzdHJpYnV0ZSBpdCBhbmQvb3IgbW9kaWZ5IGl0CisgKiB1bmRlciB0aGUgdGVybXMgYW5k
IGNvbmRpdGlvbnMgb2YgdGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlLAorICogdmVyc2lv
biAyLCBhcyBwdWJsaXNoZWQgYnkgdGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlvbi4KKyAqCisg
KiBUaGlzIHByb2dyYW0gaXMgZGlzdHJpYnV0ZWQgaW4gdGhlIGhvcGUgaXQgd2lsbCBiZSB1c2Vm
dWwsIGJ1dCBXSVRIT1VUCisgKiBBTlkgV0FSUkFOVFk7IHdpdGhvdXQgZXZlbiB0aGUgaW1wbGll
ZCB3YXJyYW50eSBvZiBNRVJDSEFOVEFCSUxJVFkgb3IKKyAqIEZJVE5FU1MgRk9SIEEgUEFSVElD
VUxBUiBQVVJQT1NFLiAgU2VlIHRoZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSBmb3IKKyAq
IG1vcmUgZGV0YWlscy4KKyAqCisgKiBZb3Ugc2hvdWxkIGhhdmUgcmVjZWl2ZWQgYSBjb3B5IG9m
IHRoZSBHTlUgR2VuZXJhbCBQdWJsaWMgTGljZW5zZSBhbG9uZyB3aXRoCisgKiB0aGlzIHByb2dy
YW07IGlmIG5vdCwgd3JpdGUgdG8gdGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlvbiwgSW5jLiwg
NTkgVGVtcGxlCisgKiBQbGFjZSAtIFN1aXRlIDMzMCwgQm9zdG9uLCBNQSAwMjExMS0xMzA3IFVT
QS4KKyAqCisgKi8KKworI2luY2x1ZGUgInZjcHUuaCIKKworI2luY2x1ZGUgPGxpbnV4L3J3c2Vt
Lmg+CisvKgorICogQ2hlY2sgdG8gc2VlIGlmIHRoZSBhZGRyZXNzIHJpZDp2YSBpcyB0cmFuc2xh
dGVkIGJ5IHRoZSBUTEIKKyAqLworCitzdGF0aWMgaW50IF9faXNfdHJfdHJhbnNsYXRlZCh0aGFz
aF9kYXRhX3QgKnRycCwgdTY0IHJpZCwgdTY0IHZhKQoreworCXJldHVybiAoKHRycC0+cCkgJiYg
KHRycC0+cmlkID09IHJpZCkKKwkJCQkmJiAoKHZhLXRycC0+dmFkcikgPCBQU0laRSh0cnAtPnBz
KSkpOworfQorCisvKgorICogT25seSBmb3IgR1VFU1QgVFIgZm9ybWF0LgorICovCitzdGF0aWMg
aW50IF9faXNfdHJfb3ZlcmxhcCh0aGFzaF9kYXRhX3QgKnRycCwgdTY0IHJpZCwgdTY0IHN2YSwg
dTY0IGV2YSkKK3sKKwl1NjQgc2ExLCBlYTE7CisKKwlpZiAoIXRycC0+cCB8fCB0cnAtPnJpZCAh
PSByaWQpCisJCXJldHVybiAwOworCisJc2ExID0gdHJwLT52YWRyOworCWVhMSA9IHNhMSArIFBT
SVpFKHRycC0+cHMpIC0gMTsKKwlldmEgLT0gMTsKKwlpZiAoKHN2YSA+IGVhMSkgfHwgKHNhMSA+
IGV2YSkpCisJCXJldHVybiAwOworCWVsc2UKKwkJcmV0dXJuIDE7CisKK30KKwordm9pZCBtYWNo
aW5lX3RsYl9wdXJnZSh1NjQgdmEsIHU2NCBwcykKK3sKKwlpYTY0X3B0Y2wodmEsIHBzIDw8IDIp
OworfQorCit2b2lkIGxvY2FsX2ZsdXNoX3RsYl9hbGwodm9pZCkKK3sKKwlpbnQgaSwgajsKKwl1
bnNpZ25lZCBsb25nIGZsYWdzLCBjb3VudDAsIGNvdW50MTsKKwl1bnNpZ25lZCBsb25nIHN0cmlk
ZTAsIHN0cmlkZTEsIGFkZHI7CisKKwlhZGRyICAgID0gY3VycmVudF92Y3B1LT5hcmNoLnB0Y2Vf
YmFzZTsKKwljb3VudDAgID0gY3VycmVudF92Y3B1LT5hcmNoLnB0Y2VfY291bnRbMF07CisJY291
bnQxICA9IGN1cnJlbnRfdmNwdS0+YXJjaC5wdGNlX2NvdW50WzFdOworCXN0cmlkZTAgPSBjdXJy
ZW50X3ZjcHUtPmFyY2gucHRjZV9zdHJpZGVbMF07CisJc3RyaWRlMSA9IGN1cnJlbnRfdmNwdS0+
YXJjaC5wdGNlX3N0cmlkZVsxXTsKKworCWxvY2FsX2lycV9zYXZlKGZsYWdzKTsKKwlmb3IgKGkg
PSAwOyBpIDwgY291bnQwOyArK2kpIHsKKwkJZm9yIChqID0gMDsgaiA8IGNvdW50MTsgKytqKSB7
CisJCQlpYTY0X3B0Y2UoYWRkcik7CisJCQlhZGRyICs9IHN0cmlkZTE7CisJCX0KKwkJYWRkciAr
PSBzdHJpZGUwOworCX0KKwlsb2NhbF9pcnFfcmVzdG9yZShmbGFncyk7CisJaWE2NF9zcmx6X2ko
KTsgICAgICAgICAgLyogc3Jsei5pIGltcGxpZXMgc3Jsei5kICovCit9CisKK2ludCB2aHB0X2Vu
YWJsZWQoVkNQVSAqdmNwdSwgdTY0IHZhZHIsIHZocHRfcmVmX3QgcmVmKQoreworCWlhNjRfcnIg
ICAgdnJyOworCWlhNjRfcHRhICAgdnB0YTsKKwlpYTY0X3BzciAgIHZwc3I7CisKKwl2cHNyLnZh
bCA9IFZDUFUodmNwdSwgdnBzcik7CisJdnJyLnZhbCA9IHZjcHVfZ2V0X3JyKHZjcHUsIHZhZHIp
OworCXZwdGEudmFsID0gdmNwdV9nZXRfcHRhKHZjcHUpOworCisJaWYgKHZyci52ZSAmIHZwdGEu
dmUpIHsKKwkJc3dpdGNoIChyZWYpIHsKKwkJY2FzZSBEQVRBX1JFRjoKKwkJY2FzZSBOQV9SRUY6
CisJCQlyZXR1cm4gdnBzci5kdDsKKwkJY2FzZSBJTlNUX1JFRjoKKwkJCXJldHVybiB2cHNyLmR0
ICYmIHZwc3IuaXQgJiYgdnBzci5pYzsKKwkJY2FzZSBSU0VfUkVGOgorCQkJcmV0dXJuIHZwc3Iu
ZHQgJiYgdnBzci5ydDsKKworCQl9CisJfQorCXJldHVybiAwOworfQorCit0aGFzaF9kYXRhX3Qg
KnZzYV90aGFzaChpYTY0X3B0YSB2cHRhLCB1NjQgdmEsIHU2NCB2cnIsIHU2NCAqdGFnKQorewor
CXU2NCBpbmRleCwgcGZuLCByaWQsIHBmbl9iaXRzOworCisJcGZuX2JpdHMgPSB2cHRhLnNpemUg
LSA1IC0gODsKKwlwZm4gPSBSRUdJT05fT0ZGU0VUKHZhKSA+PiBfUkVHSU9OX1BBR0VfU0laRSh2
cnIpOworCXJpZCA9IF9SRUdJT05fSUQodnJyKTsKKwlpbmRleCA9ICgocmlkICYgMHhmZikgPDwg
cGZuX2JpdHMpfChwZm4gJiAoKDFVTCA8PCBwZm5fYml0cykgLSAxKSk7CisJKnRhZyA9ICgocmlk
ID4+IDgpICYgMHhmZmZmKSB8ICgocGZuID4+IHBmbl9iaXRzKSA8PCAxNik7CisKKwlyZXR1cm4g
KHRoYXNoX2RhdGFfdCAqKSgodnB0YS5iYXNlIDw8IFBUQV9CQVNFX1NISUZUKSArIChpbmRleCA8
PCA1KSk7Cit9CisKK3RoYXNoX2RhdGFfdCAqX192dHJfbG9va3VwKFZDUFUgKnZjcHUsIHU2NCB2
YSwgaW50IHR5cGUpCit7CisKKwl0aGFzaF9kYXRhX3QgICp0cnA7CisJaW50ICBpOworCXU2NCBy
aWQ7CisKKwlyaWQgPSB2Y3B1X2dldF9ycih2Y3B1LCB2YSk7CisJcmlkID0gcmlkICYgUlJfUklE
X01BU0s7OworCWlmICh0eXBlID09IERfVExCKSB7CisJCWlmICh2Y3B1X3F1aWNrX3JlZ2lvbl9j
aGVjayh2Y3B1LT5hcmNoLmR0cl9yZWdpb25zLCB2YSkpIHsKKwkJCWZvciAodHJwID0gKHRoYXNo
X2RhdGFfdCAqKSZ2Y3B1LT5hcmNoLmR0cnMsIGkgPSAwOworCQkJCQkJaSA8IE5EVFJTOyBpKyss
IHRycCsrKSB7CisJCQkJaWYgKF9faXNfdHJfdHJhbnNsYXRlZCh0cnAsIHJpZCwgdmEpKQorCQkJ
CQlyZXR1cm4gdHJwOworCQkJfQorCQl9CisJfSBlbHNlIHsKKwkJaWYgKHZjcHVfcXVpY2tfcmVn
aW9uX2NoZWNrKHZjcHUtPmFyY2guaXRyX3JlZ2lvbnMsIHZhKSkgeworCQkJZm9yICh0cnAgPSAo
dGhhc2hfZGF0YV90ICopJnZjcHUtPmFyY2guaXRycywgaSA9IDA7CisJCQkJCWkgPCBOSVRSUzsg
aSsrLCB0cnArKykgeworCQkJCWlmIChfX2lzX3RyX3RyYW5zbGF0ZWQodHJwLCByaWQsIHZhKSkK
KwkJCQkJcmV0dXJuIHRycDsKKwkJCX0KKwkJfQorCX0KKworCXJldHVybiBOVUxMOworfQorCitz
dGF0aWMgdm9pZCB2aHB0X2luc2VydCh1NjQgcHRlLCB1NjQgaXRpciwgdTY0IGlmYSwgdTY0IGdw
dGUpCit7CisJaWE2NF9yciBycjsKKwl0aGFzaF9kYXRhX3QgKmhlYWQ7CisJdW5zaWduZWQgbG9u
ZyBwcywgZ3BhZGRyOworCisJcHMgPSBpdGlyX3BzKGl0aXIpOworCisJZ3BhZGRyID0gKChncHRl
ICYgX1BBR0VfUFBOX01BU0spID4+IHBzIDw8IHBzKSB8CisJCShpZmEgJiAoKDFVTCA8PCBwcykg
LSAxKSk7CisKKwlyci52YWwgPSBpYTY0X2dldF9ycihpZmEpOworCWhlYWQgPSAodGhhc2hfZGF0
YV90ICopaWE2NF90aGFzaChpZmEpOworCWhlYWQtPmV0YWcgPSBJTlZBTElEX1RJX1RBRzsKKwlp
YTY0X21mKCk7CisJaGVhZC0+cGFnZV9mbGFncyA9IHB0ZSAmIH5QQUdFX0ZMQUdTX1JWX01BU0s7
CisJaGVhZC0+aXRpciA9IHJyLnBzIDw8IDI7CisJaGVhZC0+ZXRhZyA9IGlhNjRfdHRhZyhpZmEp
OworCWhlYWQtPmdwYWRkciA9IGdwYWRkcjsKK30KKwordm9pZCBtYXJrX3BhZ2VzX2RpcnR5KFZD
UFUgKnYsIHU2NCBwdGUsIHU2NCBwcykKK3sKKwl1NjQgaSwgZGlydHlfcGFnZXMgPSAxOworCXU2
NCBiYXNlX2dmbiA9IChwdGUmX1BBR0VfUFBOX01BU0spID4+IFBBR0VfU0hJRlQ7CisJc3Bpbmxv
Y2tfdCAqbG9jayA9IF9fa3ZtX3ZhKHYtPmFyY2guZGlydHlfbG9nX2xvY2tfcGEpOworCXZvaWQg
KmRpcnR5X2JpdG1hcCA9ICh2b2lkICopdiAtIChLVk1fVkNQVV9PRlMgKyB2LT52Y3B1X2lkICog
VkNQVV9TSVpFKQorCQkJCQkJKyBLVk1fTUVNX0RJUlRZX0xPR19PRlM7CisJZGlydHlfcGFnZXMg
PDw9IHBzIDw9IFBBR0VfU0hJRlQgPyAwIDogcHMgLSBQQUdFX1NISUZUOworCisJdm1tX3NwaW5f
bG9jayhsb2NrKTsKKwlmb3IgKGkgPSAwOyBpIDwgZGlydHlfcGFnZXM7IGkrKykgeworCQkvKiBh
dm9pZCBSTVcgKi8KKwkJaWYgKCF0ZXN0X2JpdChiYXNlX2dmbiArIGksIGRpcnR5X2JpdG1hcCkp
CisJCQlzZXRfYml0KGJhc2VfZ2ZuICsgaSAsIGRpcnR5X2JpdG1hcCk7CisJfQorCXZtbV9zcGlu
X3VubG9jayhsb2NrKTsKK30KKwordm9pZCB0aGFzaF92aHB0X2luc2VydChWQ1BVICp2LCB1NjQg
cHRlLCB1NjQgaXRpciwgdTY0IHZhLCBpbnQgdHlwZSkKK3sKKwl1NjQgcGh5X3B0ZSwgcHNyOwor
CWlhNjRfcnIgbXJyOworCisJbXJyLnZhbCA9IGlhNjRfZ2V0X3JyKHZhKTsKKwlwaHlfcHRlID0g
dHJhbnNsYXRlX3BoeV9wdGUoJnB0ZSwgaXRpciwgdmEpOworCisJaWYgKGl0aXJfcHMoaXRpcikg
Pj0gbXJyLnBzKSB7CisJCXZocHRfaW5zZXJ0KHBoeV9wdGUsIGl0aXIsIHZhLCBwdGUpOworCX0g
ZWxzZSB7CisJCXBoeV9wdGUgICY9IH5QQUdFX0ZMQUdTX1JWX01BU0s7CisJCXBzciA9IGlhNjRf
Y2xlYXJfaWMoKTsKKwkJaWE2NF9pdGModHlwZSwgdmEsIHBoeV9wdGUsIGl0aXJfcHMoaXRpcikp
OworCQlpYTY0X3NldF9wc3IocHNyKTsKKwl9CisKKwlpZiAoIShwdGUmVlRMQl9QVEVfSU8pKQor
CQltYXJrX3BhZ2VzX2RpcnR5KHYsIHB0ZSwgaXRpcl9wcyhpdGlyKSk7Cit9CisKKy8qCisgKiAg
IHZocHQgbG9va3VwCisgKi8KK3RoYXNoX2RhdGFfdCAqdmhwdF9sb29rdXAodTY0IHZhKQorewor
CXRoYXNoX2RhdGFfdCAqaGVhZDsKKwl1NjQgdGFnOworCisJaGVhZCA9ICh0aGFzaF9kYXRhX3Qg
KilpYTY0X3RoYXNoKHZhKTsKKwl0YWcgPSBpYTY0X3R0YWcodmEpOworCWlmIChoZWFkLT5ldGFn
ID09IHRhZykKKwkJcmV0dXJuIGhlYWQ7CisJcmV0dXJuIE5VTEw7Cit9CisKK3U2NCBndWVzdF92
aHB0X2xvb2t1cCh1NjQgaWhhLCB1NjQgKnB0ZSkKK3sKKwl1NjQgcmV0OworCXRoYXNoX2RhdGFf
dCAqZGF0YTsKKworCWRhdGEgPSBfX3Z0cl9sb29rdXAoY3VycmVudF92Y3B1LCBpaGEsIERfVExC
KTsKKwlpZiAoZGF0YSAhPSBOVUxMKQorCQl0aGFzaF92aHB0X2luc2VydChjdXJyZW50X3ZjcHUs
IGRhdGEtPnBhZ2VfZmxhZ3MsCisJCQlkYXRhLT5pdGlyLCBpaGEsIERfVExCKTsKKworCWFzbSB2
b2xhdGlsZSAoInJzbSBwc3IuaWN8cHNyLmk7OyIKKwkJCSJzcmx6LmQ7OyIKKwkJCSJsZDgucyBy
OT1bJTFdOzsiCisJCQkidG5hdC5ueiBwNixwNz1yOTs7IgorCQkJIihwNikgbW92ICUwPTE7Igor
CQkJIihwNikgbW92IHI5PXIwOyIKKwkJCSIocDcpIGV4dHIudSByOT1yOSwwLDUzOzsiCisJCQki
KHA3KSBtb3YgJTA9cjA7IgorCQkJIihwNykgc3Q4IFslMl09cjk7OyIKKwkJCSJzc20gcHNyLmlj
OzsiCisJCQkic3Jsei5kOzsiCisJCQkvKiAic3NtIHBzci5pOzsiIE9uY2UgaW50ZXJydXB0cyBp
biB2bW0gb3BlbiwgbmVlZCBmaXgqLworCQkJOiAiPXIiKHJldCkgOiAiciIoaWhhKSwgInIiKHB0
ZSk6Im1lbW9yeSIpOworCisJcmV0dXJuIHJldDsKK30KKworLyoKKyAqICBwdXJnZSBzb2Z0d2Fy
ZSBndWVzdCB0bGIKKyAqLworCitzdGF0aWMgdm9pZCB2dGxiX3B1cmdlKFZDUFUgKnYsIHU2NCB2
YSwgdTY0IHBzKQoreworCXRoYXNoX2RhdGFfdCAqY3VyOworCXU2NCBzdGFydCwgY3VyYWRyLCBz
aXplLCBwc2JpdHMsIHRhZywgcnJfcHMsIG51bTsKKwlpYTY0X3JyIHZycjsKKwl0aGFzaF9jYl90
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
dmhwdF9wdXJnZShWQ1BVICp2LCB1NjQgdmEsIHU2NCBwcykKK3sKKwl0aGFzaF9kYXRhX3QgKmN1
cjsKKwl1NjQgc3RhcnQsIHNpemUsIHRhZywgbnVtOworCWlhNjRfcnIgcnI7CisKKwlzdGFydCA9
IHZhICYgfigoMVVMIDw8IHBzKSAtIDEpOworCXJyLnZhbCA9IGlhNjRfZ2V0X3JyKHZhKTsKKwlz
aXplID0gUFNJWkUocnIucHMpOworCW51bSA9IDFVTCA8PCAoKHBzIDwgcnIucHMpID8gMCA6IChw
cyAtIHJyLnBzKSk7CisJd2hpbGUgKG51bSkgeworCQljdXIgPSAodGhhc2hfZGF0YV90ICopaWE2
NF90aGFzaChzdGFydCk7CisJCXRhZyA9IGlhNjRfdHRhZyhzdGFydCk7CisJCWlmIChjdXItPmV0
YWcgPT0gdGFnKQorCQkJY3VyLT5ldGFnID0gSU5WQUxJRF9USV9UQUc7CisJCXN0YXJ0ICs9IHNp
emU7CisJCW51bS0tOworCX0KKwltYWNoaW5lX3RsYl9wdXJnZSh2YSwgcHMpOworfQorCisvKgor
ICogSW5zZXJ0IGFuIGVudHJ5IGludG8gaGFzaCBUTEIgb3IgVkhQVC4KKyAqIE5PVEVTOgorICog
IDE6IFdoZW4gaW5zZXJ0aW5nIFZIUFQgdG8gdGhhc2gsICJ2YSIgaXMgYSBtdXN0IGNvdmVyZWQK
KyAqICBhZGRyZXNzIGJ5IHRoZSBpbnNlcnRlZCBtYWNoaW5lIFZIUFQgZW50cnkuCisgKiAgMjog
VGhlIGZvcm1hdCBvZiBlbnRyeSBpcyBhbHdheXMgaW4gVExCLgorICogIDM6IFRoZSBjYWxsZXIg
bmVlZCB0byBtYWtlIHN1cmUgdGhlIG5ldyBlbnRyeSB3aWxsIG5vdCBvdmVybGFwCisgKiAgICAg
d2l0aCBhbnkgZXhpc3RlZCBlbnRyeS4KKyAqLwordm9pZCB2dGxiX2luc2VydChWQ1BVICp2LCB1
NjQgcHRlLCB1NjQgaXRpciwgdTY0IHZhKQoreworCXRoYXNoX2RhdGFfdCAqaGVhZDsKKwlpYTY0
X3JyIHZycjsKKwl1NjQgdGFnOworCXRoYXNoX2NiX3QgKmhjYiA9ICZ2LT5hcmNoLnZ0bGI7CisK
Kwl2cnIudmFsID0gdmNwdV9nZXRfcnIodiwgdmEpOworCXZyci5wcyA9IGl0aXJfcHMoaXRpcik7
CisJVk1YKHYsIHBzYml0c1t2YSA+PiA2MV0pIHw9ICgxVUwgPDwgdnJyLnBzKTsKKwloZWFkID0g
dnNhX3RoYXNoKGhjYi0+cHRhLCB2YSwgdnJyLnZhbCwgJnRhZyk7CisJaGVhZC0+cGFnZV9mbGFn
cyA9IHB0ZTsKKwloZWFkLT5pdGlyID0gaXRpcjsKKwloZWFkLT5ldGFnID0gdGFnOworfQorCitp
bnQgdnRyX2ZpbmRfb3ZlcmxhcChWQ1BVICp2Y3B1LCB1NjQgdmEsIHU2NCBwcywgaW50IHR5cGUp
Cit7CisJdGhhc2hfZGF0YV90ICAqdHJwOworCWludCAgaTsKKwl1NjQgZW5kLCByaWQ7CisKKwly
aWQgPSB2Y3B1X2dldF9ycih2Y3B1LCB2YSk7CisJcmlkID0gcmlkICYgUlJfUklEX01BU0s7CisJ
ZW5kID0gdmEgKyBQU0laRShwcyk7CisJaWYgKHR5cGUgPT0gRF9UTEIpIHsKKwkJaWYgKHZjcHVf
cXVpY2tfcmVnaW9uX2NoZWNrKHZjcHUtPmFyY2guZHRyX3JlZ2lvbnMsIHZhKSkgeworCQkJZm9y
ICh0cnAgPSAodGhhc2hfZGF0YV90ICopJnZjcHUtPmFyY2guZHRycywgaSA9IDA7CisJCQkJCWkg
PCBORFRSUzsgaSsrLCB0cnArKykgeworCQkJCWlmIChfX2lzX3RyX292ZXJsYXAodHJwLCByaWQs
IHZhLCBlbmQpKQorCQkJCQlyZXR1cm4gaTsKKwkJCX0KKwkJfQorCX0gZWxzZSB7CisJCWlmICh2
Y3B1X3F1aWNrX3JlZ2lvbl9jaGVjayh2Y3B1LT5hcmNoLml0cl9yZWdpb25zLCB2YSkpIHsKKwkJ
CWZvciAodHJwID0gKHRoYXNoX2RhdGFfdCAqKSZ2Y3B1LT5hcmNoLml0cnMsIGkgPSAwOworCQkJ
CQlpIDwgTklUUlM7IGkrKywgdHJwKyspIHsKKwkJCQlpZiAoX19pc190cl9vdmVybGFwKHRycCwg
cmlkLCB2YSwgZW5kKSkKKwkJCQkJcmV0dXJuIGk7CisJCQl9CisJCX0KKwl9CisJcmV0dXJuIC0x
OworfQorCisvKgorICogUHVyZ2UgZW50cmllcyBpbiBWVExCIGFuZCBWSFBUCisgKi8KK3ZvaWQg
dGhhc2hfcHVyZ2VfZW50cmllcyhWQ1BVICp2LCB1NjQgdmEsIHU2NCBwcykKK3sKKwlpZiAodmNw
dV9xdWlja19yZWdpb25fY2hlY2sodi0+YXJjaC50Y19yZWdpb25zLCB2YSkpCisJCXZ0bGJfcHVy
Z2UodiwgdmEsIHBzKTsKKwl2aHB0X3B1cmdlKHYsIHZhLCBwcyk7Cit9CisKK3ZvaWQgdGhhc2hf
cHVyZ2VfZW50cmllc19yZW1vdGUoVkNQVSAqdiwgdTY0IHZhLCB1NjQgcHMpCit7CisJdTY0IG9s
ZF92YSA9IHZhOworCXZhID0gUkVHSU9OX09GRlNFVCh2YSk7CisJaWYgKHZjcHVfcXVpY2tfcmVn
aW9uX2NoZWNrKHYtPmFyY2gudGNfcmVnaW9ucywgb2xkX3ZhKSkKKwkJdnRsYl9wdXJnZSh2LCB2
YSwgcHMpOworCXZocHRfcHVyZ2UodiwgdmEsIHBzKTsKK30KKwordTY0IHRyYW5zbGF0ZV9waHlf
cHRlKHU2NCAqcHRlLCB1NjQgaXRpciwgdTY0IHZhKQoreworCXU2NCBwcywgcHNfbWFzaywgcGFk
ZHIsIG1hZGRyOworCXVuaW9uIHB0ZV9mbGFncyBwaHlfcHRlOworCisJcHMgPSBpdGlyX3BzKGl0
aXIpOworCXBzX21hc2sgPSB+KCgxVUwgPDwgcHMpIC0gMSk7CisJcGh5X3B0ZS52YWwgPSAqcHRl
OworCXBhZGRyID0gKnB0ZTsKKwlwYWRkciA9ICgocGFkZHIgJiBfUEFHRV9QUE5fTUFTSykgJiBw
c19tYXNrKSB8ICh2YSAmIH5wc19tYXNrKTsKKwltYWRkciA9IGt2bV9sb29rdXBfbXBhKHBhZGRy
ID4+IFBBR0VfU0hJRlQpOworCWlmIChtYWRkciAmIEdQRk5fSU9fTUFTSykgeworCQkqcHRlIHw9
IFZUTEJfUFRFX0lPOworCQlyZXR1cm4gLTE7CisJfQorCW1hZGRyID0gKChtYWRkciAmIF9QQUdF
X1BQTl9NQVNLKSAmIFBBR0VfTUFTSykgfAorCQkJCQkocGFkZHIgJiB+UEFHRV9NQVNLKTsKKwlw
aHlfcHRlLnBwbiA9IG1hZGRyID4+IEFSQ0hfUEFHRV9TSElGVDsKKwlyZXR1cm4gcGh5X3B0ZS52
YWw7Cit9CisKKy8qCisgKiBQdXJnZSBvdmVybGFwIFRDcyBhbmQgdGhlbiBpbnNlcnQgdGhlIG5l
dyBlbnRyeSB0byBlbXVsYXRlIGl0YyBvcHMuCisgKiAgICBOb3RlczogT25seSBUQyBlbnRyeSBj
YW4gcHVyZ2UgYW5kIGluc2VydC4KKyAqICAgIDEgaW5kaWNhdGVzIHRoaXMgaXMgTU1JTworICov
CitpbnQgdGhhc2hfcHVyZ2VfYW5kX2luc2VydChWQ1BVICp2LCB1NjQgcHRlLCB1NjQgaXRpciwg
dTY0IGlmYSwgaW50IHR5cGUpCit7CisJdTY0IHBzOworCXU2NCBwaHlfcHRlOworCWlhNjRfcnIg
dnJyLCBtcnI7CisJaW50IHJldCA9IDA7CisKKwlwcyA9IGl0aXJfcHMoaXRpcik7CisJdnJyLnZh
bCA9IHZjcHVfZ2V0X3JyKHYsIGlmYSk7CisJbXJyLnZhbCA9IGlhNjRfZ2V0X3JyKGlmYSk7CisK
KwlwaHlfcHRlID0gdHJhbnNsYXRlX3BoeV9wdGUoJnB0ZSwgaXRpciwgaWZhKTsKKworCS8qIEVu
c3VyZSBXQiBhdHRyaWJ1dGUgaWYgcHRlIGlzIHJlbGF0ZWQgdG8gYSBub3JtYWwgbWVtIHBhZ2Us
CisJICogd2hpY2ggaXMgcmVxdWlyZWQgYnkgdmdhIGFjY2VsZXJhdGlvbiBzaW5jZSBxZW11IG1h
cHMgc2hhcmVkCisJICogdnJhbSBidWZmZXIgd2l0aCBXQi4KKwkgKi8KKwlpZiAoIShwdGUgJiBW
VExCX1BURV9JTykgJiYgKChwdGUgJiBfUEFHRV9NQV9NQVNLKSAhPSBfUEFHRV9NQV9OQVQpKSB7
CisJCXB0ZSAmPSB+X1BBR0VfTUFfTUFTSzsKKwkJcGh5X3B0ZSAmPSB+X1BBR0VfTUFfTUFTSzsK
Kwl9CisKKwlpZiAocHRlICYgVlRMQl9QVEVfSU8pCisJCXJldCA9IDE7CisKKwl2dGxiX3B1cmdl
KHYsIGlmYSwgcHMpOworCXZocHRfcHVyZ2UodiwgaWZhLCBwcyk7CisKKwlpZiAocHMgPT0gbXJy
LnBzKSB7CisJCWlmICghKHB0ZSZWVExCX1BURV9JTykpIHsKKwkJCXZocHRfaW5zZXJ0KHBoeV9w
dGUsIGl0aXIsIGlmYSwgcHRlKTsKKwkJfSBlbHNlIHsKKwkJCXZ0bGJfaW5zZXJ0KHYsIHB0ZSwg
aXRpciwgaWZhKTsKKwkJCXZjcHVfcXVpY2tfcmVnaW9uX3NldChWTVgodiwgdGNfcmVnaW9ucyks
IGlmYSk7CisJCX0KKwl9IGVsc2UgaWYgKHBzID4gbXJyLnBzKSB7CisJCXZ0bGJfaW5zZXJ0KHYs
IHB0ZSwgaXRpciwgaWZhKTsKKwkJdmNwdV9xdWlja19yZWdpb25fc2V0KFZNWCh2LCB0Y19yZWdp
b25zKSwgaWZhKTsKKwkJaWYgKCEocHRlJlZUTEJfUFRFX0lPKSkKKwkJCXZocHRfaW5zZXJ0KHBo
eV9wdGUsIGl0aXIsIGlmYSwgcHRlKTsKKwl9IGVsc2UgeworCQl1NjQgcHNyOworCQlwaHlfcHRl
ICAmPSB+UEFHRV9GTEFHU19SVl9NQVNLOworCQlwc3IgPSBpYTY0X2NsZWFyX2ljKCk7CisJCWlh
NjRfaXRjKHR5cGUsIGlmYSwgcGh5X3B0ZSwgcHMpOworCQlpYTY0X3NldF9wc3IocHNyKTsKKwl9
CisJaWYgKCEocHRlJlZUTEJfUFRFX0lPKSkKKwkJbWFya19wYWdlc19kaXJ0eSh2LCBwdGUsIHBz
KTsKKworCXJldHVybiByZXQ7Cit9CisKKy8qCisgKiBQdXJnZSBhbGwgVENzIG9yIFZIUFQgZW50
cmllcyBpbmNsdWRpbmcgdGhvc2UgaW4gSGFzaCB0YWJsZS4KKyAqCisgKi8KKwordm9pZCB0aGFz
aF9wdXJnZV9hbGwoVkNQVSAqdikKK3sKKwlpbnQgaTsKKwl0aGFzaF9kYXRhX3QgKmhlYWQ7CisJ
dGhhc2hfY2JfdCAgKnZ0bGIsICp2aHB0OworCXZ0bGIgPSAmdi0+YXJjaC52dGxiOworCXZocHQg
PSAmdi0+YXJjaC52aHB0OworCisJZm9yIChpID0gMDsgaSA8IDg7IGkrKykKKwkJVk1YKHYsIHBz
Yml0c1tpXSkgPSAwOworCisJaGVhZCA9IHZ0bGItPmhhc2g7CisJZm9yIChpID0gMDsgaSA8IHZ0
bGItPm51bTsgaSsrKSB7CisJCWhlYWQtPnBhZ2VfZmxhZ3MgPSAwOworCQloZWFkLT5ldGFnID0g
SU5WQUxJRF9USV9UQUc7CisJCWhlYWQtPml0aXIgPSAwOworCQloZWFkLT5uZXh0ID0gMDsKKwkJ
aGVhZCsrOworCX07CisKKwloZWFkID0gdmhwdC0+aGFzaDsKKwlmb3IgKGkgPSAwOyBpIDwgdmhw
dC0+bnVtOyBpKyspIHsKKwkJaGVhZC0+cGFnZV9mbGFncyA9IDA7CisJCWhlYWQtPmV0YWcgPSBJ
TlZBTElEX1RJX1RBRzsKKwkJaGVhZC0+aXRpciA9IDA7CisJCWhlYWQtPm5leHQgPSAwOworCQlo
ZWFkKys7CisJfTsKKworCWxvY2FsX2ZsdXNoX3RsYl9hbGwoKTsKK30KKworCisvKgorICogTG9v
a3VwIHRoZSBoYXNoIHRhYmxlIGFuZCBpdHMgY29sbGlzaW9uIGNoYWluIHRvIGZpbmQgYW4gZW50
cnkKKyAqIGNvdmVyaW5nIHRoaXMgYWRkcmVzcyByaWQ6dmEgb3IgdGhlIGVudHJ5LgorICoKKyAq
IElOUFVUOgorICogIGluOiBUTEIgZm9ybWF0IGZvciBib3RoIFZIUFQgJiBUTEIuCisgKi8KKwor
dGhhc2hfZGF0YV90ICp2dGxiX2xvb2t1cChWQ1BVICp2LCB1NjQgdmEsIGludCBpc19kYXRhKQor
eworCXRoYXNoX2RhdGFfdCAgKmNjaDsKKwl1NjQgICAgIHBzYml0cywgcHMsIHRhZzsKKwlpYTY0
X3JyIHZycjsKKworCXRoYXNoX2NiX3QgKmhjYiA9ICZ2LT5hcmNoLnZ0bGI7CisKKwljY2ggPSBf
X3Z0cl9sb29rdXAodiwgdmEsIGlzX2RhdGEpOzsKKwlpZiAoY2NoKQorCQlyZXR1cm4gY2NoOwor
CisJaWYgKHZjcHVfcXVpY2tfcmVnaW9uX2NoZWNrKHYtPmFyY2gudGNfcmVnaW9ucywgdmEpID09
IDApCisJCXJldHVybiBOVUxMOworCisJcHNiaXRzID0gVk1YKHYsIHBzYml0c1sodmEgPj4gNjEp
XSk7CisJdnJyLnZhbCA9IHZjcHVfZ2V0X3JyKHYsIHZhKTsKKwl3aGlsZSAocHNiaXRzKSB7CisJ
CXBzID0gX19mZnMocHNiaXRzKTsKKwkJcHNiaXRzICY9IH4oMVVMIDw8IHBzKTsKKwkJdnJyLnBz
ID0gcHM7CisJCWNjaCA9IHZzYV90aGFzaChoY2ItPnB0YSwgdmEsIHZyci52YWwsICZ0YWcpOwor
CQlpZiAoY2NoLT5ldGFnID09IHRhZyAmJiBjY2gtPnBzID09IHBzKQorCQkJcmV0dXJuIGNjaDsK
Kwl9CisKKwlyZXR1cm4gTlVMTDsKK30KKworCisvKgorICogSW5pdGlhbGl6ZSBpbnRlcm5hbCBj
b250cm9sIGRhdGEgYmVmb3JlIHNlcnZpY2UuCisgKi8KK3ZvaWQgdGhhc2hfaW5pdCh0aGFzaF9j
Yl90ICpoY2IsIHU2NCBzeikKK3sKKwlpbnQgaTsKKwl0aGFzaF9kYXRhX3QgKmhlYWQ7CisKKwlo
Y2ItPnB0YS52YWwgPSAodW5zaWduZWQgbG9uZyloY2ItPmhhc2g7CisJaGNiLT5wdGEudmYgPSAx
OworCWhjYi0+cHRhLnZlID0gMTsKKwloY2ItPnB0YS5zaXplID0gc3o7CisJaGVhZCA9IGhjYi0+
aGFzaDsKKwlmb3IgKGkgPSAwOyBpIDwgaGNiLT5udW07IGkrKykgeworCQloZWFkLT5wYWdlX2Zs
YWdzID0gMDsKKwkJaGVhZC0+aXRpciA9IDA7CisJCWhlYWQtPmV0YWcgPSBJTlZBTElEX1RJX1RB
RzsKKwkJaGVhZC0+bmV4dCA9IDA7CisJCWhlYWQrKzsKKwl9Cit9CisKK3U2NCBrdm1fbG9va3Vw
X21wYSh1NjQgZ3BmbikKK3sKKwl1NjQgKmJhc2UgPSAodTY0ICopIEtWTV9QMk1fQkFTRTsKKwly
ZXR1cm4gKihiYXNlICsgZ3Bmbik7Cit9CisKK3U2NCBrdm1fZ3BhX3RvX21wYSh1NjQgZ3BhKQor
eworCXU2NCBwdGUgPSBrdm1fbG9va3VwX21wYShncGEgPj4gUEFHRV9TSElGVCk7CisJcmV0dXJu
IChwdGUgPj4gUEFHRV9TSElGVCA8PCBQQUdFX1NISUZUKSB8IChncGEgJiB+UEFHRV9NQVNLKTsK
K30KKworCisvKgorICogRmV0Y2ggZ3Vlc3QgYnVuZGxlIGNvZGUuCisgKiBJTlBVVDoKKyAqICBn
aXA6IGd1ZXN0IGlwCisgKiAgcGJ1bmRsZTogdXNlZCB0byByZXR1cm4gZmV0Y2hlZCBidW5kbGUu
CisgKi8KK2ludCBmZXRjaF9jb2RlKFZDUFUgKnZjcHUsIHU2NCBnaXAsIElBNjRfQlVORExFICpw
YnVuZGxlKQoreworCXU2NCAgICAgZ3BpcCA9IDA7ICAgLyogZ3Vlc3QgcGh5c2ljYWwgSVAqLwor
CXU2NCAgICAgKnZwYTsKKwl0aGFzaF9kYXRhX3QgICAgKnRsYjsKKwl1NjQgICAgIG1hZGRyOwor
CisJaWYgKCEoVkNQVSh2Y3B1LCB2cHNyKSAmIElBNjRfUFNSX0lUKSkgeworCQkvKiBJLXNpZGUg
cGh5c2ljYWwgbW9kZSAqLworCQlncGlwID0gZ2lwOworCX0gZWxzZSB7CisJCXRsYiA9IHZ0bGJf
bG9va3VwKHZjcHUsIGdpcCwgSV9UTEIpOworCQlpZiAodGxiKQorCQkJZ3BpcCA9ICh0bGItPnBw
biA+PiAodGxiLT5wcyAtIDEyKSA8PCB0bGItPnBzKSB8CisJCQkJKGdpcCAmIChQU0laRSh0bGIt
PnBzKSAtIDEpKTsKKwl9CisJaWYgKGdwaXApIHsKKwkJbWFkZHIgPSBrdm1fZ3BhX3RvX21wYShn
cGlwKTsKKwl9IGVsc2UgeworCQl0bGIgPSB2aHB0X2xvb2t1cChnaXApOworCQlpZiAodGxiID09
IE5VTEwpIHsKKwkJCWlhNjRfcHRjbChnaXAsIEFSQ0hfUEFHRV9TSElGVCA8PCAyKTsKKwkJCXJl
dHVybiBJQTY0X0ZBVUxUOworCQl9CisJCW1hZGRyID0gKHRsYi0+cHBuID4+ICh0bGItPnBzIC0g
MTIpIDw8IHRsYi0+cHMpCisJCQkJCXwgKGdpcCAmIChQU0laRSh0bGItPnBzKSAtIDEpKTsKKwl9
CisJdnBhID0gKHU2NCAqKV9fa3ZtX3ZhKG1hZGRyKTsKKworCXBidW5kbGUtPmk2NFswXSA9ICp2
cGErKzsKKwlwYnVuZGxlLT5pNjRbMV0gPSAqdnBhOworCisJcmV0dXJuIElBNjRfTk9fRkFVTFQ7
Cit9CisKKwordm9pZCBrdm1faW5pdF92aHB0KFZDUFUgKnYpCit7CisJdi0+YXJjaC52aHB0Lm51
bSA9IFZIUFRfTlVNX0VOVFJJRVM7CisJdGhhc2hfaW5pdCgmdi0+YXJjaC52aHB0LCBWSFBUX1NI
SUZUKTsKKwlpYTY0X3NldF9wdGEodi0+YXJjaC52aHB0LnB0YS52YWwpOworCS8qRW5hYmxlIFZI
UFQgaGVyZT8qLworfQorCit2b2lkIGt2bV9pbml0X3Z0bGIoVkNQVSAqdikKK3sKKwl2LT5hcmNo
LnZ0bGIubnVtID0gVlRMQl9OVU1fRU5UUklFUzsKKwl0aGFzaF9pbml0KCZ2LT5hcmNoLnZ0bGIs
IFZUTEJfU0hJRlQpOworfQotLSAKMS41LjIKCg==

------_=_NextPart_001_01C89309.1A63141B--
