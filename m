From: Roland McGrath <roland@redhat.com>
Date: Thu, 22 May 2008 20:34:28 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a race
Message-Id: <20080522203428.835D626FA24@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	<1211446045.5610.33.camel@elijah.suse.cz>
	<3877989d0805220216o5add20ddye2a1fde98a0c1e69@mail.gmail.com>
	<20080522111826.BB90326FA24@magilla.localdomain>
	<3877989d0805220624i259a9d1j708795c65c636ca0@mail.gmail.com>
In-Reply-To: Luming Yu's message of  Thursday, 22 May 2008 21:24:11 +0800 <3877989d0805220624i259a9d1j708795c65c636ca0@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Luming Yu <luming.yu@gmail.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

> Sorry for confusion, Let me try to explain it more:

I understand these code paths (I wrote them).

> If TASK_TRACED is not set earlier before arch_ptrace_stop on ia64
> ptrace_notify code path, some signals would be delivered without
> letting debugger run.. (i.e. PTRACED logica in get_signal_to_deliver
> would be ignored totally!). These should cause the test case hang on
> ia64. And x86 just works..

I do not understand this at all, and it has given no information you did
not give before.  Please describe the scenario you see in fine-grained
terms.


Thanks,
Roland
