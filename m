From: Andi Kleen <ak@suse.de>
Date: Wed, 28 Jan 2004 17:41:37 +0000
Subject: Re: [RFC/PATCH, 1/4] readX_check() performance evaluation
Message-Id: <20040128184137.616b6425.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <00a201c3e541$c0e7d680$2987110a@lsd.css.fujitsu.com>
	<20040128172004.GB5494@cup.hp.com>
In-Reply-To: <20040128172004.GB5494@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: ishii.hironobu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 28 Jan 2004 09:20:04 -0800
Grant Grundler <iod00d@hp.com> wrote:


> I could be wrong. Exception handling is ugly. But my hope is that
> by putting all the exception handling in one place in the driver,
> the driver will be forced to be methodical in being "deterministic"
> WRT to driver state and can return to a known state by calling one
> routine. This will keep the drivers maintainable by "part-time hackers"
> who don't care about error recovery.

One big problem is how to get rid of the spinlocks after the exception though
(hardware access usually happens inside a spinlock) 

I presume you could return a magic value (all ones), but then you still
have to make sure the driver doesn't break when that happens. That would
likely require testing for that value on every read access and make
the code similarly ugly and difficult to write as with Linus' 
explicit checking model.

But there may be no other choice, see below...


> >        I know, unfortunately, that i386 can't support this kind
> >        of I/F, because it can't recover from machine check state.
> 
> I think i386 could. The method to check for errors will be different
> and the types of errors which are detectable are fewer.

Yes, there are often magic bits in northbridges and chipsets. Problem is that 
they're sometimes buggy (because not well tested) and give random errors.

Also enabling them tends to trigger a *lot* of bugs in random drivers.

> I'm not sure it would be recoverable though. But it should be able

They usually give an MCE, but it is not exact for writes (happens sometime
later) and may not even be for reads.

The only sane way to handle them would be a global call back per pci_dev,
but then you run into problems with the locking again.

Also in my experience from AMD64 which originally was a bit aggressive
on enabling MCEs: enabling MCEs increases your kernel support load a lot.

Many people have slightly buggy systems which still happen to work mostly.
If you report every problem you as kernel maintainer will be flooded with
reports about things you can nothing to do about. So I don't think it would
make sense to enable it by default.

One idea I played with was to only enable it for driver debugging, but
it is hard to educate driver developers about it (most just don't know 
about it and we have no way to pass information to them). In the end 
I removed it because it was too much hazzle. In short this stuff
probably only makes sense when you're a system vendor who sells
support contracts for whole systems including hardware support.
For the normal linux model where software is independent from hardware
(and hardware is usually crappy) it just doesn't work very well.

-Andi
