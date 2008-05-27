From: "Luming Yu" <luming.yu@gmail.com>
Date: Tue, 27 May 2008 03:31:43 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a race
Message-Id: <3877989d0805262031i29db16bcjfa31652afc746b49@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	 <3877989d0805220216o5add20ddye2a1fde98a0c1e69@mail.gmail.com>
	 <20080522111826.BB90326FA24@magilla.localdomain>
	 <3877989d0805220624i259a9d1j708795c65c636ca0@mail.gmail.com>
	 <20080522203428.835D626FA24@magilla.localdomain>
	 <3877989d0805222042p176da844k384ea512b1cfb0da@mail.gmail.com>
	 <20080523041940.39E8726FA24@magilla.localdomain>
	 <3877989d0805222224n77ce36b6wdf15c4bab330a0f8@mail.gmail.com>
	 <20080526001527.81E1126FA9E@magilla.localdomain>
	 <3877989d0805251830w70f19e4cu46fbc32148217749@mail.gmail.com>
In-Reply-To: <3877989d0805251830w70f19e4cu46fbc32148217749@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Roland McGrath <roland@redhat.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

>
> if happens, it should be a bug, right?

It does happen!!

Call Trace:
 [<a000000100011bd0>] show_stack+0x50/0xa0
                                sp=E000000146bbfbb0 bsp=E000000146bb0e08
 [<a000000100011c50>] dump_stack+0x30/0x60
                                sp=E000000146bbfd80 bsp=E000000146bb0de8
 [<a0000001000979a0>] get_signal_to_deliver+0x60/0x6e0
                                sp=E000000146bbfd80 bsp=E000000146bb0d80
 [<a0000001000343d0>] ia64_do_signal+0xb0/0xd00
                                sp=E000000146bbfd80 bsp=E000000146bb0cd8
 [<a000000100012650>] do_notify_resume_user+0xf0/0x140
                                sp=E000000146bbfe20 bsp=E000000146bb0ca8
 [<a00000010000aac0>] notify_resume_user+0x40/0x60
                                sp=E000000146bbfe20 bsp=E000000146bb0c58
 [<a00000010000a9f0>] skip_rbs_switch+0xe0/0x110
                                sp=E000000146bbfe30 bsp=E000000146bb0c58
 [<a000000000010740>] __kernel_syscall_via_break+0x0/0x20
                                sp=E000000146bc0000 bsp=E000000146bb0c58

>>
> I will try to customize kernel to capture call trace for a precise code p=
ath.

I applied the following patch , and got the call trace above..
If apply my RFC patch as antidote,  I don't see "deliver" ...
Is the problem clear now?  I will serve you until every thing is clear to y=
ou.

Thanks,
Luming

Signed-off-by: Yu Luming <luming.yu@intel.com>

diff -Bru 1/kernel/signal.c 0/kernel/signal.c
--- 1/kernel/signal.c   2008-05-27 15:18:48.000000000 +0800
+++ 0/kernel/signal.c   2008-05-27 15:08:51.000000000 +0800
@@ -38,6 +38,7 @@
  */

 static struct kmem_cache *sigqueue_cachep;
+unsigned long global_arch_ptrace_stop_flag =3D0;

 static int __sig_ignored(struct task_struct *t, int sig)
 {
@@ -1501,9 +1502,12 @@
                 * siglock.  That must prevent us from sleeping in TASK_TRA=
CED.
                 * So after regaining the lock, we must check for SIGKILL.
                 */
+               global_arch_ptrace_stop_flag =3D 1;
                spin_unlock_irq(&current->sighand->siglock);
                arch_ptrace_stop(exit_code, info);
+
                spin_lock_irq(&current->sighand->siglock);
+               global_arch_ptrace_stop_flag =3D 0;
                killed =3D sigkill_pending(current);
        }

@@ -1701,6 +1705,8 @@
        struct signal_struct *signal =3D current->signal;
        int signr;

+       if (global_arch_ptrace_stop_flag)
+               dump_stack();
 relock:
        /*
         * We'll jump back here after any time we were stopped in TASK_STOP=
PED.
