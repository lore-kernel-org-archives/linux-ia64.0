From: Andreas Schwab <schwab@suse.de>
Date: Mon, 22 Apr 2002 14:57:20 +0000
Subject: Re: [Linux-ia64] new kernel patch (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905489@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

n0ano@indstorage.com writes:

|> Yoav-
|>=20
|> Simple answer: Yes, it can be safely removed.
|>=20
|> Longer answer:  David likes to use `gdb' to track down bugs, it makes li=
fe
|> easier to take a fault address and use `gdb' to find the exact source li=
ne
|> that caused the error.  I personally don't like the size of the boot ima=
ge
|> file that this creates so one of the first things I've always done after
|> applying all of the IA64 patches is remove this flag.  Use it or not,
|> whatever you prefer.

Or just use "strip -g".

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE GmbH, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

