From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Thu, 08 Feb 2007 01:25:36 +0000
Subject: RE: [PATCH] Hook up getcpu system call for IA64
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086BDF@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070206000757.GA32026@linux-os.sc.intel.com>
In-Reply-To: <20070206000757.GA32026@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Luck, Tony
> Sent: 2007=C4=EA2=D4=C28=C8=D5 2:00
> To: Ken Chen; Yu, Fenghua
> Cc: linux-ia64@vger.kernel.org
> Subject: RE: [PATCH] Hook up getcpu system call for IA64
>=20
> > Andi Kleen used to lecture me every so often why it is important to
> > have fast vgetcpu on x86-64 (I don't think ia64 is excluded from
> > that).  His lecture is also all over the lkml mailing list.
>=20
> I dug though that thread ... it isn't ever explicitly stated, but
> it does appear that the intent is that a NUMA aware application
> would use a malloc() library that called getcpu() on every memory
> allocation.  If that is the usage model, then I'll agree that
> getcpu() does need to be fast.
>=20
> One possible way to achieve that on ia64 would be to make use of the
> fact that the ar.k* registers are readable by applications, and
> specifically ar.k3 contains a per-cpu value (physical address of the
> kernel percpu area).  *IF* (and that is a BIG IF) we were to guarantee
> to maintain ar.k3 as a per-cpu unique value, then we could implement
> a very fast (even faster than fsys.S) getcpu() as:
>=20
> #define __NR_getcpu                     1304
>=20
> int
> getcpu(unsigned *cpup, unsigned *nodep, void *cachep)
> {
> 	static unsigned cpu =3D ~0, node =3D ~0;
> 	static unsigned long save_ar_k3;
> 	unsigned long ar_k3;
>=20
> 	asm volatile ("mov %0=3Dar.k3" : "=3Dr" (ar_k3));
> 	if (cpu =3D ~0 || ar_k3 !=3D save_ar_k3) {
> 		if (syscall(__NR_getcpu, &cpu, &node, 0) =3D -1)
> 			return -1;
> 		save_ar_k3 =3D ar_k3;
> 	}
> 	*cpup =3D cpu;
> 	*nodep =3D node;
>=20
> 	return 0;
> }
>=20
>=20
> Too ugly for words?  Or worth serious consideration?
>=20
> -Tony

I think it is possible to pin ar.k3 to processor id, then change the raw_sm=
p_processor_id() implementation.
This should be better than current raw_smp_processor_id() implementation.

Then we could implement sys_getcpu in fsys.S
That could not be very complex, only thing we need to care is exception han=
dle in fsys code.

Thanks
Zou Nan hai

> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
