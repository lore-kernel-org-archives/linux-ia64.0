From: grundler@cup.hp.com (Grant Grundler)
Date: Thu, 30 Jan 2003 21:58:13 +0000
Subject: Re: [Linux-ia64] CMD649 driver in 2.5.5x
Message-Id: <marc-linux-ia64-105590709805781@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805780@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805780@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 30, 2003 at 08:37:12AM -0800, David Mosberger wrote:
> As of 2.5.59, the CMD649 IDE driver is still completely hosed.  It
> reliably corrupts filesystems and trying to turn on DMA mode on a
> zx1-based machine will cause an I/O TLB error.

I'm pretty sure RH AS and 2.4.20 isn't seeing those kinds of problems.
It's been passing stress testing and such. I suspect the problem
is someone is rewriting the IDE subsystem and maybe some changes
are needed to adopt cmd649 for that. Khalid would be the right
person to look at this but he's back working on Telco stuff again.

> The backtrace starts
> like this:
> 
>  [<e0000000048c4b50>] sba_map_sg+0x410/0x7a0 sp=0xe00000003d6afc90 bsp=0xe00000003d6a94d0
>  [<e0000000047de490>] ide_build_dmatable+0x330/0x340 sp=0xe00000003d6afcb0 bsp=0xe00000003d6a9478
>  [<e0000000047defd0>] ide_start_dma+0x50/0x1a0 sp=0xe00000003d6afcb0 bsp=0xe00000003d6a9438
>  [<e0000000047df190>] __ide_dma_read+0x70/0x260 sp=0xe00000003d6afcb0 bsp=0xe00000003d6a9400
>  [<e0000000047c64e0>] do_rw_disk+0x4a0/0x1220 sp=0xe00000003d6afcb0 bsp=0xe00000003d6a9358

IIRC, cmd649 driver isn't involved with DMA table/DMA mapping and this
stack trace suggests that's still true.

> Someone want to take a look?

I'll take a whack at it if we can get 2.5.59 to boot/run from our
CVS linux-2.5 (which is merged to 2.5.59).

grant

