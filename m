From: Bruno Cornec <Bruno.Cornec@hp.com>
Date: Thu, 17 Apr 2003 20:40:54 +0000
Subject: Re: [Linux-ia64] floating-point error
Message-Id: <marc-linux-ia64-105590723705546@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705538@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705538@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello,

Thanks a lot David for your quick reply (as well as others).

David Mosberger (davidm@napali.hpl.hp.com) said:
>=20
>   Bruno> Apr 17 20:24:48 rx1 kernel: oracle(7148): floating-point assist =
fault at ip 40000000048b4562
>=20
> The message is informational.  There is probably nothing wrong with
> the application, at least if the message occurs only rarely (at an
> interval less than 4 messages every 10 seconds or so). =20

Which is the case.
But on the other hand we're loosing Oracle connections. So I suppose
that the information means something in that case.

> If the message
> occurs all the time, then there could be a performance problem with
> the application.
>=20
> You should be able to turn of the message with "prctl --fpemul=3Dsilent".

Ok, will try that tomorrow.=20

Best regards,
Bruno.

PS: We may also try to recompile our own kernel based on your latest patch
+ the one given in the other messages of the thread to see if it changes
anything.
--=20
Linux Solution Consultant         T=E9l: +33 476 143 278 - Fax: +33 476 146=
 105
HP/Intel Solution Center http://hpintelco.net Hewlett-Packard Grenoble/Fran=
ce
Des infos sur Linux?  http://www.HyPer-Linux.org      http://www.hp.com/lin=
ux
La musique ancienne?  http://www.musique-ancienne.org http://www.medieval.o=
rg

