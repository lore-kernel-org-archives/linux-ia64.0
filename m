From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Fri, 01 Feb 2008 04:01:07 +0000
Subject: RE: [kvm-ia64-devel] [PATCH][10] Add TLB virtulization support.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCD321C7@pdsmsx415.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCD31FCD@pdsmsx415.ccr.corp.intel.com> <B7C86486B5373Atakebe_akio@jp.fujitsu.com>
In-Reply-To: <B7C86486B5373Atakebe_akio@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Akio Takebe <takebe_akio@jp.fujitsu.com>, Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>
Cc: kvm-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, kvm-ia64-devel@lists.sourceforge.net

Akio Takebe wrote:
> Hi, Xiantao
> 
>> +void thash_vhpt_insert(VCPU *v, u64 pte, u64 itir, u64 va, int
>> type) +{ +	u64 phy_pte, psr;
>> +	ia64_rr mrr;
>> +
>> +	mrr.val = ia64_get_rr(va);
>> +	phy_pte = translate_phy_pte(&pte, itir, va);
>> +
>> +	if (itir_ps(itir) >= mrr.ps) {
>> +		vhpt_insert(phy_pte, itir, va, pte);
>> +	} else {
>> +		phy_pte  &= ~PAGE_FLAGS_RV_MASK;
>> +		psr = ia64_clear_ic();
>> +		ia64_itc(type, va, phy_pte, itir_ps(itir));
>> +		ia64_set_psr(psr);
>> +		ia64_srlz_i();
>> +	}
>> +}
> You add ia64_srlz_i() into ia64_set_psr() with [02]patch.
> So is this a redundancy if the patch is applied?

Yes, we need to remove it. Once the second patch is picked up.  Thanks
Xiantao
