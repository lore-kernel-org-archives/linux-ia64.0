From: Andi Kleen <ak@suse.de>
Date: Fri, 19 Sep 2003 05:53:04 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106395093405614@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> This is what I changed:
> 
> === drivers/net/ns83820.c 1.19 vs edited ==> --- 1.19/drivers/net/ns83820.c  Thu Jun  5 13:50:00 2003
> +++ edited/drivers/net/ns83820.c        Fri Sep 19 13:49:23 2003
> @@ -567,7 +567,7 @@
>                 res = (long)skb->tail & 0xf;
>                 res = 0x10 - res;
>                 res &= 0xf;
> -               skb_reserve(skb, res);
> +               skb_reserve(skb, res+2);

You must add the 2 bytes in dev_alloc_skb() too.

(it also add 16 bytes by itself, but they are used for other things)

-Andi
