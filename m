From: Jeff Garzik <jgarzik@pobox.com>
Date: Thu, 11 Aug 2005 21:56:21 +0000
Subject: Re: [PATCH] IDE: don't offer IDE_GENERIC on ia64
Message-Id: <42FBC985.4030602@pobox.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200508111424.43150.bjorn.helgaas@hp.com> <200508111445.41428.bjorn.helgaas@hp.com> <42FBBB6F.1030306@pobox.com> <200508111542.07851.bjorn.helgaas@hp.com> <20050811214807.GA9775@havoc.gtf.org>
In-Reply-To: <20050811214807.GA9775@havoc.gtf.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: B.Zolnierkiewicz@elka.pw.edu.pl, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>

Jeff Garzik wrote:
> 00:1f.1 IDE interface: Intel Corporation 82801EB/ER (ICH5/ICH5R) IDE Controller 
> (rev 02) (prog-if 8a [Master SecP PriP])
>         Subsystem: Hewlett-Packard Company d530 CMT (DG746A)
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step
> ping- SERR- FastB2B-
>         Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort
> - <MAbort- >SERR- <PERR-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 169
>         Region 0: I/O ports at <ignored>
>         Region 1: I/O ports at <ignored>
>         Region 2: I/O ports at <ignored>
>         Region 3: I/O ports at <ignored>
>         Region 4: I/O ports at 14c0 [size]
>         Region 5: Memory at 40000000 (32-bit, non-prefetchable) [size=1K]
> 
> 
> 
> Trust me, IDE on PCI is still quite weird.

The above configuration also indicates that the IRQs for the PCI device 
are 14 and 15, _not_ 169.

	Jeff


