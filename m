From: Matthew Wilcox <willy@debian.org>
Date: Sat, 17 Jan 2004 00:45:02 +0000
Subject: Re: [PATCH] Kconfig cleanup, part 1
Message-Id: <20040117004502.GB16779@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401161136.37066.bjorn.helgaas@hp.com>
In-Reply-To: <200401161136.37066.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jan 16, 2004 at 05:22:36PM -0700, Bjorn Helgaas wrote:
> Here comes the revised entire patch:
[...]
>  config 64BIT
> -	def_bool y
> +	bool
> +	default y
>  

Why make this change?  def_bool is shorter and (to my mind ;-) neater.

>  config ITANIUM_BSTEP_SPECIFIC
> -	bool "Enable Itanium B-step specific code"
> +	bool "Itanium B-step specific code"
>  	depends on ITANIUM
>  	help
>  	  Select this option to build a kernel for an Itanium prototype system
> @@ -198,38 +192,30 @@
>  
>  # align cache-sensitive data to 64 bytes
>  config MCKINLEY_ASTEP_SPECIFIC
> -	bool "Enable McKinley A-step specific code"
> +	bool "McKinley A-step specific code"
>  	depends on MCKINLEY
>  	help
>  	  Select this option to build a kernel for an IA-64 McKinley prototype
>  	  system with any A-stepping CPU.
>  
>  config MCKINLEY_A0_SPECIFIC
> -	bool "Enable McKinley A0/A1-step specific code"
> +	bool "McKinley A0/A1-step specific code"
>  	depends on MCKINLEY_ASTEP_SPECIFIC
>  	help
>  	  Select this option to build a kernel for an IA-64 McKinley prototype
>  	  system with an A0 or A1 stepping CPU.

Possibly we should kill these options and the code they enable now.  Is
anyone still using A-step McKinleys and B-step Merceds?

>  config NUMA
> -	bool "Enable NUMA support" if IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
> -	default y if IA64_SGI_SN2 || IA64_GENERIC
> +	bool "NUMA support"
> +	depends on !IA64_HP_SIM
> +	default y if IA64_SGI_SN2

Nice change, much more clear.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
