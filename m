From: Grant Grundler <iod00d@hp.com>
Date: Wed, 28 Jan 2004 19:09:23 +0000
Subject: Re: [RFC/PATCH, 1/4] readX_check() performance evaluation
Message-Id: <20040128190923.GA6333@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <00a201c3e541$c0e7d680$2987110a@lsd.css.fujitsu.com> <20040128172004.GB5494@cup.hp.com> <20040128184137.616b6425.ak@suse.de>
In-Reply-To: <20040128184137.616b6425.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: ishii.hironobu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, Jan 28, 2004 at 06:41:37PM +0100, Andi Kleen wrote:
> > I could be wrong. Exception handling is ugly.
...
> One big problem is how to get rid of the spinlocks after the exception though
> (hardware access usually happens inside a spinlock) 
> 
> I presume you could return a magic value (all ones), but then you still
> have to make sure the driver doesn't break when that happens.

yes - any proposal is going to require reviewing all PIO reads
and how the read return value is consumed (or discarded).

> That would
> likely require testing for that value on every read access and make
> the code similarly ugly and difficult to write as with Linus' 
> explicit checking model.

yeah. My hope was it would be less invasive.
But more changes are probably needed than I expected.

...
> In short this stuff
> probably only makes sense when you're a system vendor who sells
> support contracts for whole systems including hardware support.
> For the normal linux model where software is independent from hardware
> (and hardware is usually crappy) it just doesn't work very well.

While ia64/parisc platforms have HW support for this,
I totally agree it won't work well for most (x86) platforms.
I'd like to reduce the burden on the driver writers for common
drivers (eg MPT) used on "vanilla" x86.

And like I pointed out before, linux kernel needs to review panic()
calls to see if some of them could easily be eliminated. The general
robustness issues (eg pci_map_single() panics on failure) aren't
prerequisites for IO error checking, but the latter seems less
useful with out the former.

I'd like to defend the pci_map_single() interface. It was designed
to reduce the complexity at the cost of robustness.
I think it was a fair trade off at the time and it sounds like
the time has come for a different trade off.

thanks,
grant

> -Andi
