From: Andreas Schwab <schwab@suse.de>
Date: Wed, 24 Mar 2004 09:34:35 +0000
Subject: Re: [PATCH] Fix SAL 3.2 detection
Message-Id: <je4qse611w.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040324015811.GF25059@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040324015811.GF25059@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Matthew Wilcox <willy@debian.org> writes:

> Hi David.  This important fix checks the SAl *revision* rather than
> the *version*.  I carefully documented which was which, then used the
> wrong one.

Thanks a lot, this has fixed all my issues!

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
