From: Andreas Schwab <schwab@suse.de>
Date: Thu, 05 Jul 2007 08:48:54 +0000
Subject: Re: [RFC][PATCH] fsys_gettimeofday leaps days if it runs with nojitter
Message-Id: <je644zkzgp.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <468CA2D6.40204@jp.fujitsu.com>
In-Reply-To: <468CA2D6.40204@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com> writes:

> I suspected the value of r28.
> So I just relocate "consuming" of r28 to early stage.
>
> <PATCH>
>> Index: linux-2.6.21/arch/ia64/kernel/fsys.S
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D>> --- linux-2.6.21.orig/arch/ia64/kernel/fsys.S
>> +++ linux-2.6.21/arch/ia64/kernel/fsys.S
>> @@ -247,6 +247,9 @@
>>  .time_redo:
>>  	.pred.rel.mutex p8,p9,p10
>>  	ld4.acq r28 =3D [r29]	// xtime_lock.sequence. Must come first for lock=
ing purposes
>> +	;;
>> +	and r28 =3D ~1,r28	// Make sequence even to force retry if odd
>> +	;;
>>  (p8)	mov r2 =3D ar.itc		// CPU_TIMER. 36 clocks latency!!!
>>  	add r22 =3D IA64_TIME_INTERPOLATOR_LAST_COUNTER_OFFSET,r20
>>  (p9)	ld8 r2 =3D [r30]		// readq(ti->address). Could also have latency i=
ssues..
>> @@ -284,7 +287,6 @@
>>  (p15)	ld8 r17 =3D [r19],-IA64_TIMESPEC_TV_NSEC_OFFSET
>>  (p7)	cmp.ne p7,p0 =3D r25,r3	// if cmpxchg not successful redo
>>  	// simulate tbit.nz.or p7,p0 =3D r28,0
>> -	and r28 =3D ~1,r28	// Make sequence even to force retry if odd
>>  	getf.sig r2 =3D f8
>>  	mf
>>  	add r8 =3D r8,r18		// Add time interpolator offset
> </PATCH>
>
> What a surprise! This patch solves the problem!

How can the register lose its contents?  The only thing that can make a
difference is the stop bit.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
