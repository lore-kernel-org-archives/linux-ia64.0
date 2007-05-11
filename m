From: Simon Arlott <simon@fire.lp0.eu>
Date: Fri, 11 May 2007 19:55:12 +0000
Subject: Re: [PATCH] spelling fixes: arch/ia64/
Message-Id: <4644CA20.2060606@simon.arlott.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <4644C6FD.6010004@simon.arlott.org.uk>
In-Reply-To: <4644C6FD.6010004@simon.arlott.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Arlott <simon@fire.lp0.eu>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, trivial@kernel.org

On 11/05/07 20:41, Simon Arlott wrote:
> diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
> index a06667c..bf7e7b5 100644
> --- a/arch/ia64/kernel/time.c
> +++ b/arch/ia64/kernel/time.c
> @@ -216,7 +216,7 @@ ia64_init_itm (void)
> #ifdef CONFIG_SMP
>         /* On IA64 in an SMP configuration ITCs are never accurately 
> synchronized.
>          * Jitter compensation requires a cmpxchg which may limit
> -         * the scalability of the syscalls for retrieving time.
> +         * the scalibility of the syscalls for retrieving time.
>          * The ITC synchronization is usually successful to within a few
>          * ITC ticks but this is not a sure thing. If you need to improve
>          * timer performance in SMP situations then boot the kernel with 
> the

I thought I'd reverted that mistake... it was correct already :/

-- 
Simon Arlott
