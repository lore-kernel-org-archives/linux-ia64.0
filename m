From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 21 Sep 2004 08:32:58 +0000
Subject: Re: [RFC&PATCH 1/2] PCI Error Recovery (readX_check)
Message-Id: <414FE73A.5070008@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <412FDE7B.3070609@jp.fujitsu.com> <414AD33A.80701@jp.fujitsu.com>
 <20040918043654.GA11259@cup.hp.com>
In-Reply-To: <20040918043654.GA11259@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Grant,
thank you for your constant comment/interest.

Grant Grundler wrote:
>>diff -Nur linux-2.6.8.1/include/asm-i386/io.h 
>>linux-2.6.8.1-pci/include/asm-i386/io.h
>>--- linux-2.6.8.1/include/asm-i386/io.h	2004-08-14 
> 
> ...
> 
>>+static inline unsigned char _readb_check(unsigned char *addr)
>>+{
>>+	return readb(addr);
>>+}
> 
> 
> Instead of adding those to io.h, wouldn't it be better to add
> a new header file? e.g io_check.h or something like that.
> 
> io.h is cluttered up with too much stuff already.
> Anyone who wants to use these functions will be writing new
> code and a new header file shouldn't be a problem.

Sounds good.
Hmm, I tend to avoid creating new file in the Linux tree... :-p


> Oh...and linus' recent addition of iomap.h to 2.6.9-rcX kernels:
> 	http://www.ussg.iu.edu/hypermail/linux/kernel/0409.1/2561.html
> 
> This might be an opportunity for you to make the new interface
> a bit more aware of error recovery.
> 
> It would make sense to integrate directly into his new design
> for new kernel functionality. If someone is (re)writing code
> to use the new interfaces, they might do it differently
> if the pci error recovery is part of that.
> 
> Sorry, I don't mean to upset the your plans and suspect
> what you are doing will be useful for existing 2.6 kernels
> shipped by distro's.

Thank you for your information.
I hadn't notice the Linus's post... iomap.h is very interesting.

In fact, I'm targeting current distro's. However now I think it is
worth to reconsider my plan if we are entering a great transitional
stage in the development of the kernel infrastructure...


>>diff -Nur linux-2.6.8.1/include/asm-ia64/io.h 
>>linux-2.6.8.1-pci/include/asm-ia64/io.h
> 
> ...
> 
>>+static inline unsigned char
>>+_readb_check(unsigned char *addr)
>>+{
>>+	register unsigned long gr8 asm("r8");
>>+	unsigned char val;
>>+
>>+	val = readb(addr);
>>+	asm volatile ("add %0=%1,r0" : "=r"(gr8) : "r"(val));
> 
> 
> Sorry - I don't understand the intent of the asm here.
> Would a short comment be sufficient to explain?
> 
> I'm trying to understand why it's different from i386 and
> not what "add" does.

This part is ia64 specific staff... we need something like "add" to
make sure the value is not poisoned.  Since the processor asserts an
MCA at the time when the poisoned value is "consumed" - more properly,
the MCA is signaled at or before the use of the IO read transaction:

LabelA:  ld8  r15 = [r16] // Load
LabelB:  Mov  r17 = r18;;
  :
LabelX:  Mov  r22 = r15   // MCA signaled at or before this instruction

So the "add" make us sure that read_pci_errors() which should follow
this readX_check() never fail to catch all MCA that could be caused by
values fetched by some readX_check().

AFAIK, this "add" works as something like barrier(), definitely certain,
and quick than PAL_MC_DRAIN call.


>>+u8  readb_check(struct pci_dev *, u8 *);
>>+u16 readw_check(struct pci_dev *, u16 *);
>>+u32 readl_check(struct pci_dev *, u32 *);
> 
> 
> These function protoypes are added to i386 and ia64 asm/pci.h and
> to linux/pci.h.
> Do you really need to add the same function proto to asm/pci.h?
> Or am I overlooking something? (It's been a long day again...)

No no, it's my overlooking... They are duplicated.
Add it only linux/pci.h.


Thanks,
H.Seto
