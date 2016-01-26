From: Boqun Feng <boqun.feng@gmail.com>
Date: Tue, 26 Jan 2016 14:35:33 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160126143533.GA6029@fixme-laptop.cn.ibm.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="VS++wcV0S1rZb1Fb"
List-Id: <linux-ia64.vger.kernel.org>
References: <56980C91.1010403@imgtec.com>
	<20160114212913.GF3818@linux.vnet.ibm.com>
	<20160115085554.GF3421@worktop> <20160115091348.GA27936@worktop>
	<20160115174612.GV3818@linux.vnet.ibm.com>
	<20160115212714.GM3421@worktop>
	<20160115215853.GC3818@linux.vnet.ibm.com>
	<20160125164242.GF22927@arm.com>
	<20160126060322.GJ4503@linux.vnet.ibm.com>
	<20160126121608.GE21553@arm.com>
In-Reply-To: <20160126121608.GE21553@arm.com>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, user-mode-linux-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-xtensa@linux-xtensa.org, james.hogan@imgtec.com, Arnd Bergmann <arnd@arndb.de>, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, adi-buildroot-devel@lists.sourceforge.net, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, ddaney.cavm@gmail.com, Thomas


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Will,

On Tue, Jan 26, 2016 at 12:16:09PM +0000, Will Deacon wrote:
> On Mon, Jan 25, 2016 at 10:03:22PM -0800, Paul E. McKenney wrote:
> > On Mon, Jan 25, 2016 at 04:42:43PM +0000, Will Deacon wrote:
> > > On Fri, Jan 15, 2016 at 01:58:53PM -0800, Paul E. McKenney wrote:
> > > > PPC Overlapping Group-B sets version 4
> > > > ""
> > > > (* When the Group-B sets from two different barriers involve instru=
ctions in
> > > >    the same thread, within that thread one set must contain the oth=
er.
> > > >=20
> > > > 	P0	P1	P2
> > > > 	Rx=3D1	Wy=3D1	Wz=3D2
> > > > 	dep.	lwsync	lwsync
> > > > 	Ry=3D0	Wz=3D1	Wx=3D1
> > > > 	Rz=3D1
> > > >=20
> > > > 	assert(!(z=3D2))
> > > >=20
> > > >    Forbidden by ppcmem, allowed by herd.
> > > > *)
> > > > {
> > > > 0:r1=3Dx; 0:r2=3Dy; 0:r3=3Dz;
> > > > 1:r1=3Dx; 1:r2=3Dy; 1:r3=3Dz; 1:r4=3D1;
> > > > 2:r1=3Dx; 2:r2=3Dy; 2:r3=3Dz; 2:r4=3D1; 2:r5=3D2;
> > > > }
> > > >  P0		| P1		| P2		;
> > > >  lwz r6,0(r1)	| stw r4,0(r2)	| stw r5,0(r3)	;
> > > >  xor r7,r6,r6	| lwsync	| lwsync	;
> > > >  lwzx r7,r7,r2	| stw r4,0(r3)	| stw r4,0(r1)	;
> > > >  lwz r8,0(r3)	|		|		;
> > > >=20
> > > > exists
> > > > (z=3D2 /\ 0:r6=3D1 /\ 0:r7=3D0 /\ 0:r8=3D1)
> > >=20
> > > That really hurts. Assuming that the "assert(!(z=3D2))" is actually t=
here
> > > to constrain the coherence order of z to be {0->1->2}, then I think t=
hat
> > > this test is forbidden on arm using dmb instead of lwsync. That said,=
 I
> > > also don't think the Rz=3D1 in P0 changes anything.
> >=20
> > What about the smp_wmb() variant of dmb that orders only stores?
>=20
> Tricky, but I think it still works out if the coherence order of z is as
> I described above. The line of reasoning is weird though -- I ended up
> considering the two cases where P0 reads z before and after it reads x
                                             ^^^^^^^^^^^^^^^
Because of the fact that two reads on the same processors can't be
executed simultaneously? I feel like this is exactly something herd
missed.

> and what that means for the read of y.
>=20

And the reasoning on PPC is similar, so looks like the read of z on P0
is a necessary condition for the exists clause to be forbidden.

Regards,
Boqun

> Will

--VS++wcV0S1rZb1Fb
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJWp4QwAAoJEEl56MO1B/q4Mm4H/0dwzlkmQS4v9KE2bwXuATC4
SH2oyc2VGgjaT9rdPY3B52Kbcqteftm7Zej4rmBFJWSh4qMKBPI+AiT00VxEecPq
FgZgZIyoQMLFeF7t8aogtY4rwkN/zhRt0vC7WdbBGP5ZC9HNxlwILuR9PwRrQysl
NjhdpzH1ufk/vRvDGYF5ILw5KllvPWGOoStBn+j8AYDCDHj0xIy2BBbNWQraBas5
jUlo1Qdm3BDCcZ6Yq52Gl/DICkIp6Qe/snmxPlASwoLTbozz1T7nhCQaN0GlWKeM
WioHqMWD7L1RxbdNp8z0wsTOLCIeNY/+weP2r+mKCnsBivVSvocqmcQP+s4W4k4=
=AQzQ
-----END PGP SIGNATURE-----

--VS++wcV0S1rZb1Fb--
