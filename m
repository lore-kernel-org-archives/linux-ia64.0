From: grundler@cup.hp.com (Grant Grundler)
Date: Mon, 31 Mar 2003 20:38:45 +0000
Subject: Re: [Linux-ia64] sba_iommu status?
Message-Id: <marc-linux-ia64-105590723705365@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705362@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705362@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 31, 2003 at 08:17:46PM +1000, Peter Chubb wrote:
> 
> Hi,
> 	What is the status of the IOMMU support?  I'm finding that
> with CONFIG_ZX1 turned on, that PCI cards that can do only 32-bit DMA
> cause system hangs.

It works fine for 2.4.x kernels.  The 100BT (tulip, eepro100/e100)
NICs and older SCSI (U160 and slower) use IO MMU.
I've run both LAN and Mass Storage tests using CONFIG_IA64_HP_ZX1=y
on 2.4.20 though none of the distributions tests/ships with 2.4.20
(well, debian has 2.4.20 available in unstable) or that config.

All drivers that advertise 32-bit capability (pci_set_dma_mask()) or
don't advertise anything, will go through IO MMU for physical memory
addresses above 4GB. IIRC, only 1GB of physical memory is below
4GB boundary and the rest above.

...
> The code works when I build the kernel as CONFIG_DIG; but not
> otherwise.

your code looks correct.
I'm wondering why CONFIG_DIG works but not CONFIG_IA64_HP_ZX1.
This sounds like 2.5.

> The trace below is typical of what I see.
> All DMA mappings except my driver bypass the IOMMU

Normally, an MCA with IO MMU means the driver didn't tell the device
to use a valid address.

However, this weekend Alex Williamson flushed out another SBA  bug
(missing wmb() when modifying IO PDIR) exposed by multiple tulip NIC
driver testing. With full debug, I wouldn't expect you to hit this
bug though.  Alex said he would post the patch shortly for 2.4.20/2.5.x.


> +BEGIN HARDWARE ERROR STATE AT MCA

Look for 
  ROPE_N_ERROR                  0x0000000000000240 

to indicate the IO Pdir entry contained an invalid mapping
in the "errdump mca" output from EFI shell.

hth,
grant

