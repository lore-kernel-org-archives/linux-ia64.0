From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 23 Jan 2004 23:14:51 +0000
Subject: RE: Loadable module and kernel gp
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F4FB108@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4010EEC0.7020003@hob.de>
In-Reply-To: <4010EEC0.7020003@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> >>>>> On Fri, 23 Jan 2004 10:52:00 +0100, Christian Hildner 
> <christian.hildner@hob.de> said:
> 
>   Christian> Hi, does anybody know a simple way for a loadable module
>   Christian> to get the gp value of the kernel? Is there any sample
>   Christian> code?
> 
> The safest way is probably to materialize a function pointer for a
> function that is known to be in the kernel (and exported) and then to
> read the second word.

In case "materialzie a function pointer" is total greek:

#include <linux/slab.h>

struct fptr {
	unsigned long func_addr;
	unsigned long gp;
};

your_routine()
{
	struct fptr = (struct fptr *)kmalloc; /*function known to be in kernel */

	printk("Kernel gp is %lx\n", fptr->gp);
}


Untested ... kmalloc is declared "inline" so that might mess things
up.  Just choose some other exported thing if it is.
