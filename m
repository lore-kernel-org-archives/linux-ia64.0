From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 18 Jan 2023 00:02:03 +0000
Subject: Re: [PATCH] ia64: Fix build error due to switch case label appearing next to declaration
Message-Id: <20230117160203.a1a22c612cdffeeb79b8d397@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230117151632.393836-1-james.morse@arm.com>
In-Reply-To: <20230117151632.393836-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Morse <james.morse@arm.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Sergei Trofimovich <slyich@gmail.com>, matoro <matoro_mailinglist_kernel@matoro.tk>, =?ISO-8859-1?Q?=C9meric?= Maschino <emeric.maschino@gmail.com>

On Tue, 17 Jan 2023 15:16:32 +0000 James Morse <james.morse@arm.com> wrote:

> Since commit aa06a9bd8533 ("ia64: fix clock_getres(CLOCK_MONOTONIC) to
> report ITC frequency"), gcc 10.1.0 fails to build ia64 with the gnomic:
> | ../arch/ia64/kernel/sys_ia64.c: In function 'ia64_clock_getres':
> | ../arch/ia64/kernel/sys_ia64.c:189:3: error: a label can only be part of a statement and a declaration is not a statement
> |   189 |   s64 tick_ns = DIV_ROUND_UP(NSEC_PER_SEC, local_cpu_data->itc_freq);
> 
> ...
>
> @@ -185,8 +188,8 @@ ia64_clock_getres(const clockid_t which_clock, struct __kernel_timespec __user *
>  	switch (which_clock) {
>  	case CLOCK_REALTIME:
>  	case CLOCK_MONOTONIC:
> -		s64 tick_ns = DIV_ROUND_UP(NSEC_PER_SEC, local_cpu_data->itc_freq);
> -		struct timespec64 rtn_tp = ns_to_timespec64(tick_ns);
> +		tick_ns = DIV_ROUND_UP(NSEC_PER_SEC, local_cpu_data->itc_freq);
> +		rtn_tp = ns_to_timespec64(tick_ns);
>  		return put_timespec64(&rtn_tp, tp);
>  	}
>  

Huh, how did that sneak through.  We usually use an extra set of braces
for this.

Thanks, I'll add cc:stable to this.
