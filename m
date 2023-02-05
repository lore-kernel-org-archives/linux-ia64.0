From: Al Viro <viro@zeniv.linux.org.uk>
Date: Sun, 05 Feb 2023 05:10:21 +0000
Subject: Re: [RFC][PATCHSET] VM_FAULT_RETRY fixes
Message-Id: <Y986PWjDy9YbHBEw@ZenIV>
List-Id: <linux-ia64.vger.kernel.org>
References: <Y9lz6yk113LmC9SI@ZenIV>
 <CAHk-=whf73Vm2U3jyTva95ihZzefQbThZZxqZuKAF-Xjwq=G4Q@mail.gmail.com>
 <Y9mD1qp/6zm+jOME@ZenIV>
 <CAHk-=wjiwFzEGd_60H3nbgVB=R_8KTcfUJmXy=hSXCvLrXQRFA@mail.gmail.com>
 <Y9mM5wiEhepjJcN0@ZenIV>
 <CAHk-=wjNwwnBckTo8HLSdsd1ndoAR=5RBoZhdOyzhsnDAYWL9g@mail.gmail.com>
 <Y9rCBqwbLlLf1fHe@x1n>
 <Y9rlI6d5J2Y/YNQ+@ZenIV>
 <Y9w/lrL6g4yauXz4@x1n>
 <Y92mP1GT28KfnPEQ@ZenIV>
In-Reply-To: <Y92mP1GT28KfnPEQ@ZenIV>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Xu <peterx@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Michal Simek <monstr@monstr.eu>, Dinh Nguyen <dinguyen@kernel.org>, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, sparclinux@vger.kernel.org

On Sat, Feb 04, 2023 at 12:26:39AM +0000, Al Viro wrote:
> On Thu, Feb 02, 2023 at 05:56:22PM -0500, Peter Xu wrote:
> 
> > IMHO it'll be merely impossible to merge things across most (if not to say,
> > all) archs.  It will need to be start from one or at least a few that still
> > shares a major common base - I would still rely on x86 as a start - then we
> > try to use the helper in as much archs as possible.
> > 
> > Even on x86, I do also see challenges so I'm not sure whether a common
> > enough routine can be abstracted indeed.  But I believe there's a way to do
> > this because obviously we still see tons of duplicated logics falling
> > around.  It may definitely need time to think out where's the best spot to
> > start, and how to gradually move towards covering more archs starting from
> > one.
> 
> FWIW, after going through everything from alpha to loongarch (in alphabetic
> order, skipping the itanic) the following seems to be suitable for all of
> them:
> 
> generic_fault(address, flags, vm_flags, regs)
[snip]

After looking through other architectures: that needs changes.

AFAICS, the right approach would be to add a pointer to (uninitialized)
kernel_siginfo.  And let it pass the signal number, etc. through that.
That way all "we want to raise a signal" return values fold together.
*IF* the page fault wants to do something extra on SIGSEGV, but not on
SIGBUS (we have several such), it can key that upon info.si_signo.

Speaking of SIGSEGV, there's a fun situation with VM_FAULT_SIGSEGV:

1) Only x86 and ppc generate VM_FAULT_SIGSEGV in handle_mm_fault()
without hitting WARN_ON_ONCE().  And neither actually returns it
to page fault handler - the conditions that would've led to that
return value (pkey stuff) are checked in the page fault handler
and handle_mm_fault() is not called in such cases.

2) on alpha, hexagon, itanic, loongarch, microblaze, mips, nios2,
openrisc, sparc, um and xtensa #PF handler would end up with SEGV_ACCERR
if it saw VM_FAULT_SIGNAL.

3) on arm, arm64, arc, m68k, powerpc, s390, sh and x86 - SEGV_MAPERR
(except that neither x86 nor powerpc #PF ever see it)

4) on csky and riscv it would end up with BUG()

5) on parisc it's complicated^Wbroken - it tries to decide which
one to use after having unlocked mmap and looking at vma in process.

As it is, VM_FAULT_SIGSEGV had ended up as "we need to report some
error to get_user_pages() and similar callers in cases when
page fault handler would've detected pkey problem and refused
to call handle_mm_fault()", with several places where it's
"we had been called with bogus arguments; printk and return
something to indicate the things had gone wrong".  It used to
have other uses, but this is what it had become now - grep and
you'll see.

AFAICS, all checks for it in page fault handlers are pretty much
dead code...
