From: Akio Takebe <takebe_akio@jp.fujitsu.com>
Date: Fri, 01 Feb 2008 03:58:30 +0000
Subject: Re: [kvm-ia64-devel] [PATCH][10] Add TLB virtulization support.
Message-Id: <B7C86486B5373Atakebe_akio@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCD31FCD@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCD31FCD-wq7ZOvIWXbMAbVU2wMM1CrfspsVTdybXVpNB7YpNyf8@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Xu, Anthony" <anthony.xu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-ia64-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org

Hi, Xiantao

>+void thash_vhpt_insert(VCPU *v, u64 pte, u64 itir, u64 va, int type)
>+{
>+	u64 phy_pte, psr;
>+	ia64_rr mrr;
>+
>+	mrr.val = ia64_get_rr(va);
>+	phy_pte = translate_phy_pte(&pte, itir, va);
>+
>+	if (itir_ps(itir) >= mrr.ps) {
>+		vhpt_insert(phy_pte, itir, va, pte);
>+	} else {
>+		phy_pte  &= ~PAGE_FLAGS_RV_MASK;
>+		psr = ia64_clear_ic();
>+		ia64_itc(type, va, phy_pte, itir_ps(itir));
>+		ia64_set_psr(psr);
>+		ia64_srlz_i();
>+	}
>+}
You add ia64_srlz_i() into ia64_set_psr() with [02]patch.
So is this a redundancy if the patch is applied?


>+ */
>+int thash_purge_and_insert(VCPU *v, u64 pte, u64 itir, u64 ifa, int
>type)
>+{
>+	u64 ps;
>+	u64 phy_pte;
>+	ia64_rr vrr, mrr;
>+	int ret = 0;
>+
>+	ps = itir_ps(itir);
>+	vrr.val = vcpu_get_rr(v, ifa);
>+	mrr.val = ia64_get_rr(ifa);
>+
>+	phy_pte = translate_phy_pte(&pte, itir, ifa);
>+
>+	/* Ensure WB attribute if pte is related to a normal mem page,
>+	 * which is required by vga acceleration since qemu maps shared
>+	 * vram buffer with WB.
>+	 */
>+	if (!(pte & VTLB_PTE_IO) && ((pte & _PAGE_MA_MASK) !>_PAGE_MA_NAT)) {
>+		pte &= ~_PAGE_MA_MASK;
>+		phy_pte &= ~_PAGE_MA_MASK;
>+	}
>+
>+	if (pte & VTLB_PTE_IO)
>+		ret = 1;
>+
>+	vtlb_purge(v, ifa, ps);
>+	vhpt_purge(v, ifa, ps);
>+
>+	if (ps = mrr.ps) {
>+		if (!(pte&VTLB_PTE_IO)) {
>+			vhpt_insert(phy_pte, itir, ifa, pte);
>+		} else {
>+			vtlb_insert(v, pte, itir, ifa);
>+			vcpu_quick_region_set(VMX(v, tc_regions), ifa);
>+		}
>+	} else if (ps > mrr.ps) {
>+		vtlb_insert(v, pte, itir, ifa);
>+		vcpu_quick_region_set(VMX(v, tc_regions), ifa);
>+		if (!(pte&VTLB_PTE_IO))
>+			vhpt_insert(phy_pte, itir, ifa, pte);
>+	} else {
>+		u64 psr;
>+		phy_pte  &= ~PAGE_FLAGS_RV_MASK;
>+		psr = ia64_clear_ic();
>+		ia64_itc(type, ifa, phy_pte, ps);
>+		ia64_set_psr(psr);
>+		ia64_srlz_i();
>+	}
>+
>+	return ret;
>+}
ditto

Best Regards,

Akio Takebe

