From: Linus Torvalds <torvalds@osdl.org>
Date: Wed, 25 Aug 2004 17:25:22 +0000
Subject: Re: [RFC&PATCH 1/2] PCI Error Recovery (readX_check)
Message-Id: <Pine.LNX.4.58.0408251013450.17766@ppc970.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <412AD123.8050605@jp.fujitsu.com> <Pine.LNX.4.58.0408232231070.17766@ppc970.osdl.org>
 <1093417267.2170.47.camel@gaston> <Pine.LNX.4.58.0408250015420.17766@ppc970.osdl.org>
 <20040825155213.GB19447@cup.hp.com>
In-Reply-To: <20040825155213.GB19447@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org



On Wed, 25 Aug 2004, Grant Grundler wrote:
> 
> Do we only need to determine there was an error in the IO hierarchy
> or do we also need to know which device/driver caused the error?
> 
> If the latter I agree with linus. If the former, then the error recovery
> can support asyncronous errors (like the bad DMA address case) and tell
> all affected (thanks willy) drivers.

Yes, that we could do without locking. The simplest way to do that is to 
have a global sequence counter, and then the whole thing really boils down 
to

	typedef unsigned long pci_error_cookie_t;

	extern pci_error_cookie_t error_sequence_number;

	static inline pci_error_cookie_t clear_pci_errors(struct pci_dev *dev)
	{
		pci_error_cookie_t now;

		now = error_sequence_number;
		io_start_error_memory_barrier(dev);
		return now;
	}

	static inline int read_pci_errors(pci_error_cookie_t then, struct pci_dev *dev)
	{
		io_end_error_memory_barrier(dev);
		return (then != error_sequence_number) ? -EIO : 0;
	}

and have the error handler just increment the "error_sequence_number" 
whenever it happens.

However, the above relies on the PCI error being a NMI in the first place
(which it may or may not be), and also on the fact that we need to have
some way to make sure we get it if it was pending to avoid races (ie the
"io_end_error_memory_barrier()" may have to be pretty expensive and
bus-serializing - likely a config space read from the device).

And the above also relies on it being ok to see other peoples errors by
mistake.

(Depending on how much information such a PCI error NMI gives the kernel,
the "error_sequence_number" could be made per-domain or per-bus, of
course, but that's an implementation detail that depends on what the
hardware supports).

But I would not be surprised if "clear_pci_errors()" actually has to 
_clear_ some bit in the bridge device and "read_pci_errors()" has to check 
the bit afterwards. And if that is the case, I really do believe that you 
want to lock the whole bridge, because you can't have people clearing the 
bit when somebody else might be actively using it...

So I think we have to design for the thing potentially being a irq-safe 
spinlock - possibly even a global one. That's the worst case, and maybe a 
lot of hardware platforms can do less intrusive things, but if we're 
looking at generic infrastructure that different drivers are supposed to 
be able to use (and I assume that's what we want), then we have to make 
the interfaces generic.

		Linus
