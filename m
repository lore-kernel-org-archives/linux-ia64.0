From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Tue, 06 Dec 2005 09:24:16 +0000
Subject: RE: Reading /proc/stat is slooow
Message-Id: <894E37DECA393E4D9374E0ACBBE7427003BC9642@pdsmsx402.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je1x0v4cpy.fsf@sykes.suse.de>
In-Reply-To: <je1x0v4cpy.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Luck, Tony
> Sent: 2005=C4=EA12=D4=C26=C8=D5 14:16
> To: Andreas Schwab
> Cc: linux-ia64@vger.kernel.org
> Subject: RE: Reading /proc/stat is slooow
>=20
> The huge bulk of the time is consumed in this loop:
>=20
> #if !defined(CONFIG_PPC64) && !defined(CONFIG_ALPHA)
>         for (i =3D 0; i < NR_IRQS; i++)
>                 seq_printf(p, " %u", kstat_irqs(i));
> #endif
>=20
> But why is this worse now than in 2.6.13?  At the top of
> show_stat() we already looked at all of the kstat_cpu(i).irqs[j]
> elements [but with the loops reversed: outer loop is all cpus,
> inner loop counts 0..NR_IRQ].

  I think the reason of second loop much slower than the first one is page =
coloring.
  For the first loop, at least cache line is hot in the inner loop.
For the second loop, things will be much worse because percpu data offset i=
s 64k....
 But I have no idea of why 2.6.13 is much faster here.

Zou Nan hai
