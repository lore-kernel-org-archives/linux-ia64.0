From: Rusty Russell <rusty@rustcorp.com.au>
Date: Wed, 27 May 2009 05:35:51 +0000
Subject: Re: [Patch 4/4] module: trim exception table in module_free()
Message-Id: <200905271453.51914.rusty@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090526083717.5050.32719.sendpatchset@localhost.localdomain> <200905271151.28045.rusty@rustcorp.com.au> <4A1CAF44.7000002@redhat.com>
In-Reply-To: <4A1CAF44.7000002@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, jdike@addtoit.com, mingo@elte.hu, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 27 May 2009 12:41:00 pm Amerigo Wang wrote:
> Rusty Russell wrote:
> > On Tue, 26 May 2009 06:05:39 pm Amerigo Wang wrote:
> >>  void module_free(struct module *mod, void *module_region)
> >>  {
> >>  	vfree(module_region);
> >> -	/* FIXME: If module_region = mod->init_region, trim exception
> >> -	   table entries. */
> >> +	if (module_region = mod->module_init)
> >> +		mod->num_exentries = 0;
> >>  }
> >
> > Hi Amerigo,
> >
> >    This looks wrong.  The extable covers both init and core exception
> > entries. We want to remove the ones in the module_init section.  The good
> > news is that it's sorted, so they're either at the start or the end
> > (except sparc 32).
>
> Hi, Rusty.
>
> Yes? The extable of a module is in '__ex_table' section, and during the
> section transfer, one
> section will be either in module_init or module_core, so its entries are
> only in one of them,
> not both, right?

32-bit example:

#include <linux/module.h>
#include <linux/uaccess.h>
#include <linux/moduleparam.h>

static unsigned long uaddr;
module_param(uaddr, ulong, 0600);

void extable_not_init(u64 val)
{
	__put_user(val, (u64 *)uaddr);
}

static int __init init(void)
{
	__put_user(0, (u64 *)uaddr);
	return 0;
}
module_init(init);

__ex_table ends up with two entries:

Contents of section __ex_table:
 0000 0c000000 00000000 0e000000 00000000  ................
 0010 10000000 0a000000 12000000 0a000000  ................

The first is for the __put_user in .text (extable_not_init()) and the second is 
for the one in .init.text (init()).

Depending on how the module gets allocated, the one referring to .init.text 
may be first or last.

(You can see here why we haven't fixed this: exceptions in __init in modules 
are rare, perhaps non-existent).

Hope that clarifies?
Rusty.
