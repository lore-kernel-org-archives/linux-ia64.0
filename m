From: Kees Cook <keescook@chromium.org>
Date: Tue, 01 Oct 2019 15:48:11 +0000
Subject: Re: [PATCH 18/29] arm64: Move EXCEPTION_TABLE to RO_DATA segment
Message-Id: <201910010846.D0712C1@keescook>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190926175602.33098-1-keescook@chromium.org>
 <20190926175602.33098-19-keescook@chromium.org>
 <20191001090355.blnaqlf4rfzucpb2@willie-the-truck>
In-Reply-To: <20191001090355.blnaqlf4rfzucpb2@willie-the-truck>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michal Simek <monstr@monstr.eu>, linux-parisc@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 01, 2019 at 10:03:56AM +0100, Will Deacon wrote:
> Hi Kees,
> 
> On Thu, Sep 26, 2019 at 10:55:51AM -0700, Kees Cook wrote:
> > The EXCEPTION_TABLE is read-only, so collapse it into RO_DATA.
> > 
> > Signed-off-by: Kees Cook <keescook@chromium.org>
> > ---
> >  arch/arm64/kernel/vmlinux.lds.S | 6 ++++--
> >  1 file changed, 4 insertions(+), 2 deletions(-)
> > 
> > diff --git a/arch/arm64/kernel/vmlinux.lds.S b/arch/arm64/kernel/vmlinux.lds.S
> > index 81d94e371c95..c6ba2eee0ee8 100644
> > --- a/arch/arm64/kernel/vmlinux.lds.S
> > +++ b/arch/arm64/kernel/vmlinux.lds.S
> > @@ -5,6 +5,8 @@
> >   * Written by Martin Mares <mj@atrey.karlin.mff.cuni.cz>
> >   */
> >  
> > +#define RO_DATA_EXCEPTION_TABLE_ALIGN	8
> > +
> >  #include <asm-generic/vmlinux.lds.h>
> >  #include <asm/cache.h>
> >  #include <asm/kernel-pgtable.h>
> > @@ -135,8 +137,8 @@ SECTIONS
> >  	. = ALIGN(SEGMENT_ALIGN);
> >  	_etext = .;			/* End of text section */
> >  
> > -	RO_DATA(PAGE_SIZE)		/* everything from this point to     */
> > -	EXCEPTION_TABLE(8)		/* __init_begin will be marked RO NX */
> > +	/* everything from this point to __init_begin will be marked RO NX */
> > +	RO_DATA(PAGE_SIZE)
> >  
> >  	. = ALIGN(PAGE_SIZE);
> 
> Do you reckon it would be worth merging this last ALIGN directive into the
> RO_DATA definition too? Given that we want to map the thing read-only, it
> really has to be aligned either side.

Actually, taking a closer look, this appears to be redundant: RO_DATA()
ends with:

	. = ALIGN(align)

(where "align" is the "PAGE_SIZE" argument to RO_DATA())

> Anyway, that's only a nit, so:
> 
> Acked-by: Will Deacon <will@kernel.org>

Thanks!

> P.S. Please CC the arm64 maintainers on arm64 patches -- I nearly missed
> this one!

Okay, I can re-expand my list. I originally had done this but it was
getting to be a rather large set of people. :)

-- 
Kees Cook
