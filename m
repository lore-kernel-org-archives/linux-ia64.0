From: Matt_Domsch@Dell.com
Date: Wed, 23 May 2001 01:34:13 +0000
Subject: RE: [Linux-ia64] 2.4.4 stability on Lions
Message-Id: <marc-linux-ia64-105590693005649@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005642@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005642@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The solution to your problem is to
> alter your SCSI host adapter settings to operate > 4GB. If 
> you can use the
> SCSI FastUtil the setting to change is found under host 
> adapter settings.

The Linux qla1280 v3.23 driver as distributed in the IA-64 patch *always*
sets a 64-bit dma_mask if running on a 64-bit processor.  The NVRAM bit
isn't read as the switch anymore.

#if BITS_PER_LONG > 32
    /* Enable 64bit addressing for OS/System combination supporting it   */
    /* actual NVRAM bit is: nv->cntr_flags_1.enable_64bit_addressing     */
    /* but we will ignore it and use BITS_PER_LONG macro to setup for    */
    /* 64 or 32 bit access of host memory in all x86/ia-64/Alpha systems */
    ha->flags.enable_64bit_addressing = 1;
#else
    ha->flags.enable_64bit_addressing = 0;
#endif

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,3,18)
    if (ha->flags.enable_64bit_addressing) {
      printk("[[[ qla1x160: 64 Bit PCI Addressing Enabled ]]]\n");

#if BITS_PER_LONG > 32
           /* Update our PCI device dma_mask for full 64 bit mask */
           //ha->pdev->dma_mask = (pci_dma_t) 0xffffffffffffffffull;
           ha->pdev->dma_mask =  0xffffffffffffffff;

#endif
    }
#endif

Jes cleaned this up a bit with his patch:

+      pci_set_dma_mask(ha->pdev, (dma_addr_t)~0ULL);                      


Thanks,
Matt


-- 
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux



> -----Original Message-----
> From: Wiegrefe, Don J [mailto:don.j.wiegrefe@intel.com]
> Sent: Tuesday, May 22, 2001 5:34 PM
> To: 'Michael Madore'; Matt_Domsch@exchange.dell.com
> Cc: linux-ia64@linuxia64.org
> Subject: RE: [Linux-ia64] 2.4.4 stability on Lions
> 
> 
> While it is true you should always use the latest BIOS that 
> matches your
> processor stepping ( in this case 76 ). The solution to your 
> problem is to
> alter your SCSI host adapter settings to operate > 4GB. If 
> you can use the
> SCSI FastUtil the setting to change is found under host 
> adapter settings.
>  Hope this helps. 
>  
>  Don Wiegrefe
>  Soft Sur/ Lion Hardware/BIOS Support
> 
> -----Original Message-----
> From: Michael Madore [mailto:mmadore@turbolinux.com]
> Sent: Tuesday, May 22, 2001 2:58 PM
> To: Matt_Domsch@Dell.com
> Cc: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] 2.4.4 stability on Lions
> 
> 
> I just noticed that the machine locked up on me while sitting 
> at the EFI
> shell prompt.  I've downloaded BIOS 76 (latest available on 
> Quad) and I'll
> see if that makes any difference.
> 
> On Tue, May 22, 2001 at 04:06:30PM -0500, Matt_Domsch@Dell.com wrote:
> > > Has anyone seem any instability with the 2.4.4 kernel + 
> > > David's patch on
> > > Lions?  I have been running it successfully on a 2P C0 Big 
> > > Sur with BIOS
> > > 103.  On a 4P C0 Lion with BIOS 73, however, I consistantly 
> > > get lockups
> > > after a short time.  Usually I get a totally black screen.  
> > > I'm going to try
> > > 2.4.3 and see if I still see the same problem.  2.4.2 seem to 
> > > work fine.
> > 
> > I had one lockup after about 18 hours of heavy stress 
> copy-and-compare and
> > NIC traffic last night.
> > 4P C0, Lion B2 board set, BIOS 80.  Black screen, no magic 
> sysrq.  I'm
> > trying to reproduce it now.
> > 
> > Under normal light loads I haven't seen any issues.
> > 
> > Thanks,
> > Matt
> > 
> > --
> > Matt Domsch
> > Sr. Software Engineer
> > Dell Linux Solutions
> > www.dell.com/linux
> 
> -- 
> Mike Madore
> Senior Software Engineer
> TurboLinux, Inc.
> (650)228-5203
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

