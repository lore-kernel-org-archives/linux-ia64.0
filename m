From: Andreas Schwab <schwab@suse.de>
Date: Thu, 25 Sep 2003 08:32:25 +0000
Subject: Re: Unaligned access question
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-=-="
Message-Id: <marc-linux-ia64-106447880214230@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106445366428887@msgid-missing>
In-Reply-To: <marc-linux-ia64-106445366428887@msgid-missing>
To: linux-ia64@vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

Martin Pool <mbp@samba.org> writes:

> On 25 Sep 2003, Ian Wienand <ianw@gelato.unsw.edu.au> wrote:
>> Hi,
>>=20
>> This isn't directly related to kernel development, but I am a bit
>> stumped as to why my test program below causes an unaligned access
>> when 'i' is 7 (that is, when it tries to access across a 64 bit
>> boundary of 'array').  It's counter intuitive to me, I would have
>> expected it either fault on all loads (for every value of 'i') or to
>> have not faulted at all.
>
> I think adding
>
>   __attribute__ ((aligned (1)))=20

You cannot decrease alignment with the aligned attribute, for that you
need the packed attribute.  This sets alignment to 1, which you can
increase again with the aligned attribute.

Andreas.

=2D-=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQA/cqgdRNUhS4J2TtURAvD2AKD67ruJpDdvOwGYnZZv+nIsnlQNkQCfensY
uHN52BlffEcKzCfWOBDE7ss=
=5s58
-----END PGP SIGNATURE-----
--=-=-=--
