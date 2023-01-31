From: Al Viro <viro@zeniv.linux.org.uk>
Date: Tue, 31 Jan 2023 21:49:27 +0000
Subject: Re: [RFC][PATCHSET] VM_FAULT_RETRY fixes
Message-Id: <Y9mM5wiEhepjJcN0@ZenIV>
List-Id: <linux-ia64.vger.kernel.org>
References: <Y9lz6yk113LmC9SI@ZenIV>
 <CAHk-=whf73Vm2U3jyTva95ihZzefQbThZZxqZuKAF-Xjwq=G4Q@mail.gmail.com>
 <Y9mD1qp/6zm+jOME@ZenIV>
 <CAHk-=wjiwFzEGd_60H3nbgVB=R_8KTcfUJmXy=hSXCvLrXQRFA@mail.gmail.com>
In-Reply-To: <CAHk-=wjiwFzEGd_60H3nbgVB=R_8KTcfUJmXy=hSXCvLrXQRFA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Xu <peterx@redhat.com>, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Michal Simek <monstr@monstr.eu>, Dinh Nguyen <dinguyen@kernel.org>, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, sparclinux@vger.kernel.org

On Tue, Jan 31, 2023 at 01:19:59PM -0800, Linus Torvalds wrote:
> On Tue, Jan 31, 2023 at 1:10 PM Al Viro <viro@zeniv.linux.org.uk> wrote:
> >
> > Umm...  What about the semantics of get_user() of unmapped address?
> > Some architectures do quiet EFAULT; some (including alpha) hit
> > the sucker with SIGBUS, no matter what.
> 
> I think we should strive to just make this all common.
> 
> The reason alpha is different is almost certainly not intentional, but
> a combination of "pure accident" and "nobody actually cares".
> 
> > Are we free to modify that behaviour, or is that part of arch-specific
> > ABI?
> 
> I'd just unify this all, probably with a preference for existing
> semantics on x86 (because of "biggest and most varied user base").
> 
> That whole "send SIGBUS even for kernel faults" is certainly bogus and
> against the usual rules. And I may well be to blame for it (I have
> this memory of disliking how EFAULT as a return code didn't actually
> return the faulting address). And realistically, it's also just not
> something that any normal application will ever hit.  Giving invalid
> addresses to system calls is basically always a bug, although there
> are always special software that do all the crazy corner cases (ie
> things like emulators tend to do odd things).
> 
> I doubt such special software exists on Linux/alpha, though.
> 
> So I wouldn't worry about those kinds of oddities overmuch.
> 
> *If* somebody then finds a load that cares, we can always fix it
> later, and I'll go "mea culpa, I didn't think it would matter, and I
> was wrong".

FWIW, from digging through the current tree:

alpha, openrisc, sparc and xtensa send SIGBUS.
m68k: not sure, do_page_fault() callers there are delicate.
mips: really interesting -
        /* Kernel mode? Handle exceptions or die */
        if (!user_mode(regs))
                goto no_context;

        /*
         * Send a sigbus, regardless of whether we were in kernel
         * or user mode.
... which is obviously a rudiment of SIGBUS variant, but nowadays
it's EFAULT.

Everything else seems to be going with EFAULT.

PS: mips used to be SIGBUS, until this
commit 1d50e5e7a6e0325b1a652c4be296a71dc54a6e96
Author: Andrew Morton <akpm@osdl.org>
Date:   Fri Feb 20 01:33:18 2004 -0800

    [PATCH] MIPS mega-patch
    
    From: Ralf Baechle <ralf@linux-mips.org>
    
    Below following 125547 lines of patches, all to arch/mips and
    include/asm-mips.  I'm going to send the remaining stuff of which the one
    or other bit may need to be discussed in smaller bits.

IOW, details are buried somewhere in historical mips tree, assuming
it survives...
