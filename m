From: Grant Grundler <iod00d@hp.com>
Date: Sat, 18 Sep 2004 04:36:54 +0000
Subject: Re: [RFC&PATCH 1/2] PCI Error Recovery (readX_check)
Message-Id: <20040918043654.GA11259@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <412FDE7B.3070609@jp.fujitsu.com> <414AD33A.80701@jp.fujitsu.com>
In-Reply-To: <414AD33A.80701@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Grant Grundler <iod00d@hp.com>, Linus Torvalds <torvalds@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Fri, Sep 17, 2004 at 09:06:18PM +0900, Hidetoshi Seto wrote:
> This is the latest patch for PCI recovery.
>  (merge Grant's text, fix spellmisses)

Hidetoshi,
sorry, I have more questions/comments...

And I still don't understand how some of the core pieces work.
Comments below just "nibble around the edges" (like a mouse
on a cracker).

> diff -Nur linux-2.6.8.1/include/asm-i386/io.h 
> linux-2.6.8.1-pci/include/asm-i386/io.h
> --- linux-2.6.8.1/include/asm-i386/io.h	2004-08-14 
...
> +static inline unsigned char _readb_check(unsigned char *addr)
> +{
> +	return readb(addr);
> +}

Instead of adding those to io.h, wouldn't it be better to add
a new header file? e.g io_check.h or something like that.

io.h is cluttered up with too much stuff already.
Anyone who wants to use these functions will be writing new
code and a new header file shouldn't be a problem.

Oh...and linus' recent addition of iomap.h to 2.6.9-rcX kernels:
	http://www.ussg.iu.edu/hypermail/linux/kernel/0409.1/2561.html

This might be an opportunity for you to make the new interface
a bit more aware of error recovery.

It would make sense to integrate directly into his new design
for new kernel functionality. If someone is (re)writing code
to use the new interfaces, they might do it differently
if the pci error recovery is part of that.

Sorry, I don't mean to upset the your plans and suspect
what you are doing will be useful for existing 2.6 kernels
shipped by distro's.

> diff -Nur linux-2.6.8.1/include/asm-ia64/io.h 
> linux-2.6.8.1-pci/include/asm-ia64/io.h
...
> +static inline unsigned char
> +_readb_check(unsigned char *addr)
> +{
> +	register unsigned long gr8 asm("r8");
> +	unsigned char val;
> +
> +	val = readb(addr);
> +	asm volatile ("add %0=%1,r0" : "=r"(gr8) : "r"(val));

Sorry - I don't understand the intent of the asm here.
Would a short comment be sufficient to explain?

I'm trying to understand why it's different from i386 and
not what "add" does.

...
> +u8  readb_check(struct pci_dev *, u8 *);
> +u16 readw_check(struct pci_dev *, u16 *);
> +u32 readl_check(struct pci_dev *, u32 *);

These function protoypes are added to i386 and ia64 asm/pci.h and
to linux/pci.h.
Do you really need to add the same function proto to asm/pci.h?
Or am I overlooking something? (It's been a long day again...)

thanks,
grant
