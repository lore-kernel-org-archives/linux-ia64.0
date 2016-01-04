From: James Hogan <james.hogan@imgtec.com>
Date: Mon, 04 Jan 2016 16:04:55 +0000
Subject: Re: [PATCH v2 20/32] metag: define __smp_xxx
Message-Id: <20160104160455.GE17861@jhogan-linux.le.imgtec.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="PGNNI9BzQDUtgA2J"
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
 <1451572003-2440-21-git-send-email-mst@redhat.com>
 <20160104134128.GZ6344@twins.programming.kicks-ass.net>
 <20160104152558.GD17861@jhogan-linux.le.imgtec.org>
 <20160104153036.GG6344@twins.programming.kicks-ass.net>
In-Reply-To: <20160104153036.GG6344@twins.programming.kicks-ass.net>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@kernel.org>, David

--PGNNI9BzQDUtgA2J
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jan 04, 2016 at 04:30:36PM +0100, Peter Zijlstra wrote:
> On Mon, Jan 04, 2016 at 03:25:58PM +0000, James Hogan wrote:
> > It is used along with the metag specific __global_lock1() (global
> > voluntary lock between hw threads) whenever a write is performed, and by
> > smp_mb/smp_rmb to try to catch other cases, but I've never been
> > confident this fixes every single corner case, since there could be
> > other places where multiple CPUs perform unsynchronised writes to the
> > same memory location, and expect cache not to become incoherent at that
> > location.
>=20
> Ah, yuck, I thought blackfin was the only one attempting !coherent SMP.
> And yes, this is bound to break in lots of places in subtle ways. We
> very much assume cache coherency for SMP in generic code.

Well, its usually completely coherent, its just a bit dodgy in a
particular hardware corner case, which was pretty hard to hit, even
without these workarounds.

>=20
> > It seemed to be sufficient to achieve stability however, and SMP on Meta
> > Linux never made it into a product anyway, since the other hw thread
> > tended to be used for RTOS stuff, so it didn't seem worth extending the
> > generic barrier API for it.
>=20
> *phew*, should we take it out then, just to be sure nobody accidentally
> tries to use it then?

SMP support on this SoC you mean? I doubt it'll be a problem tbh, and
it'd work fine in QEMU when emulating this SoC, so I'd prefer to keep it
in.

Cheers
James

--PGNNI9BzQDUtgA2J
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWipgnAAoJEGwLaZPeOHZ6H00QAJCE8+tFVrOY06765tPTdzed
wYC0LFfKDLv/TtsEAy4zBhWYEwJ0R1gQOTjCKsdaJMINDcpCy+1mWV4b1X1B+ptV
QD5oOYZy7Fln8VYYvzWp+2Tz/iAoBSnBV1S8rG9eIxwWmJ9NQmhRl7I+GaFO5kgS
+0p+z0sJ6Fvv8jmFdzGF4AIAgm4hFY2O2ojy2jtGArgkFmuSdrrrS2//Uls6z3ZC
thEMVwEapQUjh0JZXDxkImzKXDfMcDi7Sse8Pdz+hXn0Q8J1u2tlhNwL7mqlY5lz
JpV/L050BZ94Vpop0JXLmQRkqaO7dDgmi+zGXSvSqSUL7/qWHk3h6gE6tTShr4Qp
rccA+QoreW9oQmUaAERc/DlB7I8SFYZE08YTLLVh+6bqPPK2sZOSa1/XfRC3UC35
+/exm7MjSr4Emmfo9D5xxRAf4e+nYIuYjmf0rik9Hz5CUYqgbc6yoN570p0omqnL
7WaRZWn+KESjhPrBrEcEbHFqV3OYsRgCPcoiSL5MVXXE0PlRXQtkDG9ach9jmtyZ
gz103rjyp1FdqUVG3yYfmCsTNfWwiOJRX1IXLkuTJ0Spjmmk9KtFFO5sUxMV/2l6
aJ+ehCqr/o58IZf71tqQvLQPeJCvUZ6y8mqAjBAdx1b+FBxUlu2kZ+opl3tI96dK
DUA3rNDlPNmeqf8XVgY8
=bXcF
-----END PGP SIGNATURE-----

--PGNNI9BzQDUtgA2J--
