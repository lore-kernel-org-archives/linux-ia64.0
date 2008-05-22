From: "Luming Yu" <luming.yu@gmail.com>
Date: Thu, 22 May 2008 13:24:11 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a race
Message-Id: <3877989d0805220624i259a9d1j708795c65c636ca0@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	 <1211446045.5610.33.camel@elijah.suse.cz>
	 <3877989d0805220216o5add20ddye2a1fde98a0c1e69@mail.gmail.com>
	 <20080522111826.BB90326FA24@magilla.localdomain>
In-Reply-To: <20080522111826.BB90326FA24@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland McGrath <roland@redhat.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Thu, May 22, 2008 at 7:18 PM, Roland McGrath <roland@redhat.com> wrote:
> I really cannot figure out from anything you've said what the failure mode
> is or how you think it should be affected.

Sorry for confusion, Let me try to explain it more:

For ia64,the code path is like:
ptrace_notify (to let the debugger run)--> ptrace_stop
-->spin_unlock_irq->arch_ptrace_stop (ia64_ptrace_stop) ->[sync rbs
and set NOTIFY_RESUME.....]-->spin_lock_irq->set TASK_TRACED flag (to
let the debugger run)

For x86, the code path is like:
ptrace_notify (to let the debugger run) ->ptrace_stop->set TASK_TRACED
flag (to let the debugger run)-->spin_unlock_irq

If TASK_TRACED is not set earlier before arch_ptrace_stop on ia64
ptrace_notify code path, some signals would be delivered without
letting debugger run.. (i.e. PTRACED logica in get_signal_to_deliver
would be ignored totally!). These should cause the test case hang on
ia64. And x86 just works..

If you have any question , I would dig further..

Thanks,
Luming
