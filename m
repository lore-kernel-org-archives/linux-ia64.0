From: Andreas Schwab <schwab@suse.de>
Date: Wed, 21 Aug 2002 12:34:42 +0000
Subject: Re: [Linux-ia64] [RFC] Remove MCA dump?
Message-Id: <marc-linux-ia64-105590701905965@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905964@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905964@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Matthew Wilcox <willy@debian.org> writes:

|> The MCA handler is completely useless.  If I crash the machine and
|> forget to clear the MCA dump in firmware, at the next boot Linux dumps
|> the registers (in a hard-to-understand style) and hangs.

I haven't seen such hangs on our machines, except for some old
pre-production systems that lack the necessary hardware support.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

