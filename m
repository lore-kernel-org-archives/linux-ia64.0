From: Andreas Schwab <schwab@suse.de>
Date: Tue, 16 Apr 2002 20:31:02 +0000
Subject: Re: [Linux-ia64] gcc type promotion bug?
Message-Id: <marc-linux-ia64-105590701905459@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905457@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905457@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Richard Hirst <rhirst@linuxcare.com> writes:

|> #include <stdio.h>
|>=20
|> int
|> main(int argc, char **argv)
|> {
|>         long a =3D 0x70000037L;
|>         float f =3D 0.01;
|>         long b =3D a + 1L/f;
|>=20
|>         printf("%lx, %lx\n", b, a + 100L);
|>         return 0;
|> }
|>=20
|>=20
|>=20
|> In the above, 1/f =3D 100, so the two numbers printed out should be the
|> same.  For me it prints out "70000080, 7000009b".  Same for gcc 2.96
|> and 3.0.3.
|>=20
|> By trying various numbers for 'a', it appears to me that it is demoting
|> 'a' to a float when evaluating 'b', thus truncating it to 24 significant
|> bits.  I thought all mixed mode arithmetic was supposed to be promoted
|> to doubles for evaluation.

No.  There are no operands of type double or long double involved, so the
ususal arithmetic conversions (6.3.1.8) choose float as the common type:

    Otherwise, if the corresponding real type of either operand is float,
    the other operand is converted, without change of type domain, to a
    type whose corresponding real type is float.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE GmbH, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

