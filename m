From: Len Brown <lenb@kernel.org>
Date: Tue, 04 Dec 2007 06:22:07 +0000
Subject: Re: [PATCH with title] priority fix in acpi_map_lsapic()  arch/ia64/kernel/acpi.c
Message-Id: <200712040122.07391.lenb@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <473CC232.6020901@tiscali.nl> <473CC907.4040106@tiscali.nl> <20071120065145.GB10490@verge.net.au>
In-Reply-To: <20071120065145.GB10490@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Roel Kluin <12o3l@tiscali.nl>, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org

Applied.

thanks,
-Len

On Tuesday 20 November 2007 01:51, Simon Horman wrote:
> On Thu, Nov 15, 2007 at 11:32:39PM +0100, Roel Kluin wrote:
> > As above should have been its title.
> > 
> > Roel Kluin wrote:
> > > I have sent this patch before to lkml, but it appears it wasn't picked up. Also
> > > I have to admit this isn't tested. This is a patch against linus' tree.
> > > 
> > > ACPI_MADT_ENABLED is defined 1    (include/acpi/actbl1.h 501)
> > > lapic_flags: an u32 of struct acpi_madt_local_sapic (include/acpi/actbl1.h 467)
> > > --
> > > '!' has a higher priority than '&', so as was
> > > this won't test the first bit, but rather evaluates to false for any non-zero
> > > lsapic->lapic_flags.
> > > 
> > > Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
> 
> This looks correct to me, though I was curious to know why
> the problem wasn't manifesting in a bug. I investigated
> a bit and found that it seems that the only values
> lapic_flags currently takes are 0 and ACPI_MADT_ENABLED,
> so it turns out that the bogus logic actually gives the correct result
> (by chance).
> 
> Acked-by: Simon Horman <horms@verge.net.au>
> 
> > > ---
> > > diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
> > > index 3d45d24..7d78d22 100644
> > > --- a/arch/ia64/kernel/acpi.c
> > > +++ b/arch/ia64/kernel/acpi.c
> > > @@ -858,7 +858,7 @@ int acpi_map_lsapic(acpi_handle handle, int *pcpu)
> > >  	lsapic = (struct acpi_madt_local_sapic *)obj->buffer.pointer;
> > >  
> > >  	if ((lsapic->header.type != ACPI_MADT_TYPE_LOCAL_SAPIC) ||
> > > -	    (!lsapic->lapic_flags & ACPI_MADT_ENABLED)) {
> > > +	    (!(lsapic->lapic_flags & ACPI_MADT_ENABLED))) {
> > >  		kfree(buffer.pointer);
> > >  		return -EINVAL;
> > >  	}
> > > 
> 
