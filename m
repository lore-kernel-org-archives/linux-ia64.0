From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 17 Apr 2003 19:37:49 +0000
Subject: Re: [Linux-ia64] brl emulation bug fix
Message-Id: <marc-linux-ia64-105590723705539@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705514@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705514@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 16 April 2003 3:00 pm, Arun Sharma wrote:
> This applies to both 2.4 and 2.5. A 64 bit value was being assigned to
> an int.

I applied this for 2.4 as well.

> --- arch/ia64/kernel/brl_emu.c.orig     Thu Oct 17 10:02:52 2002
> +++ arch/ia64/kernel/brl_emu.c  Thu Oct 17 15:40:29 2002
> @@ -59,7 +59,7 @@
>         unsigned long next_ip;
>         struct siginfo siginfo;
>         struct illegal_op_return rv;
> -       int tmp_taken, unimplemented_address;
> +       long tmp_taken, unimplemented_address;
> 
>         rv.fkt = (unsigned long) -1;
> 


