From: Keith Owens <kaos@sgi.com>
Date: Thu, 01 Sep 2005 05:30:32 +0000
Subject: Re: testing mca/init patch
Message-Id: <15365.1125552632@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200508312343.j7VNhFOZ012157@agluck-lia64.sc.intel.com>
In-Reply-To: <200508312343.j7VNhFOZ012157@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 31 Aug 2005 21:58:58 -0700, 
david mosberger <dmosberger@gmail.com> wrote:
>Keith,
>
>I took a closer look at your patch set and, by and large, I like it a
>lot.  I suppose there will be more debate as to whether treating
>MCA/INIT events as an asynchronous task-switch is the right way to go
>about it, but so far it looks to me that it does indeed simplify a lot
>while creating only a managable set of new headaches.  I guess a key
>point is whether or not the generic scheduler mods will be accepted...
>
>Some other points:
>
>- In several places there are checks of the form:
>
>+ if ((r12 & -KERNEL_STACK_SIZE) != r13) {
>
>  I don't understand why you're doing this.  You should check for (r12
>- r13) <  KERNEL_STACK_SIZE.  That does the same without relying on
>alignments (which is something we have been careful to avoid in all
>other ia64 code).  This should also let you drop the patch to
>vmlinux.lds.S.

Paranoia.  I have seen several MCA/INIT events fail because they were
delivered while the cpu was in PAL/SAL.  r12 and r13 are preserved
around calls to PAL/SAL, but they are not preserved _within_ PAL/SAL.
I am trying to verify as much as possible of the original stack before
updating it, the alignment check is something useful that I can test
for.

>- In ia64_os_mca_virtual_begin(), I'd suggest to use the idiom:
>
>    .save rp, r0
>
>  to terminate the call-chain.  That should simplify this function.

Good idea.

>- I worry about copying machine-state from the MCA/INIT stack to the
>"old" (process) stack.  What if an MCA was caused by an ECC error on
>that old stack?  Wouldn't this prevent you from recovering from what
>might otherwise be a recoverable error?

At the moment, nobody expects to recover from an error in kernel
memory, so recovery is not relevant here.  Using the old stack is the
only way to get a backtrace of the failing process, all its state is on
the old stack.

