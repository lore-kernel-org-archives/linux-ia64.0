From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 29 Jul 2004 16:33:44 +0000
Subject: Re: [PATCH] fix IRQ types
Message-Id: <200407290933.44762.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407291033.15577.bjorn.helgaas@hp.com>
In-Reply-To: <200407291033.15577.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, July 29, 2004 9:33 am, Bjorn Helgaas wrote:
> Fix IRQ type in platform irq_to_vector functions.  Should be
> "unsigned int", but some places were "u8".
>
> Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
>
> === arch/ia64/sn/kernel/irq.c 1.24 vs edited ==> --- 1.24/arch/ia64/sn/kernel/irq.c	2004-06-30 07:31:06 -06:00
> +++ edited/arch/ia64/sn/kernel/irq.c	2004-07-29 10:17:28 -06:00
> @@ -188,7 +188,7 @@
>  }
>
>  u8
> -sn_irq_to_vector(u8 irq)
> +sn_irq_to_vector(unsigned int irq)
>  {
>  	return(irq);
>  }

Looks fine to me.

Jesse
