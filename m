From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 30 Jan 2004 21:54:56 +0000
Subject: Re: [PATCH] - Delete debug code in arch/ia64/sn/kernel/sn2/timer_interrupt.c
Message-Id: <20040130215456.GA830@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040130214803.GA20223@sgi.com>
In-Reply-To: <20040130214803.GA20223@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch already got into Linus' tree.  See
http://linux.bkbits.net:8080/linux-2.5/cset@1.1501?nav=index.html|ChangeSet@-4d

Jesse

On Fri, Jan 30, 2004 at 03:48:03PM -0600, Jack Steiner wrote:
> Some debug was left in timer_interrupt.c:
> 
> 
> diff -Naur linux_base/arch/ia64/sn/kernel/sn2/timer_interrupt.c linux/arch/ia64/sn/kernel/sn2/timer_interrupt.c
> --- linux_base/arch/ia64/sn/kernel/sn2/timer_interrupt.c	Thu Jan 29 18:14:23 2004
> +++ linux/arch/ia64/sn/kernel/sn2/timer_interrupt.c	Fri Jan 30 14:55:34 2004
> @@ -48,7 +48,6 @@
>  	if (!pda->hb_count--) {
>  		pda->hb_count = HZ/2;
>  		set_led_bits(pda->hb_state ^= LED_CPU_HEARTBEAT, LED_CPU_HEARTBEAT);
> -		printk("Blink\n");
>  	}
>  
>  	if (enable_shub_wars_1_1()) {
