From: Joe Perches <joe@perches.com>
Date: Fri, 26 Aug 2016 21:02:21 +0000
Subject: Re: [PATCH 1/5] IA64-IRQ: Use kmalloc_array() in sn_irq_lh_init()
Message-Id: <1472245341.4914.79.camel@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <349bbfb4-bada-628e-2981-ca2a315299fc@users.sourceforge.net>
         <2e046b40-1c8e-717f-68b1-534c3125724c@users.sourceforge.net>
         <alpine.DEB.2.10.1608261557130.3645@hadrien>
In-Reply-To: <alpine.DEB.2.10.1608261557130.3645@hadrien>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Julia Lawall <julia.lawall@lip6.fr>, SF Markus Elfring <elfring@users.sourceforge.net>
Cc: linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>

On Fri, 2016-08-26 at 15:57 -0400, Julia Lawall wrote:
> On Fri, 26 Aug 2016, SF Markus Elfring wrote:
> > From: Markus Elfring <elfring@users.sourceforge.net>
> > Date: Fri, 26 Aug 2016 18:32:53 +0200
> >
> > * A multiplication for the size determination of a memory allocation
> >=A0=A0 indicated that an array data structure should be processed.
> >=A0=A0 Thus use the corresponding function "kmalloc_array".
> >
> >=A0=A0 This issue was detected by using the Coccinelle software.
> >
> > * Replace the specification of data structures by pointer dereferences
> >=A0=A0 to make the corresponding size determination a bit safer accordin=
g to
> >=A0=A0 the Linux coding style convention.
> >
> > Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> > ---
> >=A0 arch/ia64/sn/kernel/irq.c | 4 ++--
> >=A0 1 file changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
[]
> > @@ -474,12 +474,12 @@ void __init sn_irq_lh_init(void)
> >=A0 {
> >=A0=A0=A0=A0=A0=A0=A0int i;
> >
> > -=A0=A0=A0=A0=A0sn_irq_lh =3D kmalloc(sizeof(struct list_head *) * NR_I=
RQS, GFP_KERNEL);
> > +=A0=A0=A0=A0=A0sn_irq_lh =3D kmalloc_array(NR_IRQS, sizeof(*sn_irq_lh)=
, GFP_KERNEL);
> >=A0=A0=A0=A0=A0=A0=A0if (!sn_irq_lh)
> >=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0panic("SN PCI INIT: Failed =
to allocate memory for PCI init\n");
> >
> >=A0=A0=A0=A0=A0=A0=A0for (i =3D 0; i < NR_IRQS; i++) {
> > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sn_irq_lh[i] =3D kmalloc(sizeof=
(struct list_head), GFP_KERNEL);
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sn_irq_lh[i] =3D kmalloc(*sn_ir=
q_lh[i], GFP_KERNEL);
>=20
> Did a sizeof get lost here?

Yes, thanks Julia.

This is why adding the generating spatch code is always good.

And Markus, please always compile test your code using the
appropriate cross-compilers available here:
https://www.kernel.org/pub/tools/crosstool/

And btw: using sizeof(*pp[i]) or sizeof(**pp) is not always
clearer or better than using sizeof(type)

If you _really wanted to clear up this code and make it more
robust/better, it'd probably be nicer to convert the
struct list_head **sn_irq_lh to a single struct list_head *
and do a single
	struct list_head *sn_irq_la =3D malloc_array(nr_irqs, sizeof(struct list_h=
ead);
instead of an malloc_array of the *sn_irq_lh and the
multiple individual struct list_head malloc entries
and change the INIT_LIST_HEAD and indexing code.

That would be less data space overall given the alignment
waste of the individual allocs.

It also appears that=A0sn_irq_lh is extern in
arch/ia64/include/asm/sn/intr.h but could be made static
to=A0arch/ia64/sn/kernel/irq.c.

But really, the conversion isn't worthwhile as NR_IRQS is
limited to much less than the maximum allocation / sizeof(ptr).

