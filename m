From: Grant Grundler <grundler@cup.hp.com>
Date: Sat, 01 Feb 2003 05:34:08 +0000
Subject: Re: [Linux-ia64] CMD649 driver in 2.5.5x
Message-Id: <marc-linux-ia64-105590709805792@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805780@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805780@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> No, the IDE subsystem is actually back to basically 2.4.xx with "some"
> changes.  So it shouldn't be too bad.

"some" is pretty loosely defined (ide-cd.c, 2.4.20 vs 2.5.59):
o substantial changes in the request_sense error handling,
o a new interrupt handler,
o some sort of new block merging code (blk_attempt_remerge()).
o just for ide-cd.c, "diff -up" output is 2988 lines

But primarily, I'm concerned about these type of changes:

                if (info->cmd = READ) {
-                       info->dma = !HWIF(drive)->dmaproc(ide_dma_read, drive);
+                       info->dma = !HWIF(drive)->ide_dma_read(drive);
                } else if (info->cmd = WRITE) {
-                       info->dma = !HWIF(drive)->dmaproc(ide_dma_write, drive);
+                       info->dma = !HWIF(drive)->ide_dma_write(drive);
                } else {
                        printk("ide-cd: DMA set, but not allowed\n");

It means someone had to rewrite cmd64x.c to match those changes.
I was looking for one of the key changes to ide-cd (start DMA after
sending the cmd) and it is in 2.5.59.

The new block merging code (if used for ide-disk.c) could introduce the
kind of data corruption bug you saw.

I'll review cmd64x.c next.

>   Grant> I'll take a whack at it if we can get 2.5.59 to boot/run from our
>   Grant> CVS linux-2.5 (which is merged to 2.5.59).
> 
> OK, that would be great.  Thanks!

Well, as of this evening, I've hung my rx2600 (disabled offending features)
several times and most recently mca'd my rx2600 4 times. I'm still am not
clueful what is causing the MCA.

Anyone have a .config they know boots on rx2600?
I noticed I'm using CONFIG_IA64_HP_ZX1 and not CONFIG_IA64_DIG.
I might switch to DIG for now.

grant

