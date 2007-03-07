From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Wed, 07 Mar 2007 09:06:39 +0000
Subject: RE: [patch 3/3] IA64: verify the base address of crashkernel
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086C0E@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070306073756.245032985@tabatha.lab.ultramonkey.org>
In-Reply-To: <20070306073756.245032985@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Horms [mailto:horms@verge.net.au]
> Sent: 2007=C4=EA3=D4=C27=C8=D5 15:55
> To: Zou, Nanhai
> Cc: Linux-IA64; fastboot@lists.osdl.org; Luck, Tony; Magnus Damm
> Subject: Re: [patch 3/3] IA64: verify the base address of crashkernel
>=20
> On Wed, Mar 07, 2007 at 12:50:12PM +0800, Zou, Nanhai wrote:
> > On Wed, Mar 07, 2007 at 11:46, Horms wrote:
> > >
> > > I think that the manual option is also important because it
> > > maintains feature-compatibility with other architectures. I don't
> > > consider it a hack that might work purely for the purposes of
> > > debugging.
> >
> > I don't understand why we need to maintain compatibility with other
> > architectures here. Manfully choose may confuse user, XXX@16M may work
> > on one arch,but not on another arch. Other architectures need manually
> > choose crash kernel region simply because they do not support kernel
> > automatically choose feature.
> >
> > I keep the XXX@YYY format to just make kdump script compatible, do
> > that distributions does not need to maintain different kdump scripts
> > for different arches.
>=20

> From my point of view, what you say in the paragraph immediately above
> Thanks, is this logic better?
>=20
  Don't write code to improve a "no user will use" feature.=20
  Let's keep kernel code clean.

> kdump_region_verify_rsvd_region (unsigned long base, unsigned long size,
>                                 struct rsvd_region *rsvd_regions, int n)
> {
> 	int i;
>=20
> 	for (i =3D 0; i < n; i++) {
> 		/* Assume that start < end && size > 0 */
> 		if (__pa(rsvd_regions[i].start) >=3D base + size &&
> 		    __pa(rsvd_regions[i].end) < base)
> 			continue;
    This is much worse. Have you ever tested it?

> 		printk(KERN_WARNING "Kdump: crashkernel region 0x%lx-0x%lx "
> 		       "clashes with reserved region 0x%lx-0x%lx\n", base,
> 		       base + size - 1, __pa(rsvd_regions[i].start),
> 		       __pa(rsvd_regions[i].end));
> 		return 0;
> 	}
> 	return 1;
> }


>=20
Zou Nan hai
> --
> Horms
>   H: http://www.vergenet.net/~horms/
>   W: http://www.valinux.co.jp/en/
