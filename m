From: Andreas Schwab <schwab@suse.de>
Date: Tue, 16 Apr 2002 20:58:48 +0000
Subject: Re: [Linux-ia64] gcc type promotion bug?
Message-Id: <marc-linux-ia64-105590701905461@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905457@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905457@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Richard Hirst <rhirst@linuxcare.com> writes:

|> On Tue, Apr 16, 2002 at 10:31:02PM +0200, Andreas Schwab wrote:
|> > No.  There are no operands of type double or long double involved, so =
the
|> > ususal arithmetic conversions (6.3.1.8) choose float as the common typ=
e:
|> >=20
|> >     Otherwise, if the corresponding real type of either operand is flo=
at,
|> >     the other operand is converted, without change of type domain, to a
|> >     type whose corresponding real type is float.
|>=20
|> OK, thanks.  I looked at (out of date) K&R, which told me all floating
|> point arithmetic in C was done in double precision, and I tried my
|> program on i386, where it appeared to worked fine.

The standard explicitly allows for using a higher precision and range for
floating point computation than those of the nominal type.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE GmbH, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

