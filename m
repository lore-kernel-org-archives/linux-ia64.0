From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 14 Feb 2006 23:34:05 +0000
Subject: Re: [PATCH] ACPI: fix vendor resource length computation
Message-Id: <200602141634.06002.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <971FCB6690CD0E4898387DBF7552B90E045AABC5@orsmsx403.amr.corp.intel.com>
In-Reply-To: <971FCB6690CD0E4898387DBF7552B90E045AABC5@orsmsx403.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Moore, Robert" <robert.moore@intel.com>
Cc: Andreas Schwab <schwab@suse.de>, Thomas Renninger <trenn@suse.de>, "Luck, Tony" <tony.luck@intel.com>, "Brown, Len" <len.brown@intel.com>, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>, efocht@hpce.nec.com

On Tuesday 14 February 2006 16:25, Moore, Robert wrote:
> Does this fix all of the slab corruptions issues we have been hearing
> about?

It fixes the one I saw with 2.6.16-rc3 on HP rx7620.  I'm pretty sure
that's the same as the one Thomas observed in pci_acpi_scan_root() and
acpi_sba_ioc_add().

But I haven't been paying attention to any other slab corruption issues,
so I can't speculate about them.

> > -----Original Message-----
> > From: Bjorn Helgaas [mailto:bjorn.helgaas@hp.com]
> > Sent: Tuesday, February 14, 2006 3:13 PM
> > To: Andreas Schwab
> > Cc: Thomas Renninger; Moore, Robert; Luck, Tony; Brown, Len; linux-
> > acpi@vger.kernel.org; linux-ia64@vger.kernel.org; Andrew Morton;
> > efocht@hpce.nec.com
> > Subject: [PATCH] ACPI: fix vendor resource length computation
> > 
> > acpi_rs_get_list_length() needs to account for all the vendor-defined
> > data bytes.  Failing to include these causes buffers to be sized too
> > small, which causes slab corruption when we later convert AML to
> > resources and run off the end of the buffer.
> > 
> > I'm no expert on this code, so please scrutinize this carefully.
> > 
> > This causes slab corruption on machines that use ACPI vendor-defined
> > resources.  All HP ia64 machines do, and I'm told that some NEC
> > machines may as well.  So if the fix is correct, it would be good
> > to have it in 2.6.16.
> > 
> > Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
> > 
> > Index: work-mm4/drivers/acpi/resources/rscalc.c
> > =================================> > --- work-mm4.orig/drivers/acpi/resources/rscalc.c	2006-02-14
> > 13:32:50.000000000 -0700
> > +++ work-mm4/drivers/acpi/resources/rscalc.c	2006-02-14
> > 13:33:25.000000000 -0700
> > @@ -391,8 +391,7 @@
> >  			 * Ensure a 32-bit boundary for the structure
> >  			 */
> >  			extra_struct_bytes > > -			    ACPI_ROUND_UP_to_32_bITS(resource_length) -
> > -			    resource_length;
> > +			    ACPI_ROUND_UP_to_32_bITS(resource_length);
> >  			break;
> > 
> >  		case ACPI_RESOURCE_NAME_END_TAG:
> > @@ -408,8 +407,7 @@
> >  			 * Add vendor data and ensure a 32-bit boundary
> for the
> > structure
> >  			 */
> >  			extra_struct_bytes > > -			    ACPI_ROUND_UP_to_32_bITS(resource_length) -
> > -			    resource_length;
> > +			    ACPI_ROUND_UP_to_32_bITS(resource_length);
> >  			break;
> > 
> >  		case ACPI_RESOURCE_NAME_ADDRESS32:
> 
