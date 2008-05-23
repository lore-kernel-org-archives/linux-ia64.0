From: Roland McGrath <roland@redhat.com>
Date: Fri, 23 May 2008 04:19:40 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a race
Message-Id: <20080523041940.39E8726FA24@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	<1211446045.5610.33.camel@elijah.suse.cz>
	<3877989d0805220216o5add20ddye2a1fde98a0c1e69@mail.gmail.com>
	<20080522111826.BB90326FA24@magilla.localdomain>
	<3877989d0805220624i259a9d1j708795c65c636ca0@mail.gmail.com>
	<20080522203428.835D626FA24@magilla.localdomain>
	<3877989d0805222042p176da844k384ea512b1cfb0da@mail.gmail.com>
In-Reply-To: Luming Yu's message of  Friday, 23 May 2008 11:42:35 +0800 <3877989d0805222042p176da844k384ea512b1cfb0da@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Luming Yu <luming.yu@gmail.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

> In the code path mentioned above, I see only ia64 has chance to let
> ptraced thread deliver those pending signals before TASK_TRACED is

This is the key thing that makes no sense to me.  What do you mean by
"deliver" here?  The normal meaning of to "deliver" a signal means that
get_signal_to_deliver() dequeues and processes it.  This can never happen
inside any other kernel code path.  It certainly can never happen inside
ptrace_stop or ptrace_notify.

The difference between ia64 and others is that inside ptrace_stop(), it can
release the siglock and then can block (in page faults, or by preemption).
No signal delivery can happen.  

What perhaps can happen is that TIF_SIGPENDING being set can cause a
TASK_INTERRUPTIBLE wait in the page fault path to return early and
ia64_sync_user_rbs will bail out before doing all its work.  But you
haven't described any problem like that.

Please tell us the exact code path you think is happening in the error case
you can reproduce.  Describe the actual code path, not high-level notions
like "deliver those pending signals".


Thanks,
Roland
