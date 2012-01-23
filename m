From: Myron Stowe <mstowe@redhat.com>
Date: Mon, 23 Jan 2012 17:48:12 +0000
Subject: Re: [PATCH 2/3] ACPI, APEI: Add RAM mapping support to ACPI
Message-Id: <1327340892.2390.84.camel@zim.stowe>
List-Id: <linux-ia64.vger.kernel.org>
References: <201201231651.23270.trenn@suse.de>
In-Reply-To: <201201231651.23270.trenn@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Renninger <trenn@suse.de>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Myron Stowe <myron.stowe@redhat.com>, lenb@kernel.org, linux-acpi@vger.kernel.org, rjw@sisk.pl, ying.huang@intel.com, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

On Mon, 2012-01-23 at 16:51 +0100, Thomas Renninger wrote:
> Hi,
> 
> Please ignore my previous mail, my mailer wrongly formatted
> it with html tags and it got filtered out from the lists.
> 
> Firstly: This has to get in quickly if it shouldn't miss
> 3.3 (again). Tiny adjustings (I don't see any, beside the
> issue Bjorn brought up) can still be done later, but I
> guess this rather big one gets rejected by Linus after
> the merge window closed.

Yes, I believe the obsolescence of atomicio.c from having taken the
conversion patch (patch 3/4 of the series) was inadvertent.  As such I
was trying to help by producing a series that addresses the two recent
additions to atomicio.c that needed ported over to osl.c so that we
would not loose such functionality with atomicio's obsolence as fast as
possible.  Linus may not allow such now that the 3.3 merge window is
closed but I think we all are thinking we should at least attempt to get
the regressions resolved immediately if possible.
> 
> Here again:
> 
> On Saturday, January 21, 2012 09:38:27 PM Bjorn Helgaas wrote:
> > +cc Tony, linux-ia64
> > 
> ...
> > >>  {
> > >> @@ -353,7 +385,7 @@ acpi_os_map_memory(acpi_physical_address phys, acpi_size size)
> > >>
> > >>        pg_off = round_down(phys, PAGE_SIZE);
> > >>        pg_sz = round_up(phys + size, PAGE_SIZE) - pg_off;
> > >> -       virt = acpi_os_ioremap(pg_off, pg_sz);
> > >> +       virt = acpi_map(pg_off, pg_sz);
> Ok, that worked before, also on IA64.
> That means that typically/normally/always io mem is tried to be mapped.
> 
> It's due to the new APEI infrastructure/features that ram could
> get mapped via acpi_os_map_memory.
> 
> Is there any Itanium out there implementing any APEI table?
> Will there ever be one?
> Even if, isn't it a BIOS bug if such stuff is declared in ram and not
> in reserved memory (also on X86)?
> Especially on an Enterprise Itanium platform,
> I guess the vendor should or better has to fix it up.
> 
> I'd do:
> can_use_ioremap(pfn) instead of should_use_kmap(pfn)
> and let it return false in ram + ia64 case, something like:
> #ifdef IA64
> #define can_use_ioremap(pfn)   !page_is_ram(pfn)
> #endif
> 
> Pass the error upwards and APEI should get disabled on IA64,
> if any ACPI code tries to ioremap real memory early (when
> the APEI table parsing happens).
> A nice FW_BUG message could be added as well (also on X86?).
> 
> Don't forget to use:
> iounmap(vaddr);
> only in acpi_unmap() then.

I must admit, while I understand the reason and concept related to
handling RAM for APEI, I do not understand memory management well enough
understand the details of the original implementation.  I was just
trying to cross-port the functionality over.  In doing such, I too, was
concerned as to the asymmetric nature of the paths (mapping vs.
unmapping) with respect to x86 as it just *felt* wrong.

Len - please let me know if you want me to adjust the patch with Thomas'
suggestions.

> 
> FWIW I even grepped for APEI tables on the most recent IA
> machine we have -> no APEI tables.
> 
> If the rest is functionally the same as the patch series
> you've send some months ago, feel free to add:
> 
> Reviewed-by: Thomas Renninger <trenn@suse.de>
> 
> I had a rather close look at those patches.

Thanks Thomas - yes, the removal patch - 3/3 - is the same.

Myron
> 
>    Thomas


