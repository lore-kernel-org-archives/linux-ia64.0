From: Simon Derr <Simon.Derr@bull.net>
Date: Thu, 25 Sep 2003 13:26:38 +0000
Subject: Re: [Lse-tech] Re: CPUSET Proposal
Message-Id: <marc-linux-ia64-106449650531871@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106444308519469@msgid-missing>
In-Reply-To: <marc-linux-ia64-106444308519469@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 24 Sep 2003, David Mosberger wrote:

> BTW: What do cpusets provide that couldn't be done with user-level
> tools on top of the existing sched_setaffinity() system call?
This is a question we had a long in-house debate about.

The main reason of the inclusion of cpusets *inside* the kernel, is that
we have to deal with applications that may call sched_setaffinity() to
bind their processes to CPUs. Therefore we have to intercept these calls.
We could try to do some LD_PRELOAD userland trick or modify the libc, but
that would not work for statically linked programs.

As pointed by Paul, another reason is the possibility to change on the fly
the size/location of cpusets, and the need to apply the change on the
attached processes.


Thanks a lot for your comments,

	Simon.

