From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 22 Feb 2006 16:19:51 +0000
Subject: RE: IA64 non-contiguous memory space bugs
Message-Id: <200602221619.k1MGJog18578@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20060222001359.GA23574@localhost.localdomain>
References: <20060222001359.GA23574@localhost.localdomain>
In-Reply-To: <20060222001359.GA23574@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'David Gibson' <david@gibson.dropbear.id.au>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

David Gibson wrote on Tuesday, February 21, 2006 4:14 PM
> --- working-2.6.orig/include/linux/mm.h	2004-09-07 10:38:00.000000000 +1000
> +++ working-2.6/include/linux/mm.h	2004-09-24 15:02:18.172776168 +1000
> @@ -41,6 +41,13 @@
>  #define MM_VM_SIZE(mm)	TASK_SIZE
>  #endif
>  
> +#ifndef REGION_MAX
> +#define REGION_MAX(addr)	TASK_SIZE
> +#endif
> +
> +#define GOOD_TASK_VM_RANGE(addr, len) \
> +	( ((addr)+(len) >= (addr)) || ((addr)+(len) <= TASK_SIZE) \
> +	  || ((addr)+(len) <= REGION_MAX(addr)) )

Looks like the logic is reversed, should be && instead of ||.

- Ken

