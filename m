From: Uros Prestor <uros@turbolinux.com>
Date: Thu, 11 Jan 2001 19:09:22 +0000
Subject: Re: [Linux-ia64] Kernel panic in dtlb_fault
Message-Id: <marc-linux-ia64-105590693005025@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205904@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205904@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I still get a kernel panic in dtlb_fault() when setting
CONFIG_DISABLE_VHPT=y.

Uros


"Mallick, Asit K" wrote:

> Here is a patch to fix this problem.
>
> Thanks,
> Asit
>
> --- linux-2.4.0/arch/ia64/kernel/ivt.S  Tue Jan  9 03:48:36 2001
> +++ linux/arch/ia64/kernel/ivt.S        Wed Jan 10 06:32:56 2001
> @@ -206,6 +206,7 @@
>         ;;
>  (p7)   ptc.l r16,r20
>  #endif
> +       mov b0=r29
>         mov pr=r31,-1
>         rfi
>         ;;
> @@ -241,6 +242,7 @@
>         ;;
>  (p7)   ptc.l r16,r20
>  #endif
> +       mov b0=r29
>         mov pr=r31,-1
>         rfi
>         ;;
>
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

--
Uros Prestor
uros@turbolinux.com




