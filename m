From: "David S. Miller" <davem@redhat.com>
Date: Fri, 16 May 2003 02:08:27 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent
Message-Id: <marc-linux-ia64-105590723705885@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: James Bottomley <James.Bottomley@HansenPartnership.com>
   Date: 15 May 2003 21:05:12 -0500
   
   > Finally, I see nobody tackling the real hard bugs we have in the DMA
   > API.  These should be fixed first before adding random DMA behaviorial
   > attributes.  For example, pci_dma_sync_*() sucks because it only syncs
   > in one direction, device to cpu, there is nothing available to sync
   > things back from cpu-->device.  This prevents MIPS from using the
   > devices that need to do syncs without unmaps (eepro100 is but one
   > example, USB host controller drivers want this too).
   
   OK, I don't get this yet, doesn't DMA_TO_DEVICE do what you want?  what
   am I missing?
   
You don't understand, a driver does:

	pci_dma_sync_single(... buf);

This transfers ownership of the buffer from device back to the CPU.
It guarentees that the CPU will see uptodate contents of the buffer
and that it may make modifications to 'buf'.

Then it looks at 'buf', and decides that it wants to give the buffer
back to the device.  What does it call to transfer ownership back from
CPU to device?

Answer: No such API call exists.

This is a big problem for implementations that need to flush CPU
caches in order to implement the cpu<-->device buffer ownership
transfer properly.

