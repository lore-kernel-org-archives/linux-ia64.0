From: "Miller, Mike (OS Dev)" <Mike.Miller@hp.com>
Date: Mon, 27 Feb 2006 18:36:09 +0000
Subject: RE: Problems with MSI-X on ia64
Message-Id: <D4CFB69C345C394284E4B78B876C1CF10BB421EC@cceexc23.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <D4CFB69C345C394284E4B78B876C1CF10B848090@cceexc23.americas.cpqcorp.net>
In-Reply-To: <D4CFB69C345C394284E4B78B876C1CF10B848090@cceexc23.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <grundler@parisc-linux.org>
Cc: "Grundler, Grant G" <grant.grundler@hp.com>, "Luck, Tony" <tony.luck@intel.com>, Chris Wedgwood <cw@f00f.org>, Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz, Jesse Barnes <jbarnes@virtuousgeek.org>, "Patterson, Andrew D (Linux R&D)" <andrew.patterson@hp.com>

> -----Original Message-----
> From: Grant Grundler [mailto:grundler@parisc-linux.org] 
> Sent: Saturday, February 25, 2006 10:24 AM
> To: Miller, Mike (OS Dev)
> Cc: Grundler, Grant G; Luck, Tony; Chris Wedgwood; Grant 
> Grundler; Greg KH; linux-kernel@vger.kernel.org; 
> linux-scsi@vger.kernel.org; linux-ia64@vger.kernel.org; 
> linux-pci@atrey.karlin.mff.cuni.cz; Jesse Barnes; Patterson, 
> Andrew D (Linux R&D)
> Subject: Re: Problems with MSI-X on ia64
> 
> On Tue, Feb 21, 2006 at 02:21:42PM -0600, Miller, Mike (OS Dev) wrote:
> > So I looked at 2.6.16-rc3 which works in my lab, but phys_addr is 
> > still an int. How can that work?
> 
> "int" (u32) will work if the top bits are zero or alias to 
> the same thing as the full 64-bit address.
> Can you apply the patch and add printk's to dump the
> pci_resource_start(dev,bir) in msix_capability_init()?

My box is in a vegetative state. Working with HW folks to resolve.

mikem

> 
> 
> > I believe Andrew saw the same thing in 2.6.15.
> 
> Yes, AFIACT 2.6.15 has the same code.
> 
> thanks,
> grant
> 
