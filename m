From: Andreas Schwab <schwab@suse.de>
Date: Sat, 13 Apr 2002 01:57:27 +0000
Subject: Re: [Linux-ia64] Missing EXPORT_SYMBOL memset
Message-Id: <marc-linux-ia64-105590701905445@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905441@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905441@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Keith Owens <kaos@ocs.com.au> writes:

|> I know about the "gcc decides to insert memset after cpp phase"
|> problem.  When it occurred in the past (it used to happen with gcc 2.7
|> in 2.[02] kernels) the response was always to change the source code to
|> prevent gcc making this wrong decision.  Adding and exporting a memset

It exists already, I didn't add anything.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE GmbH, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

