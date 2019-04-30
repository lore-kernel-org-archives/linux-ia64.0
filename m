From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Tue, 30 Apr 2019 14:10:29 +0000
Subject: Re: [PATCH 22/41] drivers: tty: serial: cpm_uart: fix logging calls
Message-Id: <20190430141029.GK9224@smile.fi.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
 <1556369542-13247-23-git-send-email-info@metux.net>
 <a00ba23b-e73e-c964-a6d0-347cb605b8c8@c-s.fr>
In-Reply-To: <a00ba23b-e73e-c964-a6d0-347cb605b8c8@c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: "Enrico Weigelt, metux IT consult" <info@metux.net>, linux-kernel@vger.kernel.org, lorenzo.pieralisi@arm.com, linux-ia64@vger.kernel.org, linux-serial@vger.kernel.org, andrew@aj.id.au, gregkh@linuxfoundation.org, sudeep.holla@arm.com, liviu.dudau@arm.com, linux-mips@vger.kernel.org, vz@mleia.com, linux@prisktech.co.nz, sparclinux@vger.kernel.org, khilman@baylibre.com, macro@linux-mips.org, slemieux.tyco@gmail.com, matthias.bgg@gmail.com, jacmet@sunsite.dk, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net

On Mon, Apr 29, 2019 at 05:59:04PM +0200, Christophe Leroy wrote:
> Le 27/04/2019 =E0 14:52, Enrico Weigelt, metux IT consult a =E9crit=A0:
> > Fix checkpatch warnings by using pr_err():
> >=20
> >      WARNING: Prefer [subsystem eg: netdev]_err([subsystem]dev, ... the=
n dev_err(dev, ... then pr_err(...  to printk(KERN_ERR ...
> >      #109: FILE: drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c:109:
> >      +		printk(KERN_ERR
> >=20
> >      WARNING: Prefer [subsystem eg: netdev]_err([subsystem]dev, ... the=
n dev_err(dev, ... then pr_err(...  to printk(KERN_ERR ...
> >      #128: FILE: drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c:128:
> >      +		printk(KERN_ERR
> >=20
> >      WARNING: Prefer [subsystem eg: netdev]_err([subsystem]dev, ... the=
n dev_err(dev, ... then pr_err(...  to printk(KERN_ERR ...
> >      +           printk(KERN_ERR
> >=20
> >      WARNING: Prefer [subsystem eg: netdev]_err([subsystem]dev, ... the=
n dev_err(dev, ... then pr_err(...  to printk(KERN_ERR ...
> >      +           printk(KERN_ERR
> >=20
> > Signed-off-by: Enrico Weigelt <info@metux.net>
>=20
> Reviewed-by: Christophe Leroy <christophe.leroy@c-s.fr>
>=20
> But is that really worth doing those changes ?
>=20
> If we want to do something useful, wouldn't it make more sense to introdu=
ce
> the use of dev_err() in order to identify the faulting device in the mess=
age
> ?

+1 for switching to dev_*().

--=20
With Best Regards,
Andy Shevchenko

