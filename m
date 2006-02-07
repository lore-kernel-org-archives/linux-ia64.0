From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Tue, 07 Feb 2006 06:45:45 +0000
Subject: RE: [PATCH]Fix wrong use of memparse in efi.c
Message-Id: <894E37DECA393E4D9374E0ACBBE7427003BC96E6@pdsmsx402.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1139283346.8654.17.camel@linux-znh>
In-Reply-To: <1139283346.8654.17.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Actually I found this when add support to min_addr=3D support,
min_addr=3D + max_addr=3D is useful for a crashdumping kernel to limit its =
memory range.

Also I think use mem=3D and max_addr=3D at the same time could be useful wh=
en testing some configurations.

Zou Nan hai

> -----Original Message-----
> From: Chen, Kenneth W [mailto:kenneth.w.chen@intel.com]
> Sent: 2006=C4=EA2=D4=C27=C8=D5 14:33
> To: Zou, Nanhai; linux-ia64@vger.kernel.org
> Cc: Luck, Tony
> Subject: RE: [PATCH]Fix wrong use of memparse in efi.c
>=20
> Zou Nan hai wrote on Monday, February 06, 2006 7:36 PM
> > The check of (end !=3D cp) after memparse in efi.c looks wrong to me.
> > The result is that we can't use mem=3D and max_addr=3D kernel parameter=
 at
> > the same time.
>=20
> Why do you want to use both parameters at the same time?  mem=3D limits
> maximum logical memory size while max_addr=3D limits maximum physical
> address used in the system. It sounds wired, but people are creative...
>=20
> - Ken

