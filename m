From: Erich Focht <focht@ess.nec.de>
Date: Tue, 02 Oct 2001 09:16:12 +0000
Subject: [Linux-ia64] Re: deadlock in crashed multithreaded job
Message-Id: <marc-linux-ia64-105590698805288@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 1 Oct 2001, Manfred Spraul wrote:

> > The symptoms: running the tests (make check) sometimes ends up
> > with hanging processes.
> 
> Does it _only_ hang during coredumping, or also during normal usage?
> 
> Could you remove
> 	down_read(&mmap_sem);
> 	binfmt->coredump();
> 	up_read(&mmap_sem);
> from fs/exec.c and rerun your tests?

Setting the coredumpsize limit to 0 already solves the problem.

The question that remains is how to deal with nested locks on the same
resource that can lead to deadlocks. Is there any (un)written rule that
one should avoid them in the Linux Kernel? Or are there any approaches to
deal with them (which are not yet included in the Kernel)?

> The hang during coredumping is known, there are 2 fixes [I have one, not
> yet released, Andrea wrote one, IIRC included in his -aa kernels].

Do these solutions deal only with the coredump problem or with nested
critical sections?

Thanks,
Erich


