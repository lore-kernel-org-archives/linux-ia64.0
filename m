From: Andreas Schwab <schwab@suse.de>
Date: Thu, 14 Jun 2007 09:29:56 +0000
Subject: Re: [IA64] Set default page size to 64k
Message-Id: <jey7im994b.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Jes Sorensen <jes@sgi.com> writes:

> I think there are still broken user apps out there that hard code the
> page size,

Those will more likely hardcode it to 4K than any else, which means they
are already broken today.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
