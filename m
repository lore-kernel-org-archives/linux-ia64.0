From: Grant Grundler <grundler@cup.hp.com>
Date: Fri, 02 Aug 2002 18:58:57 +0000
Subject: Re: [Linux-ia64] [PATCH] dynamic IRQ allocation
Message-Id: <marc-linux-ia64-105590701905889@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905851@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905851@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"KOCHI, Takayoshi" wrote:
> But how can you trust Interrupt Line value set by BIOS?

I don't see any evidence ia64 uses INT_LINE from config space.
IA64 seems to overwrite pcidev->irq with the "vector" from ACPI.
However, I've not (recently) studied iosapic.c thoroughly.
Last time I took a close look was when david/stephane publish
the full ia64 source tree in Feb 2000 at NYLWE.
(http://lists.parisc-linux.org/hypermail/parisc-linux-cvs/2859.html)

My understanding is ia64 does a looks in the "PCI routing Table"
(_PRT) provided by ACPI. Input paramters to the lookup are IO SAPIC
address, IRQ *pin*, pci device bus/dev/func.  Output values are
"global" IRQ number (= vector?) and which IRTE to use in the
given IO SAPIC.

> It is definitely not an interrupt vector number, as
> interrupt vector number is what OS allocates and ties into
> a device. Then is it a global interrupt vector?

I don't know the right terminology here.
I'd think "global" interrupt vector is what goes into pcidev->irq.
INT_LINE isn't used so maybe it just doesn't matter. ;^)

> The config space Interrupt Line value is only 8bit while
> ACPI 2.0 can describe 32bit global interrupt vector.
> NEC's platform actually use value of 256 and above
> for global interrupt vector, therefore Interrupt Line
> value of configuration space will be inevitably bogus.

right. similar issue on parisc.

...
> Okay, then pci_set_master and pci_disable_device are a pair of APIs
> and pci_enable_device/pci_disable_device are not symmetric... sigh.

I think that depends on which platform.
My preference would be drivers not use pci_set_master().

> It is ok for PCI hotplug that we don't have an architecture-dependent
> pci_disable_device hook because there are other hooks when
> a device driver releases control of a device.

ok.

> > Use different magic numbers for each IRQ?
> > They can be any *int* value. You can even use them to index into
> > an array or structures. The trick is to fully hide the IRQ<->pcidev
> > relationship in the platform specific support.
> 
> Yes, but I think it will complicate things more than necessary.

ACPI seems to provide the "magic" number.
We don't need to anything else in addition so far.

> Now I understand that
> 
>  1) pci_dev->irq should be fixed-up at pci_fixup stage
>     in the kernel

s/should/could/
It's platform dependent.

>  2) pci_dev->irq is ia64 interrupt vector only
>     because we choose to do so and can be implemented
>     another way
>  3) ia64 interrupt vector can be allocated when enabled
>     but we allocate ahead of enabling
> 
> It is an implementation choice developers took long time ago
> that sharing a vector space with all processors in a system
> and one-to-one mapping between pci_dev->irq and interrupt vector.

yes. it's simple and sufficient for boxes currently on the market.

> iosapic.c has been written upon these assumptions.
> My patch doesn't break them.

TBH, I haven't looked at your patch.

> Implementing ia64 interrupt in other ways may be interesting
> but it's a 2.5-series matter.  For 2.4, current vector
> allocation scheme is broken at least on our platform with large
> configuration.  What we'd like to do now is fix these cases for
> stable series without breaking others.

ok.

thanks,
grant

