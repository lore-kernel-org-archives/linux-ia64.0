From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 31 Jan 2005 17:34:32 +0000
Subject: Re: How to intercept system calls on ia64 linux kernel
Message-Id: <16894.27688.84989.561686@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <b3b26beb050130195674d2930c@mail.gmail.com>
In-Reply-To: <b3b26beb050130195674d2930c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Note that it is very dangerous to compile kernel modules like so:

>>>>> On Mon, 31 Jan 2005 11:56:43 +0800, JinShan Xiong <jinshan.xiong@gmai=
l.com> said:

  JinShan> gcc -c -D__KERNEL__ -DMODULE -I/lib/modules/`uname

This is missing the -mfixed-range=F12-f15,f32-f127 option, which means
that more complicated modules will end up trashing floating-point
registers which means that your module will cause random crashes in
user-level codes.  I'd recommend to compile modules the same way as normal
kernel code, except that you need to remove the -mconstant-gp flag.

In 2.6, this has gotten a lot easier, since modules are built using
the normal kbuild infrastructure.

	--david
