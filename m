From: Andreas Schwab <schwab@suse.de>
Date: Mon, 17 Mar 2003 15:29:44 +0000
Subject: Re: [Linux-ia64] question on stabs option being disabled with ia64
Message-Id: <marc-linux-ia64-105590709806141@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Robert K Gjertsen <gjertsen@us.ibm.com> writes:

|> I was wondering if someone could provide some insight on why
|> the stabs support for ia64 was disabled in gcc 3.1.

Stabs do not support 64 bit, see
<http://gcc.gnu.org/ml/gcc-patches/2001-11/msg01789.html>.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

