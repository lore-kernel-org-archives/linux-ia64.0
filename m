From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 08 Feb 2006 00:52:59 +0000
Subject: RE: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <200602080052.k180qxg16788@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20060207231713.GG3524@stusta.de>
References: <20060207231713.GG3524@stusta.de>
In-Reply-To: <20060207231713.GG3524@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Adrian Bunk' <bunk@stusta.de>, Keith Owens <kaos@sgi.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Adrian Bunk wrote on Tuesday, February 07, 2006 3:17 PM
> IOW, you want the patch below?
> 

No, I really don't think so.


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

- Ken

