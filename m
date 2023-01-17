From: Sergei Trofimovich <slyich@gmail.com>
Date: Tue, 17 Jan 2023 19:31:09 +0000
Subject: Re: [PATCH] ia64: Fix build error due to switch case label appearing next to declaration
Message-Id: <20230117193109.5650fd6f@nz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230117151632.393836-1-james.morse@arm.com>
In-Reply-To: <20230117151632.393836-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Morse <james.morse@arm.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, matoro <matoro_mailinglist_kernel@matoro.tk>, =?UTF-8?B?w4ltZXJpYw==?= Maschino <emeric.maschino@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 17 Jan 2023 15:16:32 +0000
James Morse <james.morse@arm.com> wrote:

> Since commit aa06a9bd8533 ("ia64: fix clock_getres(CLOCK_MONOTONIC) to
> report ITC frequency"), gcc 10.1.0 fails to build ia64 with the gnomic:
> | ../arch/ia64/kernel/sys_ia64.c: In function 'ia64_clock_getres':
> | ../arch/ia64/kernel/sys_ia64.c:189:3: error: a label can only be part of a statement and a declaration is not a statement
> |   189 |   s64 tick_ns = DIV_ROUND_UP(NSEC_PER_SEC, local_cpu_data->itc_freq);
> 
> This line appears immediately after a case label in a switch.
> 
> Move the declarations out of the case, to the top of the function.
> 
> Fixes: aa06a9bd8533 ("ia64: fix clock_getres(CLOCK_MONOTONIC) to report ITC frequency")
> Signed-off-by: James Morse <james.morse@arm.com>

Out of curiosity what compiler version behaves like that? I think I and
matoro build-/run-tested it on gcc-12 and maybe gcc-11.

Thank you!

Reviewed-by: Sergei Trofimovich <slyich@gmail.com>

> ---
> Found when build testing another series.
> I've only build tested this.
> 
>  arch/ia64/kernel/sys_ia64.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/ia64/kernel/sys_ia64.c b/arch/ia64/kernel/sys_ia64.c
> index f6a502e8f02c..6e948d015332 100644
> --- a/arch/ia64/kernel/sys_ia64.c
> +++ b/arch/ia64/kernel/sys_ia64.c
> @@ -170,6 +170,9 @@ ia64_mremap (unsigned long addr, unsigned long old_len, unsigned long new_len, u
>  asmlinkage long
>  ia64_clock_getres(const clockid_t which_clock, struct __kernel_timespec __user *tp)
>  {
> +	struct timespec64 rtn_tp;
> +	s64 tick_ns;
> +
>  	/*
>  	 * ia64's clock_gettime() syscall is implemented as a vdso call
>  	 * fsys_clock_gettime(). Currently it handles only
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
> -- 
> 2.30.2
> 


-- 

  Sergei
