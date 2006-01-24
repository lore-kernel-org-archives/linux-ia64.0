From: Robin Holt <holt@sgi.com>
Date: Tue, 24 Jan 2006 17:00:34 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060124170034.GA3629@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jan 24, 2006 at 10:57:13AM -0600, Brent Casavant wrote:
> On Tue, 24 Jan 2006, Robin Holt wrote:
> 
> > The mspec driver does.  It has not gotten into the mainline kernel yet,
> > but we continue to build an add-on module for the necessary releases.
> > To prevent this out of order write from happening on those machines,
> > we require the process to be pinned to a single cpu.  For MPI, this
> > is a normal way to operate for other reasons as well.
> 
> Oh, this problem affects mspec as well?  I didn't realize that.  You're
> saying that uncached memory writes are the same as PIO writes, as far
> as Shub is concerned?  If so, then the patch I'm trying to work through
> here should solve your problem as well.

Sorry, I wrote that before having any morning coffee.  mspec driver is
uncached space so ignore my earlier rambling.

Thanks,
Robin
