From: Kautuk Consul <consul.kautuk@gmail.com>
Date: Tue, 12 Jun 2012 15:54:45 +0000
Subject: Re: [PATCH 09/19 v2] ia64/mm/fault.c: Port OOM changes to ia64_do_page_fault
Message-Id: <CAFPAmTTud9KHzeUK0J3EFOdtfExagrPkT_wKC045u2CAj9CK_A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1333195412-5217-1-git-send-email-consul.kautuk@gmail.com>
In-Reply-To: <1333195412-5217-1-git-send-email-consul.kautuk@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

Can you please review this patch ?

Many archs have accpted this change so I think it is okay. :)

Thanks,
Kautuk.

On Sat, Mar 31, 2012 at 5:33 PM, Kautuk Consul <consul.kautuk@gmail.com> wr=
ote:
> Commit d065bd810b6deb67d4897a14bfe21f8eb526ba99
> (mm: retry page fault when blocking on disk transfer) and
> commit 37b23e0525d393d48a7d59f870b3bc061a30ccdb
> (x86,mm: make pagefault killable)
>
> The above commits introduced changes into the x86 pagefault handler
> for making the page fault handler retryable as well as killable.
>
> These changes reduce the mmap_sem hold time, which is crucial
> during OOM killer invocation.
>
> Port these changes to ia64.
>
> Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
> ---
> =A0arch/ia64/mm/fault.c | =A0 38 ++++++++++++++++++++++++++++++--------
> =A01 files changed, 30 insertions(+), 8 deletions(-)
>
> diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
> index 02d29c2..b0c3b29 100644
> --- a/arch/ia64/mm/fault.c
> +++ b/arch/ia64/mm/fault.c
> @@ -81,6 +81,12 @@ ia64_do_page_fault (unsigned long address, unsigned lo=
ng isr, struct pt_regs *re
> =A0 =A0 =A0 =A0struct siginfo si;
> =A0 =A0 =A0 =A0unsigned long mask;
> =A0 =A0 =A0 =A0int fault;
> + =A0 =A0 =A0 unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_=
KILLABLE;
> +
> + =A0 =A0 =A0 mask =3D ((((isr >> IA64_ISR_X_BIT) & 1UL) << VM_EXEC_BIT)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 | (((isr >> IA64_ISR_W_BIT) & 1UL) << VM_WR=
ITE_BIT));
> +
> + =A0 =A0 =A0 flags |=3D ((mask & VM_WRITE) ? FAULT_FLAG_WRITE : 0);
>
> =A0 =A0 =A0 =A0/* mmap_sem is performance critical.... */
> =A0 =A0 =A0 =A0prefetchw(&mm->mmap_sem);
> @@ -109,6 +115,7 @@ ia64_do_page_fault (unsigned long address, unsigned l=
ong isr, struct pt_regs *re
> =A0 =A0 =A0 =A0if (notify_page_fault(regs, TRAP_BRKPT))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> +retry:
> =A0 =A0 =A0 =A0down_read(&mm->mmap_sem);
>
> =A0 =A0 =A0 =A0vma =3D find_vma_prev(mm, address, &prev_vma);
> @@ -142,9 +149,6 @@ ia64_do_page_fault (unsigned long address, unsigned l=
ong isr, struct pt_regs *re
> =A0 =A0 =A0 =A0if (((isr >> IA64_ISR_R_BIT) & 1UL) && (!(vma->vm_flags & =
(VM_READ | VM_WRITE))))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto bad_area;
>
> - =A0 =A0 =A0 mask =3D ( =A0(((isr >> IA64_ISR_X_BIT) & 1UL) << VM_EXEC_B=
IT)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 | (((isr >> IA64_ISR_W_BIT) & 1UL) << VM_WR=
ITE_BIT));
> -
> =A0 =A0 =A0 =A0if ((vma->vm_flags & mask) !=3D mask)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto bad_area;
>
> @@ -153,7 +157,11 @@ ia64_do_page_fault (unsigned long address, unsigned =
long isr, struct pt_regs *re
> =A0 =A0 =A0 =A0 * sure we exit gracefully rather than endlessly redo the
> =A0 =A0 =A0 =A0 * fault.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 fault =3D handle_mm_fault(mm, vma, address, (mask & VM_WRIT=
E) ? FAULT_FLAG_WRITE : 0);
> + =A0 =A0 =A0 fault =3D handle_mm_fault(mm, vma, address, flags);
> +
> + =A0 =A0 =A0 if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(curren=
t))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> =A0 =A0 =A0 =A0if (unlikely(fault & VM_FAULT_ERROR)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * We ran out of memory, or some other thi=
ng happened
> @@ -168,10 +176,24 @@ ia64_do_page_fault (unsigned long address, unsigned=
 long isr, struct pt_regs *re
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG();
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 if (fault & VM_FAULT_MAJOR)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 current->maj_flt++;
> - =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 current->min_flt++;
> +
> + =A0 =A0 =A0 if (flags & FAULT_FLAG_ALLOW_RETRY) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (fault & VM_FAULT_MAJOR)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 current->maj_flt++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 current->min_flt++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (fault & VM_FAULT_RETRY) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 flags &=3D ~FAULT_FLAG_ALLO=
W_RETRY;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* No need to up_read(&m=
m->mmap_sem) as we would
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* have already released =
it in __lock_page_or_retry
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* in mm/filemap.c.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto retry;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0up_read(&mm->mmap_sem);
> =A0 =A0 =A0 =A0return;
>
> --
> 1.7.5.4
>
