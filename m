From: "Miller, Mike (OS Dev)" <Mike.Miller@hp.com>
Date: Tue, 21 Feb 2006 20:21:42 +0000
Subject: RE: Problems with MSI-X on ia64
Message-Id: <D4CFB69C345C394284E4B78B876C1CF10BAD8CA9@cceexc23.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <D4CFB69C345C394284E4B78B876C1CF10B848090@cceexc23.americas.cpqcorp.net>
In-Reply-To: <D4CFB69C345C394284E4B78B876C1CF10B848090@cceexc23.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Grundler, Grant G" <grant.grundler@hp.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Chris Wedgwood <cw@f00f.org>, Grant Grundler <grundler@parisc-linux.org>, Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz, Jesse Barnes <jbarnes@virtuousgeek.org>, "Patterson, Andrew D (Linux R&D)" <andrew.patterson@hp.com>

> -----Original Message-----
> From: Grundler, Grant G 
> 
> On Fri, Feb 17, 2006 at 11:52:45AM -0800, Luck, Tony wrote:
> > > Hrm, it may be doing this.  I wonder how that works though with 
> > > 4GB's of RAM installed?
> > 
> > Systems with 4G of RAM usually map part of the RAM above 4G 
> so as to 
> > leave a hole for i/o mapping etc.
> 
> exactly.
> rx2600 physical memory map only has 1GB of RAM below 4GB 
> address space.

So I looked at 2.6.16-rc3 which works in my lab, but phys_addr is still
an int. How can that work? I believe Andrew saw the same thing in
2.6.15.

mikem
