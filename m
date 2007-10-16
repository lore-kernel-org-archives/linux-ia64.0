From: Andreas Schwab <schwab@suse.de>
Date: Tue, 16 Oct 2007 13:33:59 +0000
Subject: Re: [PATCH 2/9] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <je7ilnji9k.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com> writes:

> Index: linux-2.6.23/include/asm-ia64/cputime.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux-2.6.23.orig/include/asm-ia64/cputime=
.h
> +++ linux-2.6.23/include/asm-ia64/cputime.h
> @@ -1,6 +1,82 @@
> +/*
> + *  include/asm-ia64/cputime.h

Kill that line.  Instead describe the contents of the file.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
