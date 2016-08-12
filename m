From: Borislav Petkov <bp@alien8.de>
Date: Fri, 12 Aug 2016 17:35:07 +0000
Subject: Re: [RFC v3 07/13] tables.h: add linker table support
Message-Id: <20160812173507.GC13315@nazgul.tnic>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160729100630.GA27271@nazgul.tnic>
 <20160808150539.GG3296@wotan.suse.de>
 <20160809035508.GC11445@nazgul.tnic>
 <20160812035129.GA3296@wotan.suse.de>
 <20160812052303.GB12013@nazgul.tnic>
 <20160812065011.GB3296@wotan.suse.de>
 <20160812072507.GC12013@nazgul.tnic>
 <20160812152805.GD3296@wotan.suse.de>
 <20160812155121.GB13315@nazgul.tnic>
 <20160812170451.GE3296@wotan.suse.de>
In-Reply-To: <20160812170451.GE3296@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-

On Fri, Aug 12, 2016 at 07:04:52PM +0200, Luis R. Rodriguez wrote:
> Alright, how's this new description:
> 
> diff --git a/init/Kconfig b/init/Kconfig
> index cac3f096050d..73e4890c24c4 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -53,6 +53,34 @@ config CROSS_COMPILE
>  	  need to set this unless you want the configured kernel build
>  	  directory to select the cross-compiler automatically.
>  
> +config BUILD_AVOID_BITROT
> +	bool "Always force building specially annotated targets"
> +	default n
> +	help
> +	  If enabled then the the special table-* Makefile targets will always
> +	  be forced to be compiled even if their respective CONFIG_ option has

"will always be compiled" is already absolute.

> +	  been disabled, but its objects will only be linked in if the same
> +	  respective CONFIG_ option has been enabled. This helps avoid code
> +	  bit rot issues, use for these targets should be carefully considred

s/This helps avoid code bit rot issues, u/U/

The bit-rot thing comes again below.

> +	  by maintainers. You can safely enable this option at the expense of
> +	  increasing compile time. Enabling this option helps avoid code bit
> +	  rot by taking advantage of the facilities provided and enabled by
> +	  using linker tables documented under:
> +
> +	  include/linux/tables.h
> +
> +	  The special targets supported are:
> +
> +	    o table-obj-y
> +	    o table-lib-y
> +
> +	  Say Y if you have a decent build machine and would like to help test
> +	  building code for more subsystems. Say N if you do you not have a
> +	  good build machine or only want to compile what you've enabled for
> +	  your kernel.
> +
> +	  Enabling this option never increases the size of your kernel.
> +

Other than those minor formulation nits, yeah, nice!

Thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--
