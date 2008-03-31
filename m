From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Mon, 31 Mar 2008 10:17:18 +0000
Subject: RE: [kvm-devel] [02/17][PATCH] Implement smp_call_function_mask foria64 - V8
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC010482D7@pdsmsx415.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDC01048240@pdsmsx415.ccr.corp.intel.com> <47F0AB18.2010707@sgi.com>
In-Reply-To: <47F0AB18.2010707@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: Carsten Otte <cotte@de.ibm.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, kvm-ia64-devel@lists.sourceforge.net, kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>, virtualization@lists.linux-foundation.org

Jes Sorensen wrote:
> Zhang, Xiantao wrote:
>>> From 697d50286088e98da5ac8653c80aaa96c81abf87 Mon Sep 17 00:00:00
>>> 2001 
>> From: Xiantao Zhang <xiantao.zhang@intel.com>
>> Date: Mon, 31 Mar 2008 09:50:24 +0800
>> Subject: [PATCH] KVM:IA64: Implement smp_call_function_mask for ia64
>> 
>> This function provides more flexible interface for smp
>> infrastructure. Signed-off-by: Xiantao Zhang
>> <xiantao.zhang@intel.com> 
> 
> Hi Xiantao,
> 
> I'm a little wary of the performance impact of this change. Doing a
> cpumask compare on all smp_call_function calls seems a little
> expensive. Maybe it's just noise in the big picture compared to the
> actual cost of the IPIs, but I thought I'd bring it up.
> Keep in mind that a cpumask can be fairly big these days, max NR_CPUS
> is currently 4096. For those booting a kernel with NR_CPUS at 4096 on
> a dual CPU machine, it would be a bit expensive.
> 
> Why not keep smp_call_function() the way it was before, rather than
> implementing it via the call to smp_call_function_mask()?

Hi, Jes
   I'm not aware of the performance impact before.  If the worst case
occurs,  it need 64 comparisions ?  Maybe keeping old smp_call_function
is better ? 
Xiantao
> 
>
------------------------------------------------------------------------
-
> Check out the new SourceForge.net Marketplace.
> It's the best place to buy or sell services for
> just about anything Open Source.
>
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketp
lace
> _______________________________________________
> kvm-devel mailing list
> kvm-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/kvm-devel

