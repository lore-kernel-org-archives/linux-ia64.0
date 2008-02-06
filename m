From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 06 Feb 2008 06:30:44 +0000
Subject: Re: [PATCH 0/5] WMI patches for acpi-test (v2)
Message-Id: <200802052330.44989.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080205021658.4422.83165.stgit@pacifica> <200802051735.55106.bjorn.helgaas@hp.com> <200802060203.24856.carlos@strangeworlds.co.uk>
In-Reply-To: <200802060203.24856.carlos@strangeworlds.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Carlos Corbacho <carlos@strangeworlds.co.uk>
Cc: Len Brown <lenb@kernel.org>, linux-acpi@vger.kernel.org, Matthew Garrett <mjg59@srcf.ucam.org>, Alexey Starikovskiy <aystarik@gmail.com>, linux-ia64@vger.kernel.org

On Tuesday 05 February 2008 07:03:23 pm Carlos Corbacho wrote:
> On Wednesday 06 February 2008 00:35:54 Bjorn Helgaas wrote:
> > > Ok. The only other vendors I really have in mind are HP and Fujitsu,
> > > since both those vendors use WMI on their laptops, so they would be my
> > > most likely candidates to have WMI on an IA64 box (if anyone actually
> > > does use WMI on IA64).
> >
> > How could I tell whether our HP systems use WMI?
> 
> Do you have any PNP0C14 or *pnp0c14 _HID objects defined in the DSDTs for your 
> systems? If not, then your systems don't use WMI.

I looked at DSDTs for a few HP ia64 systems (rx7620,
rx8640, and superdome), and none has a PNP0C14 object.
