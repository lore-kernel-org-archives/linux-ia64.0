From: Andreas Schwab <schwab@suse.de>
Date: Wed, 22 May 2002 08:09:47 +0000
Subject: Re: [Linux-ia64] NTP broken?
Message-Id: <marc-linux-ia64-105590701905593@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905591@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905591@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Peter Chubb <peter@chubb.wattle.id.au> writes:

|> NTP on Linux 2.4.17/IA64 appears broken.   ntpd never seems to be able
|> to pull the PLL into sync, even after using ntpdate to set the clock
|> to the correct server time.
|>=20
|> What are other peoples' experiences with NTP on IA64? =20

It appears to be working correctly on all our machines, with various
kernel versions.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE GmbH, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

