From: Jiri Bohac <jbohac@suse.cz>
Date: Tue, 01 Sep 2009 11:35:18 +0000
Subject: Re: [RFC][PATCH] ia64: fix csum_ipv6_magic()
Message-Id: <20090901113518.GA4874@midget.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090827211113.GA22793@midget.suse.cz>
 <A6AD88C3F2289247BE726C37303E1EB8B954B4A6@orsmsx505.amr.corp.intel.com>
In-Reply-To: <A6AD88C3F2289247BE726C37303E1EB8B954B4A6@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Yu, Fenghua" <fenghua.yu@intel.com>
Cc: 'Jiri Bohac' <jbohac@suse.cz>, "Luck, Tony" <tony.luck@intel.com>, "'kenneth.w.chen@intel.com'" <kenneth.w.chen@intel.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-ia64@vger.kernel.org'" <linux-ia64@vger.kernel.org>

On Fri, Aug 28, 2009 at 02:19:19PM -0700, Yu, Fenghua wrote:
> >I was seeing "nf_ct_icmpv6: ICMPv6 checksum failed" errors on
> >every ICMPv6 packet received. The packets did not pass the
> >netfilter checksum verification but they did pass the standard
> >verification later and got processed. This happenns with hardware
> >checksumming turned off or with adapters that do not checksum
> >ICMP packets (e.g. tg3). I tracked the problem down to the ia64
> >version of csum_ipv6_magic() introduced by 007d77d0c5.  For some
> >arguments, it gives differrent results than the generic version.
> >
> >The following patch fixes the problem for me. IA64 experts, can
> >you please have a look?
> 
> Looks good to me. Do you know the caller function for the failed csum_ipv6_magic()?

I saw the problem when csum_ipv6_magic() was called from
nf_ip6_checksum(), in the CHECKSUM_NONE branch.

The the bug is triggered by having some bits set in the high
32-bits of the register used to pass the sum parameter to
csum_ipv6_magic().

For some reason, the 
	csum_sub(skb->csum, skb_checksum(skb, 0, dataoff, 0))
in the CHECKSUM_COMPLETE branch does not seem to trigger this,
while the
	csum_sub(0, skb_checksum(skb, 0, dataoff, 0))
in the CHECKSUM_NONE branch does.

I haven't looked at the disassembly to see why, though.

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

