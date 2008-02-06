From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 06 Feb 2008 00:35:54 +0000
Subject: Re: [PATCH 0/5] WMI patches for acpi-test (v2)
Message-Id: <200802051735.55106.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080205021658.4422.83165.stgit@pacifica> <200802051603.30466.lenb@kernel.org> <200802052118.02733.carlos@strangeworlds.co.uk>
In-Reply-To: <200802052118.02733.carlos@strangeworlds.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Carlos Corbacho <carlos@strangeworlds.co.uk>
Cc: Len Brown <lenb@kernel.org>, linux-acpi@vger.kernel.org, Matthew Garrett <mjg59@srcf.ucam.org>, Alexey Starikovskiy <aystarik@gmail.com>, linux-ia64@vger.kernel.org

On Tuesday 05 February 2008 02:18:01 pm Carlos Corbacho wrote:
> On Tuesday 05 February 2008 21:03:30 Len Brown wrote:
> > On Monday 04 February 2008 21:16, Carlos Corbacho wrote:
> > > 2) Do you know of any IA64 systems using ACPI-WMI? At the moment, WMI
> > > will work on x86 and hopefully IA64, but if it turns out that no vendor
> > > has or ever will implement ACPI-WMI on IA64, then we could safely drop it
> > > there.
> >
> > I recommend skipping WMI on IA64 unless/until a real need to support it
> > emerges. There are no WMI extensions on the Intel Tiger or Hitachi Fusion
> > IA64 boxes I have access to.
> 
> Ok. The only other vendors I really have in mind are HP and Fujitsu, since 
> both those vendors use WMI on their laptops, so they would be my most likely 
> candidates to have WMI on an IA64 box (if anyone actually does use WMI on 
> IA64).

How could I tell whether our HP systems use WMI?

Bjorn
