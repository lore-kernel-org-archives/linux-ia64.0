From: Brent Casavant <bcasavan@sgi.com>
Date: Mon, 14 Apr 2008 21:59:07 +0000
Subject: Re: [2.6 patch] add SGI_IOC4 hardware dependencies
Message-Id: <alpine.BSF.1.10.0804141615030.52763@pkunk.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080413181543.GF2182@cs181133002.pp.htv.fi>
In-Reply-To: <20080413181543.GF2182@cs181133002.pp.htv.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 14 Apr 2008, Adrian Bunk wrote:

> On Mon, Apr 14, 2008 at 02:40:37PM -0500, Brent Casavant wrote:
> > On Sun, 13 Apr 2008, Adrian Bunk wrote:
> > 
> > > Considering that all users of this code depend on
> > > (IA64_SGI_SN2 || IA64_GENERIC) the SGI_IOC4 option
> > > should also depend on it.
> > > 
> > > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> > 
> > Tony,
> > 
> > Please don't apply this yet.  I'll need some guidance from Adrian
> > and you on how to proceed.
> > 
> > The IOC4 chip _is_ available on a PCI card for x86 based systems.
> > And that is why I removed the dependence of the config option on
> > IA64_SGI_SN2 || IA64_GENERIC.
> > 
> > Unfortunately the only user of IOC4 on x86 is the "external interrupt"
> > IOC4 sub-driver which is available under the GPL, but was not accepted
> > into the Linux kernel.
> >...
> 
> I wasn't aware of that driver.

No big deal.  It's not very well publicized, and as I mentioned I
overlooked making it easily available for download (we do make the
source available on physical media to everyone we send precompiled
binaries to).  I'm working on rectifying that oversight.

> Why wasn't it accepted?

The short answer is (to paraphrase) "the code is too complex for a
one-off device".

The linux-kernel thread regarding this begins with these three posts:

	http://marc.info/?l=linux-kernel&m2448872525388&w=2
	http://marc.info/?l=linux-kernel&m2448872506580&w=2
	http://marc.info/?l=linux-kernel&m2448872526711&w=2

(Don't look too hard at the code, it's been improved since then.  But
the general structure remains the same.)

Curiously enough I can't find the message where there were complaints
about it being too complex.  I wonder if those only came to me privately.
I was a bit more timid in my early lkml experience, and might have been
too easily dissuaded from pursuing this. Anyway. . .

In order to present a common method of interacting with external
interrupt hardware to user space (i.e. present a common set of
/sys/class/extint/*/* files and operations), I split the external
interrupt driver into two parts.  This was done so that not only would
the IOC4 chip would be supported, but so that if there was interest
someone else could write external interrupt support for the IOC3
chip, or use this same interface as a generic mechanism for any
similar device other parties may provide.

The first "low level" part is the section resposible for functioning
the underlying hardware.  The second "abstraction" part exports the
consistent user-visible portions (i.e. the /sys/class and /dev interfaces).
These two portions interact with one another to abstract away all
the nitty-gritty low-level details of the hardware, such that the
user doesn't have to be concerned with what hardware device is
at the bottom of the stack.  Sort of like how you don't worry which
Ethernet controller is being used when writing (most) networking
applications.

As you can imagine, this means there was a whole layer of interface
between the low-level and abstraction driver that was generalized to
handle the needs of both.  I submitted only a single low-level driver
(for IOC4) as part of the original patch set, as that's all I had
written.  The patch set was rejected because it was carrying around far
too much complexity/generality for the one device which would use it.

It's hard to argue that such complaints were invalid given what I'd
submitted. :)

Since then I've had the Linux MIPS folks ask me about this code at a
few points in time, as they might want to use it for the IOC3 present
on SGI's old Octane and Origin 2000 machines.  Also, as SGI moves onto
newer platforms we're investigating replacing the IOC4-based devices with
something else, hopefully that we don't have to build ourselves.  We
would certainly be looking to fit any such device into the existing
external interrupt framework.  At that point it would become a lot
easier to justify the additional complexity of the abstraction layer,
but sadly we're not there yet.

I hope that's some useful background.

Looking again at the feedback I received originally, I may just have
been too timid to push this for inclusion.  Perhaps I need to try
again with the latest and greatest.

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
