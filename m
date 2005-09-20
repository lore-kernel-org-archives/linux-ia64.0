From: "Moore, Robert" <robert.moore@intel.com>
Date: Tue, 20 Sep 2005 23:16:37 +0000
Subject: RE: [ACPI] [PATCH] ACPI: implement UUID-labelled vendor-defined resources
Message-Id: <971FCB6690CD0E4898387DBF7552B90E02C8E63F@orsmsx403.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506211421.20446.bjorn.helgaas@hp.com>
In-Reply-To: <200506211421.20446.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>, acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Cc: "Brown, Len" <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Alex Williamson <alex.williamson-VXdhtT5mjnY@public.gmane.org>, "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

I'll get to this a bit later.
Thx
Bob


> -----Original Message-----
> From: Bjorn Helgaas [mailto:bjorn.helgaas@hp.com]
> Sent: Tuesday, September 20, 2005 4:10 PM
> To: acpi-devel@lists.sourceforge.net
> Cc: Moore, Robert; Brown, Len; Alex Williamson; Luck, Tony; linux-
> ia64@vger.kernel.org
> Subject: Re: [ACPI] [PATCH] ACPI: implement UUID-labelled
vendor-defined
> resources
> 
> On Monday 19 September 2005 9:31 am, Bjorn Helgaas wrote:
> > > BTW, Please explain in more detail what support is needed in
ACPICA
> for
> > > the ACPI 3.0 vendor-defined resource.  Also, any idea how we are
> > > supposed to determine if the UUID data exists within the
descriptor?
> > > (i.e., how do we differentiate an ACPI 2.0 vendor descriptor from
an
> > > ACPI 3.0 descriptor?)
> >
> > There's no mark that distinguishes 2.0 and 3.0 vendor descriptors.
> > As far as I can tell, a 3.0 descriptor (that contains a UUID and
> > sub-type) is also a perfectly valid 2.0 descriptor.
> >
> > ACPI 3.0 "strongs recommends," but apparently doesn't actually
> > require a UUID, so a 2.0 vendor descriptor should also be a valid
> > 3.0 descriptor.
> >
> > The idea is that we just look through all the vendor descriptors
> > for the supplied UUID.  If we find one, we return the information.
> > There's a small possibility that an ACPI 2.0, non-UUID-labelled
> > descriptor will contain data that happens to match the random
> > 16-byte UUID, and we'll return it by mistake.  But that possibility
> > is pretty remote, I think.
> 
> Ping...  Did this make any sense, or did I answer the wrong questions?
