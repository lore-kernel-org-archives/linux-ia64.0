From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 16 Dec 2004 17:04:46 +0000
Subject: Re: [PATCH] add legacy I/O port & memory APIs to /proc/bus/pci
Message-Id: <200412160904.46665.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412160850.20223.jbarnes@engr.sgi.com> <20041216165602.GA10560@infradead.org>
In-Reply-To: <20041216165602.GA10560@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, willy@debian.org

On Thursday, December 16, 2004 8:56 am, Christoph Hellwig wrote:
> On Thu, Dec 16, 2004 at 08:50:19AM -0800, Jesse Barnes wrote:
> > This patch documents the /proc/bus/pci interface and adds some optional
> > architecture specific APIs for accessing legacy I/O port and memory
> > space. This is necessary on platforms where legacy I/O port space doesn't
> > 'soft fail' like it does on PCs, and is useful for systems that can route
> > legacy space to different PCI busses.
>
> Please don't add more interfaces to procfs.  And ioctl() on procfs is even
> more evil.

Oh come on, there's already an API there, and now it's documented even!  The 
additions are straightforward and there's no where else to put them...  /sys 
doesn't seem like a good place either, would you prefer a device driver?

I really don't see what the problem is though.  /proc/bus/pci is a commonly 
used API and I don't see it going away.  These extensions just make it a 
little more usable on platforms like sn2 and ppc.

Jesse
