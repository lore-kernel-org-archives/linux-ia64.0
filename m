From: Bruno Cornec <Bruno.Cornec@hp.com>
Date: Tue, 22 Apr 2003 15:25:19 +0000
Subject: [Linux-ia64] [Summary] floating-point error
Message-Id: <marc-linux-ia64-105590723705584@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger (davidm@napali.hpl.hp.com) said:

> >>>>> On Thu, 17 Apr 2003 21:21:48 +0200, Bruno Cornec <Bruno.Cornec@hp.c=
om> said:
>=20
>   Bruno> Sometimes the Oracle process dies with the following error messa=
ge:
>   Bruno> Apr 17 20:24:48 rx1 kernel: oracle(7148): floating-point assist =
fault at ip 40000000048b4562
>=20
> The message is informational.  There is probably nothing wrong with
> the application, at least if the message occurs only rarely (at an
> interval less than 4 messages every 10 seconds or so).  If the message
> occurs all the time, then there could be a performance problem with
> the application.

This explanation was confirmed later on by the fact that we saw exactly the
same messages by just launching mozilla on one of the systems.
So definitively unrelated.

The Oracle process were dying probably dur to a lack of bandwidth at=20
our load-balancing system level. We are reconfiguring the network to
avoid that bottle neck, and will let you know what perf we're getting from
the configuration (4 RDBM systems Oracle/Linux/ia64 and 6 applications
servers PHP/Apahce/Linux/ia32)

Thanks a lot for all the replies given which enlightened a lot our=20
knowledge.

Best regards,
Bruno.
--=20
Linux Solution Consultant         T=E9l: +33 476 143 278 - Fax: +33 476 146=
 105
HP/Intel Solution Center http://hpintelco.net Hewlett-Packard Grenoble/Fran=
ce
Des infos sur Linux?  http://www.HyPer-Linux.org      http://www.hp.com/lin=
ux
La musique ancienne?  http://www.musique-ancienne.org http://www.medieval.o=
rg

