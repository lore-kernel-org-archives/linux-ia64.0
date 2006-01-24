From: Grant Grundler <iod00d@hp.com>
Date: Tue, 24 Jan 2006 16:40:55 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060124164055.GB1528@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jan 24, 2006 at 06:10:52AM -0600, Robin Holt wrote:
> > OK - just not many user space programs map uncache IO space.
> 
> The mspec driver does.  It has not gotten into the mainline kernel yet,
> but we continue to build an add-on module for the necessary releases.

I don't know what mspec driver does. I'll guess it's something
similar to RDMA but using altix/sn2 chipset as the "fabric".
Ie part of the "driver" is really a user space lib.

> To prevent this out of order write from happening on those machines,
> we require the process to be pinned to a single cpu.  For MPI, this
> is a normal way to operate for other reasons as well.

My objective was to figure out if the kernel could detect when an
application might access MMIO space and then a platform vector
could be invoked to deal with the MMIO write ordering.

But maybe that's not necessary if you can avoid the problem by
pinning the process in the mspec user space library. Then
the whole problem of process migration can be handled
in mspec user library, no?

Maybe that's a moot discussion.

> Brent, if you find a way to prevent this out-of-order write, please
> remind me to include it in the mspec driver.

RDMA support will need something more general.
(I'm asuming mspec is sn2 specific.)

thanks,
grant
