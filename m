From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Sat, 28 Jul 2001 08:03:38 +0000
Subject: [Linux-ia64] IA64 Linux issues
Message-Id: <marc-linux-ia64-105590693005948@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm running Caldera's 6/20/01 snapshot (modified 2.4.4 kernel) on a 4X,
8GB Lion.

Under even "light" I/O load (mkfs to 2-4 disks) I get horiffic behavior --
basically what is described on this thread:
http://www.cs.helsinki.fi/linux/linux-kernel/2001-20/0763.html
[I/O drops down to < 300 I/Os per second (vmstat), but all the CPUs are
pegged 99%+ system time.]

That is after I first used "swiotlb240" at elilo to avoid the panic,
and then hacked the qlogicfc driver (patch at bottom) and applied the
latest Adaptec driver patch (6.2.0) from freebsd.org to get 39-bit DMA.
Problem occurs with 39160 & QL2200.

I tried upgrading to 2.4.7+IA64-010726, but when I did that, "init" dies:
  init[1]: IA-64 Illegal operation fault 0
[...]
  Kernel panic: Attempted to kill init!

So i tried 2.4.5+IA64-010626.  Once I fixed two bugs in smp.c that prevented
compilation, it seemed to work.  Except that the I/O peformance was just as
bad.



qlogicfc.c patch:
doesn't do this in 2.4.7, which seems odd, since the driver *appears*
to support 64-bit DMA.

Anyway, with the following patch I appear to get 64-bit DMA enabled (at
least I don't get a panic on the 8GB IA-64 box running QL2200 cards w/o
tweaking the swiotlb array size).

--- qlogicfc.c.orig
+++ qlogicfc.c
@@ -2079,6 +2079,9 @@ static int isp2x00_init(struct Scsi_Host
        sh->irq = irq;
        sh->io_port = io_base;

+       if (pci_set_dma_mask(pdev, (dma_addr_t) 0xFFFFffffFFFFffffUL))
+               printk("qlogicfc%d: Failed to update dma_mask\n",
+                       hostdata->host_id);
        LEAVE("isp2x00_init");

        return 0;

