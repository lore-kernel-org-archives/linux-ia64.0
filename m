From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Sat, 17 May 2003 18:36:01 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent
Message-Id: <marc-linux-ia64-105590723705924@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2003-05-16 at 13:18, Russell King wrote:
> Isn't the common use (eg, net devices):
> 
> 	buffer passed from lower levels
> 
> 	map buffer
> 
> 	(device owns buffer)
> 
> 	device uses buffer
> 
> 	unmap buffer
> 
> 	(cpu owns buffer)
> 
> 	free buffer
> 
> So, to use your example:
> 
> 	(cpu owns region)
> 
> 	map
> 
> 	(device owns region)
> 
> 	dma_sync...cpu
> 
> 	(cpu owns region)
> 
> 	dma_sync...device
> 
> 	(device owns region)
> 
> 	unmap
> 
> 	(cpu owns region)

A grep through the tree implies that you (for arm) and me (for parisc)
are the only current implementors of the dma_ API.

The only consumers seem to be:  lasi_82596, 53c700 and sym53c8xx_comm.h
(all of which I did anyway), and usb/core/usb.c

How would you feel about making this API change?  I take it you have a
preference for using _to_cpu and _to_device call variants?

James




