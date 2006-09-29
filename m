From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Fri, 29 Sep 2006 02:21:33 +0000
Subject: RE: [Xen-ia64-devel] Re: ia64 kexec: xen -> linux
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086ACF@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200609271152.12393.Tristan.Gingold@bull.net>
In-Reply-To: <200609271152.12393.Tristan.Gingold@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Magnus Damm [mailto:magnus.damm@gmail.com]
> Sent: 2006=C4=EA9=D4=C228=C8=D5 20:34
> To: Tristan Gingold
> Cc: Horms; Zou, Nanhai; Linux-IA64; xen-ia64-devel@lists.xensource.com
> Subject: Re: [Xen-ia64-devel] Re: ia64 kexec: xen -> linux
>=20
> On 9/28/06, Tristan Gingold <Tristan.Gingold@bull.net> wrote:
> > Le Jeudi 28 Septembre 2006 03:27, Horms a =A8=A6crit :
> > > On Wed, Sep 27, 2006 at 11:52:12AM +0200, Tristan Gingold wrote:
> > > > Linux and xen call efi in real mode if set_virtual_address_map fail=
s.
> > > > You may add an option in both xen and linux to force calling efi in=
 real
> > > > mode. This should be really simple and you will be able to make pro=
gress.
> > >
> > > Great, I will test this out and see how it goes.
> > >
> > > > The only possible drawback is performance.
> > >
> > > What kind of performance issues would you expect?
> > Making EFI calls in physical mode is slower: Linux must switch from and=
 to
> > virtual mode.
> >
> > However EFI calls are very unfrequent so the impact should be almost nu=
l.
>=20
> This makes me wonder - is it really worth having two code paths in that c=
ase?
>=20
> / magnus

I am still not quiet clear about the particular issue on Xen.

For native IA64,
I put an empty efi.set_virtual_address_map() in purgatory code,=20
So when the second kernel boots, it will still call to set_virtual_address_=
map() as if it successes.=20
I guess you can modify the empty function in purgatory to return an error.
So the second kernel will call EFI in physical mode.

Thanks
Zou Nan hai=20

