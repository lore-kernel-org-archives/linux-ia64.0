From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 16 Dec 2004 16:56:02 +0000
Subject: Re: [PATCH] add legacy I/O port & memory APIs to /proc/bus/pci
Message-Id: <20041216165602.GA10560@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412160850.20223.jbarnes@engr.sgi.com>
In-Reply-To: <200412160850.20223.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, willy@debian.org

On Thu, Dec 16, 2004 at 08:50:19AM -0800, Jesse Barnes wrote:
> This patch documents the /proc/bus/pci interface and adds some optional 
> architecture specific APIs for accessing legacy I/O port and memory space.  
> This is necessary on platforms where legacy I/O port space doesn't 'soft 
> fail' like it does on PCs, and is useful for systems that can route legacy 
> space to different PCI busses.

Please don't add more interfaces to procfs.  And ioctl() on procfs is even
more evil.

