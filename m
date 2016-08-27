From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 27 Aug 2016 06:20:19 +0000
Subject: Re: IA64-IRQ: Use kmalloc_array() in sn_irq_lh_init()
Message-Id: <0374f7bd-4623-fc4c-8913-894b1e0bb612@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <349bbfb4-bada-628e-2981-ca2a315299fc@users.sourceforge.net>
 <2e046b40-1c8e-717f-68b1-534c3125724c@users.sourceforge.net>
 <alpine.DEB.2.10.1608261557130.3645@hadrien>
In-Reply-To: <alpine.DEB.2.10.1608261557130.3645@hadrien>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julia Lawall <julia.lawall@lip6.fr>
Cc: linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>

>> -		sn_irq_lh[i] = kmalloc(sizeof(struct list_head), GFP_KERNEL);
>> +		sn_irq_lh[i] = kmalloc(*sn_irq_lh[i], GFP_KERNEL);
> 
> Did a sizeof get lost here?

Unfortunately,  yes.

It is strange that I overlooked such a hiccup yesterday.


Should I start to automate the source code transformation which I imagined here
better with further scripts for the semantic patch language?

Regards,
Markus
