From: Richard Henderson <rth@twiddle.net>
Date: Fri, 15 Oct 2004 07:19:26 +0000
Subject: Re: [PATCH] Introduce PCI <-> CPU address conversion [1/2]
Message-Id: <20041015071926.GA11457@twiddle.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041014124737.GM16153@parcelfarce.linux.theplanet.co.uk> <20041014182704.A13971@jurassic.park.msu.ru> <20041014143924.GP16153@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20041014143924.GP16153@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Greg KH <greg@kroah.com>, linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, Oct 14, 2004 at 03:39:24PM +0100, Matthew Wilcox wrote:
> I can't use it in the symbios driver because it only exists on alpha,
> arm, mips, parisc, ppc, ppc64, sparc64 and v850.  It doesn't exist on
> i386, ia64, x86_64, arm26, cris, h8300, m32r, sh, sh64 or sparc.

So you conclude from 50% of the ports implementing things in a 
particular way that you should invent a totally new interface?
Isn't the obvious solution to implement the existing interface
for the ports that don't have it?


r~
