From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 04 Aug 2005 16:27:56 +0000
Subject: Re: 2.6.13-rc5 does not boot on Tiger4
Message-Id: <200508041027.56205.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeoe8fyrfb.fsf@sykes.suse.de>
In-Reply-To: <jeoe8fyrfb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 03 August 2005 10:24 pm, Alex Williamson wrote:
> On Thu, 2005-08-04 at 14:08 +1000, Peter Chubb wrote:
> > After I sorted out the console problem, it turns out that the MPT
> > fusion driver is no longer enabled in the ZX1_defconfig.
> > 
> > Should it be?  What machines is configs/zx1_defconfig supposed to
> > cover?  I thought it was for all non-NUMA HP machines with a ZX1
> > chipset --- zx2000, rx2600, etc.
> 
>    Yes, MPT is needed by default on several zx1 systems.

I think the MPT config options changed recently, so zx1_defconfig
is probably just a little out of date.

>    The zx1 
> machvec covers all HP boxes, zx1 & sx1000, so it would be nice if the
> zx1_defconfig worked on them all.  Or maybe we should have an
> sx1000_defconfig as well(?)

There's so little difference between zx1 and sx1000, I don't think
it's really worth having a separate defconfig for them.  I wouldn't
mind a more inclusive name than zx1_defconfig, though.  I tried
something like "HP" a while back, until somebody pointed out the
old HP i2000 (Intel 460GX-based).
