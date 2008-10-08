From: Andreas Schwab <schwab@suse.de>
Date: Wed, 08 Oct 2008 07:56:49 +0000
Subject: Re: [patch] ia64: Order of operations bug in PT_LOAD segment reader
Message-Id: <jeljwza5a6.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081008064940.GA11893@verge.net.au>
In-Reply-To: <20081008064940.GA11893@verge.net.au> (Simon Horman's message of
	"Wed, 8 Oct 2008 17:49:41 +1100")
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Simon Horman <horms@verge.net.au>
Cc: kexec@lists.infradead.org, Bernhard Walle <bwalle@suse.de>, "Luck,
	Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Jay Lan <jlan@sgi.com>

Simon Horman <horms@verge.net.au> writes:

> The bug comes about because the break statment was never executed because
> the if clause would bever be true because the if clause will never be true
> because &  has higher precedence than !=3D.
                 ^^^^^^
                 lower

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
