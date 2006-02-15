From: "Moore, Robert" <robert.moore@intel.com>
Date: Wed, 15 Feb 2006 18:38:06 +0000
Subject: RE: [PATCH] ACPI: fix vendor resource length computation
Message-Id: <971FCB6690CD0E4898387DBF7552B90E045DA285@orsmsx403.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602141613.09152.bjorn.helgaas@hp.com>
In-Reply-To: <200602141613.09152.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Renninger <trenn@suse.de>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, Andreas Schwab <schwab@suse.de>, "Luck, Tony" <tony.luck@intel.com>, "Brown, Len" <len.brown@intel.com>, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>, efocht@hpce.nec.com

I'm working on the alignment issue also, should be a fix this week.
Bob


> -----Original Message-----
> From: Thomas Renninger [mailto:trenn@suse.de]
> Sent: Wednesday, February 15, 2006 9:50 AM
> To: Moore, Robert
> Cc: Bjorn Helgaas; Andreas Schwab; Luck, Tony; Brown, Len; linux-
> acpi@vger.kernel.org; linux-ia64@vger.kernel.org; Andrew Morton;
> efocht@hpce.nec.com
> Subject: Re: [PATCH] ACPI: fix vendor resource length computation
> 
> Moore, Robert wrote:
> > I think the original code may have been attempting to subtract off
the
> > size of the descriptor header to obtain the length of the vendor
data
> > bytes. However, something like a global replace may have broken it.
> >
> Thanks, this one fixes the mem corruption.
> Unaligned access messages still remain...
> 
> 
>    Thomas
