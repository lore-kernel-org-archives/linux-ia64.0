From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Thu, 28 Jan 2021 22:51:15 +0000
Subject: Re: [PATCH] ia64: add support for TIF_NOTIFY_SIGNAL
Message-Id: <82f1e3d1-c16b-8974-2781-31214d229a11@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <d3a2aa1e-0fae-1d3f-519f-d32adc608c38@kernel.dk>
In-Reply-To: <d3a2aa1e-0fae-1d3f-519f-d32adc608c38@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 1/28/21 11:42 PM, Jens Axboe wrote:
>> I just tried Linus' current tree (ge5ff2cb9cf67) and the problem still persists.
> 
> Funky... Can you see if this helps?
> 
> diff --git a/arch/ia64/kernel/signal.c b/arch/ia64/kernel/signal.c
> index e67b22fc3c60..7de57ace4799 100644
> --- a/arch/ia64/kernel/signal.c
> +++ b/arch/ia64/kernel/signal.c
> @@ -358,9 +358,6 @@ ia64_do_signal (struct sigscratch *scr, long in_syscall)
>  			 */
>  			restart = 0;
>  
> -		if (ksig.sig <= 0)
> -			break;
> -
>  		if (unlikely(restart)) {
>  			switch (errno) {
>  			case ERESTART_RESTARTBLOCK:
> @@ -381,6 +378,9 @@ ia64_do_signal (struct sigscratch *scr, long in_syscall)
>  			}
>  		}
>  
> +		if (ksig.sig <= 0)
> +			break;
> +
>  		/*
>  		 * Whee!  Actually deliver the signal.  If the delivery failed, we need to
>  		 * continue to iterate in this loop so we can deliver the SIGSEGV...

This one doesn't help. Will try the other in a minute.

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
