From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Fri, 02 Mar 2001 01:00:44 +0000
Subject: RE: [Linux-ia64] CONFIG_IA64_L1_CACHE_SHIFT
Message-Id: <marc-linux-ia64-105590693005240@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005236@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005236@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Also this is configurable to take care of future processors that may have
higher cache line sizes.

Thanks,
Asit


> -----Original Message-----
> From: David Mosberger [mailto:davidm@hpl.hp.com]
> Sent: Thursday, March 01, 2001 2:35 PM
> To: Jes Sorensen
> Cc: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] CONFIG_IA64_L1_CACHE_SHIFT
> 
> 
> >>>>> On 01 Mar 2001 20:29:28 +0100, Jes Sorensen 
> <jes@linuxcare.com> said:
> 
>   Jes> Hi Anyone who can explain why there is a
> 
>   Jes> define_int CONFIG_IA64_L1_CACHE_SHIFT 6
> 
>   Jes> in the config file? We already have SMP_CACHE_BYTES and
>   Jes> L1_CACHE bytes for all architectures, it doesn't make a whole
>   Jes> lot of sense to me ot invent yet another alignment rule.
> 
> $ fgrep CONFIG_IA64_L1 include/asm-ia64/cache.h 
> #define L1_CACHE_SHIFT          CONFIG_IA64_L1_CACHE_SHIFT
> 
> 	--david
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

