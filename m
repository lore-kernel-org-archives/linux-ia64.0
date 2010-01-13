From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 13 Jan 2010 17:13:42 +0000
Subject: Re: [drm:drm_mmap_locked] *ERROR* Could not find map: Could this be  kernel-related?
Message-Id: <201001131013.43005.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
In-Reply-To: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wednesday 13 January 2010 12:15:00 am =C9meric Maschino wrote:
> 2010/1/11 Bjorn Helgaas <bjorn.helgaas@hp.com>:
> > Right? =A0I'm a bit confused because that should have been what you were
> > testing here: http://marc.info/?l=3Dlinux-ia64&m=126290536216298&w=3D2,
> > unless you applied the patch by hand and made a mistake.
>=20
> I've probably incorrectly applied your patches without restarting from
> the original file at each attempt. Anyway, it's fine now, thanks.
>=20
> > I'm afraid I won't be much help with the DRM issue below. =A0I think
> > you'll have better luck with the dri-devel people now. =A0If this is
> > a regression and you can identify an old working kernel, that might
> > help.
>=20
> I've performed regression tests. The problem appears with kernel
> 2.6.30. Last working kernel is 2.6.29.6. I'm not a kernel developer,
> but could this be due to this commit
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3Dco=
mmitdiff;h=955b12def42e83287c1bdb1411d99451753c1391?

Nice work identifying working and non-working versions!

I don't know how much time and energy you want to devote to this, but
I think there are two ways we can make progress:

  1) Try to convince DRM folks to help debug this.

  2) Use git bisect[1] between v2.6.29 and v2.6.30.  This looks like
     about 13 kernel rebuild/test cycles.  I don't see the stable
     releases like 2.6.29.6 in the git repo, but you won't lose much
     by starting with 2.6.29.

[1] http://www.kernel.org/pub/software/scm/git/docs/git-bisect.html

Bjorn
