From: Grant Grundler <grundler@parisc-linux.org>
Date: Sat, 25 Feb 2006 16:23:46 +0000
Subject: Re: Problems with MSI-X on ia64
Message-Id: <20060225162346.GA15372@colo.lackof.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <D4CFB69C345C394284E4B78B876C1CF10BAD8CA9@cceexc23.americas.cpqcorp.net>
In-Reply-To: <D4CFB69C345C394284E4B78B876C1CF10BAD8CA9@cceexc23.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Miller, Mike (OS Dev)" <Mike.Miller@hp.com>
Cc: "Grundler, Grant G" <grant.grundler@hp.com>, "Luck, Tony" <tony.luck@intel.com>, Chris Wedgwood <cw@f00f.org>, Grant Grundler <grundler@parisc-linux.org>, Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz, Jesse Barnes <jbarnes@virtuousgeek.org>, "Patterson, Andrew D (Linux R&D)" <andrew.patterson@hp.com>

On Tue, Feb 21, 2006 at 02:21:42PM -0600, Miller, Mike (OS Dev) wrote:
> So I looked at 2.6.16-rc3 which works in my lab, but phys_addr is still
> an int. How can that work?

"int" (u32) will work if the top bits are zero or alias to the
same thing as the full 64-bit address.
Can you apply the patch and add printk's to dump the
pci_resource_start(dev,bir) in msix_capability_init()?


> I believe Andrew saw the same thing in 2.6.15.

Yes, AFIACT 2.6.15 has the same code.

thanks,
grant
