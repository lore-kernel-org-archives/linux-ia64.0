From: Manik Raina <manik@cisco.com>
Date: Fri, 21 Jun 2002 06:10:18 +0000
Subject: [Linux-ia64] Re: [Trivial Patch] : (2.5 latest) More __builtin_expect() cleanup in
Message-Id: <marc-linux-ia64-105590701905696@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905695@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905695@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Manik Raina wrote:
> 
> diff -u -r linux-2.5.22/include/asm-ia64/softirq.h real/include/asm-ia64/softirq.h
> --- linux-2.5.22/include/asm-ia64/softirq.h     Mon Jun 17 08:01:35 2002
> +++ real/include/asm-ia64/softirq.h     Fri Jun 21 10:44:05 2002
> @@ -13,7 +13,7 @@
>  #define local_bh_enable()                                                              \
>  do {                                                                                   \
>         __local_bh_enable();                                                            \
> -       if (__builtin_expect(local_softirq_pending(), 0) && really_local_bh_count() = 0)       \
> +       if (unlikely(local_softirq_pending()) && really_local_bh_count() = 0)  \
>                 do_softirq();                                                           \
>  } while (0)
> 

	I don't think softirq.h includes linux/compiler.h . Can you please include
	that ?

