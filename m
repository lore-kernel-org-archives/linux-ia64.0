From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 08 Feb 2006 02:58:42 +0000
Subject: RE: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <200602080258.k182wgg27146@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <10378.1139366890@kao2.melbourne.sgi.com>
References: <20060207231713.GG3524@stusta.de>
In-Reply-To: <20060207231713.GG3524@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Keith Owens' <kaos@sgi.com>
Cc: 'Adrian Bunk' <bunk@stusta.de>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Keith Owens wrote on Tuesday, February 07, 2006 6:48 PM
> >You patch does more than what you described and is wrong.  Selecting
> >platform type should not be tied into selecting SMP nor should it tied
> >with processor type, nor should it tied with ARCH_FLATMEM_ENABLE.  All
> >of them are orthogonal and independent.
> 
> Blame me for the SMP bit.  I have a dim, distant memory that Intel
> required all IA64 boxes to be SMP, but I could be wrong.  Also it is
> almost pointless to do a generic build which pulls in NUMA etc.,
> without also including SMP.

I'm not disagreeing with the SMP bit.  In my very first reply, I
disagree with the hunk that disable CONFIG_MCKINLEY for CONFIG_IA64_GENERIC.
People tends to mix the terminology, CONFIG_IA64_GENERIC is a
platform type choice, it is a sub-requirement for building a
kernel that boots everywhere.  People keeps on promoting the
config option.

- Ken


Excerpt from earlier email:

> --- linux-2.6.16-rc1-mm5-ia64/arch/ia64/Kconfig.old
> +++ linux-2.6.16-rc1-mm5-ia64/arch/ia64/Kconfig
> @@ -132,10 +134,11 @@
>  	  This choice is safe for all IA-64 systems, but may not perform
>  	  optimally on systems with, say, Itanium 2 or newer processors.
>  
>  config MCKINLEY
>  	bool "Itanium 2"
> +	depends on IA64_GENERIC=n
>  	help
>  	  Select this to configure for an Itanium 2 (McKinley) processor.
>  
>  endchoice
>  

This hunk does not make any logical sense.  Select generic system type
does not mean Itanium processor is the only choice I can have.  What's
wrong with having an option that works just fine right now?

