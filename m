From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Date: Tue, 14 Nov 2006 08:21:01 +0000
Subject: Re: [PATCH] Incorrect MSI interrupt type name
Message-Id: <1163492461.4311.60.camel@ymzhang-perf.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1163488977.4311.52.camel@ymzhang-perf.sh.intel.com>
	 <20061113234315.767f7516.akpm@osdl.org>
In-Reply-To: <20061113234315.767f7516.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Andrew Morton <akpm@osdl.org>
Cc: Ingo Molnar <mingo@elte.hu>, "Eric W. Biederman" <ebiederm@xmission.com>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Tue, 2006-11-14 at 15:43, Andrew Morton wrote:
> On Tue, 14 Nov 2006 15:22:57 +0800
> "Zhang, Yanmin" <yanmin_zhang@linux.intel.com> wrote:
>=20
> > /proc/interrupts shows "<NULL>" for MSI interrupt type name on
> > my ia64 machine.
> >=20
> > Below patch against 2.6.19-rc5-mm1 fixes it.
> >=20
> > Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>
> >=20
> > ---
> >=20
> > --- linux-2.6.19-rc5-mm1/arch/ia64/kernel/msi_ia64.c	2006-11-14 14:16:1=
2.000000000 +0800
> > +++ linux-2.6.19-rc5-mm1_fix/arch/ia64/kernel/msi_ia64.c	2006-11-14 15:=
08:37.000000000 +0800
> > @@ -115,7 +115,7 @@ static int ia64_msi_retrigger_irq(unsign
> >   * Generic ops used on most IA64 platforms.
> >   */
> >  static struct irq_chip ia64_msi_chip =3D {
> > -	.name		=3D "PCI-MSI",
> > +	.typename	=3D "PCI-MSI",
> >  	.mask		=3D mask_msi_irq,
> >  	.unmask		=3D unmask_msi_irq,
> >  	.ack		=3D ia64_ack_msi_irq,
>=20
> I think the bug is that ia64 is printing ->typename, whereas it should be
> printing ->name:
A couple of other arch also use typename instead of name when printing.

In addition, function irq_chip_set_defaults will let name=3Dtypename if
name is NULL.

Is it more reasonable to delete typename completely?

>=20
>=20
>  arch/ia64/kernel/iosapic.c |    2 +-
>  arch/ia64/kernel/irq.c     |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff -puN arch/ia64/kernel/iosapic.c~ia64-irqs-use-name-not-typename arch=
/ia64/kernel/iosapic.c
> --- a/arch/ia64/kernel/iosapic.c~ia64-irqs-use-name-not-typename
> +++ a/arch/ia64/kernel/iosapic.c
> @@ -664,7 +664,7 @@ register_intr (unsigned int gsi, int vec
>  			printk(KERN_WARNING
>  			       "%s: changing vector %d from %s to %s\n",
>  			       __FUNCTION__, vector,
> -			       idesc->chip->typename, irq_type->typename);
> +			       idesc->chip->name, irq_type->name);
>  		idesc->chip =3D irq_type;
>  	}
>  	return 0;
> diff -puN arch/ia64/kernel/irq.c~ia64-irqs-use-name-not-typename arch/ia6=
4/kernel/irq.c
> --- a/arch/ia64/kernel/irq.c~ia64-irqs-use-name-not-typename
> +++ a/arch/ia64/kernel/irq.c
> @@ -76,7 +76,7 @@ int show_interrupts(struct seq_file *p,=20
>  			seq_printf(p, "%10u ", kstat_cpu(j).irqs[i]);
>  		}
>  #endif
> -		seq_printf(p, " %14s", irq_desc[i].chip->typename);
> +		seq_printf(p, " %14s", irq_desc[i].chip->name);
>  		seq_printf(p, "  %s", action->name);
> =20
>  		for (action=ACtion->next; action; action =3D action->next)
> _
