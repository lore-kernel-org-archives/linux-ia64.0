From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 11 Dec 2003 19:32:04 +0000
Subject: Re: Latest 2.4 IA64 Baseline (Bjorn) + Latest ACPI testing report
Message-Id: <marc-linux-ia64-107117122723575@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106863619315583@msgid-missing>
In-Reply-To: <marc-linux-ia64-106863619315583@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 10 December 2003 5:34 pm, I wrote:
> > >> 3.alloc 0x0-0xcf7 from PCI IO for PCI Bus 00:00 failed   (Known issue)
> > 
> > Since VGA console driver faile to allocate that port range,  why it still can work?
> > Does it mean 0x3c0-0x3df is inessential to  VGA console driver.
> 
> No, I think those ports are essential.  The driver just uses them,
> even if the allocation fails.  I have a 2.6 patch that cleans this
> up.  It doesn't change any functionality; it just gets rid of the
> message and makes /proc/ioports more correct.  I'll submit it as
> soon as it makes sense to put non-critical changes into 2.6.

I didn't answer this quite right.  The VGA driver allocates ports
0x3c0-0x3df early, and that allocation succeeds.  Later, we
discover the PCI root bridges, and try to allocate the port ranges
for each.  It's the PCI root bridge allocation that fails, because
it's trying to allocate a range that includes the VGA ports.

So we end up with something like this in /proc/ioports (this is a
made-up example, but same idea):

	000003c0-000003df : vga+
	00004000-00009fff : PCI Bus 00:00
	  00004000-000040ff : sym53c8xx
	  00004100-000041ff : sym53c8xx

when we should have this:

	00000000-00000cf7 : PCI Bus 00:00
	  000003c0-000003df : vga+
	00004000-00009fff : PCI Bus 00:00
	  00004000-000040ff : sym53c8xx
	  00004100-000041ff : sym53c8xx

The patch just changes the PCI root bridge allocation so that
instead of failing if part of the range has already been allocated,
it inserts a new range up one level, so it encloses the previous
VGA allocation.

Bjorn

