From: Robin Holt <holt@sgi.com>
Date: Tue, 24 Jan 2006 12:10:52 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060124121052.GC5334@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jan 23, 2006 at 11:04:21PM -0800, Grant Grundler wrote:
> On Tue, Jan 24, 2006 at 12:30:42AM -0600, Brent Casavant wrote:
> > On Mon, 23 Jan 2006, Grant Grundler wrote:
> > > Would an app first need to mmap an uncached address?
> > > Or some other obvious "marker" that might warn the kernel?
> > 
> > I'm not sure an uncached address would be appropriate, as I
> > believe there are other non-IO uncached mappings which can
> > be performed (whatever the fetchop stuff morphed into, for
> > example -- I can't remember what its called now).
> 
> OK - just not many user space programs map uncache IO space.

The mspec driver does.  It has not gotten into the mainline kernel yet,
but we continue to build an add-on module for the necessary releases.
To prevent this out of order write from happening on those machines,
we require the process to be pinned to a single cpu.  For MPI, this
is a normal way to operate for other reasons as well.

Brent, if you find a way to prevent this out-of-order write, please
remind me to include it in the mspec driver.

Thanks,
Robin
