From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 22 Feb 2005 17:37:10 +0000
Subject: Re: [PATCH] Errenous use of memset and memcpy
Message-Id: <1109093830.30562.14.camel@eeyore>
List-Id: <linux-ia64.vger.kernel.org>
References: <1108848352.682.2.camel@boxen>
In-Reply-To: <1108848352.682.2.camel@boxen>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 2005-02-20 at 11:38 +0100, Alexander Nyberg wrote:
> === arch/ia64/ia32/ia32_signal.c 1.35 vs edited ==> --- 1.35/arch/ia64/ia32/ia32_signal.c	2005-01-25 21:23:45 +01:00
> +++ edited/arch/ia64/ia32/ia32_signal.c	2005-02-20 11:32:55 +01:00
> @@ -460,9 +460,9 @@ __ia32_rt_sigsuspend (compat_sigset_t *s
>  	sigset_t oldset, set;
>  
>  	scr->scratch_unat = 0;	/* avoid leaking kernel bits to user level */
> -	memset(&set, 0, sizeof(&set));
> +	memset(&set, 0, sizeof(sigset_t));

To check that the above is correct, you have to go look up
the declaration of "set".  Why not do this:

+	memset(&set, 0, sizeof(set));

which is clearly correct, regardless of the declaration?

