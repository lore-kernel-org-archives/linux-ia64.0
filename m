From: Andreas Schwab <schwab@suse.de>
Date: Tue, 27 Jul 2004 20:42:22 +0000
Subject: Re: [PATCH] Altix console mod
Message-Id: <jeoem189n5.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407271953.i6RJrAma119179@fsgi900.americas.sgi.com>
In-Reply-To: <200407271953.i6RJrAma119179@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Patrick Gefre <pfg@sgi.com> writes:

> You're right, I forgot the else on the if (to write out the lf) ....
> So send the cr even if one is already there - guess it doesn't hurt ?

The kernel normally does not output CRs anyway, since it's just using \n
for EOL.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
