From: Andi Kleen <andi@firstfloor.org>
Date: Sun, 22 Jun 2008 17:41:35 +0000
Subject: Re: [PATCH] SN2: security hole in sn2_ptc_proc_write
Message-Id: <87r6apwenk.fsf@basil.nowhere.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <E1K9SIg-0005n6-Ea@eag09.americas.sgi.com>
In-Reply-To: <E1K9SIg-0005n6-Ea@eag09.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Cliff Wickman <cpw@sgi.com> writes:
>
> Signed-off-by: Cliff Wickman <cpw@sgi.com>
> ---
>  arch/ia64/sn/kernel/sn2/sn2_smp.c |    2 ++
>  1 file changed, 2 insertions(+)
>
> Index: linux-2.6/arch/ia64/sn/kernel/sn2/sn2_smp.c
> =================================> --- linux-2.6.orig/arch/ia64/sn/kernel/sn2/sn2_smp.c
> +++ linux-2.6/arch/ia64/sn/kernel/sn2/sn2_smp.c
> @@ -512,6 +512,8 @@ static ssize_t sn2_ptc_proc_write(struct
>  	int cpu;
>  	char optstr[64];
>  
> +	if (count > 64)
> +		return -EINVAL;
>  	if (copy_from_user(optstr, user, count))
>  		return -EFAULT;
>  	optstr[count - 1] = '\0';


When someone passes 0 you get an buffer underflow? 

You need if (count < 0 || count > 64) me thinks.

-Andi
