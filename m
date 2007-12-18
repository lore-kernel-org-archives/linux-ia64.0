From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 18 Dec 2007 01:05:45 +0000
Subject: Re: [PATCH] ia64: Avoid unnecessary TLB flushes when allocating
Message-Id: <20071218100545.14ae2c73.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <7575980D7C4188408E8BDB171DA164B73A875A92A6@G3W1111.americas.hpqcorp.net>
In-Reply-To: <7575980D7C4188408E8BDB171DA164B73A875A92A6@G3W1111.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "de Dinechin, Christophe (Integrity VM)" <christophe.de-dinechin@hp.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Picco, Robert W." <robert.picco@hp.com>, "tony.luck@intel.com" <tony.luck@intel.com>

On Thu, 13 Dec 2007 15:03:07 +0000

> +       if (mm != active_mm) {
> +               /* Restore region IDs for mm */
> +               if (mm && active_mm) {
> +                       activate_context(mm);
> +               } else {
> +                       flush_tlb_all();
> +                       return;
> +               }
>         }
should be 

preempt_disable();
activate_context(mm);
preempt_enable();

?
(from comments for activate_context()).


Thanks,
-Kame

