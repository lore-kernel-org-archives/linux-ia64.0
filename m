From: Al Viro <viro@zeniv.linux.org.uk>
Date: Thu, 02 Feb 2023 00:57:09 +0000
Subject: Re: [RFC][PATCHSET] VM_FAULT_RETRY fixes
Message-Id: <Y9sKZTJI7V6qCNRJ@ZenIV>
List-Id: <linux-ia64.vger.kernel.org>
References: <Y9lz6yk113LmC9SI@ZenIV>
 <CAHk-=whf73Vm2U3jyTva95ihZzefQbThZZxqZuKAF-Xjwq=G4Q@mail.gmail.com>
 <Y9mD1qp/6zm+jOME@ZenIV>
 <CAHk-=wjiwFzEGd_60H3nbgVB=R_8KTcfUJmXy=hSXCvLrXQRFA@mail.gmail.com>
 <Y9mM5wiEhepjJcN0@ZenIV>
 <CAHk-=wjNwwnBckTo8HLSdsd1ndoAR=5RBoZhdOyzhsnDAYWL9g@mail.gmail.com>
 <Y9rCBqwbLlLf1fHe@x1n>
 <Y9rlI6d5J2Y/YNQ+@ZenIV>
In-Reply-To: <Y9rlI6d5J2Y/YNQ+@ZenIV>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Xu <peterx@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Michal Simek <monstr@monstr.eu>, Dinh Nguyen <dinguyen@kernel.org>, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, sparclinux@vger.kernel.org

On Wed, Feb 01, 2023 at 10:18:11PM +0000, Al Viro wrote:
> 	* logics for stack expansion includes this twist:
>         if (!(vma->vm_flags & VM_GROWSDOWN))
>                 goto map_err;
>         if (user_mode(regs)) {
>                 /* Accessing the stack below usp is always a bug.  The
>                    "+ 256" is there due to some instructions doing
>                    pre-decrement on the stack and that doesn't show up
>                    until later.  */
>                 if (address + 256 < rdusp())
>                         goto map_err;
>         }
>         if (expand_stack(vma, address))
>                 goto map_err;
> That's m68k; ISTR similar considerations elsewhere, but I could be
> wrong.

Hell, yes - 
        if (!(vma->vm_flags & VM_GROWSDOWN))
                goto bad_area;
        if (!(fault_code & FAULT_CODE_WRITE)) {
                /* Non-faulting loads shouldn't expand stack. */
                insn = get_fault_insn(regs, insn);
                if ((insn & 0xc0800000) = 0xc0800000) {
                        unsigned char asi;

                        if (insn & 0x2000)
                                asi = (regs->tstate >> 24);
                        else
                                asi = (insn >> 5);
                        if ((asi & 0xf2) = 0x82)
                                goto bad_area;
                }
        }
        if (expand_stack(vma, address))
                goto bad_area;

Note that it's very much not a bug - it's a nonfaulting (= speculative)
load, and the place where we are heading from bad_area in this case is
this in do_kernel_fault():
        if (!(fault_code & (FAULT_CODE_WRITE|FAULT_CODE_ITLB)) &&
            (insn & 0xc0800000) = 0xc0800000) {
                if (insn & 0x2000)
                        asi = (regs->tstate >> 24);
                else  
                        asi = (insn >> 5);
                if ((asi & 0xf2) = 0x82) {
                        if (insn & 0x1000000) {
                                handle_ldf_stq(insn, regs);
                        } else {
                                /* This was a non-faulting load. Just clear the
                                 * destination register(s) and continue with the next
                                 * instruction. -jj
                                 */
                                handle_ld_nf(insn, regs);
                        }
                        return;

(the name is misguiding - it covers userland stuff as well; in this
particular case the triggering instruction is non-priveleged)
