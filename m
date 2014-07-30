From: Julia Lawall <julia.lawall@lip6.fr>
Date: Wed, 30 Jul 2014 08:48:43 +0000
Subject: Re: [PATCH 6/9] gpiolib: devres: use correct structure type name in sizeof
Message-Id: <alpine.DEB.2.10.1407301048170.2389@hadrien>
List-Id: <linux-ia64.vger.kernel.org>
References: <1406647011-8543-1-git-send-email-Julia.Lawall@lip6.fr> <1406647011-8543-7-git-send-email-Julia.Lawall@lip6.fr> <CAAVeFuLZb3CVV6B771V3-mzYdp0zsxaBfAAdikQDMBxSZTPTjA@mail.gmail.com>
In-Reply-To: <CAAVeFuLZb3CVV6B771V3-mzYdp0zsxaBfAAdikQDMBxSZTPTjA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexandre Courbot <gnurou@gmail.com>
Cc: Linus Walleij <linus.walleij@linaro.org>, kernel-janitors@vger.kernel.org, linux-ia64@vger.kernel.org, ceph-devel@vger.kernel.org, toralf.foerster@gmx.de, hmh@hmh.eng.br, "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>



On Wed, 30 Jul 2014, Alexandre Courbot wrote:

> On Wed, Jul 30, 2014 at 12:16 AM, Julia Lawall <Julia.Lawall@lip6.fr> wrote:
> > From: Julia Lawall <Julia.Lawall@lip6.fr>
> >
> > Correct typo in the name of the type given to sizeof.  Because it is the
> > size of a pointer that is wanted, the typo has no impact on compilation or
> > execution.
> >
> > This problem was found using Coccinelle (http://coccinelle.lip6.fr/).  The
> > semantic patch used can be found in message 0 of this patch series.
>
> Acked-by: Alexandre Courbot <acourbot@nvidia.com>
>
> Interestingly the compiler never complains despite gpiod_desc not
> being a declared type...

The compiler doesn't care.  A pointer is a pointer, regardless of the
type.

julia
