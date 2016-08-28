From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 28 Aug 2016 07:37:20 +0000
Subject: Re: IA64-IRQ: Use kmalloc_array() in sn_irq_lh_init()
Message-Id: <4afdc7ca-6618-4c88-32da-3ac126f852f4@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <349bbfb4-bada-628e-2981-ca2a315299fc@users.sourceforge.net>
 <2e046b40-1c8e-717f-68b1-534c3125724c@users.sourceforge.net>
 <alpine.DEB.2.10.1608261557130.3645@hadrien>
 <1472245341.4914.79.camel@perches.com>
 <894bf885-4cf0-fcaa-e040-35d9add64acc@users.sourceforge.net>
 <1472344806.26978.30.camel@perches.com>
In-Reply-To: <1472344806.26978.30.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: Julia Lawall <julia.lawall@lip6.fr>, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>

> While elimination of code duplication should be good,
> what it means it you should avoid making changes that
> are merely mechanical and strive to make changes that
> improve code execution speed or reduce overall object
> size while not impacting overall execution speed.

Do other contributors spot any further improvement opportunities
with a higher value in the source files for this software module?

Regards,
Markus
