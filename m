From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Fri, 12 Aug 2016 15:28:05 +0000
Subject: Re: [RFC v3 07/13] tables.h: add linker table support
Message-Id: <20160812152805.GD3296@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
 <1469222687-1600-8-git-send-email-mcgrof@kernel.org>
 <20160729100630.GA27271@nazgul.tnic>
 <20160808150539.GG3296@wotan.suse.de>
 <20160809035508.GC11445@nazgul.tnic>
 <20160812035129.GA3296@wotan.suse.de>
 <20160812052303.GB12013@nazgul.tnic>
 <20160812065011.GB3296@wotan.suse.de>
 <20160812072507.GC12013@nazgul.tnic>
In-Reply-To: <20160812072507.GC12013@nazgul.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Borislav Petkov <bp@alien8.de>
Cc: gnomes@lxorguk.ukuu.org.uk, linux-ia64@vger.kernel.org, jkosina@suse.cz, benh@kernel.crashing.org, ming.lei@canonical.com, heiko.carstens@de.ibm.com, platform-driver-x86@vger.kernel.org, paul.gortmaker@windriver.com, hpa@zytor.com, masami.hiramatsu.pt@hitachi.com, linux-arch@vger.kernel.org, sparclinux@vger.kernel.org, xen-devel@lists.xensource.com, linux@arm.linux.org.uk, linux-sh@vger.kernel.org, will.deacon@arm.com, korea.drzix@gmail.com, x86@kernel.org, anil.s.keshavamurthy@intel.com, fontana@sharpeleven.org, torvalds@linux-foundation.org, mingo@redhat.com, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, dvhart@infradead.org, david.vrabel@citrix.com, pali.rohar@gmail.com, keescook@chromium.org, arnd@arndb.de, realmz6@gmail.com, linux@rasmusvillemoes.dk, rusty@rustcorp.com.au, rostedt@goodmis.org, christopher.denicolo@suse.com, jbaron@akamai.com

On Fri, Aug 12, 2016 at 09:25:07AM +0200, Borislav Petkov wrote:
> On Fri, Aug 12, 2016 at 08:50:11AM +0200, Luis R. Rodriguez wrote:
> > On Fri, Aug 12, 2016 at 07:23:03AM +0200, Borislav Petkov wrote:
> > > On Fri, Aug 12, 2016 at 05:51:29AM +0200, Luis R. Rodriguez wrote:
> > > > OK I've added CONFIG_BUILD_AVOID_BITROT.
> > > 
> > > What does that do?
> > 
> > 
> > Enabling it allows the forced compilation chosen by maintainers.
> > Otherwise forced compilations with the new special targets are
> > ignored.
> 
> Nice.
> 
> > I've gone with table-obj-y and table-lib-y as we have
> > to support both lib-y and obj-y respective targets.
> > 
> > diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> > index 33e2966dd741..7893e3b8da82 100644
> > --- a/lib/Kconfig.debug
> > +++ b/lib/Kconfig.debug
> > @@ -1895,6 +1895,30 @@ config PROVIDE_OHCI1394_DMA_INIT
> >  
> >  	  See Documentation/debugging-via-ohci1394.txt for more information.
> >  
> > +config BUILD_AVOID_BITROT
> > +	bool "Always force building specially annotated"
> 
> 					   ...annotated targets"
> 
> > +	default y
> > +	help
> > +	  If enabled then the the special table-* Makefile targets will always
> > +	  be forced to be compiled even if their respective CONFIG_ option has
> > +	  been disabled, but its objects will only be linked in if the same
> > +	  respective CONFIG_ option has been enabled. This helps avoid code
> > +	  bit rot issues, use for these targets should be carefully considred
> > +	  by maintainers. You can safely enable this option at the expense of
> > +	  increasing compile time slightly. Enabling this option helps avoid
> 
> s/slightly//
> 
> :-)
> 
> > +	  code bit rot by taking advantage of the facilities provided and
> > +	  enabled by using linker tables documented under:
> > +
> > +	  include/linux/tables.h
> > +
> > +	  The special targets supported are:
> > +
> > +	    o table-obj-y
> > +	    o table-lib-y
> > +
> > +	  Say Y unless you are a grumpy maintainer and don't trust other
> > +	  maintainer's judgements on what code should always get compiled.
> 
> ... or you're running a tiny-config setup

Even so, you don't link the compiled extra code so the only penalty
here is when compiling, nothing more. And if you are compiling typically
the cost here is just a few seconds.

> ... or you're an embedded, resource-constrained person

For the compilation of th kernel ?

> ... or you simply don't want to have stuff which is forcibly enabled on you even
> if you're never going to need it
> ...

Which seems to be the same as the reason I noted ?

> I got a million o'those :-)

I can remove the grumpy maintainer description :)

 Luis
