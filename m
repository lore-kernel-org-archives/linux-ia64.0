From: Andrew Morton <akpm@osdl.org>
Date: Wed, 06 Dec 2006 06:19:13 +0000
Subject: Re: [PATCH] CPEI gets warning at
Message-Id: <20061205221913.1ef416f9.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4575212A.3020902@jp.fujitsu.com>
In-Reply-To: <4575212A.3020902@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel list <linux-kernel@vger.kernel.org>, Arjan van de Ven <arjan@infradead.org>

On Tue, 05 Dec 2006 16:35:06 +0900
Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com> wrote:

> Hi,
>=20
> While running my MCA test (hardware error injection) on 2.6.19,
> I got some warning like following:
>=20
> > BUG: warning at kernel/irq/migration.c:27/move_masked_irq()
> >
> > Call Trace:
> >  [<a000000100013d20>] show_stack+0x40/0xa0
> >                                 sp=E00000006b2578d0 bsp=E00000006b2510b0
> >  [<a000000100013db0>] dump_stack+0x30/0x60
> >                                 sp=E00000006b257aa0 bsp=E00000006b251098
> >  [<a0000001000de430>] move_masked_irq+0xb0/0x240
> >                                 sp=E00000006b257aa0 bsp=E00000006b251070
> >  [<a0000001000de6a0>] move_native_irq+0xe0/0x180
> >                                 sp=E00000006b257aa0 bsp=E00000006b251040
> >  [<a00000010004ff50>] iosapic_end_level_irq+0x30/0xe0
> >                                 sp=E00000006b257aa0 bsp=E00000006b251020
> >  [<a0000001000d94d0>] __do_IRQ+0x170/0x400
> >                                 sp=E00000006b257aa0 bsp=E00000006b250fd8
> >  [<a0000001000116f0>] ia64_handle_irq+0x1b0/0x260
> >                                 sp=E00000006b257aa0 bsp=E00000006b250fa8
> >  [<a00000010000c3a0>] ia64_leave_kernel+0x0/0x280
> >                                 sp=E00000006b257aa0 bsp=E00000006b250fa8
> >  [<a000000100690cf0>] _spin_unlock_irqrestore+0x30/0x60
> >                                 sp=E00000006b257c70 bsp=E00000006b250f90
>=20
> It comes from:
>=20
> [kernel/irq/migration.c]
>   26         if (CHECK_IRQ_PER_CPU(desc->status)) {
>   27                 WARN_ON(1);
>   28                 return;
>   29         }
>=20
> By putting some printk in kernel, I found that irqbalance is trying to
> move CPEI which is handled as PER_CPU irq. That's why.
>=20
> CPEI(Corrected Platform Error Interrupt) is ia64 specific irq, is
> allowed to pin to particular processor which selected by the platform, and
> even it is PER_CPU but it has set_affinity handler (=3Diosapic_set_affini=
ty)
> as same as other IO-SAPIC-level interrupts. (I don't know why, but
> I guess that there would be typical situation where the handler for
> migration is needed, such as hotplug - the processor going to be
> offline/hot-removed.)
>=20
> To shut up this warning, there are 2 way at least:
>  a) fix CPEI stuff
>  b) prohibit setting affinity to PER_CPU irq
>=20
> I'm not sure what stuff of CPEI need to be fixed, but I think that
> returning error to attempting move PER_CPU irq is useful for all
> applications since it will never work.
>=20
> Following small patch takes b) style.
> It works, the warning disappeared and irqbalance still runs well.
>=20
> Thanks,
> H.Seto
>=20
> Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
>=20
> ---
>  kernel/irq/proc.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> Index: linux-2.6.19/kernel/irq/proc.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux-2.6.19.orig/kernel/irq/proc.c
> +++ linux-2.6.19/kernel/irq/proc.c
> @@ -54,7 +54,8 @@ static int irq_affinity_write_proc(struc
>  	unsigned int irq =3D (int)(long)data, full_count =3D count, err;
>  	cpumask_t new_value, tmp;
>=20
> -	if (!irq_desc[irq].chip->set_affinity || no_irq_affinity)
> +	if (!irq_desc[irq].chip->set_affinity || no_irq_affinity ||
> +				CHECK_IRQ_PER_CPU(irq_desc[irq].status))
>  		return -EIO;

It'd be nice if we could just teach the userspace balancer to not try to
move perpcu IRQs?

otoh, the patch is super-cheap.   Arjan?

