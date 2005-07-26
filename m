From: Andreas Schwab <schwab@suse.de>
Date: Tue, 26 Jul 2005 17:26:35 +0000
Subject: Re: [PATCH 2.6.13-rc3] fix unaligned memory access in snsc_event.c
Message-Id: <jek6jd1nsk.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.58.0507261138570.39385@gallifrey.americas.sgi.com>
In-Reply-To: <Pine.SGI.4.58.0507261138570.39385@gallifrey.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Greg Howard <ghoward@sgi.com> writes:

> I've added a new function to the file that copies a (big-endian)
> integer out of a byte buffer and into a little-endian integer
> variable.

How about using get_unaligned?

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
