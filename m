From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 18 Feb 2000 05:27:52 +0000
Subject: Re: [Linux-ia64] LINUX IA64 Memory Support
Message-Id: <marc-linux-ia64-105590678204941@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204939@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204939@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 15 Feb 2000 22:03:03 +0100, Jes Sorensen <Jes.Sorensen@cern.ch> said:

>>>>> "Venkatesh" = Venkatesh Ramamurthy <Venkateshr@ami.com> writes:
  Venkatesh> Hi, Is there any way in which one can allocate memory say
  Venkatesh> below 4 GB ( physical address )in drivers.  TIA Venkatesh

  Jes> This is not IA64 specific actually, so consider it a general
  Jes> answer rather than an IA64 one.

  Jes> A regular GFP_KERNEL should give you memory within the PCI
  Jes> DMA'able area, which with the old PCI system meant within the
  Jes> 4GB range. GFP_DMA will give you something within the ISA DMA
  Jes> space. However, in principle none of the above means that the
  Jes> memory is within the lower 4GB memory range, if the machine in
  Jes> question has an IOMMU type device, you may be handed memory
  Jes> which is in the middle of the memory space, but which is mapped
  Jes> to the 4GB the PCI bus in the machine can see.

  Jes> With the new PCI allocation system it is even more flexible,
  Jes> here you may get addresess anywhere and you then tell the PCI
  Jes> subsystem at run time to map the memory to the space the PCI
  Jes> bus can address. This means it will be possible to support
  Jes> systems with for instance 200 PCI busses (if someone feels like
  Jes> building such) etc.

Jes's answer is basically correct:

 - If you're writing a driver, use the new PCI DMA API (see pci.h in
   kernel 2.3.44 or later) and you'll be fine.

 - If you need memory below 4GB for some other reason, you're
   presently out of luck.  However, the already agreed upon solution
   is to add a new "zone" which will represent memory below 4GB
   (ZONE_32BIT or some such).  I plan to do this asap as we need this
   zone to properly implement the PCI DMA API (it currently works only
   because no Itanium system we know of/have access to has more than
   1GB of RAM ;-).

	--david


