From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 25 Sep 2003 16:50:53 +0000
Subject: Re: [Lse-tech] Re: CPUSET Proposal
Message-Id: <marc-linux-ia64-106450912817595@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106444308519469@msgid-missing>
In-Reply-To: <marc-linux-ia64-106444308519469@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2003-09-25 at 06:26, Simon Derr wrote:
> On Wed, 24 Sep 2003, David Mosberger wrote:
> 
> > BTW: What do cpusets provide that couldn't be done with user-level
> > tools on top of the existing sched_setaffinity() system call?
> This is a question we had a long in-house debate about.
> 
> The main reason of the inclusion of cpusets *inside* the kernel, is that
> we have to deal with applications that may call sched_setaffinity() to
> bind their processes to CPUs. Therefore we have to intercept these calls.
> We could try to do some LD_PRELOAD userland trick or modify the libc, but
> that would not work for statically linked programs.

You could also do a big chunk of this by allowing normal privledge users
to sched_setaffinity() a *subset* of their current allowed CPU set, but
not expand it.  sched_setaffinity() isn't *that* old of an interface, so
I'm not sure why you can't just change the application at this point.  

-- 
Dave Hansen
haveblue@us.ibm.com

