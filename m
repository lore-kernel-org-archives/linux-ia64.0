From: Roland McGrath <roland@redhat.com>
Date: Thu, 20 Mar 2008 08:16:58 +0000
Subject: Re: [PATCH 6/8] ptrace: arch_ptrace -ENOSYS return
Message-Id: <20080320081658.0B23826F995@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080319211714.8B14226F995@magilla.localdomain>
	<20080319212024.EA03126F995@magilla.localdomain>
	<alpine.LFD.1.00.0803191935080.3020@woody.linux-foundation.org>
In-Reply-To: Linus Torvalds's message of  Wednesday, 19 March 2008 19:40:25 -0700 <alpine.LFD.1.00.0803191935080.3020@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, David Miller <davem@davemloft.net>, sparclinux@vger.kernel.org, Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org, Richard Henderson <rth@twiddle.net>, tony.luck@intel.com, linux-ia64@vger.kernel.org

> Hmm.. I see the whole series, and I see this patch, but I think it adds 
> new code and new complexity, and I don't really see *why*.

The motivation is to get the arch function out of the code path for the
machine-independent request handling.  I want to be able to change the
implementation later without touching the arch code again.  

The arguments passed down to arch_ptrace are sufficient for what the arch
code itself needs and for the current implementation in ptrace_request.
In future, I'd like the option of changing the code for the standard
requests to use a local data structure set up at the start of ptrace, and
such like (so more pointers and the like would need to be passed down to
ptrace_request).  These patches let me remove ptrace_request or change
its calling convention without touching the arch code again.

> Wouldn't it be nicer to just let "arch_ptrace()" return a flag saying 
> whether it handled things or not?

It would certainly be nicer.  I would prefer:

extern int arch_ptrace(struct task_struct *child, long request,
       	    	       long addr, long data, long *retval);

where it returns an error code or it returns 0 and *retval is the value
or it returns 1 and it didn't do anything.

The reason I took the approach I did instead is incrementalism.
I can't change that signature without breaking about 22 arch builds.
I'm only really prepared to thoroughly verify a change on 2 of those
myself.  It should be a simple enough change to make blind and get 
right.  But I've gotten a lot of things wrong before.  On principle,
I wouldn't really expect anyone to sign off on stuff I won't even
claim to have tried.  I did the forced_successful_syscall_return()
macro for arch's I don't try to build, and was just awful sure golly
that I hadn't got them wrong, because the generic change would break
those few arch's (not 20) without it.

So this ugliness seemed like a better bet than waiting for 20 more
arch sign-offs before any of it could go in.  You are certainly in a
position to just change the generic signature and make every arch do
the update (or fix your typos if you just tweak them all blind), and
let them grumble.  I did not presume to do so.

If you'd like a patch that changes this signature, updates all arch
implementations, and is actually verified to compile and work only
on x86 and powerpc, I'll be happy to provide that.


Thanks,
Roland
