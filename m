From: Andreas Schwab <schwab@suse.de>
Date: Sat, 14 Aug 2004 22:37:05 +0000
Subject: Re: [PATCH] Don't allow hw_random to be selected on ia64
Message-Id: <jebrhdxs6m.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040814220537.GD12936@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040814220537.GD12936@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Matthew Wilcox <willy@debian.org> writes:

> The hw_random driver includes some i386 asm so won't compile on ia64.

Works fine here.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
