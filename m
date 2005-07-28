From: david mosberger <dmosberger@gmail.com>
Date: Thu, 28 Jul 2005 23:13:19 +0000
Subject: Re: Xen and the Art of Linux/ia64 Virtualization
Message-Id: <ed5aea4305072816132b98afcf@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
In-Reply-To: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Dan,

I was hoping someone else would bring this up, but alas....

Why do you need to split getreg into get_eflag etc?  By definition,
wherever you call get_eflag, you have a getreg(R) call with R a
constant (and, in this case, R=_IA64_REG_AR_EFLAG).  Thus, you can
just have a Xen variant of getreg() which checks if R is a constant
and, if so, redirects the call to the appropriate code for special
registers such as EFLAG.

  --david

On 7/28/05, Magenheimer, Dan (HP Labs Fort Collins)
<dan.magenheimer@hp.com> wrote:
> Revision 4.  Minor formatting change suggested by
> Christoph.  Also, no change for "symmetry" suggested
> by Christoph as Tony wanted to leave as is.
> 
> Tony I think this is now ready to apply.  If there is
> anything else needed, please let me know.
> 
> Thanks,
> Dan Magenheimer
> 
> > -----Original Message-----
> > From: Magenheimer, Dan (HP Labs Fort Collins)
> > Sent: Thursday, July 14, 2005 3:18 PM
> > To: 'linux-ia64@vger.kernel.org'
> > Subject: RE: Xen and the Art of Linux/ia64 Virtualization
> >
> > Revision 3.  Incorporates some more feedback and
> > a minor bug fix.
> >
> > Dan
> >
> > > -----Original Message-----
> > > From: Magenheimer, Dan (HP Labs Fort Collins)
> > > Sent: Wednesday, July 06, 2005 2:47 PM
> > > To: 'linux-ia64@vger.kernel.org'
> > > Subject: RE: Xen and the Art of Linux/ia64 Virtualization
> > >
> > > The patch I posted yesterday had a couple of bugs.
> > > This version applies cleanly against 2.6.12 and
> > > (when augmented with additional files from various
> > > Xen subdirectories) has been booted both on Xen/ia64
> > > and on hardware.
> > >
> > > Note that a patch to drivers/acpi/motherboard.c (that
> > > allows for acpi to be enabled on a stubbed acpi tree
> > > without a kernel null pointer dereference!) is required
> > > and has been submitted separately to the linux-acpi list.
> > >
> > > With the exception of three short CONFIG_XEN
> > > ifdefs, the vast majority of changes in this patch
> > > are code rearrangement to enable a number of routines
> > > and defines to add one level of abstraction.
> > >
> > > Comments and feedback would be much appreciated!
> > >
> > >  arch/ia64/Kconfig             |    7 +
> > >  arch/ia64/Makefile            |    1
> > >  arch/ia64/hp/sim/Makefile     |    2
> > >  arch/ia64/ia32/elfcore32.h    |    2
> > >  arch/ia64/ia32/ia32_signal.c  |    6 -
> > >  arch/ia64/ia32/ia32_support.c |    4 -
> > >  arch/ia64/kernel/entry.S      |   30 ++++---
> > >  arch/ia64/kernel/head.S       |    4 +
> > >  arch/ia64/kernel/irq_ia64.c   |   12 +--
> > >  arch/ia64/kernel/pal.S        |    5 -
> > >  arch/ia64/kernel/setup.c      |    3
> > >  include/asm-ia64/delay.h      |   53 -------------
> > >  include/asm-ia64/privop.h     |  160
> > > ++++++++++++++++++++++++++++++++++++++++++
> > >  include/asm-ia64/processor.h  |   56 --------------
> > >  include/asm-ia64/system.h     |   12 +--
> > >  15 files changed, 217 insertions(+), 140 deletions(-)
> > >
> > > > -----Original Message-----
> > > > From: Magenheimer, Dan (HP Labs Fort Collins)
> > > > Sent: Tuesday, July 05, 2005 2:21 PM
> > > > To: linux-ia64@vger.kernel.org
> > > > Subject: RE: Xen and the Art of Linux/ia64 Virtualization
> > > >
> > > > Thanks to excellent feedback from David Mosberger and
> > > > Christophe Hellwig, I have greatly cleaned up the attached
> > > > patch by using some very nice abstractions.  In fact,
> > > > most of the bulk in the attached patch results from
> > > > moving some code from asm-ia64/{delay,processor}.h to
> > > > a new file, asm-ia64/privop.h.  And the number of
> > > > CONFIG_XEN ifdefs is dramatically reduced.
> > > >
> > > > More feedback appreciated (including comments about how
> > > > close this might be to be ready for submission to Tony).
> > > >
> > > > Thanks,
> > > > Dan Magenheimer
> > > >
> > > > P.S. Anybody who is attending OLS who wants to talk about
> > > > Xen (and specifically Xen/ia64)?  I'll be there... send
> > > > me email.
> > > >
> > >
> >
> 
> 
> 


-- 
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
