From: Jes Sorensen <jes@sgi.com>
Date: Tue, 01 Apr 2008 08:49:39 +0000
Subject: Re: [07/17][PATCH] kvm/ia64: Add TLB virtulization support.-V8
Message-Id: <47F1F723.4010900@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDC0104824B@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDC0104824B@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, Akio Takebe <takebe_akio@jp.fujitsu.com>, kvm-devel@lists.sourceforge.net, kvm-ia64-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, virtualization@lists.linux-foundation.org, Carsten Otte <cotte@de.ibm.com>

Zhang, Xiantao wrote:
>>From 6b731c15afa8cec84f16408c421c286f1dd1b7d3 Mon Sep 17 00:00:00 2001
> From: Xiantao Zhang <xiantao.zhang@intel.com>
> Date: Wed, 12 Mar 2008 13:45:40 +0800
> Subject: [PATCH] KVM:IA64 : Add TLB virtulization support.
> 
> vtlb.c includes tlb/VHPT virtulization.
> Signed-off-by: Anthony Xu <anthony.xu@intel.com>
> Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>

Hi Xiantao,

Just a clarification question on this one:


> +void machine_tlb_purge(u64 va, u64 ps)
> +{
> +	ia64_ptcl(va, ps << 2);
> +}

What is the purpose of machine_tlb_purge()? Is it supposed to do a
global purge of the tlb on the host machine? If so, how does this macro
differ from platform_global_tlb_purge()?

I am mentioning this because it's very important to keep in mind that
the regular tlb purging instructions are not functional on all ia64
platforms, which is why we have special implementations via the
machine vector interface.

Cheers,
Jes
