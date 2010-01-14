From: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Date: Thu, 14 Jan 2010 08:50:12 +0000
Subject: Re: [drm:drm_mmap_locked] *ERROR* Could not find map: Could this be
Message-Id: <d72eeaf61001140050n77bec183o59bf9575ae1563fc@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
In-Reply-To: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

2010/1/13 Bjorn Helgaas <bjorn.helgaas@hp.com>:
> Nice work identifying working and non-working versions!
>
> I don't know how much time and energy you want to devote to this, but

Well, I'll take the time it needs ;-)

Indeed, more and more desktop environments provide graphical effects
needing DRI. While I consider these just "fun demos" at this time, it
seems that the future of desktop environment will require working DRI.
I've tried e.g. the GnomeShell 2.28 package currently in Debian
"Squeeze" Testing, and it's completely unusable at this time. Since
GnomeShell (http://live.gnome.org/GnomeShell) appears to be the
default environment in the GNOME 3.0 release, it would be nice if I
can help fix DRI on Itanium by September 2010.

> I think there are two ways we can make progress:
>
> =A01) Try to convince DRM folks to help debug this.
>
> =A02) Use git bisect[1] between v2.6.29 and v2.6.30. =A0This looks like
> =A0 =A0 about 13 kernel rebuild/test cycles. =A0I don't see the stable
> =A0 =A0 releases like 2.6.29.6 in the git repo, but you won't lose much
> =A0 =A0 by starting with 2.6.29.

I'll try the git bisect route first, and then ask for help when I have
the bad commit identified.

Emeric
