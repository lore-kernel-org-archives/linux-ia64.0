From: Joe Perches <joe@perches.com>
Date: Sun, 28 Aug 2016 00:40:06 +0000
Subject: Re: [PATCH 1/5] IA64-IRQ: Use kmalloc_array() in sn_irq_lh_init()
Message-Id: <1472344806.26978.30.camel@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <349bbfb4-bada-628e-2981-ca2a315299fc@users.sourceforge.net>
         <2e046b40-1c8e-717f-68b1-534c3125724c@users.sourceforge.net>
         <alpine.DEB.2.10.1608261557130.3645@hadrien>
         <1472245341.4914.79.camel@perches.com>
         <894bf885-4cf0-fcaa-e040-35d9add64acc@users.sourceforge.net>
In-Reply-To: <894bf885-4cf0-fcaa-e040-35d9add64acc@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: SF Markus Elfring <elfring@users.sourceforge.net>
Cc: Julia Lawall <julia.lawall@lip6.fr>, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>

On Sat, 2016-08-27 at 09:02 +0200, SF Markus Elfring wrote:
> > If you _really wanted to clear up this code and make it more
> > robust/better, it'd probably be nicer to convert the
> > struct list_head **sn_irq_lh to a single struct list_head *
> > That would be less data space overall given the alignment
> > waste of the individual allocs.
> Does this suggestion mean that I should drop my proposal
> around the software components "IRQ" and "TLB" for the system
> architecture "IA64" in such a questionable patch series?

While elimination of code duplication should be good,
what it means it you should avoid making changes that
are merely mechanical and strive to make changes that
improve code execution speed or reduce overall object
size while not impacting overall execution speed.
