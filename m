From: =?ISO-8859-1?Q?G=E9rard_Roudier?= <groudier@free.fr>
Date: Tue, 04 Dec 2001 19:38:24 +0000
Subject: Re: [Linux-ia64] 2.4.16-ia64-011128 is missing dma64_addr_t
Message-Id: <marc-linux-ia64-105590698805612@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805568@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805568@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


On Tue, 4 Dec 2001, David Mosberger wrote:

> >>>>> On Tue, 4 Dec 2001 19:15:06 +0100 (CET), =3D?ISO-8859-1?Q?G=3DE9rar=
d_Roudier?=3D <groudier@free.fr> said:
>
>   Gerard> I am under the impression that it has been invented for
>   Gerard> sparc64 as a provision for PCI devices that may gain
>   Gerard> advantage of real 64 bit DMA PCI on this hardware. This
>   Gerard> platform has some streaming mode DMA implemented for 32 bit
>   Gerard> PCI through an IO/MMU.
>
>   Gerard> Choices are:
>
>   Gerard> 1) Faster IOs but only in 32 bit PCI mode + software
>   Gerard> complexity as a malus.  2) Slower IOs in 64 bit PCI mode.
>
>   Gerard> Chosing the less bad one, here choice #1, is what is to be
>   Gerard> done when no good choice is available.
>
> Close, but not quite: DaveM *always* wants to use SAC on SPARC64
> (using the I/O TLB if necessary) *unless* the device creates so many
> mappings that it could exhaust the address space of the I/O TLB.  His
> choice is motivated by the assumption that DAC is slower than SAC.  I

DAC costs 1 additionnal PCI cycle more than SAC for each transaction.
Given reasonnable burst lengths you will not see significant differences
all other things being equal, but they aren't on sparc64.

> don't believe that's a significant effect for machines with real
> 64-bit PCI buses.  Also, I think for most device driver writers, the
> complexity of having to choose between pci_* and pci_dac_* is just too
> much (just look at the original qlogic drivers if you don't know what
> I mean...).

I can guess.

> So, the rule of thumb should be:
>
>  (1) use the normal pci_* routines.
>
>  (2) if the device is DAC capable and can *truly* address all 64-bit
>      address bits (not just 36 bits or whatever) and SPARC64 runs into
>      I/O TLB address space trouble, consider using pci_dac_*.

I am rather interested in practice here and the pci_dac_* stuff seems to
address sparc64 only (and only linux, btw). Nothing than can motivate
anybody excepted DSM, in my opinion. :-)

  G=E9rard.


