From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 20 Dec 2006 01:33:29 +0000
Subject: Re: [patch] Cache error recovery
Message-Id: <458892E9.3060404@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200612191705.kBJH5e0s69613196@clink.americas.sgi.com>
In-Reply-To: <200612191705.kBJH5e0s69613196@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson wrote:
> @@ -688,11 +690,11 @@ recover_from_processor_error(int platfor
>  	 * The cache check and bus check bits have four possible states
>  	 *   cc bc
>  	 *    0  0	Weird record, not recovered
> -	 *    1  0	Cache error, not recovered
> +	 *    1  0	Cache error, attempt recovered
>  	 *    0  1	I/O error, attempt recovery
>  	 *    1  1	Memory error, attempt recovery
>  	 */

Which is right, attempt-"recovered" or "recovery"?

> -	if (psp->bc = 0 || pbci = NULL)
> +	if (psp->cc = 0 && (psp->bc = 0 || pbci = NULL))
>  		return fatal_mca("No bus check");

The message should be replaced by more appropriate one...
"No recoverable check" or just "Weird record"?

And also there are some comments need to be fixed since this
patch makes it incorrect, ex.

 >         /*
 >          * Well, here is only one bus error.
 >          */

Thanks,
H.Seto

