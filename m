From: Jes Sorensen <jes@sgi.com>
Date: Mon, 31 Mar 2008 09:12:56 +0000
Subject: Re: [02/17][PATCH] Implement smp_call_function_mask for ia64 - V8
Message-Id: <47F0AB18.2010707@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDC01048240@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDC01048240@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, Akio Takebe <takebe_akio@jp.fujitsu.com>, kvm-devel@lists.sourceforge.net, kvm-ia64-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, virtualization@lists.linux-foundation.org, Carsten Otte <cotte@de.ibm.com>

Zhang, Xiantao wrote:
>>From 697d50286088e98da5ac8653c80aaa96c81abf87 Mon Sep 17 00:00:00 2001
> From: Xiantao Zhang <xiantao.zhang@intel.com>
> Date: Mon, 31 Mar 2008 09:50:24 +0800
> Subject: [PATCH] KVM:IA64: Implement smp_call_function_mask for ia64
> 
> This function provides more flexible interface for smp
> infrastructure.
> Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>

Hi Xiantao,

I'm a little wary of the performance impact of this change. Doing a
cpumask compare on all smp_call_function calls seems a little expensive.
Maybe it's just noise in the big picture compared to the actual cost of
the IPIs, but I thought I'd bring it up.

Keep in mind that a cpumask can be fairly big these days, max NR_CPUS
is currently 4096. For those booting a kernel with NR_CPUS at 4096 on
a dual CPU machine, it would be a bit expensive.

Why not keep smp_call_function() the way it was before, rather than
implementing it via the call to smp_call_function_mask()?

Cheers,
Jes
