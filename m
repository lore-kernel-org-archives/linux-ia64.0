From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 05 Dec 2007 23:17:33 +0000
Subject: Re: [patch 2/3] ia64: don't assume that unwcheck.py is executable
Message-Id: <20071205151733.86182901.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200712052232.lB5MWE3W028394@imap1.linux-foundation.org>
In-Reply-To: <200712052232.lB5MWE3W028394@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 06 Dec 2007 00:06:14 +0100
Andreas Schwab <schwab@suse.de> wrote:

> akpm@linux-foundation.org writes:
> 
> > diff -puN arch/ia64/Makefile~ia64-dont-assume-that-unwcheckpy-is-executable arch/ia64/Makefile
> > --- a/arch/ia64/Makefile~ia64-dont-assume-that-unwcheckpy-is-executable
> > +++ a/arch/ia64/Makefile
> > @@ -77,7 +77,7 @@ vmlinux.gz: vmlinux
> >  	$(Q)$(MAKE) $(build)=$(boot) $@
> >  
> >  unwcheck: vmlinux
> > -	-$(Q)READELF=$(READELF) $(srctree)/arch/ia64/scripts/unwcheck.py $<
> > +	-$(Q)READELF=$(READELF) $(CONFIG_SHELL) $(srctree)/arch/ia64/scripts/unwcheck.py $<
> 
> unwcheck.py is not a shell script.
> 

Oh well, whatever.  Please treat this as a bug report.

ie: someone please fix it.
