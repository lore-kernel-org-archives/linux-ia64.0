From: "White, Charles" <Charles.White@COMPAQ.com>
Date: Mon, 09 Jul 2001 15:33:24 +0000
Subject: RE: [Linux-ia64] RE: DMA memory limitation?
Message-Id: <marc-linux-ia64-105590693005829@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005820@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005820@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yes, I thought about doing it that way, and it COULD be done, but right now
the driver allocates command buffer for IOCTLs as needed.  

So the pci_dev set to NULL allows to continue to do that... 

		-----Original Message-----
		From:	Matt_Domsch@Dell.com [mailto:Matt_Domsch@Dell.com]
		Sent:	Monday, July 09, 2001 10:20 AM
		To:	White, Charles
		Cc:	linux-ia64@linuxia64.org
		Subject:	RE: [Linux-ia64] RE: DMA memory limitation?

		> My device has the limitation that the command buffers I
send 
		> must be in 32
		> bit space, but the IO can be in 64 bit.  But there is only

		> ONE dma_mask for the device.

		Ahh, yes.  The AMI MegaRAID driver/controllers have the same
requirements.
		megaraid solved it as:

		pci_find_device() finds their device, they get a pci_dev
back which has a
		32-bit dma_mask.
		pci_alloc_consistent() the mailbox (this must be in 32-bit
space).
		if it's a 64-bit-capable controller, set pci_dev->dma_mask ~0L.
		pci_alloc_consistent() the command buffers and
scatter-gather lists (these
		can be in 64-bit space).

		Could something similar work for you?

		Thanks,
		Matt

		--
		Matt Domsch
		Sr. Software Engineer
		Dell Linux Solutions
		www.dell.com/linux
		#2 Linux Server provider with 17% in the US and 14%
Worldwide (IDC)!
		#3 Unix provider with 18% in the US (Dataquest)!
		

