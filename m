From: "Moore, Robert" <robert.moore@intel.com>
Date: Mon, 13 Sep 2004 22:11:29 +0000
Subject: RE: [ACPI] [PATCH] restore _OS object to "Linux" for ia64
Message-Id: <37F890616C995246BE76B3E6B2DBE05501FB49C2@orsmsx403.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1095103349.2512.16.camel@d845pe>
In-Reply-To: <1095103349.2512.16.camel@d845pe>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Gerald Pfeifer <gp-l3A5Bk7waGM@public.gmane.org>
Cc: "Brown, Len" <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Alex Williamson <alex.williamson-VXdhtT5mjnY@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ACPI Developers <acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>

I don't know what the specific machines were.  There was lots of
discussion on the Linux/ACPI list before we did this.  I think they were
all 32-bit machines, however.


> -----Original Message-----
> From: Gerald Pfeifer [mailto:gp@suse.de]
> Sent: Monday, September 13, 2004 2:30 PM
> To: Moore, Robert
> Cc: Brown, Len; Alex Williamson; linux-ia64@vger.kernel.org; ACPI
> Developers
> Subject: RE: [ACPI] [PATCH] restore _OS object to "Linux" for ia64
> 
> On Mon, 13 Sep 2004, Moore, Robert wrote:
> > Not only is the !Windows code path apparently untested for the most
> > part, we have discovered many machines that simply do not work
properly
> > unless we report "Microsoft Windows NT" for the _OS string.
> 
> Can you name some of these (broken) systems?
> 
> Given that we apparently did not encounter this with our 2.6.5-based
SLES9
> kernel so far, I'm a bit sceptical that many (if any) ia64 machines
are
> affected.
> 
> Gerald
