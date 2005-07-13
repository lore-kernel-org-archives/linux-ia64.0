From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 13 Jul 2005 00:18:57 +0000
Subject: Re: [PATCH 2.6.13-rc1 03/10] IOCHK interface for I/O error
Message-Id: <1121213938.31924.406.camel@gaston>
List-Id: <linux-ia64.vger.kernel.org>
References: <42CB63B2.6000505@jp.fujitsu.com>
	 <42CB664E.1050003@jp.fujitsu.com>  <20050712195120.GE26607@austin.ibm.com>
In-Reply-To: <20050712195120.GE26607@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linas Vepstas <linas@austin.ibm.com>
Cc: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>


> Are you assuming that a device driver will use an iochk_read() for
> every DMA operation? for every MMIO to the card?  
> 
> For high performance devices, it seems to me that this will cause
> a rather large performance burden, especially if its envisioned that
> all architectures will do something similar.
> 
> My concern is that (at least on ppc64) the call pci_read_config_word()
> requires a call into "firmware" aka "BIOS", which takes thousands upon
> thousands of cpu cycles.  There are hundreds of cycles of gratuitous
> crud just to get into the firmware, and then lord-knows-what the
> firmware does while its in there; probably doing all sorts of crazy
> math to compute bus addresses and other arcane things.  I would imagine
> that most architectures, includig ia64, are similar.
> 
> Thus, one wouldn't want to perform an iochk_read() in this way unless
> one was already pretty sure that an error had already occured ... 
> 
> Am I misunderstanding something?

I would expect pSeries not to use the "default" error checking (that
tests the status register) but rather use EEH.

Ben.


