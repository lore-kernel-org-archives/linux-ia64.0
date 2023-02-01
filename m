From: Peter Xu <peterx@redhat.com>
Date: Wed, 01 Feb 2023 19:48:22 +0000
Subject: Re: [RFC][PATCHSET] VM_FAULT_RETRY fixes
Message-Id: <Y9rCBqwbLlLf1fHe@x1n>
List-Id: <linux-ia64.vger.kernel.org>
References: <Y9lz6yk113LmC9SI@ZenIV>
 <CAHk-=whf73Vm2U3jyTva95ihZzefQbThZZxqZuKAF-Xjwq=G4Q@mail.gmail.com>
 <Y9mD1qp/6zm+jOME@ZenIV>
 <CAHk-=wjiwFzEGd_60H3nbgVB=R_8KTcfUJmXy=hSXCvLrXQRFA@mail.gmail.com>
 <Y9mM5wiEhepjJcN0@ZenIV>
 <CAHk-=wjNwwnBckTo8HLSdsd1ndoAR=5RBoZhdOyzhsnDAYWL9g@mail.gmail.com>
In-Reply-To: <CAHk-=wjNwwnBckTo8HLSdsd1ndoAR=5RBoZhdOyzhsnDAYWL9g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Michal Simek <monstr@monstr.eu>, Dinh Nguyen <dinguyen@kernel.org>, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, sparclinux@vger.kernel.org

On Tue, Jan 31, 2023 at 04:00:22PM -0800, Linus Torvalds wrote:
> So most of the time it's probably not going to matter all that much
> which signal gets sent in practice.

I do also see a common pattern of the possibility to have a generic fault
handler like generic_page_fault().

It probably should start with taking the mmap_sem until providing some
retval that is much easier to digest further by the arch-dependent code, so
it can directly do something rather than parsing the bitmask in a
duplicated way (hence the new retval should hopefully not a bitmask anymore
but a "what to do").

Maybe it can be something like:

/**
 * enum page_fault_retval - Higher level fault retval, generalized from
 * vm_fault_reason above that is only used by hardware page fault handlers.
 * It generalizes the bitmask-versioned retval into something that the arch
 * dependent code should react upon.
 *
 * @PF_RET_COMPLETED:		The page fault is completed successfully
 * @PF_RET_BAD_AREA:		The page fault address falls in a bad area
 *				(e.g., vma not found, expand_stack() fails..)
 * @PF_RET_ACCESS_ERR:		The page fault has access errors
 *				(e.g., write fault on !VM_WRITE vmas)
 * @PF_RET_KERN_FIXUP:		The page fault requires kernel fixups
 *				(e.g., during copy_to_user() but fault failed?)
 * @PF_RET_HWPOISON:		The page fault encountered poisoned pages
 * @PF_RET_SIGNAL:		The page fault encountered poisoned pages
 * ...
 */
enum page_fault_retval {
	PF_RET_DONE = 0,
	PF_RET_BAD_AREA,
	PF_RET_ACCESS_ERR,
	PF_RET_KERN_FIXUP,
        PF_RET_HWPOISON,
        PF_RET_SIGNAL,
	...
};

As a start we may still want to return some more information (perhaps still
the vm_fault_t alongside?  Or another union that will provide different
information based on different PF_RET_*).  One major thing is I see how we
handle VM_FAULT_HWPOISON and also the fact that we encode something more
into the bitmask on page sizes (VM_FAULT_HINDEX_MASK).

So the generic helper could, hopefully, hide the complexity of:

  - Taking and releasing of mmap lock
  - find_vma(), and also relevant checks on access or stack handling
  - handle_mm_fault() itself (of course...)
  - detect signals
  - handle page fault retries (so, in the new layer of retval there should
    have nothing telling it to retry; it should always be the ultimate result)
  - parse different errors into "what the arch code should do", and
    generalize the common ones, e.g.
    - OOM, do pagefault_out_of_memory() for user-mode
    - VM_FAULT_SIGSEGV, which should be able to merge into PF_RET_BAD_AREA?
    - ...

It'll simplify things if we can unify some small details like whether the
-EFAULT above should contain a sigbus.

A trivial detail I found when I was looking at this is, x86_64 passes in
different signals to kernelmode_fixup_or_oops() - in do_user_addr_fault()
there're three call sites and each of them pass over a differerent signal.
IIUC that will only make a difference if there's a nested page fault during
the vsyscall emulation (but I may be wrong too because I'm new to this
code), and I have no idea when it'll happen and whether that needs to be
strictly followed.

Thanks,

-- 
Peter Xu
