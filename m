From: Marc Aurele La France <tsi@gpu.srv.ualberta.ca>
Date: Mon, 21 Aug 2000 16:12:33 +0000
Subject: [Linux-ia64] IA-64 XFree86 (was: XFree 4.0.1 module loading)
Message-Id: <marc-linux-ia64-105590678205361@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 17 Aug 2000, Stuart Anderson wrote:

> On Wed, 16 Aug 2000, Marc Aurele La France wrote:

> > On Fri, 11 Aug 2000, Keith Owens wrote:

> > > >> I guess my question now is:  Should the dlopen() loader be able to
> > > >> resolve inter-module dependencies?  If not, what is left to be done with
> > > >> the elf loader make it functional on IA64?

> > > >Support for the ELF64 relocation types. Just like a block of code was added
> > > >for Alpha support, the same type of thing will have to be added for IA64.

> > > modutils 2.3.13 has IA64 relocation support, courtesy of Mike Stephens
> > > at Intel.  obj/obj_ia64.c should be a reasonable starting point.

> > Is anyone going ahead with this?  If not, I can probably come pretty close
> > to getting it working even though I'd be going in blind (no hardware).

> > Let me know.

> I've received some code, and should have hardware soon, so I was planning
> on working on it.

ATI is funding me to go to their labs near Toronto from 2000.09.13 to
2000.09.22 and work on IA-64 support.  This despite that they are aware
Michael Madore has both the ATI and R128 drivers working reasonably well.
I see this as a measure of how important they feel IA-64 support this.  I
agree with them.  And so, my goal with this "outing" will be to bring
XFree86's IA-64 server up to as close to an "out-of-the-box" condition as
I can, using what we currently provide on IA-32 as a benchmark.

So that I don't end up duplicating effort and/or working in the dark, I'd
like us to coordinate our efforts.

First, I ask David Dawes or Keith Packard to set up an XFree86-internal
mailing list, say ia64@xfree86.org.  At this point, I don't think this
list should be public.  Its initial membership would be

	Stuart Anderson <anderson@metrolink.com>
	David Dawes <dawes@xfree86.org>
	Dirk Hohndel <hondel@suse.de>
	Marc Aurele La France <tsi@ualberta.ca>
	Michael Madore <mmadore@turbolinux.com>
	Bill Nottingham <notting@redhat.com>
	Keith Owens <kaos@ocs.com.au>
	Michael Smith <msmith@ati.com>
	Mark Vojkovich <mvojkovich@valinux.com>

... and anyone else willing to participate.

Second, I propose we use XFree86's CVS repository as a common code base.
I'd like to check in all the work that has been done so far, warts
included.

Third, I ask everyone here with IA-64 hardware and compilation environment
to give the server a reasonably thorough shakedown, and report on and/or
fix what falls out.  In terms of a status report, I am currently aware of
the following:

        - ATI and R128 drivers work OK (Michael Madore)
        - MGA and R128 drivers work OK (Mark Vojkovich)
        - The loader needs to be changed to understand the IA64 flavour of
          ELF64.  From the above, it appears that Stuart has volunteered
          for this one ;-)
        - SIGILL's in VBE, probably related to int10 (Michael Madore)
	- SIGSEGV's when loading/unloading pcidata and scanpci modules
          (Michael Madore).

This is surely incomplete and needs to be kept up to date.

These's a non-zero probability that most issues will be resolved by the
time I get to ATI's labs, but I'm willing to accept that risk.  There are
lots of other things I can talk to ATI about anyway.

I might be way off base on this one, but I believe the development of an
out-of-the-box XFree86 IA-64 server to be important, crucial even.  It is
my understanding that IA-64 systems have yet to hit the streets.  If so,
then we have an opportunity to preempt, or at least match, MS's entry into
this market.  Also, it's just a matter of time before the *BSD's join the
IA-64 bandwagon, and XFree86 should be ready for them.

So, please, let's get our act together and have something to show for our
efforts by 2000.09.22.

Thanks.

Marc.

+----------------------------------+-----------------------------------+
|  Marc Aurele La France           |  work:   1-780-492-9310           |
|  Computing and Network Services  |  fax:    1-780-492-1729           |
|  352 General Services Building   |  email:  tsi@ualberta.ca          |
|  University of Alberta           +-----------------------------------+
|  Edmonton, Alberta               |                                   |
|  T6G 2H1                         |     Standard disclaimers apply    |
|  CANADA                          |                                   |
+----------------------------------+-----------------------------------+
XFree86 Core Team member.  ATI driver and X server internals.


