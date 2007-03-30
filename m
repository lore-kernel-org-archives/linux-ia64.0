From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Fri, 30 Mar 2007 17:37:08 +0000
Subject: Re: [PATCH 4/4] Cleanup lock order in iosapic_register_intr
Message-Id: <1175276229.4402.2.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
References: <4608A1EB.3000701@jp.fujitsu.com>
In-Reply-To: <4608A1EB.3000701@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> >  	spin_lock_irqsave(&irq_desc[vector].lock, flags);
>         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> This linue must be
>         spin_lock(&irq_desc[vector].lock, flags);

I wanted to say 

	spin_lock(&irq_desc[vector].lock);

Patch is OK. Sorry again...

Thanks,
Kenji Kaneshige



