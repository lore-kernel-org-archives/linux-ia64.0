From: Andreas Schwab <schwab@suse.de>
Date: Wed, 24 Oct 2001 19:46:34 +0000
Subject: Re: [Linux-ia64] C union on ia-64
Message-Id: <marc-linux-ia64-105590698805385@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805377@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805377@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Gururaj Ananthateerta <gururaj@cup.hp.com> writes:

|> http://developer.intel.com/design/itanium/linuxDDPorting/sld025.htm
|>=20
|> The above link provides an example.

How are the types defined?  Without that information nothing can be said
about it.  The C standard explictly says that it is undefined behaviour if
you access a member of a union that was stored under a different member.

Andreas.

--=20
Andreas Schwab                                  "And now for something
Andreas.Schwab@suse.de				completely different."
SuSE Labs, SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

