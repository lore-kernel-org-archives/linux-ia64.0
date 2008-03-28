From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Fri, 28 Mar 2008 09:58:51 +0000
Subject: [07/17][PATCH] kvm/ia64: Add TLB virtulization support.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF9@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C890BA.53FC0293"
List-Id: <linux-ia64.vger.kernel.org>
To: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, Jes Sorensen <jes@sgi.com>, Akio Takebe <takebe_akio@jp.fujitsu.com>, 

This is a multi-part message in MIME format.

------_=_NextPart_001_01C890BA.53FC0293
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From 56d3f7acf8d45d2491646be77ced344dcc516cd7 Mon Sep 17 00:00:00 2001
From: Xiantao Zhang <xiantao.zhang@intel.com>
Date: Wed, 12 Mar 2008 13:45:40 +0800
Subject: [PATCH] kvm/ia64: Add TLB virtulization support.

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

------_=_NextPart_001_01C890BA.53FC0293
Content-Type: application/octet-stream;
	name="0007-kvm-ia64-Add-TLB-virtulization-support.patch"
Content-Transfer-Encoding: base64
Content-Description: 0007-kvm-ia64-Add-TLB-virtulization-support.patch
Content-Disposition: attachment;
	filename="0007-kvm-ia64-Add-TLB-virtulization-support.patch"

RnJvbSA1NmQzZjdhY2Y4ZDQ1ZDI0OTE2NDZiZTc3Y2VkMzQ0ZGNjNTE2Y2Q3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFudGFvIFpoYW5nIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogV2VkLCAxMiBNYXIgMjAwOCAxMzo0NTo0MCArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IGt2bS9pYTY0OiBBZGQgVExCIHZpcnR1bGl6YXRpb24gc3VwcG9ydC4KCnZ0bGIuYyBpbmNsdWRl
cyB0bGIvVkhQVCB2aXJ0dWxpemF0aW9uLgpTaWduZWQtb2ZmLWJ5OiBBbnRob255IFh1IDxhbnRo
b255Lnh1QGludGVsLmNvbT4KU2lnbmVkLW9mZi1ieTogWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56
aGFuZ0BpbnRlbC5jb20+Ci0tLQogYXJjaC9pYTY0L2t2bS92dGxiLmMgfCAgNjMxICsrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrCiAxIGZpbGVzIGNoYW5n
ZWQsIDYzMSBpbnNlcnRpb25zKCspLCAwIGRlbGV0aW9ucygtKQogY3JlYXRlIG1vZGUgMTAwNjQ0
IGFyY2gvaWE2NC9rdm0vdnRsYi5jCgpkaWZmIC0tZ2l0IGEvYXJjaC9pYTY0L2t2bS92dGxiLmMg
Yi9hcmNoL2lhNjQva3ZtL3Z0bGIuYwpuZXcgZmlsZSBtb2RlIDEwMDY0NAppbmRleCAwMDAwMDAw
Li42ZTZlZDI1Ci0tLSAvZGV2L251bGwKKysrIGIvYXJjaC9pYTY0L2t2bS92dGxiLmMKQEAgLTAs
MCArMSw2MzEgQEAKKy8qCisgKiB2dGxiLmM6IGd1ZXN0IHZpcnR1YWwgdGxiIGhhbmRsaW5nIG1v
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
aD4KKy8qCisgKiBDaGVjayB0byBzZWUgaWYgdGhlIGFkZHJlc3MgcmlkOnZhIGlzIHRyYW5zbGF0
ZWQgYnkgdGhlIFRMQgorICovCisKK3N0YXRpYyBpbnQgX19pc190cl90cmFuc2xhdGVkKHRoYXNo
X2RhdGFfdCAqdHJwLCB1NjQgcmlkLCB1NjQgdmEpCit7CisJcmV0dXJuICgodHJwLT5wKSAmJiAo
dHJwLT5yaWQgPT0gcmlkKQorCQkJCSYmICgodmEtdHJwLT52YWRyKSA8IFBTSVpFKHRycC0+cHMp
KSk7Cit9CisKKy8qCisgKiBPbmx5IGZvciBHVUVTVCBUUiBmb3JtYXQuCisgKi8KK3N0YXRpYyBp
bnQgX19pc190cl9vdmVybGFwKHRoYXNoX2RhdGFfdCAqdHJwLCB1NjQgcmlkLCB1NjQgc3ZhLCB1
NjQgZXZhKQoreworCXU2NCBzYTEsIGVhMTsKKworCWlmICghdHJwLT5wIHx8IHRycC0+cmlkICE9
IHJpZCkKKwkJcmV0dXJuIDA7CisKKwlzYTEgPSB0cnAtPnZhZHI7CisJZWExID0gc2ExICsgUFNJ
WkUodHJwLT5wcykgLSAxOworCWV2YSAtPSAxOworCWlmICgoc3ZhID4gZWExKSB8fCAoc2ExID4g
ZXZhKSkKKwkJcmV0dXJuIDA7CisJZWxzZQorCQlyZXR1cm4gMTsKKworfQorCit2b2lkIG1hY2hp
bmVfdGxiX3B1cmdlKHU2NCB2YSwgdTY0IHBzKQoreworCWlhNjRfcHRjbCh2YSwgcHMgPDwgMik7
Cit9CisKK3ZvaWQgbG9jYWxfZmx1c2hfdGxiX2FsbCh2b2lkKQoreworCWludCBpLCBqOworCXVu
c2lnbmVkIGxvbmcgZmxhZ3MsIGNvdW50MCwgY291bnQxOworCXVuc2lnbmVkIGxvbmcgc3RyaWRl
MCwgc3RyaWRlMSwgYWRkcjsKKworCWFkZHIgICAgPSBjdXJyZW50X3ZjcHUtPmFyY2gucHRjZV9i
YXNlOworCWNvdW50MCAgPSBjdXJyZW50X3ZjcHUtPmFyY2gucHRjZV9jb3VudFswXTsKKwljb3Vu
dDEgID0gY3VycmVudF92Y3B1LT5hcmNoLnB0Y2VfY291bnRbMV07CisJc3RyaWRlMCA9IGN1cnJl
bnRfdmNwdS0+YXJjaC5wdGNlX3N0cmlkZVswXTsKKwlzdHJpZGUxID0gY3VycmVudF92Y3B1LT5h
cmNoLnB0Y2Vfc3RyaWRlWzFdOworCisJbG9jYWxfaXJxX3NhdmUoZmxhZ3MpOworCWZvciAoaSA9
IDA7IGkgPCBjb3VudDA7ICsraSkgeworCQlmb3IgKGogPSAwOyBqIDwgY291bnQxOyArK2opIHsK
KwkJCWlhNjRfcHRjZShhZGRyKTsKKwkJCWFkZHIgKz0gc3RyaWRlMTsKKwkJfQorCQlhZGRyICs9
IHN0cmlkZTA7CisJfQorCWxvY2FsX2lycV9yZXN0b3JlKGZsYWdzKTsKKwlpYTY0X3NybHpfaSgp
OyAgICAgICAgICAvKiBzcmx6LmkgaW1wbGllcyBzcmx6LmQgKi8KK30KKworaW50IHZocHRfZW5h
YmxlZChWQ1BVICp2Y3B1LCB1NjQgdmFkciwgdmhwdF9yZWZfdCByZWYpCit7CisJaWE2NF9yciAg
ICB2cnI7CisJaWE2NF9wdGEgICB2cHRhOworCWlhNjRfcHNyICAgdnBzcjsKKworCXZwc3IudmFs
ID0gVkNQVSh2Y3B1LCB2cHNyKTsKKwl2cnIudmFsID0gdmNwdV9nZXRfcnIodmNwdSwgdmFkcik7
CisJdnB0YS52YWwgPSB2Y3B1X2dldF9wdGEodmNwdSk7CisKKwlpZiAodnJyLnZlICYgdnB0YS52
ZSkgeworCQlzd2l0Y2ggKHJlZikgeworCQljYXNlIERBVEFfUkVGOgorCQljYXNlIE5BX1JFRjoK
KwkJCXJldHVybiB2cHNyLmR0OworCQljYXNlIElOU1RfUkVGOgorCQkJcmV0dXJuIHZwc3IuZHQg
JiYgdnBzci5pdCAmJiB2cHNyLmljOworCQljYXNlIFJTRV9SRUY6CisJCQlyZXR1cm4gdnBzci5k
dCAmJiB2cHNyLnJ0OworCisJCX0KKwl9CisJcmV0dXJuIDA7Cit9CisKK3RoYXNoX2RhdGFfdCAq
dnNhX3RoYXNoKGlhNjRfcHRhIHZwdGEsIHU2NCB2YSwgdTY0IHZyciwgdTY0ICp0YWcpCit7CisJ
dTY0IGluZGV4LCBwZm4sIHJpZCwgcGZuX2JpdHM7CisKKwlwZm5fYml0cyA9IHZwdGEuc2l6ZSAt
IDUgLSA4OworCXBmbiA9IFJFR0lPTl9PRkZTRVQodmEpID4+IF9SRUdJT05fUEFHRV9TSVpFKHZy
cik7CisJcmlkID0gX1JFR0lPTl9JRCh2cnIpOworCWluZGV4ID0gKChyaWQgJiAweGZmKSA8PCBw
Zm5fYml0cyl8KHBmbiAmICgoMVVMIDw8IHBmbl9iaXRzKSAtIDEpKTsKKwkqdGFnID0gKChyaWQg
Pj4gOCkgJiAweGZmZmYpIHwgKChwZm4gPj4gcGZuX2JpdHMpIDw8IDE2KTsKKworCXJldHVybiAo
dGhhc2hfZGF0YV90ICopKCh2cHRhLmJhc2UgPDwgUFRBX0JBU0VfU0hJRlQpICsgKGluZGV4IDw8
IDUpKTsKK30KKwordGhhc2hfZGF0YV90ICpfX3Z0cl9sb29rdXAoVkNQVSAqdmNwdSwgdTY0IHZh
LCBpbnQgdHlwZSkKK3sKKworCXRoYXNoX2RhdGFfdCAgKnRycDsKKwlpbnQgIGk7CisJdTY0IHJp
ZDsKKworCXJpZCA9IHZjcHVfZ2V0X3JyKHZjcHUsIHZhKTsKKwlyaWQgPSByaWQgJiBSUl9SSURf
TUFTSzs7CisJaWYgKHR5cGUgPT0gRF9UTEIpIHsKKwkJaWYgKHZjcHVfcXVpY2tfcmVnaW9uX2No
ZWNrKHZjcHUtPmFyY2guZHRyX3JlZ2lvbnMsIHZhKSkgeworCQkJZm9yICh0cnAgPSAodGhhc2hf
ZGF0YV90ICopJnZjcHUtPmFyY2guZHRycywgaSA9IDA7CisJCQkJCQlpIDwgTkRUUlM7IGkrKywg
dHJwKyspIHsKKwkJCQlpZiAoX19pc190cl90cmFuc2xhdGVkKHRycCwgcmlkLCB2YSkpCisJCQkJ
CXJldHVybiB0cnA7CisJCQl9CisJCX0KKwl9IGVsc2UgeworCQlpZiAodmNwdV9xdWlja19yZWdp
b25fY2hlY2sodmNwdS0+YXJjaC5pdHJfcmVnaW9ucywgdmEpKSB7CisJCQlmb3IgKHRycCA9ICh0
aGFzaF9kYXRhX3QgKikmdmNwdS0+YXJjaC5pdHJzLCBpID0gMDsKKwkJCQkJaSA8IE5JVFJTOyBp
KyssIHRycCsrKSB7CisJCQkJaWYgKF9faXNfdHJfdHJhbnNsYXRlZCh0cnAsIHJpZCwgdmEpKQor
CQkJCQlyZXR1cm4gdHJwOworCQkJfQorCQl9CisJfQorCisJcmV0dXJuIE5VTEw7Cit9CisKK3N0
YXRpYyB2b2lkIHZocHRfaW5zZXJ0KHU2NCBwdGUsIHU2NCBpdGlyLCB1NjQgaWZhLCB1NjQgZ3B0
ZSkKK3sKKwlpYTY0X3JyIHJyOworCXRoYXNoX2RhdGFfdCAqaGVhZDsKKwl1bnNpZ25lZCBsb25n
IHBzLCBncGFkZHI7CisKKwlwcyA9IGl0aXJfcHMoaXRpcik7CisKKwlncGFkZHIgPSAoKGdwdGUg
JiBfUEFHRV9QUE5fTUFTSykgPj4gcHMgPDwgcHMpIHwKKwkJKGlmYSAmICgoMVVMIDw8IHBzKSAt
IDEpKTsKKworCXJyLnZhbCA9IGlhNjRfZ2V0X3JyKGlmYSk7CisJaGVhZCA9ICh0aGFzaF9kYXRh
X3QgKilpYTY0X3RoYXNoKGlmYSk7CisJaGVhZC0+ZXRhZyA9IElOVkFMSURfVElfVEFHOworCWlh
NjRfbWYoKTsKKwloZWFkLT5wYWdlX2ZsYWdzID0gcHRlICYgflBBR0VfRkxBR1NfUlZfTUFTSzsK
KwloZWFkLT5pdGlyID0gcnIucHMgPDwgMjsKKwloZWFkLT5ldGFnID0gaWE2NF90dGFnKGlmYSk7
CisJaGVhZC0+Z3BhZGRyID0gZ3BhZGRyOworfQorCit2b2lkIG1hcmtfcGFnZXNfZGlydHkoVkNQ
VSAqdiwgdTY0IHB0ZSwgdTY0IHBzKQoreworCXU2NCBpLCBkaXJ0eV9wYWdlcyA9IDE7CisJdTY0
IGJhc2VfZ2ZuID0gKHB0ZSZfUEFHRV9QUE5fTUFTSykgPj4gUEFHRV9TSElGVDsKKwlzcGlubG9j
a190ICpsb2NrID0gX19rdm1fdmEodi0+YXJjaC5kaXJ0eV9sb2dfbG9ja19wYSk7CisJdm9pZCAq
ZGlydHlfYml0bWFwID0gKHZvaWQgKil2IC0gKEtWTV9WQ1BVX09GUyArIHYtPnZjcHVfaWQgKiBW
Q1BVX1NJWkUpCisJCQkJCQkrIEtWTV9NRU1fRElSVFlfTE9HX09GUzsKKwlkaXJ0eV9wYWdlcyA8
PD0gcHMgPD0gUEFHRV9TSElGVCA/IDAgOiBwcyAtIFBBR0VfU0hJRlQ7CisKKwl2bW1fc3Bpbl9s
b2NrKGxvY2spOworCWZvciAoaSA9IDA7IGkgPCBkaXJ0eV9wYWdlczsgaSsrKSB7CisJCS8qIGF2
b2lkIFJNVyAqLworCQlpZiAoIXRlc3RfYml0KGJhc2VfZ2ZuICsgaSwgZGlydHlfYml0bWFwKSkK
KwkJCXNldF9iaXQoYmFzZV9nZm4gKyBpICwgZGlydHlfYml0bWFwKTsKKwl9CisJdm1tX3NwaW5f
dW5sb2NrKGxvY2spOworfQorCit2b2lkIHRoYXNoX3ZocHRfaW5zZXJ0KFZDUFUgKnYsIHU2NCBw
dGUsIHU2NCBpdGlyLCB1NjQgdmEsIGludCB0eXBlKQoreworCXU2NCBwaHlfcHRlLCBwc3I7CisJ
aWE2NF9yciBtcnI7CisKKwltcnIudmFsID0gaWE2NF9nZXRfcnIodmEpOworCXBoeV9wdGUgPSB0
cmFuc2xhdGVfcGh5X3B0ZSgmcHRlLCBpdGlyLCB2YSk7CisKKwlpZiAoaXRpcl9wcyhpdGlyKSA+
PSBtcnIucHMpIHsKKwkJdmhwdF9pbnNlcnQocGh5X3B0ZSwgaXRpciwgdmEsIHB0ZSk7CisJfSBl
bHNlIHsKKwkJcGh5X3B0ZSAgJj0gflBBR0VfRkxBR1NfUlZfTUFTSzsKKwkJcHNyID0gaWE2NF9j
bGVhcl9pYygpOworCQlpYTY0X2l0Yyh0eXBlLCB2YSwgcGh5X3B0ZSwgaXRpcl9wcyhpdGlyKSk7
CisJCWlhNjRfc2V0X3Bzcihwc3IpOworCX0KKworCWlmICghKHB0ZSZWVExCX1BURV9JTykpCisJ
CW1hcmtfcGFnZXNfZGlydHkodiwgcHRlLCBpdGlyX3BzKGl0aXIpKTsKK30KKworLyoKKyAqICAg
dmhwdCBsb29rdXAKKyAqLwordGhhc2hfZGF0YV90ICp2aHB0X2xvb2t1cCh1NjQgdmEpCit7CisJ
dGhhc2hfZGF0YV90ICpoZWFkOworCXU2NCB0YWc7CisKKwloZWFkID0gKHRoYXNoX2RhdGFfdCAq
KWlhNjRfdGhhc2godmEpOworCXRhZyA9IGlhNjRfdHRhZyh2YSk7CisJaWYgKGhlYWQtPmV0YWcg
PT0gdGFnKQorCQlyZXR1cm4gaGVhZDsKKwlyZXR1cm4gTlVMTDsKK30KKwordTY0IGd1ZXN0X3Zo
cHRfbG9va3VwKHU2NCBpaGEsIHU2NCAqcHRlKQoreworCXU2NCByZXQ7CisJdGhhc2hfZGF0YV90
ICpkYXRhOworCisJZGF0YSA9IF9fdnRyX2xvb2t1cChjdXJyZW50X3ZjcHUsIGloYSwgRF9UTEIp
OworCWlmIChkYXRhICE9IE5VTEwpCisJCXRoYXNoX3ZocHRfaW5zZXJ0KGN1cnJlbnRfdmNwdSwg
ZGF0YS0+cGFnZV9mbGFncywKKwkJCWRhdGEtPml0aXIsIGloYSwgRF9UTEIpOworCisJYXNtIHZv
bGF0aWxlICgicnNtIHBzci5pY3xwc3IuaTs7IgorCQkJInNybHouZDs7IgorCQkJImxkOC5zIHI5
PVslMV07OyIKKwkJCSJ0bmF0Lm56IHA2LHA3PXI5OzsiCisJCQkiKHA2KSBtb3YgJTA9MTsiCisJ
CQkiKHA2KSBtb3Ygcjk9cjA7IgorCQkJIihwNykgZXh0ci51IHI5PXI5LDAsNTM7OyIKKwkJCSIo
cDcpIG1vdiAlMD1yMDsiCisJCQkiKHA3KSBzdDggWyUyXT1yOTs7IgorCQkJInNzbSBwc3IuaWM7
OyIKKwkJCSJzcmx6LmQ7OyIKKwkJCS8qICJzc20gcHNyLmk7OyIgT25jZSBpbnRlcnJ1cHRzIGlu
IHZtbSBvcGVuLCBuZWVkIGZpeCovCisJCQk6ICI9ciIocmV0KSA6ICJyIihpaGEpLCAiciIocHRl
KToibWVtb3J5Iik7CisKKwlyZXR1cm4gcmV0OworfQorCisvKgorICogIHB1cmdlIHNvZnR3YXJl
IGd1ZXN0IHRsYgorICovCisKK3N0YXRpYyB2b2lkIHZ0bGJfcHVyZ2UoVkNQVSAqdiwgdTY0IHZh
LCB1NjQgcHMpCit7CisJdGhhc2hfZGF0YV90ICpjdXI7CisJdTY0IHN0YXJ0LCBjdXJhZHIsIHNp
emUsIHBzYml0cywgdGFnLCBycl9wcywgbnVtOworCWlhNjRfcnIgdnJyOworCXRoYXNoX2NiX3Qg
KmhjYiA9ICZ2LT5hcmNoLnZ0bGI7CisKKwl2cnIudmFsID0gdmNwdV9nZXRfcnIodiwgdmEpOwor
CXBzYml0cyA9IFZNWCh2LCBwc2JpdHNbKHZhID4+IDYxKV0pOworCXN0YXJ0ID0gdmEgJiB+KCgx
VUwgPDwgcHMpIC0gMSk7CisJd2hpbGUgKHBzYml0cykgeworCQljdXJhZHIgPSBzdGFydDsKKwkJ
cnJfcHMgPSBfX2Zmcyhwc2JpdHMpOworCQlwc2JpdHMgJj0gfigxVUwgPDwgcnJfcHMpOworCQlu
dW0gPSAxVUwgPDwgKChwcyA8IHJyX3BzKSA/IDAgOiAocHMgLSBycl9wcykpOworCQlzaXplID0g
UFNJWkUocnJfcHMpOworCQl2cnIucHMgPSBycl9wczsKKwkJd2hpbGUgKG51bSkgeworCQkJY3Vy
ID0gdnNhX3RoYXNoKGhjYi0+cHRhLCBjdXJhZHIsIHZyci52YWwsICZ0YWcpOworCQkJaWYgKGN1
ci0+ZXRhZyA9PSB0YWcgJiYgY3VyLT5wcyA9PSBycl9wcykKKwkJCQljdXItPmV0YWcgPSBJTlZB
TElEX1RJX1RBRzsKKwkJCWN1cmFkciArPSBzaXplOworCQkJbnVtLS07CisJCX0KKwl9Cit9CisK
KworLyoKKyAqICBwdXJnZSBWSFBUIGFuZCBtYWNoaW5lIFRMQgorICovCitzdGF0aWMgdm9pZCB2
aHB0X3B1cmdlKFZDUFUgKnYsIHU2NCB2YSwgdTY0IHBzKQoreworCXRoYXNoX2RhdGFfdCAqY3Vy
OworCXU2NCBzdGFydCwgc2l6ZSwgdGFnLCBudW07CisJaWE2NF9yciBycjsKKworCXN0YXJ0ID0g
dmEgJiB+KCgxVUwgPDwgcHMpIC0gMSk7CisJcnIudmFsID0gaWE2NF9nZXRfcnIodmEpOworCXNp
emUgPSBQU0laRShyci5wcyk7CisJbnVtID0gMVVMIDw8ICgocHMgPCByci5wcykgPyAwIDogKHBz
IC0gcnIucHMpKTsKKwl3aGlsZSAobnVtKSB7CisJCWN1ciA9ICh0aGFzaF9kYXRhX3QgKilpYTY0
X3RoYXNoKHN0YXJ0KTsKKwkJdGFnID0gaWE2NF90dGFnKHN0YXJ0KTsKKwkJaWYgKGN1ci0+ZXRh
ZyA9PSB0YWcpCisJCQljdXItPmV0YWcgPSBJTlZBTElEX1RJX1RBRzsKKwkJc3RhcnQgKz0gc2l6
ZTsKKwkJbnVtLS07CisJfQorCW1hY2hpbmVfdGxiX3B1cmdlKHZhLCBwcyk7Cit9CisKKy8qCisg
KiBJbnNlcnQgYW4gZW50cnkgaW50byBoYXNoIFRMQiBvciBWSFBULgorICogTk9URVM6CisgKiAg
MTogV2hlbiBpbnNlcnRpbmcgVkhQVCB0byB0aGFzaCwgInZhIiBpcyBhIG11c3QgY292ZXJlZAor
ICogIGFkZHJlc3MgYnkgdGhlIGluc2VydGVkIG1hY2hpbmUgVkhQVCBlbnRyeS4KKyAqICAyOiBU
aGUgZm9ybWF0IG9mIGVudHJ5IGlzIGFsd2F5cyBpbiBUTEIuCisgKiAgMzogVGhlIGNhbGxlciBu
ZWVkIHRvIG1ha2Ugc3VyZSB0aGUgbmV3IGVudHJ5IHdpbGwgbm90IG92ZXJsYXAKKyAqICAgICB3
aXRoIGFueSBleGlzdGVkIGVudHJ5LgorICovCit2b2lkIHZ0bGJfaW5zZXJ0KFZDUFUgKnYsIHU2
NCBwdGUsIHU2NCBpdGlyLCB1NjQgdmEpCit7CisJdGhhc2hfZGF0YV90ICpoZWFkOworCWlhNjRf
cnIgdnJyOworCXU2NCB0YWc7CisJdGhhc2hfY2JfdCAqaGNiID0gJnYtPmFyY2gudnRsYjsKKwor
CXZyci52YWwgPSB2Y3B1X2dldF9ycih2LCB2YSk7CisJdnJyLnBzID0gaXRpcl9wcyhpdGlyKTsK
KwlWTVgodiwgcHNiaXRzW3ZhID4+IDYxXSkgfD0gKDFVTCA8PCB2cnIucHMpOworCWhlYWQgPSB2
c2FfdGhhc2goaGNiLT5wdGEsIHZhLCB2cnIudmFsLCAmdGFnKTsKKwloZWFkLT5wYWdlX2ZsYWdz
ID0gcHRlOworCWhlYWQtPml0aXIgPSBpdGlyOworCWhlYWQtPmV0YWcgPSB0YWc7Cit9CisKK2lu
dCB2dHJfZmluZF9vdmVybGFwKFZDUFUgKnZjcHUsIHU2NCB2YSwgdTY0IHBzLCBpbnQgdHlwZSkK
K3sKKwl0aGFzaF9kYXRhX3QgICp0cnA7CisJaW50ICBpOworCXU2NCBlbmQsIHJpZDsKKworCXJp
ZCA9IHZjcHVfZ2V0X3JyKHZjcHUsIHZhKTsKKwlyaWQgPSByaWQgJiBSUl9SSURfTUFTSzsKKwll
bmQgPSB2YSArIFBTSVpFKHBzKTsKKwlpZiAodHlwZSA9PSBEX1RMQikgeworCQlpZiAodmNwdV9x
dWlja19yZWdpb25fY2hlY2sodmNwdS0+YXJjaC5kdHJfcmVnaW9ucywgdmEpKSB7CisJCQlmb3Ig
KHRycCA9ICh0aGFzaF9kYXRhX3QgKikmdmNwdS0+YXJjaC5kdHJzLCBpID0gMDsKKwkJCQkJaSA8
IE5EVFJTOyBpKyssIHRycCsrKSB7CisJCQkJaWYgKF9faXNfdHJfb3ZlcmxhcCh0cnAsIHJpZCwg
dmEsIGVuZCkpCisJCQkJCXJldHVybiBpOworCQkJfQorCQl9CisJfSBlbHNlIHsKKwkJaWYgKHZj
cHVfcXVpY2tfcmVnaW9uX2NoZWNrKHZjcHUtPmFyY2guaXRyX3JlZ2lvbnMsIHZhKSkgeworCQkJ
Zm9yICh0cnAgPSAodGhhc2hfZGF0YV90ICopJnZjcHUtPmFyY2guaXRycywgaSA9IDA7CisJCQkJ
CWkgPCBOSVRSUzsgaSsrLCB0cnArKykgeworCQkJCWlmIChfX2lzX3RyX292ZXJsYXAodHJwLCBy
aWQsIHZhLCBlbmQpKQorCQkJCQlyZXR1cm4gaTsKKwkJCX0KKwkJfQorCX0KKwlyZXR1cm4gLTE7
Cit9CisKKy8qCisgKiBQdXJnZSBlbnRyaWVzIGluIFZUTEIgYW5kIFZIUFQKKyAqLwordm9pZCB0
aGFzaF9wdXJnZV9lbnRyaWVzKFZDUFUgKnYsIHU2NCB2YSwgdTY0IHBzKQoreworCWlmICh2Y3B1
X3F1aWNrX3JlZ2lvbl9jaGVjayh2LT5hcmNoLnRjX3JlZ2lvbnMsIHZhKSkKKwkJdnRsYl9wdXJn
ZSh2LCB2YSwgcHMpOworCXZocHRfcHVyZ2UodiwgdmEsIHBzKTsKK30KKwordm9pZCB0aGFzaF9w
dXJnZV9lbnRyaWVzX3JlbW90ZShWQ1BVICp2LCB1NjQgdmEsIHU2NCBwcykKK3sKKwl1NjQgb2xk
X3ZhID0gdmE7CisJdmEgPSBSRUdJT05fT0ZGU0VUKHZhKTsKKwlpZiAodmNwdV9xdWlja19yZWdp
b25fY2hlY2sodi0+YXJjaC50Y19yZWdpb25zLCBvbGRfdmEpKQorCQl2dGxiX3B1cmdlKHYsIHZh
LCBwcyk7CisJdmhwdF9wdXJnZSh2LCB2YSwgcHMpOworfQorCit1NjQgdHJhbnNsYXRlX3BoeV9w
dGUodTY0ICpwdGUsIHU2NCBpdGlyLCB1NjQgdmEpCit7CisJdTY0IHBzLCBwc19tYXNrLCBwYWRk
ciwgbWFkZHI7CisJdW5pb24gcHRlX2ZsYWdzIHBoeV9wdGU7CisKKwlwcyA9IGl0aXJfcHMoaXRp
cik7CisJcHNfbWFzayA9IH4oKDFVTCA8PCBwcykgLSAxKTsKKwlwaHlfcHRlLnZhbCA9ICpwdGU7
CisJcGFkZHIgPSAqcHRlOworCXBhZGRyID0gKChwYWRkciAmIF9QQUdFX1BQTl9NQVNLKSAmIHBz
X21hc2spIHwgKHZhICYgfnBzX21hc2spOworCW1hZGRyID0ga3ZtX2xvb2t1cF9tcGEocGFkZHIg
Pj4gUEFHRV9TSElGVCk7CisJaWYgKG1hZGRyICYgR1BGTl9JT19NQVNLKSB7CisJCSpwdGUgfD0g
VlRMQl9QVEVfSU87CisJCXJldHVybiAtMTsKKwl9CisJbWFkZHIgPSAoKG1hZGRyICYgX1BBR0Vf
UFBOX01BU0spICYgUEFHRV9NQVNLKSB8CisJCQkJCShwYWRkciAmIH5QQUdFX01BU0spOworCXBo
eV9wdGUucHBuID0gbWFkZHIgPj4gQVJDSF9QQUdFX1NISUZUOworCXJldHVybiBwaHlfcHRlLnZh
bDsKK30KKworLyoKKyAqIFB1cmdlIG92ZXJsYXAgVENzIGFuZCB0aGVuIGluc2VydCB0aGUgbmV3
IGVudHJ5IHRvIGVtdWxhdGUgaXRjIG9wcy4KKyAqICAgIE5vdGVzOiBPbmx5IFRDIGVudHJ5IGNh
biBwdXJnZSBhbmQgaW5zZXJ0LgorICogICAgMSBpbmRpY2F0ZXMgdGhpcyBpcyBNTUlPCisgKi8K
K2ludCB0aGFzaF9wdXJnZV9hbmRfaW5zZXJ0KFZDUFUgKnYsIHU2NCBwdGUsIHU2NCBpdGlyLCB1
NjQgaWZhLCBpbnQgdHlwZSkKK3sKKwl1NjQgcHM7CisJdTY0IHBoeV9wdGU7CisJaWE2NF9yciB2
cnIsIG1ycjsKKwlpbnQgcmV0ID0gMDsKKworCXBzID0gaXRpcl9wcyhpdGlyKTsKKwl2cnIudmFs
ID0gdmNwdV9nZXRfcnIodiwgaWZhKTsKKwltcnIudmFsID0gaWE2NF9nZXRfcnIoaWZhKTsKKwor
CXBoeV9wdGUgPSB0cmFuc2xhdGVfcGh5X3B0ZSgmcHRlLCBpdGlyLCBpZmEpOworCisJLyogRW5z
dXJlIFdCIGF0dHJpYnV0ZSBpZiBwdGUgaXMgcmVsYXRlZCB0byBhIG5vcm1hbCBtZW0gcGFnZSwK
KwkgKiB3aGljaCBpcyByZXF1aXJlZCBieSB2Z2EgYWNjZWxlcmF0aW9uIHNpbmNlIHFlbXUgbWFw
cyBzaGFyZWQKKwkgKiB2cmFtIGJ1ZmZlciB3aXRoIFdCLgorCSAqLworCWlmICghKHB0ZSAmIFZU
TEJfUFRFX0lPKSAmJiAoKHB0ZSAmIF9QQUdFX01BX01BU0spICE9IF9QQUdFX01BX05BVCkpIHsK
KwkJcHRlICY9IH5fUEFHRV9NQV9NQVNLOworCQlwaHlfcHRlICY9IH5fUEFHRV9NQV9NQVNLOwor
CX0KKworCWlmIChwdGUgJiBWVExCX1BURV9JTykKKwkJcmV0ID0gMTsKKworCXZ0bGJfcHVyZ2Uo
diwgaWZhLCBwcyk7CisJdmhwdF9wdXJnZSh2LCBpZmEsIHBzKTsKKworCWlmIChwcyA9PSBtcnIu
cHMpIHsKKwkJaWYgKCEocHRlJlZUTEJfUFRFX0lPKSkgeworCQkJdmhwdF9pbnNlcnQocGh5X3B0
ZSwgaXRpciwgaWZhLCBwdGUpOworCQl9IGVsc2UgeworCQkJdnRsYl9pbnNlcnQodiwgcHRlLCBp
dGlyLCBpZmEpOworCQkJdmNwdV9xdWlja19yZWdpb25fc2V0KFZNWCh2LCB0Y19yZWdpb25zKSwg
aWZhKTsKKwkJfQorCX0gZWxzZSBpZiAocHMgPiBtcnIucHMpIHsKKwkJdnRsYl9pbnNlcnQodiwg
cHRlLCBpdGlyLCBpZmEpOworCQl2Y3B1X3F1aWNrX3JlZ2lvbl9zZXQoVk1YKHYsIHRjX3JlZ2lv
bnMpLCBpZmEpOworCQlpZiAoIShwdGUmVlRMQl9QVEVfSU8pKQorCQkJdmhwdF9pbnNlcnQocGh5
X3B0ZSwgaXRpciwgaWZhLCBwdGUpOworCX0gZWxzZSB7CisJCXU2NCBwc3I7CisJCXBoeV9wdGUg
ICY9IH5QQUdFX0ZMQUdTX1JWX01BU0s7CisJCXBzciA9IGlhNjRfY2xlYXJfaWMoKTsKKwkJaWE2
NF9pdGModHlwZSwgaWZhLCBwaHlfcHRlLCBwcyk7CisJCWlhNjRfc2V0X3Bzcihwc3IpOworCX0K
KwlpZiAoIShwdGUmVlRMQl9QVEVfSU8pKQorCQltYXJrX3BhZ2VzX2RpcnR5KHYsIHB0ZSwgcHMp
OworCisJcmV0dXJuIHJldDsKK30KKworLyoKKyAqIFB1cmdlIGFsbCBUQ3Mgb3IgVkhQVCBlbnRy
aWVzIGluY2x1ZGluZyB0aG9zZSBpbiBIYXNoIHRhYmxlLgorICoKKyAqLworCit2b2lkIHRoYXNo
X3B1cmdlX2FsbChWQ1BVICp2KQoreworCWludCBpOworCXRoYXNoX2RhdGFfdCAqaGVhZDsKKwl0
aGFzaF9jYl90ICAqdnRsYiwgKnZocHQ7CisJdnRsYiA9ICZ2LT5hcmNoLnZ0bGI7CisJdmhwdCA9
ICZ2LT5hcmNoLnZocHQ7CisKKwlmb3IgKGkgPSAwOyBpIDwgODsgaSsrKQorCQlWTVgodiwgcHNi
aXRzW2ldKSA9IDA7CisKKwloZWFkID0gdnRsYi0+aGFzaDsKKwlmb3IgKGkgPSAwOyBpIDwgdnRs
Yi0+bnVtOyBpKyspIHsKKwkJaGVhZC0+cGFnZV9mbGFncyA9IDA7CisJCWhlYWQtPmV0YWcgPSBJ
TlZBTElEX1RJX1RBRzsKKwkJaGVhZC0+aXRpciA9IDA7CisJCWhlYWQtPm5leHQgPSAwOworCQlo
ZWFkKys7CisJfTsKKworCWhlYWQgPSB2aHB0LT5oYXNoOworCWZvciAoaSA9IDA7IGkgPCB2aHB0
LT5udW07IGkrKykgeworCQloZWFkLT5wYWdlX2ZsYWdzID0gMDsKKwkJaGVhZC0+ZXRhZyA9IElO
VkFMSURfVElfVEFHOworCQloZWFkLT5pdGlyID0gMDsKKwkJaGVhZC0+bmV4dCA9IDA7CisJCWhl
YWQrKzsKKwl9OworCisJbG9jYWxfZmx1c2hfdGxiX2FsbCgpOworfQorCisKKy8qCisgKiBMb29r
dXAgdGhlIGhhc2ggdGFibGUgYW5kIGl0cyBjb2xsaXNpb24gY2hhaW4gdG8gZmluZCBhbiBlbnRy
eQorICogY292ZXJpbmcgdGhpcyBhZGRyZXNzIHJpZDp2YSBvciB0aGUgZW50cnkuCisgKgorICog
SU5QVVQ6CisgKiAgaW46IFRMQiBmb3JtYXQgZm9yIGJvdGggVkhQVCAmIFRMQi4KKyAqLworCit0
aGFzaF9kYXRhX3QgKnZ0bGJfbG9va3VwKFZDUFUgKnYsIHU2NCB2YSwgaW50IGlzX2RhdGEpCit7
CisJdGhhc2hfZGF0YV90ICAqY2NoOworCXU2NCAgICAgcHNiaXRzLCBwcywgdGFnOworCWlhNjRf
cnIgdnJyOworCisJdGhhc2hfY2JfdCAqaGNiID0gJnYtPmFyY2gudnRsYjsKKworCWNjaCA9IF9f
dnRyX2xvb2t1cCh2LCB2YSwgaXNfZGF0YSk7OworCWlmIChjY2gpCisJCXJldHVybiBjY2g7CisK
KwlpZiAodmNwdV9xdWlja19yZWdpb25fY2hlY2sodi0+YXJjaC50Y19yZWdpb25zLCB2YSkgPT0g
MCkKKwkJcmV0dXJuIE5VTEw7CisKKwlwc2JpdHMgPSBWTVgodiwgcHNiaXRzWyh2YSA+PiA2MSld
KTsKKwl2cnIudmFsID0gdmNwdV9nZXRfcnIodiwgdmEpOworCXdoaWxlIChwc2JpdHMpIHsKKwkJ
cHMgPSBfX2Zmcyhwc2JpdHMpOworCQlwc2JpdHMgJj0gfigxVUwgPDwgcHMpOworCQl2cnIucHMg
PSBwczsKKwkJY2NoID0gdnNhX3RoYXNoKGhjYi0+cHRhLCB2YSwgdnJyLnZhbCwgJnRhZyk7CisJ
CWlmIChjY2gtPmV0YWcgPT0gdGFnICYmIGNjaC0+cHMgPT0gcHMpCisJCQlyZXR1cm4gY2NoOwor
CX0KKworCXJldHVybiBOVUxMOworfQorCisKKy8qCisgKiBJbml0aWFsaXplIGludGVybmFsIGNv
bnRyb2wgZGF0YSBiZWZvcmUgc2VydmljZS4KKyAqLwordm9pZCB0aGFzaF9pbml0KHRoYXNoX2Ni
X3QgKmhjYiwgdTY0IHN6KQoreworCWludCBpOworCXRoYXNoX2RhdGFfdCAqaGVhZDsKKworCWhj
Yi0+cHRhLnZhbCA9ICh1bnNpZ25lZCBsb25nKWhjYi0+aGFzaDsKKwloY2ItPnB0YS52ZiA9IDE7
CisJaGNiLT5wdGEudmUgPSAxOworCWhjYi0+cHRhLnNpemUgPSBzejsKKwloZWFkID0gaGNiLT5o
YXNoOworCWZvciAoaSA9IDA7IGkgPCBoY2ItPm51bTsgaSsrKSB7CisJCWhlYWQtPnBhZ2VfZmxh
Z3MgPSAwOworCQloZWFkLT5pdGlyID0gMDsKKwkJaGVhZC0+ZXRhZyA9IElOVkFMSURfVElfVEFH
OworCQloZWFkLT5uZXh0ID0gMDsKKwkJaGVhZCsrOworCX0KK30KKwordTY0IGt2bV9sb29rdXBf
bXBhKHU2NCBncGZuKQoreworCXU2NCAqYmFzZSA9ICh1NjQgKikgS1ZNX1AyTV9CQVNFOworCXJl
dHVybiAqKGJhc2UgKyBncGZuKTsKK30KKwordTY0IGt2bV9ncGFfdG9fbXBhKHU2NCBncGEpCit7
CisJdTY0IHB0ZSA9IGt2bV9sb29rdXBfbXBhKGdwYSA+PiBQQUdFX1NISUZUKTsKKwlyZXR1cm4g
KHB0ZSA+PiBQQUdFX1NISUZUIDw8IFBBR0VfU0hJRlQpIHwgKGdwYSAmIH5QQUdFX01BU0spOwor
fQorCisKKy8qCisgKiBGZXRjaCBndWVzdCBidW5kbGUgY29kZS4KKyAqIElOUFVUOgorICogIGdp
cDogZ3Vlc3QgaXAKKyAqICBwYnVuZGxlOiB1c2VkIHRvIHJldHVybiBmZXRjaGVkIGJ1bmRsZS4K
KyAqLworaW50IGZldGNoX2NvZGUoVkNQVSAqdmNwdSwgdTY0IGdpcCwgSUE2NF9CVU5ETEUgKnBi
dW5kbGUpCit7CisJdTY0ICAgICBncGlwID0gMDsgICAvKiBndWVzdCBwaHlzaWNhbCBJUCovCisJ
dTY0ICAgICAqdnBhOworCXRoYXNoX2RhdGFfdCAgICAqdGxiOworCXU2NCAgICAgbWFkZHI7CisK
KwlpZiAoIShWQ1BVKHZjcHUsIHZwc3IpICYgSUE2NF9QU1JfSVQpKSB7CisJCS8qIEktc2lkZSBw
aHlzaWNhbCBtb2RlICovCisJCWdwaXAgPSBnaXA7CisJfSBlbHNlIHsKKwkJdGxiID0gdnRsYl9s
b29rdXAodmNwdSwgZ2lwLCBJX1RMQik7CisJCWlmICh0bGIpCisJCQlncGlwID0gKHRsYi0+cHBu
ID4+ICh0bGItPnBzIC0gMTIpIDw8IHRsYi0+cHMpIHwKKwkJCQkoZ2lwICYgKFBTSVpFKHRsYi0+
cHMpIC0gMSkpOworCX0KKwlpZiAoZ3BpcCkgeworCQltYWRkciA9IGt2bV9ncGFfdG9fbXBhKGdw
aXApOworCX0gZWxzZSB7CisJCXRsYiA9IHZocHRfbG9va3VwKGdpcCk7CisJCWlmICh0bGIgPT0g
TlVMTCkgeworCQkJaWE2NF9wdGNsKGdpcCwgQVJDSF9QQUdFX1NISUZUIDw8IDIpOworCQkJcmV0
dXJuIElBNjRfRkFVTFQ7CisJCX0KKwkJbWFkZHIgPSAodGxiLT5wcG4gPj4gKHRsYi0+cHMgLSAx
MikgPDwgdGxiLT5wcykKKwkJCQkJfCAoZ2lwICYgKFBTSVpFKHRsYi0+cHMpIC0gMSkpOworCX0K
Kwl2cGEgPSAodTY0ICopX19rdm1fdmEobWFkZHIpOworCisJcGJ1bmRsZS0+aTY0WzBdID0gKnZw
YSsrOworCXBidW5kbGUtPmk2NFsxXSA9ICp2cGE7CisKKwlyZXR1cm4gSUE2NF9OT19GQVVMVDsK
K30KKworCit2b2lkIGt2bV9pbml0X3ZocHQoVkNQVSAqdikKK3sKKwl2LT5hcmNoLnZocHQubnVt
ID0gVkhQVF9OVU1fRU5UUklFUzsKKwl0aGFzaF9pbml0KCZ2LT5hcmNoLnZocHQsIFZIUFRfU0hJ
RlQpOworCWlhNjRfc2V0X3B0YSh2LT5hcmNoLnZocHQucHRhLnZhbCk7CisJLypFbmFibGUgVkhQ
VCBoZXJlPyovCit9CisKK3ZvaWQga3ZtX2luaXRfdnRsYihWQ1BVICp2KQoreworCXYtPmFyY2gu
dnRsYi5udW0gPSBWVExCX05VTV9FTlRSSUVTOworCXRoYXNoX2luaXQoJnYtPmFyY2gudnRsYiwg
VlRMQl9TSElGVCk7Cit9Ci0tIAoxLjUuMgoK

------_=_NextPart_001_01C890BA.53FC0293--
