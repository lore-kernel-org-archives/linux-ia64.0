From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 22 Mar 2005 21:52:21 +0000
Subject: RE: [patch 1/1] printk : arch/ia64/kernel/smp.c
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03211699@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050319131906.E934A1F245@trashy.coderock.org>
In-Reply-To: <20050319131906.E934A1F245@trashy.coderock.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 	if (cpuid = me) {
>-		printk("%s: trying to call self\n", __FUNCTION__);
>+		printk(KERN_INFO "%s: trying to call self\n", __FUNCTION__);
> 		put_cpu();
> 		return -EBUSY;
> 	}

I think this is a bit higher priority than KERN_INFO.  If we
get here, then someone did something wrong at a higher level,
and they may be disapponited that the function they want called
isn't going to be called.

Perhaps KERN_WARNING would be more appropriate?

It might also be kind to anyone trying to debug this to print
the "func" argument.

-Tony
