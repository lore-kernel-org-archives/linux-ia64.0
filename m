From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Fri, 06 Feb 2009 17:00:55 +0000
Subject: Re: [PATCH] ia64: prevent irq migration race in __cpu_disable path
Message-Id: <20090206170055.GI10918@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090206162213.GD8208@ldl.fc.hp.com>
In-Reply-To: <20090206162213.GD8208@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Alex Chiang <achiang@hp.com>, tony.luck@intel.com, stable@kernel.org, linux-ia64@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Feb 06, 2009 at 09:22:13AM -0700, Alex Chiang wrote:
> Commit e7b14036 (prevent ia64 from invoking irq handlers on
> offline CPUs) introduced a bug, where we call fixup_irqs before
> removing the CPU from the cpu_online_map.
>=20
> This is wrong because fixup_irqs calls migrate_irqs, and in
> migrate_irqs, we use the cpu_online_map to:
>=20
> 	1. look for interrupts on current CPU
> 	2. if we find one, move it to the first available CPU in
> 	the cpu_online_map
>=20
> This means we can potentially migrate an interrupt off ourself
> back to... ourself. Uh oh.
>=20
> We hit a NULL deref later which causes us to oops (output trimmed):
>=20
> Unable to handle kernel NULL pointer dereference (address 000000000000004=
0)
> ip is at profile_tick+0xd0/0x1c0
>=20
> Call Trace:
>  [<a00000010003c700>] die+0x1a0/0x2e0
>                                 sp=E0000009c922fbd0 bsp=E0000009c9221438
>  [<a0000001006e92f0>] ia64_do_page_fault+0x950/0xa80
>                                 sp=E0000009c922fbd0 bsp=E0000009c92213d8
>  [<a00000010000c7a0>] ia64_native_leave_kernel+0x0/0x270
>                                 sp=E0000009c922fc60 bsp=E0000009c92213d8
>  [<a0000001000ecdb0>] profile_tick+0xd0/0x1c0
>                                 sp=E0000009c922fe30 bsp=E0000009c9221398
>  [<a00000010003bb90>] timer_interrupt+0x170/0x3e0
>                                 sp=E0000009c922fe30 bsp=E0000009c9221330
>  [<a00000010013a800>] handle_IRQ_event+0x80/0x120
>                                 sp=E0000009c922fe30 bsp=E0000009c92212f8
>  [<a00000010013aa00>] __do_IRQ+0x160/0x4a0
>                                 sp=E0000009c922fe30 bsp=E0000009c9221290
>  [<a000000100012290>] ia64_process_pending_intr+0x2b0/0x360
>                                 sp=E0000009c922fe30 bsp=E0000009c9221208
>  [<a0000001000112d0>] fixup_irqs+0xf0/0x2a0
>                                 sp=E0000009c922fe30 bsp=E0000009c92211a8
>  [<a00000010005bd80>] __cpu_disable+0x140/0x240
>                                 sp=E0000009c922fe30 bsp=E0000009c9221168
>  [<a0000001006c5870>] take_cpu_down+0x50/0xa0
>                                 sp=E0000009c922fe30 bsp=E0000009c9221148
>  [<a000000100122610>] stop_cpu+0xd0/0x200
>                                 sp=E0000009c922fe30 bsp=E0000009c92210f0
>=20
> Reading through the original thread:
>=20
> 	http://lkml.org/lkml/2008/8/31/116
>=20
> It looks like Paul fixed his original issue correctly, put in a
> new call to cpu_clear() in the wrong spot, and then was convinced
> to remove the _correct_ call to cpu_clear().
>=20
> Cc: stable@kernel.org
> Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Signed-off-by: Alex Chiang <achiang@hp.com>
> ---
> In my opinion, this is .29 material.
>=20
> Sorry for the huge changelog:patch ratio, but this area is tricky
> enough that more explanation is better than less, I think.
>=20
> Also, I'm still a little troubled by Paul's original patch. What
> happens if we're trying to offline the CPEI target? The code in
> migrate_platform_irqs() uses cpu_online_map to select the new
> CPEI target, and it seems like we can end up in the same
> situation as the problem I'm trying to fix now.
>=20
> Paul?
>=20
> My patch has held up for over 24 hours of stress testing, where
> we put the system under a heavy load and then randomly
> offline/online CPUs every 2 seconds. Without this patch, the
> machine would crash reliably within 15 minutes.

I don't claim much expertise on IA64 low-level architectural details,
so am reduced to asking the usual question...  Does this patch guarantee
that a given CPU won't be executing irq handlers while marked offline?
If there is no such guarantee, things can break.  (See below.)

In any case, apologies for failing to correctly fix the original
problem!!!

> ---
>=20
> diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
> index 1146399..2a17d1c 100644
> --- a/arch/ia64/kernel/smpboot.c
> +++ b/arch/ia64/kernel/smpboot.c
> @@ -742,8 +742,8 @@ int __cpu_disable(void)
>  	}
>=20
>  	remove_siblinginfo(cpu);
> -	fixup_irqs();
>  	cpu_clear(cpu, cpu_online_map);
> +	fixup_irqs();

So you argument is that because we are running in the context of
stop_machine(), even though fixup_irqs() does in fact cause irq handlers
to run on the current CPU which is marked offline, the fact that there
is no one running to notice this misbehavior makes it OK?  (Which
perhaps it is, just asking the question.)

							Thanx, Paul

>  	local_flush_tlb_all();
>  	cpu_clear(cpu, cpu_callin_map);
>  	return 0;
