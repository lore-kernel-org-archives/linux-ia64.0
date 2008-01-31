From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 10:29:40 +0000
Subject: [PATCH][10] Add TLB virtulization support.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCD31FCD@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C863F4.2FE684CB"
List-Id: <linux-ia64.vger.kernel.org>
To: Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Xu, Anthony" <anthony.xu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Zhang, Xiantao" <xiantao.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-ia64-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C863F4.2FE684CB
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

From: Zhang Xiantao <xiantao.zhang@intel.com>
Date: Tue, 29 Jan 2008 14:26:29 +0800
Subject: [PATCH] kvm/ia64: Add TLB virtulization support.

vtlb.c includes tlb/VHPT virtulization.
Signed-off-by: Anthony Xu <anthony.xu@intel.com>
Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>
---
 arch/ia64/kvm/vtlb.c |  606
++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 606 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kvm/vtlb.c

diff --git a/arch/ia64/kvm/vtlb.c b/arch/ia64/kvm/vtlb.c
new file mode 100644
index 0000000..25f9ad6
--- /dev/null
+++ b/arch/ia64/kvm/vtlb.c
@@ -0,0 +1,606 @@
+/*
+ * vtlb.c: guest virtual tlb handling module.
+ * Copyright (c) 2004, Intel Corporation.
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
+ *  Yaozu Dong (Eddie Dong) (Eddie.dong@intel.com)
+ *  Xuefei Xu (Anthony Xu) (anthony.xu@intel.com)
+ */
+
+#include "vcpu.h"
+
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
+		ia64_srlz_i();
+	}
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
+		ia64_srlz_i();
+	}
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
1.5.1

------_=_NextPart_001_01C863F4.2FE684CB
Content-Type: application/octet-stream;
	name="0010-kvm-ia64-Add-TLB-virtulization-support.patch"
Content-Transfer-Encoding: base64
Content-Description: 0010-kvm-ia64-Add-TLB-virtulization-support.patch
Content-Disposition: attachment;
	filename="0010-kvm-ia64-Add-TLB-virtulization-support.patch"

RnJvbSBjMjE5NmVjMDUyNTZhYmNiMWYyMjFjZTk3NjRlM2QxYmVmZTJhMDY3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBaaGFuZyBYaWFudGFvIDx4aWFudGFvLnpoYW5nQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAyOSBKYW4gMjAwOCAxNDoyNjoyOSArMDgwMApTdWJqZWN0OiBbUEFUQ0hd
IGt2bS9pYTY0OiBBZGQgVExCIHZpcnR1bGl6YXRpb24gc3VwcG9ydC4KCnZ0bGIuYyBpbmNsdWRl
cyB0bGIvVkhQVCB2aXJ0dWxpemF0aW9uLgpTaWduZWQtb2ZmLWJ5OiBBbnRob255IFh1IDxhbnRo
b255Lnh1QGludGVsLmNvbT4KU2lnbmVkLW9mZi1ieTogWGlhbnRhbyBaaGFuZyA8eGlhbnRhby56
aGFuZ0BpbnRlbC5jb20+Ci0tLQogYXJjaC9pYTY0L2t2bS92dGxiLmMgfCAgNjA2ICsrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrCiAxIGZpbGVzIGNoYW5n
ZWQsIDYwNiBpbnNlcnRpb25zKCspLCAwIGRlbGV0aW9ucygtKQogY3JlYXRlIG1vZGUgMTAwNjQ0
IGFyY2gvaWE2NC9rdm0vdnRsYi5jCgpkaWZmIC0tZ2l0IGEvYXJjaC9pYTY0L2t2bS92dGxiLmMg
Yi9hcmNoL2lhNjQva3ZtL3Z0bGIuYwpuZXcgZmlsZSBtb2RlIDEwMDY0NAppbmRleCAwMDAwMDAw
Li4yNWY5YWQ2Ci0tLSAvZGV2L251bGwKKysrIGIvYXJjaC9pYTY0L2t2bS92dGxiLmMKQEAgLTAs
MCArMSw2MDYgQEAKKy8qCisgKiB2dGxiLmM6IGd1ZXN0IHZpcnR1YWwgdGxiIGhhbmRsaW5nIG1v
ZHVsZS4KKyAqIENvcHlyaWdodCAoYykgMjAwNCwgSW50ZWwgQ29ycG9yYXRpb24uCisgKgorICog
VGhpcyBwcm9ncmFtIGlzIGZyZWUgc29mdHdhcmU7IHlvdSBjYW4gcmVkaXN0cmlidXRlIGl0IGFu
ZC9vciBtb2RpZnkgaXQKKyAqIHVuZGVyIHRoZSB0ZXJtcyBhbmQgY29uZGl0aW9ucyBvZiB0aGUg
R05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2UsCisgKiB2ZXJzaW9uIDIsIGFzIHB1Ymxpc2hlZCBi
eSB0aGUgRnJlZSBTb2Z0d2FyZSBGb3VuZGF0aW9uLgorICoKKyAqIFRoaXMgcHJvZ3JhbSBpcyBk
aXN0cmlidXRlZCBpbiB0aGUgaG9wZSBpdCB3aWxsIGJlIHVzZWZ1bCwgYnV0IFdJVEhPVVQKKyAq
IEFOWSBXQVJSQU5UWTsgd2l0aG91dCBldmVuIHRoZSBpbXBsaWVkIHdhcnJhbnR5IG9mIE1FUkNI
QU5UQUJJTElUWSBvcgorICogRklUTkVTUyBGT1IgQSBQQVJUSUNVTEFSIFBVUlBPU0UuICBTZWUg
dGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlIGZvcgorICogbW9yZSBkZXRhaWxzLgorICoK
KyAqIFlvdSBzaG91bGQgaGF2ZSByZWNlaXZlZCBhIGNvcHkgb2YgdGhlIEdOVSBHZW5lcmFsIFB1
YmxpYyBMaWNlbnNlIGFsb25nIHdpdGgKKyAqIHRoaXMgcHJvZ3JhbTsgaWYgbm90LCB3cml0ZSB0
byB0aGUgRnJlZSBTb2Z0d2FyZSBGb3VuZGF0aW9uLCBJbmMuLCA1OSBUZW1wbGUKKyAqIFBsYWNl
IC0gU3VpdGUgMzMwLCBCb3N0b24sIE1BIDAyMTExLTEzMDcgVVNBLgorICoKKyAqICBZYW96dSBE
b25nIChFZGRpZSBEb25nKSAoRWRkaWUuZG9uZ0BpbnRlbC5jb20pCisgKiAgWHVlZmVpIFh1IChB
bnRob255IFh1KSAoYW50aG9ueS54dUBpbnRlbC5jb20pCisgKi8KKworI2luY2x1ZGUgInZjcHUu
aCIKKworLyoKKyAqIENoZWNrIHRvIHNlZSBpZiB0aGUgYWRkcmVzcyByaWQ6dmEgaXMgdHJhbnNs
YXRlZCBieSB0aGUgVExCCisgKi8KKworc3RhdGljIGludCBfX2lzX3RyX3RyYW5zbGF0ZWQodGhh
c2hfZGF0YV90ICp0cnAsIHU2NCByaWQsIHU2NCB2YSkKK3sKKwlyZXR1cm4gKCh0cnAtPnApICYm
ICh0cnAtPnJpZCA9PSByaWQpCisJCQkJJiYgKCh2YS10cnAtPnZhZHIpIDwgUFNJWkUodHJwLT5w
cykpKTsKK30KKworLyoKKyAqIE9ubHkgZm9yIEdVRVNUIFRSIGZvcm1hdC4KKyAqLworc3RhdGlj
IGludCBfX2lzX3RyX292ZXJsYXAodGhhc2hfZGF0YV90ICp0cnAsIHU2NCByaWQsIHU2NCBzdmEs
IHU2NCBldmEpCit7CisJdTY0IHNhMSwgZWExOworCisJaWYgKCF0cnAtPnAgfHwgdHJwLT5yaWQg
IT0gcmlkKQorCQlyZXR1cm4gMDsKKworCXNhMSA9IHRycC0+dmFkcjsKKwllYTEgPSBzYTEgKyBQ
U0laRSh0cnAtPnBzKSAtIDE7CisJZXZhIC09IDE7CisJaWYgKChzdmEgPiBlYTEpIHx8IChzYTEg
PiBldmEpKQorCQlyZXR1cm4gMDsKKwllbHNlCisJCXJldHVybiAxOworCit9CisKK3ZvaWQgbWFj
aGluZV90bGJfcHVyZ2UodTY0IHZhLCB1NjQgcHMpCit7CisJaWE2NF9wdGNsKHZhLCBwcyA8PCAy
KTsKK30KKwordm9pZCBsb2NhbF9mbHVzaF90bGJfYWxsKHZvaWQpCit7CisJaW50IGksIGo7CisJ
dW5zaWduZWQgbG9uZyBmbGFncywgY291bnQwLCBjb3VudDE7CisJdW5zaWduZWQgbG9uZyBzdHJp
ZGUwLCBzdHJpZGUxLCBhZGRyOworCisJYWRkciAgICA9IGN1cnJlbnRfdmNwdS0+YXJjaC5wdGNl
X2Jhc2U7CisJY291bnQwICA9IGN1cnJlbnRfdmNwdS0+YXJjaC5wdGNlX2NvdW50WzBdOworCWNv
dW50MSAgPSBjdXJyZW50X3ZjcHUtPmFyY2gucHRjZV9jb3VudFsxXTsKKwlzdHJpZGUwID0gY3Vy
cmVudF92Y3B1LT5hcmNoLnB0Y2Vfc3RyaWRlWzBdOworCXN0cmlkZTEgPSBjdXJyZW50X3ZjcHUt
PmFyY2gucHRjZV9zdHJpZGVbMV07CisKKwlsb2NhbF9pcnFfc2F2ZShmbGFncyk7CisJZm9yIChp
ID0gMDsgaSA8IGNvdW50MDsgKytpKSB7CisJCWZvciAoaiA9IDA7IGogPCBjb3VudDE7ICsraikg
eworCQkJaWE2NF9wdGNlKGFkZHIpOworCQkJYWRkciArPSBzdHJpZGUxOworCQl9CisJCWFkZHIg
Kz0gc3RyaWRlMDsKKwl9CisJbG9jYWxfaXJxX3Jlc3RvcmUoZmxhZ3MpOworCWlhNjRfc3Jsel9p
KCk7ICAgICAgICAgIC8qIHNybHouaSBpbXBsaWVzIHNybHouZCAqLworfQorCitpbnQgdmhwdF9l
bmFibGVkKFZDUFUgKnZjcHUsIHU2NCB2YWRyLCB2aHB0X3JlZl90IHJlZikKK3sKKwlpYTY0X3Jy
ICAgIHZycjsKKwlpYTY0X3B0YSAgIHZwdGE7CisJaWE2NF9wc3IgICB2cHNyOworCisJdnBzci52
YWwgPSBWQ1BVKHZjcHUsIHZwc3IpOworCXZyci52YWwgPSB2Y3B1X2dldF9ycih2Y3B1LCB2YWRy
KTsKKwl2cHRhLnZhbCA9IHZjcHVfZ2V0X3B0YSh2Y3B1KTsKKworCWlmICh2cnIudmUgJiB2cHRh
LnZlKSB7CisJCXN3aXRjaCAocmVmKSB7CisJCWNhc2UgREFUQV9SRUY6CisJCWNhc2UgTkFfUkVG
OgorCQkJcmV0dXJuIHZwc3IuZHQ7CisJCWNhc2UgSU5TVF9SRUY6CisJCQlyZXR1cm4gdnBzci5k
dCAmJiB2cHNyLml0ICYmIHZwc3IuaWM7CisJCWNhc2UgUlNFX1JFRjoKKwkJCXJldHVybiB2cHNy
LmR0ICYmIHZwc3IucnQ7CisKKwkJfQorCX0KKwlyZXR1cm4gMDsKK30KKwordGhhc2hfZGF0YV90
ICp2c2FfdGhhc2goaWE2NF9wdGEgdnB0YSwgdTY0IHZhLCB1NjQgdnJyLCB1NjQgKnRhZykKK3sK
Kwl1NjQgaW5kZXgsIHBmbiwgcmlkLCBwZm5fYml0czsKKworCXBmbl9iaXRzID0gdnB0YS5zaXpl
IC0gNSAtIDg7CisJcGZuID0gUkVHSU9OX09GRlNFVCh2YSkgPj4gX1JFR0lPTl9QQUdFX1NJWkUo
dnJyKTsKKwlyaWQgPSBfUkVHSU9OX0lEKHZycik7CisJaW5kZXggPSAoKHJpZCAmIDB4ZmYpIDw8
IHBmbl9iaXRzKXwocGZuICYgKCgxVUwgPDwgcGZuX2JpdHMpIC0gMSkpOworCSp0YWcgPSAoKHJp
ZCA+PiA4KSAmIDB4ZmZmZikgfCAoKHBmbiA+PiBwZm5fYml0cykgPDwgMTYpOworCisJcmV0dXJu
ICh0aGFzaF9kYXRhX3QgKikoKHZwdGEuYmFzZSA8PCBQVEFfQkFTRV9TSElGVCkgKyAoaW5kZXgg
PDwgNSkpOworfQorCit0aGFzaF9kYXRhX3QgKl9fdnRyX2xvb2t1cChWQ1BVICp2Y3B1LCB1NjQg
dmEsIGludCB0eXBlKQoreworCisJdGhhc2hfZGF0YV90ICAqdHJwOworCWludCAgaTsKKwl1NjQg
cmlkOworCisJcmlkID0gdmNwdV9nZXRfcnIodmNwdSwgdmEpOworCXJpZCA9IHJpZCAmIFJSX1JJ
RF9NQVNLOzsKKwlpZiAodHlwZSA9PSBEX1RMQikgeworCQlpZiAodmNwdV9xdWlja19yZWdpb25f
Y2hlY2sodmNwdS0+YXJjaC5kdHJfcmVnaW9ucywgdmEpKSB7CisJCQlmb3IgKHRycCA9ICh0aGFz
aF9kYXRhX3QgKikmdmNwdS0+YXJjaC5kdHJzLCBpID0gMDsKKwkJCQkJCWkgPCBORFRSUzsgaSsr
LCB0cnArKykgeworCQkJCWlmIChfX2lzX3RyX3RyYW5zbGF0ZWQodHJwLCByaWQsIHZhKSkKKwkJ
CQkJcmV0dXJuIHRycDsKKwkJCX0KKwkJfQorCX0gZWxzZSB7CisJCWlmICh2Y3B1X3F1aWNrX3Jl
Z2lvbl9jaGVjayh2Y3B1LT5hcmNoLml0cl9yZWdpb25zLCB2YSkpIHsKKwkJCWZvciAodHJwID0g
KHRoYXNoX2RhdGFfdCAqKSZ2Y3B1LT5hcmNoLml0cnMsIGkgPSAwOworCQkJCQlpIDwgTklUUlM7
IGkrKywgdHJwKyspIHsKKwkJCQlpZiAoX19pc190cl90cmFuc2xhdGVkKHRycCwgcmlkLCB2YSkp
CisJCQkJCXJldHVybiB0cnA7CisJCQl9CisJCX0KKwl9CisKKwlyZXR1cm4gTlVMTDsKK30KKwor
c3RhdGljIHZvaWQgdmhwdF9pbnNlcnQodTY0IHB0ZSwgdTY0IGl0aXIsIHU2NCBpZmEsIHU2NCBn
cHRlKQoreworCWlhNjRfcnIgcnI7CisJdGhhc2hfZGF0YV90ICpoZWFkOworCXVuc2lnbmVkIGxv
bmcgcHMsIGdwYWRkcjsKKworCXBzID0gaXRpcl9wcyhpdGlyKTsKKworCWdwYWRkciA9ICgoZ3B0
ZSAmIF9QQUdFX1BQTl9NQVNLKSA+PiBwcyA8PCBwcykgfAorCQkoaWZhICYgKCgxVUwgPDwgcHMp
IC0gMSkpOworCisJcnIudmFsID0gaWE2NF9nZXRfcnIoaWZhKTsKKwloZWFkID0gKHRoYXNoX2Rh
dGFfdCAqKWlhNjRfdGhhc2goaWZhKTsKKwloZWFkLT5ldGFnID0gSU5WQUxJRF9USV9UQUc7CisJ
aWE2NF9tZigpOworCWhlYWQtPnBhZ2VfZmxhZ3MgPSBwdGUgJiB+UEFHRV9GTEFHU19SVl9NQVNL
OworCWhlYWQtPml0aXIgPSByci5wcyA8PCAyOworCWhlYWQtPmV0YWcgPSBpYTY0X3R0YWcoaWZh
KTsKKwloZWFkLT5ncGFkZHIgPSBncGFkZHI7Cit9CisKK3ZvaWQgdGhhc2hfdmhwdF9pbnNlcnQo
VkNQVSAqdiwgdTY0IHB0ZSwgdTY0IGl0aXIsIHU2NCB2YSwgaW50IHR5cGUpCit7CisJdTY0IHBo
eV9wdGUsIHBzcjsKKwlpYTY0X3JyIG1ycjsKKworCW1yci52YWwgPSBpYTY0X2dldF9ycih2YSk7
CisJcGh5X3B0ZSA9IHRyYW5zbGF0ZV9waHlfcHRlKCZwdGUsIGl0aXIsIHZhKTsKKworCWlmIChp
dGlyX3BzKGl0aXIpID49IG1yci5wcykgeworCQl2aHB0X2luc2VydChwaHlfcHRlLCBpdGlyLCB2
YSwgcHRlKTsKKwl9IGVsc2UgeworCQlwaHlfcHRlICAmPSB+UEFHRV9GTEFHU19SVl9NQVNLOwor
CQlwc3IgPSBpYTY0X2NsZWFyX2ljKCk7CisJCWlhNjRfaXRjKHR5cGUsIHZhLCBwaHlfcHRlLCBp
dGlyX3BzKGl0aXIpKTsKKwkJaWE2NF9zZXRfcHNyKHBzcik7CisJCWlhNjRfc3Jsel9pKCk7CisJ
fQorfQorCisvKgorICogICB2aHB0IGxvb2t1cAorICovCit0aGFzaF9kYXRhX3QgKnZocHRfbG9v
a3VwKHU2NCB2YSkKK3sKKwl0aGFzaF9kYXRhX3QgKmhlYWQ7CisJdTY0IHRhZzsKKworCWhlYWQg
PSAodGhhc2hfZGF0YV90ICopaWE2NF90aGFzaCh2YSk7CisJdGFnID0gaWE2NF90dGFnKHZhKTsK
KwlpZiAoaGVhZC0+ZXRhZyA9PSB0YWcpCisJCXJldHVybiBoZWFkOworCXJldHVybiBOVUxMOwor
fQorCit1NjQgZ3Vlc3RfdmhwdF9sb29rdXAodTY0IGloYSwgdTY0ICpwdGUpCit7CisJdTY0IHJl
dDsKKwl0aGFzaF9kYXRhX3QgKmRhdGE7CisKKwlkYXRhID0gX192dHJfbG9va3VwKGN1cnJlbnRf
dmNwdSwgaWhhLCBEX1RMQik7CisJaWYgKGRhdGEgIT0gTlVMTCkKKwkJdGhhc2hfdmhwdF9pbnNl
cnQoY3VycmVudF92Y3B1LCBkYXRhLT5wYWdlX2ZsYWdzLAorCQkJZGF0YS0+aXRpciwgaWhhLCBE
X1RMQik7CisKKwlhc20gdm9sYXRpbGUgKCJyc20gcHNyLmljfHBzci5pOzsiCisJCQkic3Jsei5k
OzsiCisJCQkibGQ4LnMgcjk9WyUxXTs7IgorCQkJInRuYXQubnogcDYscDc9cjk7OyIKKwkJCSIo
cDYpIG1vdiAlMD0xOyIKKwkJCSIocDYpIG1vdiByOT1yMDsiCisJCQkiKHA3KSBleHRyLnUgcjk9
cjksMCw1Mzs7IgorCQkJIihwNykgbW92ICUwPXIwOyIKKwkJCSIocDcpIHN0OCBbJTJdPXI5Ozsi
CisJCQkic3NtIHBzci5pYzs7IgorCQkJInNybHouZDs7IgorCQkJLyogInNzbSBwc3IuaTs7IiBP
bmNlIGludGVycnVwdHMgaW4gdm1tIG9wZW4sIG5lZWQgZml4Ki8KKwkJCTogIj1yIihyZXQpIDog
InIiKGloYSksICJyIihwdGUpOiJtZW1vcnkiKTsKKworCXJldHVybiByZXQ7Cit9CisKKy8qCisg
KiAgcHVyZ2Ugc29mdHdhcmUgZ3Vlc3QgdGxiCisgKi8KKworc3RhdGljIHZvaWQgdnRsYl9wdXJn
ZShWQ1BVICp2LCB1NjQgdmEsIHU2NCBwcykKK3sKKwl0aGFzaF9kYXRhX3QgKmN1cjsKKwl1NjQg
c3RhcnQsIGN1cmFkciwgc2l6ZSwgcHNiaXRzLCB0YWcsIHJyX3BzLCBudW07CisJaWE2NF9yciB2
cnI7CisJdGhhc2hfY2JfdCAqaGNiID0gJnYtPmFyY2gudnRsYjsKKworCXZyci52YWwgPSB2Y3B1
X2dldF9ycih2LCB2YSk7CisJcHNiaXRzID0gVk1YKHYsIHBzYml0c1sodmEgPj4gNjEpXSk7CisJ
c3RhcnQgPSB2YSAmIH4oKDFVTCA8PCBwcykgLSAxKTsKKwl3aGlsZSAocHNiaXRzKSB7CisJCWN1
cmFkciA9IHN0YXJ0OworCQlycl9wcyA9IF9fZmZzKHBzYml0cyk7CisJCXBzYml0cyAmPSB+KDFV
TCA8PCBycl9wcyk7CisJCW51bSA9IDFVTCA8PCAoKHBzIDwgcnJfcHMpID8gMCA6IChwcyAtIHJy
X3BzKSk7CisJCXNpemUgPSBQU0laRShycl9wcyk7CisJCXZyci5wcyA9IHJyX3BzOworCQl3aGls
ZSAobnVtKSB7CisJCQljdXIgPSB2c2FfdGhhc2goaGNiLT5wdGEsIGN1cmFkciwgdnJyLnZhbCwg
JnRhZyk7CisJCQlpZiAoY3VyLT5ldGFnID09IHRhZyAmJiBjdXItPnBzID09IHJyX3BzKQorCQkJ
CWN1ci0+ZXRhZyA9IElOVkFMSURfVElfVEFHOworCQkJY3VyYWRyICs9IHNpemU7CisJCQludW0t
LTsKKwkJfQorCX0KK30KKworCisvKgorICogIHB1cmdlIFZIUFQgYW5kIG1hY2hpbmUgVExCCisg
Ki8KK3N0YXRpYyB2b2lkIHZocHRfcHVyZ2UoVkNQVSAqdiwgdTY0IHZhLCB1NjQgcHMpCit7CisJ
dGhhc2hfZGF0YV90ICpjdXI7CisJdTY0IHN0YXJ0LCBzaXplLCB0YWcsIG51bTsKKwlpYTY0X3Jy
IHJyOworCisJc3RhcnQgPSB2YSAmIH4oKDFVTCA8PCBwcykgLSAxKTsKKwlyci52YWwgPSBpYTY0
X2dldF9ycih2YSk7CisJc2l6ZSA9IFBTSVpFKHJyLnBzKTsKKwludW0gPSAxVUwgPDwgKChwcyA8
IHJyLnBzKSA/IDAgOiAocHMgLSByci5wcykpOworCXdoaWxlIChudW0pIHsKKwkJY3VyID0gKHRo
YXNoX2RhdGFfdCAqKWlhNjRfdGhhc2goc3RhcnQpOworCQl0YWcgPSBpYTY0X3R0YWcoc3RhcnQp
OworCQlpZiAoY3VyLT5ldGFnID09IHRhZykKKwkJCWN1ci0+ZXRhZyA9IElOVkFMSURfVElfVEFH
OworCQlzdGFydCArPSBzaXplOworCQludW0tLTsKKwl9CisJbWFjaGluZV90bGJfcHVyZ2UodmEs
IHBzKTsKK30KKworLyoKKyAqIEluc2VydCBhbiBlbnRyeSBpbnRvIGhhc2ggVExCIG9yIFZIUFQu
CisgKiBOT1RFUzoKKyAqICAxOiBXaGVuIGluc2VydGluZyBWSFBUIHRvIHRoYXNoLCAidmEiIGlz
IGEgbXVzdCBjb3ZlcmVkCisgKiAgYWRkcmVzcyBieSB0aGUgaW5zZXJ0ZWQgbWFjaGluZSBWSFBU
IGVudHJ5LgorICogIDI6IFRoZSBmb3JtYXQgb2YgZW50cnkgaXMgYWx3YXlzIGluIFRMQi4KKyAq
ICAzOiBUaGUgY2FsbGVyIG5lZWQgdG8gbWFrZSBzdXJlIHRoZSBuZXcgZW50cnkgd2lsbCBub3Qg
b3ZlcmxhcAorICogICAgIHdpdGggYW55IGV4aXN0ZWQgZW50cnkuCisgKi8KK3ZvaWQgdnRsYl9p
bnNlcnQoVkNQVSAqdiwgdTY0IHB0ZSwgdTY0IGl0aXIsIHU2NCB2YSkKK3sKKwl0aGFzaF9kYXRh
X3QgKmhlYWQ7CisJaWE2NF9yciB2cnI7CisJdTY0IHRhZzsKKwl0aGFzaF9jYl90ICpoY2IgPSAm
di0+YXJjaC52dGxiOworCisJdnJyLnZhbCA9IHZjcHVfZ2V0X3JyKHYsIHZhKTsKKwl2cnIucHMg
PSBpdGlyX3BzKGl0aXIpOworCVZNWCh2LCBwc2JpdHNbdmEgPj4gNjFdKSB8PSAoMVVMIDw8IHZy
ci5wcyk7CisJaGVhZCA9IHZzYV90aGFzaChoY2ItPnB0YSwgdmEsIHZyci52YWwsICZ0YWcpOwor
CWhlYWQtPnBhZ2VfZmxhZ3MgPSBwdGU7CisJaGVhZC0+aXRpciA9IGl0aXI7CisJaGVhZC0+ZXRh
ZyA9IHRhZzsKK30KKworaW50IHZ0cl9maW5kX292ZXJsYXAoVkNQVSAqdmNwdSwgdTY0IHZhLCB1
NjQgcHMsIGludCB0eXBlKQoreworCXRoYXNoX2RhdGFfdCAgKnRycDsKKwlpbnQgIGk7CisJdTY0
IGVuZCwgcmlkOworCisJcmlkID0gdmNwdV9nZXRfcnIodmNwdSwgdmEpOworCXJpZCA9IHJpZCAm
IFJSX1JJRF9NQVNLOworCWVuZCA9IHZhICsgUFNJWkUocHMpOworCWlmICh0eXBlID09IERfVExC
KSB7CisJCWlmICh2Y3B1X3F1aWNrX3JlZ2lvbl9jaGVjayh2Y3B1LT5hcmNoLmR0cl9yZWdpb25z
LCB2YSkpIHsKKwkJCWZvciAodHJwID0gKHRoYXNoX2RhdGFfdCAqKSZ2Y3B1LT5hcmNoLmR0cnMs
IGkgPSAwOworCQkJCQlpIDwgTkRUUlM7IGkrKywgdHJwKyspIHsKKwkJCQlpZiAoX19pc190cl9v
dmVybGFwKHRycCwgcmlkLCB2YSwgZW5kKSkKKwkJCQkJcmV0dXJuIGk7CisJCQl9CisJCX0KKwl9
IGVsc2UgeworCQlpZiAodmNwdV9xdWlja19yZWdpb25fY2hlY2sodmNwdS0+YXJjaC5pdHJfcmVn
aW9ucywgdmEpKSB7CisJCQlmb3IgKHRycCA9ICh0aGFzaF9kYXRhX3QgKikmdmNwdS0+YXJjaC5p
dHJzLCBpID0gMDsKKwkJCQkJaSA8IE5JVFJTOyBpKyssIHRycCsrKSB7CisJCQkJaWYgKF9faXNf
dHJfb3ZlcmxhcCh0cnAsIHJpZCwgdmEsIGVuZCkpCisJCQkJCXJldHVybiBpOworCQkJfQorCQl9
CisJfQorCXJldHVybiAtMTsKK30KKworLyoKKyAqIFB1cmdlIGVudHJpZXMgaW4gVlRMQiBhbmQg
VkhQVAorICovCit2b2lkIHRoYXNoX3B1cmdlX2VudHJpZXMoVkNQVSAqdiwgdTY0IHZhLCB1NjQg
cHMpCit7CisJaWYgKHZjcHVfcXVpY2tfcmVnaW9uX2NoZWNrKHYtPmFyY2gudGNfcmVnaW9ucywg
dmEpKQorCQl2dGxiX3B1cmdlKHYsIHZhLCBwcyk7CisJdmhwdF9wdXJnZSh2LCB2YSwgcHMpOwor
fQorCit2b2lkIHRoYXNoX3B1cmdlX2VudHJpZXNfcmVtb3RlKFZDUFUgKnYsIHU2NCB2YSwgdTY0
IHBzKQoreworCXU2NCBvbGRfdmEgPSB2YTsKKwl2YSA9IFJFR0lPTl9PRkZTRVQodmEpOworCWlm
ICh2Y3B1X3F1aWNrX3JlZ2lvbl9jaGVjayh2LT5hcmNoLnRjX3JlZ2lvbnMsIG9sZF92YSkpCisJ
CXZ0bGJfcHVyZ2UodiwgdmEsIHBzKTsKKwl2aHB0X3B1cmdlKHYsIHZhLCBwcyk7Cit9CisKK3U2
NCB0cmFuc2xhdGVfcGh5X3B0ZSh1NjQgKnB0ZSwgdTY0IGl0aXIsIHU2NCB2YSkKK3sKKwl1NjQg
cHMsIHBzX21hc2ssIHBhZGRyLCBtYWRkcjsKKwl1bmlvbiBwdGVfZmxhZ3MgcGh5X3B0ZTsKKwor
CXBzID0gaXRpcl9wcyhpdGlyKTsKKwlwc19tYXNrID0gfigoMVVMIDw8IHBzKSAtIDEpOworCXBo
eV9wdGUudmFsID0gKnB0ZTsKKwlwYWRkciA9ICpwdGU7CisJcGFkZHIgPSAoKHBhZGRyICYgX1BB
R0VfUFBOX01BU0spICYgcHNfbWFzaykgfCAodmEgJiB+cHNfbWFzayk7CisJbWFkZHIgPSBrdm1f
bG9va3VwX21wYShwYWRkciA+PiBQQUdFX1NISUZUKTsKKwlpZiAobWFkZHIgJiBHUEZOX0lPX01B
U0spIHsKKwkJKnB0ZSB8PSBWVExCX1BURV9JTzsKKwkJcmV0dXJuIC0xOworCX0KKwltYWRkciA9
ICgobWFkZHIgJiBfUEFHRV9QUE5fTUFTSykgJiBQQUdFX01BU0spIHwKKwkJCQkJKHBhZGRyICYg
flBBR0VfTUFTSyk7CisJcGh5X3B0ZS5wcG4gPSBtYWRkciA+PiBBUkNIX1BBR0VfU0hJRlQ7CisJ
cmV0dXJuIHBoeV9wdGUudmFsOworfQorCisKKy8qCisgKiBQdXJnZSBvdmVybGFwIFRDcyBhbmQg
dGhlbiBpbnNlcnQgdGhlIG5ldyBlbnRyeSB0byBlbXVsYXRlIGl0YyBvcHMuCisgKiAgICBOb3Rl
czogT25seSBUQyBlbnRyeSBjYW4gcHVyZ2UgYW5kIGluc2VydC4KKyAqICAgIDEgaW5kaWNhdGVz
IHRoaXMgaXMgTU1JTworICovCitpbnQgdGhhc2hfcHVyZ2VfYW5kX2luc2VydChWQ1BVICp2LCB1
NjQgcHRlLCB1NjQgaXRpciwgdTY0IGlmYSwgaW50IHR5cGUpCit7CisJdTY0IHBzOworCXU2NCBw
aHlfcHRlOworCWlhNjRfcnIgdnJyLCBtcnI7CisJaW50IHJldCA9IDA7CisKKwlwcyA9IGl0aXJf
cHMoaXRpcik7CisJdnJyLnZhbCA9IHZjcHVfZ2V0X3JyKHYsIGlmYSk7CisJbXJyLnZhbCA9IGlh
NjRfZ2V0X3JyKGlmYSk7CisKKwlwaHlfcHRlID0gdHJhbnNsYXRlX3BoeV9wdGUoJnB0ZSwgaXRp
ciwgaWZhKTsKKworCS8qIEVuc3VyZSBXQiBhdHRyaWJ1dGUgaWYgcHRlIGlzIHJlbGF0ZWQgdG8g
YSBub3JtYWwgbWVtIHBhZ2UsCisJICogd2hpY2ggaXMgcmVxdWlyZWQgYnkgdmdhIGFjY2VsZXJh
dGlvbiBzaW5jZSBxZW11IG1hcHMgc2hhcmVkCisJICogdnJhbSBidWZmZXIgd2l0aCBXQi4KKwkg
Ki8KKwlpZiAoIShwdGUgJiBWVExCX1BURV9JTykgJiYgKChwdGUgJiBfUEFHRV9NQV9NQVNLKSAh
PSBfUEFHRV9NQV9OQVQpKSB7CisJCXB0ZSAmPSB+X1BBR0VfTUFfTUFTSzsKKwkJcGh5X3B0ZSAm
PSB+X1BBR0VfTUFfTUFTSzsKKwl9CisKKwlpZiAocHRlICYgVlRMQl9QVEVfSU8pCisJCXJldCA9
IDE7CisKKwl2dGxiX3B1cmdlKHYsIGlmYSwgcHMpOworCXZocHRfcHVyZ2UodiwgaWZhLCBwcyk7
CisKKwlpZiAocHMgPT0gbXJyLnBzKSB7CisJCWlmICghKHB0ZSZWVExCX1BURV9JTykpIHsKKwkJ
CXZocHRfaW5zZXJ0KHBoeV9wdGUsIGl0aXIsIGlmYSwgcHRlKTsKKwkJfSBlbHNlIHsKKwkJCXZ0
bGJfaW5zZXJ0KHYsIHB0ZSwgaXRpciwgaWZhKTsKKwkJCXZjcHVfcXVpY2tfcmVnaW9uX3NldChW
TVgodiwgdGNfcmVnaW9ucyksIGlmYSk7CisJCX0KKwl9IGVsc2UgaWYgKHBzID4gbXJyLnBzKSB7
CisJCXZ0bGJfaW5zZXJ0KHYsIHB0ZSwgaXRpciwgaWZhKTsKKwkJdmNwdV9xdWlja19yZWdpb25f
c2V0KFZNWCh2LCB0Y19yZWdpb25zKSwgaWZhKTsKKwkJaWYgKCEocHRlJlZUTEJfUFRFX0lPKSkK
KwkJCXZocHRfaW5zZXJ0KHBoeV9wdGUsIGl0aXIsIGlmYSwgcHRlKTsKKwl9IGVsc2UgeworCQl1
NjQgcHNyOworCQlwaHlfcHRlICAmPSB+UEFHRV9GTEFHU19SVl9NQVNLOworCQlwc3IgPSBpYTY0
X2NsZWFyX2ljKCk7CisJCWlhNjRfaXRjKHR5cGUsIGlmYSwgcGh5X3B0ZSwgcHMpOworCQlpYTY0
X3NldF9wc3IocHNyKTsKKwkJaWE2NF9zcmx6X2koKTsKKwl9CisKKwlyZXR1cm4gcmV0OworfQor
CisvKgorICogUHVyZ2UgYWxsIFRDcyBvciBWSFBUIGVudHJpZXMgaW5jbHVkaW5nIHRob3NlIGlu
IEhhc2ggdGFibGUuCisgKgorICovCisKK3ZvaWQgdGhhc2hfcHVyZ2VfYWxsKFZDUFUgKnYpCit7
CisJaW50IGk7CisJdGhhc2hfZGF0YV90ICpoZWFkOworCXRoYXNoX2NiX3QgICp2dGxiLCAqdmhw
dDsKKwl2dGxiID0gJnYtPmFyY2gudnRsYjsKKwl2aHB0ID0gJnYtPmFyY2gudmhwdDsKKworCWZv
ciAoaSA9IDA7IGkgPCA4OyBpKyspCisJCVZNWCh2LCBwc2JpdHNbaV0pID0gMDsKKworCWhlYWQg
PSB2dGxiLT5oYXNoOworCWZvciAoaSA9IDA7IGkgPCB2dGxiLT5udW07IGkrKykgeworCQloZWFk
LT5wYWdlX2ZsYWdzID0gMDsKKwkJaGVhZC0+ZXRhZyA9IElOVkFMSURfVElfVEFHOworCQloZWFk
LT5pdGlyID0gMDsKKwkJaGVhZC0+bmV4dCA9IDA7CisJCWhlYWQrKzsKKwl9OworCisJaGVhZCA9
IHZocHQtPmhhc2g7CisJZm9yIChpID0gMDsgaSA8IHZocHQtPm51bTsgaSsrKSB7CisJCWhlYWQt
PnBhZ2VfZmxhZ3MgPSAwOworCQloZWFkLT5ldGFnID0gSU5WQUxJRF9USV9UQUc7CisJCWhlYWQt
Pml0aXIgPSAwOworCQloZWFkLT5uZXh0ID0gMDsKKwkJaGVhZCsrOworCX07CisKKwlsb2NhbF9m
bHVzaF90bGJfYWxsKCk7Cit9CisKKworLyoKKyAqIExvb2t1cCB0aGUgaGFzaCB0YWJsZSBhbmQg
aXRzIGNvbGxpc2lvbiBjaGFpbiB0byBmaW5kIGFuIGVudHJ5CisgKiBjb3ZlcmluZyB0aGlzIGFk
ZHJlc3MgcmlkOnZhIG9yIHRoZSBlbnRyeS4KKyAqCisgKiBJTlBVVDoKKyAqICBpbjogVExCIGZv
cm1hdCBmb3IgYm90aCBWSFBUICYgVExCLgorICovCisKK3RoYXNoX2RhdGFfdCAqdnRsYl9sb29r
dXAoVkNQVSAqdiwgdTY0IHZhLCBpbnQgaXNfZGF0YSkKK3sKKwl0aGFzaF9kYXRhX3QgICpjY2g7
CisJdTY0ICAgICBwc2JpdHMsIHBzLCB0YWc7CisJaWE2NF9yciB2cnI7CisKKwl0aGFzaF9jYl90
ICpoY2IgPSAmdi0+YXJjaC52dGxiOworCisJY2NoID0gX192dHJfbG9va3VwKHYsIHZhLCBpc19k
YXRhKTs7CisJaWYgKGNjaCkKKwkJcmV0dXJuIGNjaDsKKworCWlmICh2Y3B1X3F1aWNrX3JlZ2lv
bl9jaGVjayh2LT5hcmNoLnRjX3JlZ2lvbnMsIHZhKSA9PSAwKQorCQlyZXR1cm4gTlVMTDsKKwor
CXBzYml0cyA9IFZNWCh2LCBwc2JpdHNbKHZhID4+IDYxKV0pOworCXZyci52YWwgPSB2Y3B1X2dl
dF9ycih2LCB2YSk7CisJd2hpbGUgKHBzYml0cykgeworCQlwcyA9IF9fZmZzKHBzYml0cyk7CisJ
CXBzYml0cyAmPSB+KDFVTCA8PCBwcyk7CisJCXZyci5wcyA9IHBzOworCQljY2ggPSB2c2FfdGhh
c2goaGNiLT5wdGEsIHZhLCB2cnIudmFsLCAmdGFnKTsKKwkJaWYgKGNjaC0+ZXRhZyA9PSB0YWcg
JiYgY2NoLT5wcyA9PSBwcykKKwkJCXJldHVybiBjY2g7CisJfQorCisJcmV0dXJuIE5VTEw7Cit9
CisKKworLyoKKyAqIEluaXRpYWxpemUgaW50ZXJuYWwgY29udHJvbCBkYXRhIGJlZm9yZSBzZXJ2
aWNlLgorICovCit2b2lkIHRoYXNoX2luaXQodGhhc2hfY2JfdCAqaGNiLCB1NjQgc3opCit7CisJ
aW50IGk7CisJdGhhc2hfZGF0YV90ICpoZWFkOworCisJaGNiLT5wdGEudmFsID0gKHVuc2lnbmVk
IGxvbmcpaGNiLT5oYXNoOworCWhjYi0+cHRhLnZmID0gMTsKKwloY2ItPnB0YS52ZSA9IDE7CisJ
aGNiLT5wdGEuc2l6ZSA9IHN6OworCWhlYWQgPSBoY2ItPmhhc2g7CisJZm9yIChpID0gMDsgaSA8
IGhjYi0+bnVtOyBpKyspIHsKKwkJaGVhZC0+cGFnZV9mbGFncyA9IDA7CisJCWhlYWQtPml0aXIg
PSAwOworCQloZWFkLT5ldGFnID0gSU5WQUxJRF9USV9UQUc7CisJCWhlYWQtPm5leHQgPSAwOwor
CQloZWFkKys7CisJfQorfQorCit1NjQga3ZtX2xvb2t1cF9tcGEodTY0IGdwZm4pCit7CisJdTY0
ICpiYXNlID0gKHU2NCAqKSBLVk1fUDJNX0JBU0U7CisJcmV0dXJuICooYmFzZSArIGdwZm4pOwor
fQorCit1NjQga3ZtX2dwYV90b19tcGEodTY0IGdwYSkKK3sKKwl1NjQgcHRlID0ga3ZtX2xvb2t1
cF9tcGEoZ3BhID4+IFBBR0VfU0hJRlQpOworCXJldHVybiAocHRlID4+IFBBR0VfU0hJRlQgPDwg
UEFHRV9TSElGVCkgfCAoZ3BhICYgflBBR0VfTUFTSyk7Cit9CisKKworLyoKKyAqIEZldGNoIGd1
ZXN0IGJ1bmRsZSBjb2RlLgorICogSU5QVVQ6CisgKiAgZ2lwOiBndWVzdCBpcAorICogIHBidW5k
bGU6IHVzZWQgdG8gcmV0dXJuIGZldGNoZWQgYnVuZGxlLgorICovCitpbnQgZmV0Y2hfY29kZShW
Q1BVICp2Y3B1LCB1NjQgZ2lwLCBJQTY0X0JVTkRMRSAqcGJ1bmRsZSkKK3sKKwl1NjQgICAgIGdw
aXAgPSAwOyAgIC8qIGd1ZXN0IHBoeXNpY2FsIElQKi8KKwl1NjQgICAgICp2cGE7CisJdGhhc2hf
ZGF0YV90ICAgICp0bGI7CisJdTY0ICAgICBtYWRkcjsKKworCWlmICghKFZDUFUodmNwdSwgdnBz
cikgJiBJQTY0X1BTUl9JVCkpIHsKKwkJLyogSS1zaWRlIHBoeXNpY2FsIG1vZGUgKi8KKwkJZ3Bp
cCA9IGdpcDsKKwl9IGVsc2UgeworCQl0bGIgPSB2dGxiX2xvb2t1cCh2Y3B1LCBnaXAsIElfVExC
KTsKKwkJaWYgKHRsYikKKwkJCWdwaXAgPSAodGxiLT5wcG4gPj4gKHRsYi0+cHMgLSAxMikgPDwg
dGxiLT5wcykgfAorCQkJCShnaXAgJiAoUFNJWkUodGxiLT5wcykgLSAxKSk7CisJfQorCWlmIChn
cGlwKSB7CisJCW1hZGRyID0ga3ZtX2dwYV90b19tcGEoZ3BpcCk7CisJfSBlbHNlIHsKKwkJdGxi
ID0gdmhwdF9sb29rdXAoZ2lwKTsKKwkJaWYgKHRsYiA9PSBOVUxMKSB7CisJCQlpYTY0X3B0Y2wo
Z2lwLCBBUkNIX1BBR0VfU0hJRlQgPDwgMik7CisJCQlyZXR1cm4gSUE2NF9GQVVMVDsKKwkJfQor
CQltYWRkciA9ICh0bGItPnBwbiA+PiAodGxiLT5wcyAtIDEyKSA8PCB0bGItPnBzKQorCQkJCQl8
IChnaXAgJiAoUFNJWkUodGxiLT5wcykgLSAxKSk7CisJfQorCXZwYSA9ICh1NjQgKilfX2t2bV92
YShtYWRkcik7CisKKwlwYnVuZGxlLT5pNjRbMF0gPSAqdnBhKys7CisJcGJ1bmRsZS0+aTY0WzFd
ID0gKnZwYTsKKworCXJldHVybiBJQTY0X05PX0ZBVUxUOworfQorCisKK3ZvaWQga3ZtX2luaXRf
dmhwdChWQ1BVICp2KQoreworCXYtPmFyY2gudmhwdC5udW0gPSBWSFBUX05VTV9FTlRSSUVTOwor
CXRoYXNoX2luaXQoJnYtPmFyY2gudmhwdCwgVkhQVF9TSElGVCk7CisJaWE2NF9zZXRfcHRhKHYt
PmFyY2gudmhwdC5wdGEudmFsKTsKKwkvKkVuYWJsZSBWSFBUIGhlcmU/Ki8KK30KKwordm9pZCBr
dm1faW5pdF92dGxiKFZDUFUgKnYpCit7CisJdi0+YXJjaC52dGxiLm51bSA9IFZUTEJfTlVNX0VO
VFJJRVM7CisJdGhhc2hfaW5pdCgmdi0+YXJjaC52dGxiLCBWVExCX1NISUZUKTsKK30KLS0gCjEu
NS4xCgo=

------_=_NextPart_001_01C863F4.2FE684CB--
