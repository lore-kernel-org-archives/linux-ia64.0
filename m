From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 27 Aug 2016 07:02:49 +0000
Subject: Re: [PATCH 1/5] IA64-IRQ: Use kmalloc_array() in sn_irq_lh_init()
Message-Id: <894bf885-4cf0-fcaa-e040-35d9add64acc@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <349bbfb4-bada-628e-2981-ca2a315299fc@users.sourceforge.net>
 <2e046b40-1c8e-717f-68b1-534c3125724c@users.sourceforge.net>
 <alpine.DEB.2.10.1608261557130.3645@hadrien>
 <1472245341.4914.79.camel@perches.com>
In-Reply-To: <1472245341.4914.79.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Joe Perches <joe@perches.com>
Cc: Julia Lawall <julia.lawall@lip6.fr>, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>

>>> @@ -474,12 +474,12 @@ void __init sn_irq_lh_init(void)
>>>   {
>>>        int i;
>>>
>>> -     sn_irq_lh =3D kmalloc(sizeof(struct list_head *) * NR_IRQS, GFP_K=
ERNEL);
>>> +     sn_irq_lh =3D kmalloc_array(NR_IRQS, sizeof(*sn_irq_lh), GFP_KERN=
EL);
>>>        if (!sn_irq_lh)
>>>                panic("SN PCI INIT: Failed to allocate memory for PCI in=
it\n");
>>>
>>>        for (i =3D 0; i < NR_IRQS; i++) {
>>> -             sn_irq_lh[i] =3D kmalloc(sizeof(struct list_head), GFP_KE=
RNEL);
>>> +             sn_irq_lh[i] =3D kmalloc(*sn_irq_lh[i], GFP_KERNEL);
>>
>> Did a sizeof get lost here?
>=20
> Yes, thanks Julia.

Unfortunately, another copy mistake happened during a bit of
source code editing.


> This is why adding the generating spatch code is always good.

I find that this broken update suggestion can point a few details out
for further considerations.

I dared to combine some software aspects once more in this use case.
Such a combination (join point) shows interesting challenges,
doesn't it?


> And Markus, please always compile test your code using the
> appropriate cross-compilers available here:
> https://www.kernel.org/pub/tools/crosstool/

Thanks for your link.


> And btw: using sizeof(*pp[i]) or sizeof(**pp) is not always
> clearer or better than using sizeof(type)

Do you express a target conflict between your expectations
and the evolving Linux coding style documentation here?

Would any software developers insist to see the corresponding
data type directly instead of "evaluating" a pointer expression?


> If you _really wanted to clear up this code and make it more
> robust/better, it'd probably be nicer to convert the
> struct list_head **sn_irq_lh to a single struct list_head *
=85
> That would be less data space overall given the alignment
> waste of the individual allocs.

Does this suggestion mean that I should drop my proposal
around the software components "IRQ" and "TLB" for the system
architecture "IA64" in such a questionable patch series?

Regards,
Markus
