From: "David S. Miller" <davem@redhat.com>
Date: Wed, 24 Apr 2002 04:04:10 +0000
Subject: [Linux-ia64] Re: PCI DAC routines for SN
Message-Id: <marc-linux-ia64-105590701905503@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905493@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905493@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Jesse Barnes <jbarnes@sgi.com>
   Date: Mon, 22 Apr 2002 16:40:14 -0700

   On Mon, Apr 22, 2002 at 04:07:33PM -0700, David Mosberger wrote:
   > Oh man, what a mess!  Have you checked with Dave Miller?  I suspect
   > he might not like this.  I'm not terribly fond of it either as it
   
   He was the one that implemented it I thought.  His assertion was that
   since most chipsets don't handle 64 bit coherent allocations well, the
   consistent interface should be forced to return a 32 bit address (is
   that right Dave?).  I don't mind that as long as we add a DAC
   consistent call, otherwise I'd like to leave it up to the platform
   (i.e. ia64/sn could return a 64 bit address and sparc64 could do 32).
   
%99 of PCI chips out there do not support DAC addressing for things
like descriptor tables etc.  So it's not a matter of "well" it's
a matter of "at all".

Therefore pci_alloc_consistent MUST provide SAC only addressing.

I was seeing patches where people would set the DMA mask for the
pci_dev around pci_alloc_consistent calls in order to accomplish
getting SAC addresses.  That is exactly the kind of crap I was
trying to avoid.

Therefore, as per the API specification
(Documentation/DMA-mapping.txt) and reality, it's unacceptable
for pci_alloc_consistent() to return anything other than SAC
addresses (or something more constrained, if the DMA mask indicates
this, for example for devices with ISA addressing limitations).

I think it is unreasonable to add a special DAC alloc consistent
call.

Is this needed because you bozos don't have any physical memory below
4GB on some weird ia64 system ___AND___ you lack a PCI IOMMU in the
controllers again?  This is getting rediculious if so, and I really
want to avoid crapping up the PCI DMA interfaces just because the ia64
PCI hardware folks keep making stupid design decisions.

