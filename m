From: JinShan Xiong <jinshan.xiong@gmail.com>
Date: Tue, 01 Feb 2005 02:53:42 +0000
Subject: Re: How to intercept system calls on ia64 linux kernel
Message-Id: <b3b26beb05013118532a9e96ca@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <b3b26beb050130195674d2930c@mail.gmail.com>
In-Reply-To: <b3b26beb050130195674d2930c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

OK.

Thanks a lot.

JinShan


On Mon, 31 Jan 2005 09:34:32 -0800, David Mosberger
<davidm@napali.hpl.hp.com> wrote:
> Note that it is very dangerous to compile kernel modules like so:
>=20
> >>>>> On Mon, 31 Jan 2005 11:56:43 +0800, JinShan Xiong <jinshan.xiong@gm=
ail.com> said:
>=20
>   JinShan> gcc -c -D__KERNEL__ -DMODULE -I/lib/modules/`uname
>=20
> This is missing the -mfixed-range=F12-f15,f32-f127 option, which means
> that more complicated modules will end up trashing floating-point
> registers which means that your module will cause random crashes in
> user-level codes.  I'd recommend to compile modules the same way as normal
> kernel code, except that you need to remove the -mconstant-gp flag.
>=20
> In 2.6, this has gotten a lot easier, since modules are built using
> the normal kbuild infrastructure.
>=20
>         --david
>
