From: Rusty Russell <rusty@rustcorp.com.au>
Date: Fri, 15 Oct 2004 01:35:22 +0000
Subject: Re: [PATCH 1/5][Diskdump] IPF(IA64) support
Message-Id: <1097804121.22673.43.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <14C4709A99D341indou.takao@soft.fujitsu.com>
	 <15C4709AD81CB1indou.takao@soft.fujitsu.com>
In-Reply-To: <15C4709AD81CB1indou.takao@soft.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Takao Indoh <indou.takao@soft.fujitsu.com>
Cc: lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Fri, 2004-07-23 at 19:53, Takao Indoh wrote:
> +static unsigned int fallback_on_err = 1;
> +static unsigned int allow_risky_dumps = 1;
> +static unsigned int block_order = 2;
> +static int sample_rate = 8;
> +module_param(fallback_on_err, uint, 0);
> +module_param(allow_risky_dumps, uint, 0);
> +module_param(block_order, uint, 0);
> +module_param(sample_rate, int, 0);

Hi Takao!

	Are you sure you want "uint" for fallback_on_err and allow_risky_dumps
and not "bool"?  Also, I suggest "0400" as permissions so you can read
them out of sysfs; maybe even 0600 if these parameters can be changed
after loading.

Thanks!
Rusty.
-- 
Anyone who quotes me in their signature is an idiot -- Rusty Russell

