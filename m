From: Andreas Schwab <schwab@suse.de>
Date: Mon, 19 May 2008 09:46:13 +0000
Subject: Re: ld2.acq - sign extension?
Message-Id: <jek5hqr5i2.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0wslqiqyp.fsf@jaguar.mkp.net>
In-Reply-To: <yq0wslqiqyp.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Jes Sorensen <jes@sgi.com> writes:

> Basically if I apply the below diff my code no longer works. However I
> am under the impression that ld2.acq does sign extension?

ld always zero extends.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
