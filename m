From: Andreas Schwab <schwab@suse.de>
Date: Thu, 21 Mar 2002 10:28:52 +0000
Subject: Re: [Linux-ia64] Trouble building cross compilers
Message-Id: <marc-linux-ia64-105590701905312@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905309@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905309@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Jesse Barnes <jbarnes@sgi.com> writes:

|> a) built and installed binutils 2.12 (configured with
|>    --target=3Dia64-gnu-linux --prefix=3D/tmp/ia64-cross-3.0)
|> b) tried to build and install gcc 3.0 (configured with the same options
|>    as above), but with 'make LANGUAGES=3Dc' instead of just 'make'

LANGUAGES=3Dc is obsolete, configure with --enable-languages=3Dc instead.

|> Unfortunately, I got hung up in the middle of step (b) with the errors
|> shown below.  IIRC, the Cygnus snapshot tarballs were 'cross-compile
|> ready' in that they had all the necessary header files and utilities
|> needed for a full cross development environment.  Any notes on how
|> those trees were built would be appreciated.

You need to have the target headers installed somewhere and use
--with-headers=3D/place/of/target/headers when configuring the cross
compiler.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE GmbH, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

