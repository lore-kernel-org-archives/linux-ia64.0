From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Mon, 06 Aug 2001 12:30:08 +0000
Subject: Re: [Linux-ia64] Kernel BUG report
Message-Id: <marc-linux-ia64-105590693006003@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005999@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005999@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 3 Aug 2001, Van Maren, Kevin wrote:

> This is in __free_pages_ok:
> 	if (page->mapping)
> =>		BUG();

It's hard to see a connection between this problem and the one you report
below.

> I've also been getting a LOT (100's, not 10's) of these:
>   Warning - running *really* short on DMA buffers
> which appear to be coming from the SCSI subsystem.

This comes from the mid SCSI layer. I wonder if it's possible that
there's still SCSI DMA memory shortage although the driver is capable
of 39-bit addressing. We know that this driver is very hungry for buffers,
especially if it has a lot of disks attached---However, with the new
driver, SCSI memory should only be allocated for bookeeping such as
scatter-gather lists, right?  It might be worthwile to watch
scsi_resize_dma_pool. In particular, I wonder whether

[l. 288 scsi_dma.c]
	/* limit DMA memory to 32MB: */
	new_dma_sectors = (new_dma_sectors + 15) & 0xfff0;

may be a problem with a very DMA-hungry driver ?

> Update: I ran the "test" again, and I got a bunch more "short on DMA
> buffers"
> messages, and then I got a bunch of lines like:
>   Segment 0xe000000228eb7840, blocks 2, addr 0x228eb13ff
> followed by:
>   Kernel panic:  Ththththaats all folks.  Too dangerous to continue.

Weird - this happens if the number of requests in a scatter-gather list
is incorrect. Again, doesn't look like a driver-related problem in the
first place, unless the driver intentionally or unintentionally overwrites
the scatter-gather data structures.

Have you informed Justin of the problem?
In any case, if you get more information, please keep me informed.

Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113




