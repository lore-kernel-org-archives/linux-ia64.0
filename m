From: "Luming Yu" <luming.yu@gmail.com>
Date: Fri, 23 May 2008 05:24:44 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a race
Message-Id: <3877989d0805222224n77ce36b6wdf15c4bab330a0f8@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	 <1211446045.5610.33.camel@elijah.suse.cz>
	 <3877989d0805220216o5add20ddye2a1fde98a0c1e69@mail.gmail.com>
	 <20080522111826.BB90326FA24@magilla.localdomain>
	 <3877989d0805220624i259a9d1j708795c65c636ca0@mail.gmail.com>
	 <20080522203428.835D626FA24@magilla.localdomain>
	 <3877989d0805222042p176da844k384ea512b1cfb0da@mail.gmail.com>
	 <20080523041940.39E8726FA24@magilla.localdomain>
In-Reply-To: <20080523041940.39E8726FA24@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland McGrath <roland@redhat.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

> This is the key thing that makes no sense to me.  What do you mean by
> "deliver" here?  The normal meaning of to "deliver" a signal means that
> get_signal_to_deliver() dequeues and processes it.  This can never happen
> inside any other kernel code path.  It certainly can never happen inside
> ptrace_stop or ptrace_notify.

"deliver" here I mean get_signal_to_deliver()...
Please clarify, in ptrace_notify code path, is it allowed that ptraced
thread can ignore signals (such as SIGTRAP) without telling debugger
what happened? This is key problem I'm not quite sure... Because if
the test doesn't block SIGTRAP, it works on IA64 too.. Hope I have
made the problem clear...
