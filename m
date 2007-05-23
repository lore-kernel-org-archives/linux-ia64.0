From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 23 May 2007 06:43:14 +0000
Subject: Re: BUG: sleeping function called from invalid context at
Message-Id: <20070522234314.54081817.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070523063154.GR85884050@sgi.com>
In-Reply-To: <20070523063154.GR85884050@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: David Chinner <dgc@sgi.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Wed, 23 May 2007 16:31:54 +1000 David Chinner <dgc@sgi.com> wrote:

> Saw this when running strace -f on a script on 2.6.21 on ia64:
>=20
> BUG: sleeping function called from invalid context at kernel/fork.c:385
> in_atomic():1, irqs_disabled():0
>=20
> Call Trace:
>  [<a000000100014700>] show_stack+0x80/0xa0
>                                 sp=E00000306e6f7a00 bsp=E00000306e6f0ef8
>  [<a000000100014750>] dump_stack+0x30/0x60
>                                 sp=E00000306e6f7bd0 bsp=E00000306e6f0ee0
>  [<a0000001000acaf0>] __might_sleep+0x1f0/0x260
>                                 sp=E00000306e6f7bd0 bsp=E00000306e6f0eb8
>  [<a0000001000bd2e0>] mmput+0x20/0x220
>                                 sp=E00000306e6f7bd0 bsp=E00000306e6f0e90
>  [<a0000001000321e0>] sys_ptrace+0x460/0x1600
>                                 sp=E00000306e6f7bd0 bsp=E00000306e6f0d80
>  [<a00000010000bc40>] ia64_ret_from_syscall+0x0/0x20
>                                 sp=E00000306e6f7e30 bsp=E00000306e6f0d80
>  [<a000000000010620>] __kernel_syscall_via_break+0x0/0x20
>                                 sp=E00000306e6f8000 bsp=E00000306e6f0d80
> BUG: sleeping function called from invalid context at kernel/fork.c:385
> in_atomic():1, irqs_disabled():0
>=20
> Call Trace:
>  [<a000000100014700>] show_stack+0x80/0xa0
>                                 sp=E00000306e6f7a00 bsp=E00000306e6f0ef8
>  [<a000000100014750>] dump_stack+0x30/0x60
>                                 sp=E00000306e6f7bd0 bsp=E00000306e6f0ee0
>  [<a0000001000acaf0>] __might_sleep+0x1f0/0x260
>                                 sp=E00000306e6f7bd0 bsp=E00000306e6f0eb8
>  [<a0000001000bd2e0>] mmput+0x20/0x220
>                                 sp=E00000306e6f7bd0 bsp=E00000306e6f0e90
>  [<a0000001000321e0>] sys_ptrace+0x460/0x1600
>                                 sp=E00000306e6f7bd0 bsp=E00000306e6f0d80
>  [<a00000010000bc40>] ia64_ret_from_syscall+0x0/0x20
>                                 sp=E00000306e6f7e30 bsp=E00000306e6f0d80
>  [<a000000000010620>] __kernel_syscall_via_break+0x0/0x20
>                                 sp=E00000306e6f8000 bsp=E00000306e6f0d80
>=20
> I could reproduce it via 'strace -f sleep 1'
>=20

I'd say this is specific to ia64.   Someone would have spotted it on
x86 by now.
