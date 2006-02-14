From: Horms <horms@verge.net.au>
Date: Tue, 14 Feb 2006 04:06:44 +0000
Subject: Re: [Patch]IA64 kexec
Message-Id: <20060214040644.GA28891@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1131406068.2524.15.camel@linux-znh>
In-Reply-To: <1131406068.2524.15.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 13, 2006 at 09:26:58AM -0800, Luck, Tony wrote:
> > Here is an as-yet untested forward port of the kexec-ia64 patch to
> > today's Linus git tree (~2.6.16-rc3).
> 
> Thanks for taking a look at this ... I'm glad to see that there is
> still interest in kexec.

Likewise.

In case anyone cares, my interest in kexec is twofold.
Firstly the ia64 box I have takes a really long time to reboot,
and it would be nice if kexec could trim that down to speed
up my crash-and-burn development cycle.

But more importantly, I'm interested in using it for
kdump functionality, hopefully in conjunction with Xen - 
though as you can see, I haven't got that far yet.

> Khalid Aziz at HP is woking on merging the good parts of that patch
> from Nan Hai with the kexec patch that he had produced earlier).  We
> should see the results of that merge next week, & I hope to see
> lots more commentary and testing this time around.

Awsome, I look forward to seeing it. Would I be right in thinking
that it will show up on this list?

> > I haven't looked into what other features have been added 
> > to other arches kexec. Nor if the features above are applicable -
> > seems that they probably are, exept that ia64 doesn't have NMI
> > (right?) so the cpu shutdown would need to be done another way.
> 
> Nan Hai makes use of HOTPLUG_CPU to offline the other cpus ... which
> in many ways is a very elegant solution (as it puts the cpus neatly
> back into SAL ready for the new OS to bring it back online again).
> But there are a couple of downsides:
> 1) Requires CONFIG_HOTPLUG_CPU (perhaps this isn't really a big issue)

That isn't a particular concern to me. 

> 2) May run into trouble for kdump case where we'd like to rely on
> less known state/code to get a good dump when the Linux kernel is
> known to be in some unstable state.
> 
> The ia64 equivalent of NMI (large brick through the window) is INIT.
> Some systems have a button on the front panel to generate INIT, or
> have a maintenance processor that can send INIT.  So a good kdump
> solution should eventually make use of INIT.
> 
> -Tony

On Tue, Feb 14, 2006 at 08:17:35AM +1100, Keith Owens wrote:
> "Luck, Tony" (on Mon, 13 Feb 2006 09:26:58 -0800) wrote:
> >The ia64 equivalent of NMI (large brick through the window) is INIT.
> >Some systems have a button on the front panel to generate INIT, or
> >have a maintenance processor that can send INIT.  So a good kdump
> >solution should eventually make use of INIT.
> 
> Which raises a small problem.  As of about 2.6.15, INIT is a
> recoverable event.  INIT _must_ be recoverable, because it can be sent
> when an MCA occurs and one or more cpus was running with interrupts
> disabled.  For example, when the cpu that takes the MCA owns a disabled
> spinlock that other cpus are waiting on.  If INIT is not recoverable
> then some MCAs that could be recovered also become unrecoverable, at
> random.
> 
> Since INIT is recoverable, pressing NMI gives you a stack trace for
> each cpu, then the system resumes.  This allows a user to see if the
> system is making progress, albeit slowly, or if it really is stuck.
> The downside of a recoverable INIT is that you cannot use it to take a
> dump, or at least not the first time that NMI is issued.  Unfortunately
> there is no way to distinguish between an NMI where the user wants to
> see what the system is doing and an NMI to take a dump.  Nobody has
> implemented the "Read Programmer's Mind" instruction yet.

I sense pain. Looking over the code - very naievely - would it be
possible to register an alternate INIT handler when kexecing.

What I'm getting at is ia64_os_init_dispatch_monarch and
ia64_os_init_dispatch_slave are basically the same, but r19
is set so the code knows which variant is running for the core that
cares. I wonder if an aditional bit in r19 could be used by
alternate handlers that are registered when kexec wants to shut
down the cpus.

Off course, this assume that reregistering handlers is possible,
which is where the "naieve" bit comes in.

-- 
Horms
