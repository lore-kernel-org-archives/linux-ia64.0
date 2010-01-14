From: Dave Airlie <airlied@redhat.com>
Date: Thu, 14 Jan 2010 00:10:09 +0000
Subject: Re: [drm:drm_mmap_locked] *ERROR* Could not find map: Could this
Message-Id: <1263427809.3888.1.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
In-Reply-To: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wed, 2010-01-13 at 10:13 -0700, Bjorn Helgaas wrote:
> On Wednesday 13 January 2010 12:15:00 am =C3=89meric Maschino wrote:
> > 2010/1/11 Bjorn Helgaas <bjorn.helgaas@hp.com>:
> > > Right?  I'm a bit confused because that should have been what you were
> > > testing here: http://marc.info/?l=3Dlinux-ia64&m=126290536216298&w=3D=
2,
> > > unless you applied the patch by hand and made a mistake.
> >=20
> > I've probably incorrectly applied your patches without restarting from
> > the original file at each attempt. Anyway, it's fine now, thanks.
> >=20
> > > I'm afraid I won't be much help with the DRM issue below.  I think
> > > you'll have better luck with the dri-devel people now.  If this is
> > > a regression and you can identify an old working kernel, that might
> > > help.
> >=20
> > I've performed regression tests. The problem appears with kernel
> > 2.6.30. Last working kernel is 2.6.29.6. I'm not a kernel developer,
> > but could this be due to this commit
> > http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=955b12def42e83287c1bdb1411d99451753c1391?
>=20
> Nice work identifying working and non-working versions!
>=20
> I don't know how much time and energy you want to devote to this, but
> I think there are two ways we can make progress:
>=20
>   1) Try to convince DRM folks to help debug this.

If I had to guess I'd go with

b674137755bbe2750f997a2a1264db3cdf8abcb3

But maybe a bisect would be more definite.

Dave.

>=20
>   2) Use git bisect[1] between v2.6.29 and v2.6.30.  This looks like
>      about 13 kernel rebuild/test cycles.  I don't see the stable
>      releases like 2.6.29.6 in the git repo, but you won't lose much
>      by starting with 2.6.29.
>=20
> [1] http://www.kernel.org/pub/software/scm/git/docs/git-bisect.html
>=20
> Bjorn


