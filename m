From: Roland McGrath <roland@redhat.com>
Date: Tue, 27 May 2008 06:12:09 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a race
Message-Id: <20080527061209.9A24426FAA6@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	<3877989d0805220624i259a9d1j708795c65c636ca0@mail.gmail.com>
	<20080522203428.835D626FA24@magilla.localdomain>
	<3877989d0805222042p176da844k384ea512b1cfb0da@mail.gmail.com>
	<20080523041940.39E8726FA24@magilla.localdomain>
	<3877989d0805222224n77ce36b6wdf15c4bab330a0f8@mail.gmail.com>
	<20080526001527.81E1126FA9E@magilla.localdomain>
	<3877989d0805251830w70f19e4cu46fbc32148217749@mail.gmail.com>
	<3877989d0805262031i29db16bcjfa31652afc746b49@mail.gmail.com>
	<20080527040454.053C526FA9E@magilla.localdomain>
	<3877989d0805262249yab130cbyfc5f5e54065cec5c@mail.gmail.com>
In-Reply-To: Luming Yu's message of  Tuesday, 27 May 2008 13:49:44 +0800 <3877989d0805262249yab130cbyfc5f5e54065cec5c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Luming Yu <luming.yu@gmail.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

>  [<a00000010000a9f0>] skip_rbs_switch+0xe0/0x110
>                                 sp=E000000141c9fe30 bsp=E000000141c90cf8
>  [<a000000000010740>] __kernel_syscall_via_break+0x0/0x20
>                                 sp=E000000141ca0000 bsp=E000000141c90cf8
>  [<a0000001000971c0>] ptrace_stop+0xa0/0x3e0
>                                 sp=E00000014716fdb0 bsp=E000000147160ca8
>  [<a000000100097650>] ptrace_notify+0x150/0x1c0
>                                 sp=E00000014716fdb0 bsp=E000000147160c88

If this is a backtrace of a single thread on the same kernel stack, it has
a stack depth of over 84MB.  You still need to follow the path inside
ia64_ptrace_stop() to see how any of this is possible.


Thanks,
Roland
