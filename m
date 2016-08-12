From: Borislav Petkov <bp@alien8.de>
Date: Fri, 12 Aug 2016 07:25:07 +0000
Subject: Re: [RFC v3 07/13] tables.h: add linker table support
Message-Id: <20160812072507.GC12013@nazgul.tnic>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
 <1469222687-1600-8-git-send-email-mcgrof@kernel.org>
 <20160729100630.GA27271@nazgul.tnic>
 <20160808150539.GG3296@wotan.suse.de>
 <20160809035508.GC11445@nazgul.tnic>
 <20160812035129.GA3296@wotan.suse.de>
 <20160812052303.GB12013@nazgul.tnic>
 <20160812065011.GB3296@wotan.suse.de>
In-Reply-To: <20160812065011.GB3296@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-

On Fri, Aug 12, 2016 at 08:50:11AM +0200, Luis R. Rodriguez wrote:
> On Fri, Aug 12, 2016 at 07:23:03AM +0200, Borislav Petkov wrote:
> > On Fri, Aug 12, 2016 at 05:51:29AM +0200, Luis R. Rodriguez wrote:
> > > OK I've added CONFIG_BUILD_AVOID_BITROT.
> > 
> > What does that do?
> 
> 
> Enabling it allows the forced compilation chosen by maintainers.
> Otherwise forced compilations with the new special targets are
> ignored.

Nice.

> I've gone with table-obj-y and table-lib-y as we have
> to support both lib-y and obj-y respective targets.
> 
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index 33e2966dd741..7893e3b8da82 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -1895,6 +1895,30 @@ config PROVIDE_OHCI1394_DMA_INIT
>  
>  	  See Documentation/debugging-via-ohci1394.txt for more information.
>  
> +config BUILD_AVOID_BITROT
> +	bool "Always force building specially annotated"

					   ...annotated targets"

> +	default y
> +	help
> +	  If enabled then the the special table-* Makefile targets will always
> +	  be forced to be compiled even if their respective CONFIG_ option has
> +	  been disabled, but its objects will only be linked in if the same
> +	  respective CONFIG_ option has been enabled. This helps avoid code
> +	  bit rot issues, use for these targets should be carefully considred
> +	  by maintainers. You can safely enable this option at the expense of
> +	  increasing compile time slightly. Enabling this option helps avoid

s/slightly//

:-)

> +	  code bit rot by taking advantage of the facilities provided and
> +	  enabled by using linker tables documented under:
> +
> +	  include/linux/tables.h
> +
> +	  The special targets supported are:
> +
> +	    o table-obj-y
> +	    o table-lib-y
> +
> +	  Say Y unless you are a grumpy maintainer and don't trust other
> +	  maintainer's judgements on what code should always get compiled.

... or you're running a tiny-config setup
... or you're an embedded, resource-constrained person
... or you simply don't want to have stuff which is forcibly enabled on you even
if you're never going to need it
...

I got a million o'those :-)

Thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--
