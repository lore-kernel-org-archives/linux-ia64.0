From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Fri, 04 Jun 2004 11:11:26 +0000
Subject: Re: sched_clock
Message-Id: <40C058DE.EF547CFB@nospam.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <40B4868F.B649611C@nospam.org>
In-Reply-To: <40B4868F.B649611C@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
>=20
> Yes, you're right, there is an intermediate-result overflow problem in
> sched_clock() that I missed.  How does the attached patch work for you?

Thank you, it is O.K.

On the other hand, we might have similar problems in fsys.S. Some comments
like the one below makes me worry a bit:

	// if now < last_tick, set p7 =3D 1, p8 =3D 0

I cannot really say that I fully understand what is in fsys.S, but
should not "now" always be after no matter what time stamp, last tick ?

Thanks,

Zolt=E1n
