From: Petr Tesarik <ptesarik@suse.cz>
Date: Tue, 03 Jun 2008 14:32:57 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a
Message-Id: <48455619.6040608@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>	 <20080523041940.39E8726FA24@magilla.localdomain>	 <3877989d0805222224n77ce36b6wdf15c4bab330a0f8@mail.gmail.com>	 <20080526001527.81E1126FA9E@magilla.localdomain>	 <3877989d0805251830w70f19e4cu46fbc32148217749@mail.gmail.com>	 <3877989d0805262031i29db16bcjfa31652afc746b49@mail.gmail.com>	 <20080527040454.053C526FA9E@magilla.localdomain>	 <3877989d0805262249yab130cbyfc5f5e54065cec5c@mail.gmail.com>	 <20080527061209.9A24426FAA6@magilla.localdomain>	 <1211869515.29836.2.camel@elijah.suse.cz> <3877989d0806022304w35764b17p9d4c3c95eceae0f5@mail.gmail.com> <48450864.6080707@suse.cz>
In-Reply-To: <48450864.6080707@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Petr Tesarik <ptesarik@suse.cz>
Cc: Luming Yu <luming.yu@gmail.com>, Roland McGrath <roland@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Petr Tesarik wrote:
> Luming Yu wrote:
>> On Tue, May 27, 2008 at 2:25 PM, Petr Tesarik <ptesarik@suse.cz> wrote:
>>> On Mon, 2008-05-26 at 23:12 -0700, Roland McGrath wrote:
>>>>>  [<a00000010000a9f0>] skip_rbs_switch+0xe0/0x110
>>>>>                                 sp=E000000141c9fe30 bsp=E000000141c90=
cf8
>>>>>  [<a000000000010740>] __kernel_syscall_via_break+0x0/0x20
>>>>>                                 sp=E000000141ca0000 bsp=E000000141c90=
cf8
>>> Indeed, there seems to be a large hole here. So, this is either a bug in
>>> the unwinder, or a bug in the RBS synchronization, which causes
>>> corruption. My test machine currently needs some work to run 2.6.25
>>> again, but I'll try your test case as soon as I re-install it later this
>>> week.
>> Just want to check if the test case works for you?
>=20
> Yes, the test case hangs here too. But the problem seems to be
> elsewhere. Did you look into the strace output? This line is pretty
> suspicious:
>=20
> 3258  clone2(child_stack=3D0, stack_size=3D0,
> flags=3DCLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD,
> child_tidptr=3D0x200000000004e290) =3D 1
>=20
> Obviously, strace cannot attach PID 1, and since it is not designed to
> handle this situation, it hangs. I'm going to investigate why the return
> value of the clone2 syscall is seen as 1 by the tracer. Might even turn
> out to be a bug in strace...

It's definitely a bug in strace. For some reason (I don't care about)
the execve() syscall produces an extra notification. However, this
notification message is suppressed when SIGTRAP is blocked. This
explains why the test case fails only when SIGTRAP is blocked.

Now, you may ask why it only fails on ia64 and not on i386 or x86_64.
Well, I was so good that I even looked into strace sources to make sure.
Whereas for i386 and x86_64, the value of EAX/RAX is checked for -ENOSYS
in syscall_fixup(), for ia64 the first ptrace() after an execve() is
unconditionally ignored, see code in get_scno().

I don't know why Luming's fix helps here, but, please, fix strace, don't
introduce weird behaviour in the kernel.

The only thing I'm willing to talk about is why the extra notification
message is sent, and how userspace (strace) is supposed to recognize it.
FWIW the backtrace (system tap was at __group_send_sig_info):

 0xa0000001000b1a60 : __group_send_sig_info+0x0/0x180 []
 0xa0000001000b1e30 : do_notify_parent_cldstop+0x250/0x2c0 []
 0xa0000001000b2230 : ptrace_stop+0x2b0/0x3c0 []
 0xa0000001000b5200 : get_signal_to_deliver+0x200/0xa40 []
 0xa000000100035920 : ia64_do_signal+0xa0/0xee0 []
 0xa000000100014b60 : do_notify_resume_user+0x100/0x160 []
 0xa00000010000d040 : notify_resume_user+0x40/0x60 []
 0xa00000010000cf40 : skip_rbs_switch+0xf0/0x150 []
 0xa000000000010620 : __kernel_syscall_via_break+0x0/0x20 []

Regards,
Petr Tesarik

