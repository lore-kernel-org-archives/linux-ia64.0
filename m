From: Joe Perches <joe@perches.com>
Date: Sun, 28 Aug 2016 18:33:05 +0000
Subject: Re: [PATCH 1/5] IA64-IRQ: Use kmalloc_array() in sn_irq_lh_init()
Message-Id: <1472409185.26978.100.camel@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <349bbfb4-bada-628e-2981-ca2a315299fc@users.sourceforge.net>
         <2e046b40-1c8e-717f-68b1-534c3125724c@users.sourceforge.net>
         <alpine.DEB.2.10.1608261557130.3645@hadrien>
         <1472245341.4914.79.camel@perches.com>
         <894bf885-4cf0-fcaa-e040-35d9add64acc@users.sourceforge.net>
         <1472344806.26978.30.camel@perches.com>
         <alpine.DEB.2.10.1608281121520.3321@hadrien>
In-Reply-To: <alpine.DEB.2.10.1608281121520.3321@hadrien>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Julia Lawall <julia.lawall@lip6.fr>
Cc: SF Markus Elfring <elfring@users.sourceforge.net>, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>

On Sun, 2016-08-28 at 11:28 +0200, Julia Lawall wrote:

> I do think that there is some value in doing similar things in a uniform
> way, using meaningful names, even if in a particular case it doesn't help
> performance or reduce code size.=A0 Even duplicating code could be OK if =
it
> is not in a critical path and it makes the code overall easier to
> understand.=A0 But if the maintainer prefers the code not to be duplicate=
d,
> then of course it should not be duplicated.

All true too, thanks Julia.

It's all maintainer choice.
