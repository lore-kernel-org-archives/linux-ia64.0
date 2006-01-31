From: Andreas Schwab <schwab@suse.de>
Date: Tue, 31 Jan 2006 10:15:20 +0000
Subject: Re: [patch 1/6] align kenrel rbs on 128 byte
Message-Id: <jefyn4putj.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601310848.k0V8mbg11087@unix-os.sc.intel.com>
In-Reply-To: <200601310848.k0V8mbg11087@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Keith Owens <kaos@sgi.com> writes:

> The cache lines are not guaranteed to be 128 byte aligned, they were 64
> on bigsur.

A 128 byte aligned address is also 64 byte aligned.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
