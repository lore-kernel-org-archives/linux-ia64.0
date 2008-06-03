From: Roland McGrath <roland@redhat.com>
Date: Tue, 03 Jun 2008 22:13:35 +0000
Subject: RE: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a race
Message-Id: <20080603221335.44ECD26FC96@magilla.localdomain>
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
	<20080603210125.1724C26FC96@magilla.localdomain>
	<1FE6DD409037234FAB833C420AA843EC017C44B2@orsmsx424.amr.corp.intel.com>
In-Reply-To: Luck, Tony's message of  Tuesday, 3 June 2008 14:31:50 -0700 <1FE6DD409037234FAB833C420AA843EC017C44B2@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, Luming Yu <luming.yu@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

> This might not be the same bug ... but I do have a definite 100%
> reproducible bug (latest git kernel, old version of strace (4.5.15-1.el4.=
1))

Please start a thread with a sensical subject line about that.

> Backtrace of pid 6443 (make)
>=20
> Call Trace:
>  [<a0000001007069b0>] schedule+0x11f0/0x1380
>                                 sp=E0000001b768fb40 bsp=E0000001b7680d58
>  [<a000000100707800>] schedule_timeout+0x40/0x180
>                                 sp=E0000001b768fb60 bsp=E0000001b7680d28
>  [<a000000100706d60>] wait_for_common+0x220/0x380
>                                 sp=E0000001b768fb90 bsp=E0000001b7680cd8
>  [<a000000100706f00>] wait_for_completion+0x40/0x60
>                                 sp=E0000001b768fbf0 bsp=E0000001b7680cb8
>  [<a0000001000794d0>] do_fork+0x430/0x4a0
>                                 sp=E0000001b768fbf0 bsp=E0000001b7680c60
>  [<a00000010000a340>] sys_clone+0x60/0x80
>                                 sp=E0000001b768fc20 bsp=E0000001b7680c10
>  [<a00000010000a990>] ia64_trace_syscall+0xd0/0x110
>                                 sp=E0000001b768fe30 bsp=E0000001b7680c10
>  [<a000000000010740>] __kernel_syscall_via_break+0x0/0x20
>                                 sp=E0000001b7690000 bsp=E0000001b7680c10

This trace (do_fork->wait_for_completion) tells us this is a vfork call.
It is waiting for its child (presumably 6444) to exit or exec.

> Backtrace of pid 6444 (make)
>=20
> Call Trace:
>  [<a0000001007069b0>] schedule+0x11f0/0x1380
>                                 sp=E0000001b803fd60 bsp=E0000001b8030dd8
>  [<a000000100097590>] ptrace_stop+0x2d0/0x380
>                                 sp=E0000001b803fd80 bsp=E0000001b8030da0
>  [<a000000100097c90>] get_signal_to_deliver+0x1d0/0x6a0
>                                 sp=E0000001b803fd80 bsp=E0000001b8030d38
>  [<a000000100034a10>] ia64_do_signal+0xb0/0xd00
>                                 sp=E0000001b803fd80 bsp=E0000001b8030c90
>  [<a000000100012c60>] do_notify_resume_user+0x100/0x180
>                                 sp=E0000001b803fe20 bsp=E0000001b8030c60
>  [<a00000010000b0c0>] notify_resume_user+0x40/0x60
>                                 sp=E0000001b803fe20 bsp=E0000001b8030c10
>  [<a00000010000aff0>] skip_rbs_switch+0xe0/0x110
>                                 sp=E0000001b803fe30 bsp=E0000001b8030c10
>  [<a000000000010740>] __kernel_syscall_via_break+0x0/0x20
>                                 sp=E0000001b8040000 bsp=E0000001b8030c10

This is the normal trace for the child having received a signal and stopped
to tell ptrace about it (not a syscall tracing stop).

I think you need to look into what strace is doing.  There is far too much
going to know much of anything just from the kernel state where the
processes sit.  In particular, the sequence of ptrace and wait calls strace
made.  If the same strace (identical everything) behaved differently with
an older kernel, then compare the sequence of ptrace and wait calls and see
where it differs.


Thanks,
Roland
