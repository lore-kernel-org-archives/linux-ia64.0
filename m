From: Carlos Corbacho <carlos@strangeworlds.co.uk>
Date: Wed, 06 Feb 2008 02:03:23 +0000
Subject: Re: [PATCH 0/5] WMI patches for acpi-test (v2)
Message-Id: <200802060203.24856.carlos@strangeworlds.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080205021658.4422.83165.stgit@pacifica> <200802052118.02733.carlos@strangeworlds.co.uk> <200802051735.55106.bjorn.helgaas@hp.com>
In-Reply-To: <200802051735.55106.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Len Brown <lenb@kernel.org>, linux-acpi@vger.kernel.org, Matthew Garrett <mjg59@srcf.ucam.org>, Alexey Starikovskiy <aystarik@gmail.com>, linux-ia64@vger.kernel.org

On Wednesday 06 February 2008 00:35:54 Bjorn Helgaas wrote:
> > Ok. The only other vendors I really have in mind are HP and Fujitsu,
> > since both those vendors use WMI on their laptops, so they would be my
> > most likely candidates to have WMI on an IA64 box (if anyone actually
> > does use WMI on IA64).
>
> How could I tell whether our HP systems use WMI?

Do you have any PNP0C14 or *pnp0c14 _HID objects defined in the DSDTs for your 
systems? If not, then your systems don't use WMI.

-Carlos
-- 
E-Mail: carlos@strangeworlds.co.uk
Web: strangeworlds.co.uk
GPG Key ID: 0x23EE722D
