From: Domen Puncer <domen@coderock.org>
Date: Wed, 23 Mar 2005 11:31:24 +0000
Subject: Re: [patch 1/1] printk : arch/ia64/kernel/smp.c
Message-Id: <20050323113124.GB7472@nd47.coderock.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050319131906.E934A1F245@trashy.coderock.org>
In-Reply-To: <20050319131906.E934A1F245@trashy.coderock.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 23/03/05 11:02 +0100, Christophe Lucas wrote:
>  	if (cpuid = me) {
> -		printk("%s: trying to call self\n", __FUNCTION__);
> +		printk(KERN_WARNING "%s: trying to call self with info:%08x\n", __FUNCTION__, info);

Hmm... %p is supposed to be used for pointers, right?



	Domen
