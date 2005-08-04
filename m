From: Alex Williamson <alex.williamson@hp.com>
Date: Thu, 04 Aug 2005 04:24:17 +0000
Subject: Re: 2.6.13-rc5 does not boot on Tiger4
Message-Id: <1123129457.28064.37.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeoe8fyrfb.fsf@sykes.suse.de>
In-Reply-To: <jeoe8fyrfb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2005-08-04 at 14:08 +1000, Peter Chubb wrote:
> After I sorted out the console problem, it turns out that the MPT
> fusion driver is no longer enabled in the ZX1_defconfig.
> 
> Should it be?  What machines is configs/zx1_defconfig supposed to
> cover?  I thought it was for all non-NUMA HP machines with a ZX1
> chipset --- zx2000, rx2600, etc.

   Yes, MPT is needed by default on several zx1 systems.  The zx1
machvec covers all HP boxes, zx1 & sx1000, so it would be nice if the
zx1_defconfig worked on them all.  Or maybe we should have an
sx1000_defconfig as well(?)  I typically use the default (generic)
defconfig, so I don't tend to notice when the zx1 file gets stale.  I've
been running happily on zx1 w/ defconfig on -rc5.  Thanks,

	Alex

