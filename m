From: Andi Kleen <ak@suse.de>
Date: Wed, 15 Oct 2003 12:42:58 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106622180407727@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>  	__kernel_old_dev_t	ex_dev;
> +#ifdef __ia64__
> +	unsigned int		ex_ino;	/* ABI preservation */
> +#else
>  	__kernel_ino_t		ex_ino;
> +#endif

Please don't make it #ifdef __ia64__, but some other define that other
architectures who may want to move the 64bit ino_t too can just set.

-Andi
