From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 12 Aug 2004 23:30:55 +0000
Subject: Re: r996 - in trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7: . debian
Message-Id: <200408121630.55814.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040810071417.GA5080@lst.de>
In-Reply-To: <20040810071417.GA5080@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, August 12, 2004 4:03 pm, dann frazier wrote:
> On Tue, Aug 10, 2004 at 09:14:17AM +0200, Christoph Hellwig wrote:
> > Btw, where is this patch from and why wasn't it discussed on linux-ia64?
>
> Alex Williamson sent it to me a few patches to fix build problems on
> an earlier 2.6 kernel - this is one that I still need when building
> UP kernels w/ 2.6.7.  Here's where the builds fail (both using the
> attached config).
>
> If I remove this patch, it forces DISCONTIGMEM on, which doesn't build w/o
> SMP:

I think you'll need CONFIG_NUMA and CONFIG_SMP for a generic kernel.

Jesse
