From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 25 Apr 2003 17:18:39 +0000
Subject: Re: [Linux-ia64] [PATCH] 1/4 multi-ioport space support for 2.5
Message-Id: <marc-linux-ia64-105590723705609@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705599@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705599@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Apr 25, 2003 at 12:36:28PM +0100, Matthew Wilcox wrote:
> On Thu, Apr 24, 2003 at 06:05:37PM -0700, Jesse Barnes wrote:
> > I must be missing something.  I understand that you've effectively
> > created legacy I/O port spaces for each pci controller, but I don't
> > see how that helps you with a driver that does e.g. inb(0x3e8).  What
> > do you anticipate that your stuff will be used for?  That would help
> > out a bit...
> 
> Most drivers don't do that any more though.  All PCI drivers just read
> their BARs and do inb() from there.  There's no ISA devices on hp's
> ia64 boxes, so ISA probes aren't an issue.  We've been doing something
> similar on PA for a while (io addresses are 0xBBiiii; the EISA bus if
> present gets bus 0) with no problems.

Ok, if that's the case, then SN boxes should be ok (I think), since
we'll mess around with the BARs in pci_fixup so that they're all
accessible.

Jesse

