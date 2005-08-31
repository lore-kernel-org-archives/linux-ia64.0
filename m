From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Wed, 31 Aug 2005 15:52:29 +0000
Subject: RE: Xen and the Art of Linux/ia64 Virtualization
Message-Id: <516F50407E01324991DD6D07B0531AD56954B5@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
In-Reply-To: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> On 8/30/05, Keith Owens <kaos@sgi.com> wrote:
> > Tony, can you give some indication on your plans for my MCA/INIT
> > rewrite?  Will you send it to Linus in the next couple of weeks or
will
> > it have to wait for 2.6.15 to open?

Same question as as Keith but for the virtualization prep patch...
the patch is strictly syntactic with !CONFIG_XEN but
is a necessary foundation for which to build Xen/ia64 on top of
in the future and has been generalized so that it should serve
well for yet-to-be-defined non-Xen paravirtualization approaches.
It's been reviewed by the key Linux/ia64 developers (with
feedback/changes incorporated) and also by Chris Wright who is
working with Linus to get a similar (but orthogonal) set of
changes into Linux/x86.

Is it time yet?

Thanks,
Dan

> Sent: Monday, August 29, 2005 1:12 PM
> To: linux-ia64@vger.kernel.org; tony.luck@intel.com
> Subject: Re: Xen and the Art of Linux/ia64 Virtualization
> 
> Final revision, this one regen'd against 2.6.13.
> Incorporates some minor feedback from Chris Wright
> and Arun Sharma.
> 
> Tony, please apply!
> 
> Thanks,
> Dan Magenheimer
> HP Labs
> 
> > -----Original Message-----
> > From: Magenheimer, Dan (HP Labs Fort Collins) 
> > Sent: Friday, August 12, 2005 4:09 PM
> > To: 'linux-ia64@vger.kernel.org'
> > Cc: 'tony.luck@intel.com'
> > Subject: RE: Xen and the Art of Linux/ia64 Virtualization
> > 
> > Revision 5.  Incorporates abstraction changes to ia64_getreg
> > and ia64_setreg as suggested by David Mosberger and Tony
> > Luck.  Also generalized a bit so that it will be easy to
> > support other virtualization software that may come along.
> > This patch is currently against 2.6.12 (thus for review only).
> > 
> > Signed-off-by: Dan Magenheimer <dan.magenheimer@hp.com>
> > 
> > Tony, I think this is now ready to go.  I suppose the best
> > thing would be for me to regenerate this against 2.6.13
> > as soon as it comes out?
> > 
> > I've also attached include/asm-ia64/xen/privop.h.  Note
> > that this is not quite final but is provided for now as
> > a well-documented (para)virtualization example which
> > should answer many questions.
> > 
> > Dan
> > 
> > > -----Original Message-----
> > > From: Magenheimer, Dan (HP Labs Fort Collins) 
> > > Sent: Thursday, July 28, 2005 4:39 PM
> > > To: 'linux-ia64@vger.kernel.org'
> > > Cc: 'tony.luck@intel.com'
> > > Subject: RE: Xen and the Art of Linux/ia64 Virtualization
> > > 
> > > Revision 4.  Minor formatting change suggested by
> > > Christoph.  Also, no change for "symmetry" suggested
> > > by Christoph as Tony wanted to leave as is. 
> > > 
> > > Tony I think this is now ready to apply.  If there is
> > > anything else needed, please let me know.
> > > 
> > > Thanks,
> > > Dan Magenheimer
> > > 
> > > > -----Original Message-----
> > > > From: Magenheimer, Dan (HP Labs Fort Collins) 
> > > > Sent: Thursday, July 14, 2005 3:18 PM
> > > > To: 'linux-ia64@vger.kernel.org'
> > > > Subject: RE: Xen and the Art of Linux/ia64 Virtualization
> > > > 
> > > > Revision 3.  Incorporates some more feedback and
> > > > a minor bug fix.
> > > > 
> > > > Dan
> > > > 
> > > > > -----Original Message-----
> > > > > From: Magenheimer, Dan (HP Labs Fort Collins) 
> > > > > Sent: Wednesday, July 06, 2005 2:47 PM
> > > > > To: 'linux-ia64@vger.kernel.org'
> > > > > Subject: RE: Xen and the Art of Linux/ia64 Virtualization
> > > > > 
> > > > > The patch I posted yesterday had a couple of bugs.
> > > > > This version applies cleanly against 2.6.12 and
> > > > > (when augmented with additional files from various
> > > > > Xen subdirectories) has been booted both on Xen/ia64
> > > > > and on hardware.
> > > > > 
> > > > > Note that a patch to drivers/acpi/motherboard.c (that
> > > > > allows for acpi to be enabled on a stubbed acpi tree
> > > > > without a kernel null pointer dereference!) is required
> > > > > and has been submitted separately to the linux-acpi list.
> > > > > 
> > > > > With the exception of three short CONFIG_XEN
> > > > > ifdefs, the vast majority of changes in this patch
> > > > > are code rearrangement to enable a number of routines
> > > > > and defines to add one level of abstraction.
> > > > > 
> > > > > Comments and feedback would be much appreciated!
> > > > > 
> > > > >  arch/ia64/Kconfig             |    7 +
> > > > >  arch/ia64/Makefile            |    1 
> > > > >  arch/ia64/hp/sim/Makefile     |    2 
> > > > >  arch/ia64/ia32/elfcore32.h    |    2 
> > > > >  arch/ia64/ia32/ia32_signal.c  |    6 -
> > > > >  arch/ia64/ia32/ia32_support.c |    4 -
> > > > >  arch/ia64/kernel/entry.S      |   30 ++++---
> > > > >  arch/ia64/kernel/head.S       |    4 +
> > > > >  arch/ia64/kernel/irq_ia64.c   |   12 +--
> > > > >  arch/ia64/kernel/pal.S        |    5 -
> > > > >  arch/ia64/kernel/setup.c      |    3 
> > > > >  include/asm-ia64/delay.h      |   53 -------------
> > > > >  include/asm-ia64/privop.h     |  160 
> > > > > ++++++++++++++++++++++++++++++++++++++++++
> > > > >  include/asm-ia64/processor.h  |   56 --------------
> > > > >  include/asm-ia64/system.h     |   12 +--
> > > > >  15 files changed, 217 insertions(+), 140 deletions(-)
> > > > > 
> > > > > > -----Original Message-----
> > > > > > From: Magenheimer, Dan (HP Labs Fort Collins) 
> > > > > > Sent: Tuesday, July 05, 2005 2:21 PM
> > > > > > To: linux-ia64@vger.kernel.org
> > > > > > Subject: RE: Xen and the Art of Linux/ia64 Virtualization
> > > > > > 
> > > > > > Thanks to excellent feedback from David Mosberger and
> > > > > > Christophe Hellwig, I have greatly cleaned up the attached
> > > > > > patch by using some very nice abstractions.  In fact,
> > > > > > most of the bulk in the attached patch results from
> > > > > > moving some code from asm-ia64/{delay,processor}.h to
> > > > > > a new file, asm-ia64/privop.h.  And the number of
> > > > > > CONFIG_XEN ifdefs is dramatically reduced.
> > > > > > 
> > > > > > More feedback appreciated (including comments about how
> > > > > > close this might be to be ready for submission to Tony).
> > > > > > 
> > > > > > Thanks,
> > > > > > Dan Magenheimer
> > > > > > 
> > > > > > P.S. Anybody who is attending OLS who wants to talk about
> > > > > > Xen (and specifically Xen/ia64)?  I'll be there... send
> > > > > > me email.
> > > > > > 
> > > > > 
> > > > 
> > > 
> > 
> 
