From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 04 Mar 2002 18:37:11 +0000
Subject: Re: [Linux-ia64] O(1) scheduler K3+ for IA64
Message-Id: <marc-linux-ia64-105590701905214@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905201@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905201@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I applied the fix below, but still get hangs at boot sometimes.
Here's the output with one of the smpboot debug switches turned on,
hope it helps.

Thanks,
Jesse

CPU13: CPU has booted.
Sending wakeup vector 18 to AP 0xe/0x302.
Waiting on callin_map ...start_secondary: starting CPU 0x302
CPU 14: mapping PAL code [0x0-0x100000) into
[0xe000000000000000-0xe000000004000
000)
CPU 14: 51 virtual and 44 physical address bits
CPU 13 is set to go.
CPU 14: base freq=133.017MHz, ITC ratio=11/2, ITC freqs1.598MHz
C PROM ERROR: Unimplemented SAL call (sal_get_state_info)
ia64_log_get: Failed to retrieve SAL error record type 0
Unexpected irq vector 0xe12 on CPU 14!
Calibrating delay loop... 728.32 BogoMIPSD PROM RTS_TRACE:
(sal_freq_base)

Stack on CPU 14 at about e00000004ff6fe60I'm alive and well


CPU14: CPU has booted.
Sending wakeup vector 18 to AP 0xf/0x303.
Waiting on callin_map ...start_secondary: starting CPU 0x303
CPU 15: mapping PAL code [0x0-0x100000) into
[0xe000000000000000-0xe000000004000
000)
CPU 15: 51 virtual and 44 physical address bits
CPU 14 is set to go.
CPU 15: base freq=133.017MHz, ITC ratio=11/2, ITC freqs1.598MHz
D PROM ERROR: Unimplemented SAL call (sal_get_state_info)
ia64_log_get: Failed to retrieve SAL error record type 0
Unexpected irq vector 0xf12 on CPU 15!
Calibrating delay loop... 728.32 BogoMIPS
Stack on CPU 15 at about e00000004ff67e60

CPU15: CPU has booted.
Before bogomips.
Total of 16 processors activated (11650.12 BogoMIPS).
Setting commenced=3D1, go go go
CPU 3 is starting idle.
CPU 2 is starting idle.
CPU 4 is starting idle.
CPU 5 is starting idle.
CPU 7 is starting idle.
CPU 6 is starting idle.
CPU 9 is starting idle.
CPU 8 is starting idle.
CPU 12 is starting idle.
CPU 13 is starting idle.
CPU 14 is starting idle.
CPU 11 is starting idle.
CPU 10 is starting idle.
migration_task on cpu=3D0 mask=3D1
migration_task on cpu=3D1 mask=3D2
migration_task on cpu=3D2 mask=3D4
CPU 15 is set to go.
CPU 15 is starting idle.
migration_task on cpu=14 mask@00
migration_task on cpu=13 mask 00
migration_task on cpu=12 mask=1000
migration_task on cpu=3D8 mask=100
migration_task on cpu=3D6 mask@
migration_task on cpu=3D7 mask=80
migration_task on cpu=3D9 mask 0
migration_task on cpu=3D4 mask=10
migration_task on cpu=3D5 mask=20
migration_task on cpu=11 mask=800
migration_task on cpu=10 mask@0
migration_task on cpu=15 mask=8000


On Mon, Mar 04, 2002 at 12:41:40PM +0100, Erich Focht wrote:
> Hi Jesse,
>=20
> On Fri, 1 Mar 2002, Jesse Barnes wrote:
>=20
> > Hey Erich, I've been testing out your latest K3+ patch (along with
> > yours and Mike's NUMA scheduler changes) and found that it seems less
> > stable than the old version that used locking for the tlb flush stuff.
> > I think there's a deadlock somewhere in the new code since
> > 2.4.17 + kdb + ia64 + Ingo K3 + old K3+: rock solid
> > 2.4.17 + kdb + ia64 + Ingo K3 + new K3+: sometimes hangs at boot,
>=20
> please find attached a fix the should help for the K3+ scheduler. I had
> this fixed in the NUMA patch I've sent out...
>=20
> The NUMA patch can have similar problems, there I needed to eliminate the
> idle checks in scan_pools().
>=20
> Best regards,
> Erich
>=20
> --- 2.4.17-ia64-kdbv2.1-K3+/kernel/sched.c.~1~	Mon Mar  4 11:39:18 2002
> +++ 2.4.17-ia64-kdbv2.1-K3+/kernel/sched.c	Mon Mar  4 11:54:01 2002
> @@ -1539,7 +1539,8 @@
> =20
>  	for (;;) {
>  		if (test_and_clear_bit(smp_processor_id(), &migration_mask))
> -			current->cpus_allowed =3D 1 << smp_processor_id();
> +                        printk("migration_task on cpu=3D%d mask=3D%lx\n",
> +                               cpu(),current->cpus_allowed);
>  		if (current->need_resched)
>  			schedule();
>  		if (!migration_mask)
>=20
>=20

