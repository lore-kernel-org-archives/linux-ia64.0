From: Roland McGrath <roland@redhat.com>
Date: Tue, 03 Jun 2008 21:01:25 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a
Message-Id: <20080603210125.1724C26FC96@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	<20080523041940.39E8726FA24@magilla.localdomain>
	<3877989d0805222224n77ce36b6wdf15c4bab330a0f8@mail.gmail.com>
	<20080526001527.81E1126FA9E@magilla.localdomain>
	<3877989d0805251830w70f19e4cu46fbc32148217749@mail.gmail.com>
	<3877989d0805262031i29db16bcjfa31652afc746b49@mail.gmail.com>
	<20080527040454.053C526FA9E@magilla.localdomain>
	<3877989d0805262249yab130cbyfc5f5e54065cec5c@mail.gmail.com>
	<20080527061209.9A24426FAA6@magilla.localdomain>
	<1211869515.29836.2.camel@elijah.suse.cz>
	<3877989d0806022304w35764b17p9d4c3c95eceae0f5@mail.gmail.com>
	<48450864.6080707@suse.cz>
	<48455619.6040608@suse.cz>
In-Reply-To: Petr Tesarik's message of  Tuesday, 3 June 2008 16:32:57 +0200 <48455619.6040608@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Tesarik <ptesarik@suse.cz>
Cc: Luming Yu <luming.yu@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

> It's definitely a bug in strace. For some reason (I don't care about)
> the execve() syscall produces an extra notification. However, this
> notification message is suppressed when SIGTRAP is blocked. This
> explains why the test case fails only when SIGTRAP is blocked.

What do you mean by "extra"?  There is a SIGTRAP sent after execve
completes when ptraced, even when PTRACE_SYSCALL is not being used.
So for an execve that succeeds under PTRACE_SYSCALL, there is a
ptrace_notify at syscall entry, then a SIGTRAP queued (i.e., not seen
by ptrace if blocked), then a ptrace_notify at syscall exit.  If
that's what's happening (including the blocked SIGTRAP not being seen
by the ptracer, i.e. strace), then there is no mystery (and no bug).


Thanks,
Roland
