From: Keith Owens <kaos@sgi.com>
Date: Thu, 20 Jan 2005 10:26:18 +0000
Subject: Re: [patch] Resched skip_rbs_switch to run 4 cycles faster on McKinley-type cores.
Message-Id: <8236.1106216778@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501190500.j0J505jY002441@napali.hpl.hp.com>
In-Reply-To: <200501190500.j0J505jY002441@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 19 Jan 2005 22:50:07 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Thu, 20 Jan 2005 09:25:35 +1100, Keith Owens <kaos@sgi.com> said:
>
>  Keith> Instead of being garbage when the interrupted code was in the
>  Keith> kernel, ar_bspstore and ar_rnat are set to zero.  The test
>  Keith> for "do I skip_rbs_switch" changes from pUStk to "is saved
>  Keith> ar_bspstore non-zero".
>
>Wouldn't this prevent user-level code from setting ar.bspstore to
>zero?  I'm not sure we should nail that into the kernel (by default
>the first page is a NaT page, so it's not likely to be a real problem
>as of today).

Good point, use ar_bspstore = 1 to mean no rbs switch required.

>  Keith> Comments?
>
>Libunwind does support multiple register backing-stores, but since we
>cannot unwind across firmware, I'm not sure whether this by itself
>would make your life easier.  If it would, let me know.

It would help, if libunwind were in the kernel.

Unwinding across firmware is not an issue here, we have two views of
the MCA/INIT context.  One view is "how to return to SAL?", that data
is stored outside the stack.  The other view is "what was the cpu doing
when the event occurred?".  It is the latter that I am working on.

From the point of view of unwind, I want the MCA/INIT to look like a
normal interrupt, with the addition of separate backing store.  That
will let us backtrace during MCA/INIT processing to see what the cpu
was really doing.  SAL will not appear in the backtrace at all.

One side effect of this change is that the unwinder needs an MCA/INIT
safe allocator.  The existing code uses kmalloc which works most of the
time, but some MCA/INIT traces have been killed by the unwinder calling
kmalloc when the slab structures were inconsistent.  I recently added
an MCA/INIT safe, last ditch allocator to kdb, so we can get
diagnostics even when GFP_ATOMIC has been exhausted and in MCA/INIT.

