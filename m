From: "Martin K. Petersen" <martin.petersen@oracle.com>
Date: Wed, 09 Sep 2020 02:09:14 +0000
Subject: Re: [PATCH 00/29] treewide: Convert comma separated statements
Message-Id: <159961731707.5787.13988542229153933257.b4-ty@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1598331148.git.joe@perches.com>
In-Reply-To: <cover.1598331148.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linuxppc-dev@lists.ozlabs.org, linux-ide@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-hwmon@vger.kernel.org, Joe Perches <joe@perches.com>, oprofile-list@lists.sf.net, linux-fsdevel@vger.kernel.org, linux-media@vger.kernel.org, linaro-mm-sig@lists.linaro.org, drbd-dev@tron.linbit.com, intel-gfx@lists.freedesktop.org, linux-arm-kernel@lists.infradead.org, linux-input@vger.kernel.org, linux-nfs@vger.kernel.org, netdev@vger.kernel.org, reiserfs-devel@vger.kernel.org, linux-bcache@vger.kernel.org, Jiri Kosina <trivial@kernel.org>
Cc: "Martin K . Petersen" <martin.petersen@oracle.com>, sparclinux@vger.kernel.org, linux-mtd@lists.infradead.org, linux-s390@vger.kernel.org, linux-doc@vger.kernel.org, linux-block@vger.kernel.org, linux-ia64@vger.kernel.org, linux-pm@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-fbdev@vger.kernel.org, devel@driverdev.osuosl.org, linux-scsi@vger.kernel.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 24 Aug 2020 21:55:57 -0700, Joe Perches wrote:

> There are many comma separated statements in the kernel.
> See:https://lore.kernel.org/lkml/alpine.DEB.2.22.394.2008201856110.2524@hadrien/
> 
> Convert the comma separated statements that are in if/do/while blocks
> to use braces and semicolons.
> 
> Many comma separated statements still exist but those are changes for
> another day.
> 
> [...]

Applied to 5.10/scsi-queue, thanks!

[01/29] coding-style.rst: Avoid comma statements
        (no commit info)
[02/29] alpha: Avoid comma separated statements
        (no commit info)
[03/29] ia64: Avoid comma separated statements
        (no commit info)
[04/29] sparc: Avoid comma separated statements
        (no commit info)
[05/29] ata: Avoid comma separated statements
        (no commit info)
[06/29] drbd: Avoid comma separated statements
        (no commit info)
[07/29] lp: Avoid comma separated statements
        (no commit info)
[08/29] dma-buf: Avoid comma separated statements
        (no commit info)
[09/29] drm/gma500: Avoid comma separated statements
        (no commit info)
[10/29] drm/i915: Avoid comma separated statements
        (no commit info)
[11/29] hwmon: (scmi-hwmon): Avoid comma separated statements
        (no commit info)
[12/29] Input: MT - Avoid comma separated statements
        (no commit info)
[13/29] bcache: Avoid comma separated statements
        (no commit info)
[14/29] media: Avoid comma separated statements
        (no commit info)
[15/29] mtd: Avoid comma separated statements
        (no commit info)
[16/29] 8390: Avoid comma separated statements
        (no commit info)
[17/29] fs_enet: Avoid comma separated statements
        (no commit info)
[18/29] wan: sbni: Avoid comma separated statements
        (no commit info)
[19/29] s390/tty3270: Avoid comma separated statements
        (no commit info)
[20/29] scsi: arm: Avoid comma separated statements
        https://git.kernel.org/mkp/scsi/c/a08a07326510
[21/29] media: atomisp: Avoid comma separated statements
        (no commit info)
[22/29] video: fbdev: Avoid comma separated statements
        (no commit info)
[23/29] fuse: Avoid comma separated statements
        (no commit info)
[24/29] reiserfs: Avoid comma separated statements
        (no commit info)
[25/29] lib/zlib: Avoid comma separated statements
        (no commit info)
[26/29] lib: zstd: Avoid comma separated statements
        (no commit info)
[27/29] ipv6: fib6: Avoid comma separated statements
        (no commit info)
[28/29] sunrpc: Avoid comma separated statements
        (no commit info)
[29/29] tools: Avoid comma separated statements
        (no commit info)

-- 
Martin K. Petersen	Oracle Linux Engineering
