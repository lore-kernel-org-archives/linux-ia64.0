From: Roland McGrath <roland@redhat.com>
Date: Mon, 26 May 2008 00:15:27 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a race
Message-Id: <20080526001527.81E1126FA9E@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	<1211446045.5610.33.camel@elijah.suse.cz>
	<3877989d0805220216o5add20ddye2a1fde98a0c1e69@mail.gmail.com>
	<20080522111826.BB90326FA24@magilla.localdomain>
	<3877989d0805220624i259a9d1j708795c65c636ca0@mail.gmail.com>
	<20080522203428.835D626FA24@magilla.localdomain>
	<3877989d0805222042p176da844k384ea512b1cfb0da@mail.gmail.com>
	<20080523041940.39E8726FA24@magilla.localdomain>
	<3877989d0805222224n77ce36b6wdf15c4bab330a0f8@mail.gmail.com>
In-Reply-To: Luming Yu's message of  Friday, 23 May 2008 13:24:44 +0800 <3877989d0805222224n77ce36b6wdf15c4bab330a0f8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Luming Yu <luming.yu@gmail.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

> "deliver" here I mean get_signal_to_deliver()...

This can never happen inside ptrace_stop.  
So your line of inquiry doesn't make sense to me.

> the test doesn't block SIGTRAP, it works on IA64 too.. Hope I have
> made the problem clear...

It was already quite clear what elements have to be present to cause a
problem with the test case (ia64 and blocked SIGTRAP).  Nothing else about
it is yet clear to me, sorry.

Please tell us the exact code path you think is happening in the error case
you can reproduce.  


Thanks,
Roland
