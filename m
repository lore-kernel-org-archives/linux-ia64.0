From: Mario Smarduch <cms063@email.mot.com>
Date: Mon, 11 Nov 2002 21:46:05 +0000
Subject: [Linux-ia64] Re: +-AFs-Linux-ia64+-AF0- reader-writer livelock proble
Message-Id: <marc-linux-ia64-105590709805393@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

> >>>>> On Mon, 11 Nov 2002 14:36:38 -0600, "Van Maren, Kevin" <kevin.vanmaren@unisys.com> said:
>
>   Van> I have not looked at this, but I don't believe it is the right
>   Van> way to solve the problem: users who _need_ to use all
>   Van> the CPUs for computation would be punished just to work around
>   Van> a kernel implementation issue: that's like saying don't allow
>   Van> processes to allocate virtual memory because if the VM is
>   Van> over-committed by X amount the kernel deadlocks.
>
>   Van> It would be a bad hack to limit the system-call rate just to
>   Van> prevent livelock.
>
> Certainly.  I didn't suggest PRM as a way to _solve_ the livelock
> problem, but since Mario asked for a method to cap CPU utilization, I
> mentiond it.
>
>         --david

Absolutelly its not a method to solve the problem.  As a matter of fact
its just a first approach that came to mind to protect the system.
It could be any other viable way before a final fix.
Like I said in the previous email you're not going to sell too many
high end servers to a customer aware of this issue without a contingency plan.

- Mario.


