From: Petr Mladek <pmladek@suse.com>
Date: Tue, 28 Nov 2017 15:44:57 +0000
Subject: Re: [PATCHv4 5/6] symbol lookup: introduce dereference_symbol_descriptor()
Message-Id: <20171128154457.fa44duhcjiux2wbh@pathway.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171109234830.5067-1-sergey.senozhatsky@gmail.com>
 <20171109234830.5067-6-sergey.senozhatsky@gmail.com>
 <20171110180931.xhhi35osclzceba2@agluck-desk>
 <20171111044932.GB596@tigerII.localdomain>
In-Reply-To: <20171111044932.GB596@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Sat 2017-11-11 13:49:32, Sergey Senozhatsky wrote:
> On (11/10/17 10:09), Luck, Tony wrote:
> > On Fri, Nov 10, 2017 at 08:48:29AM +0900, Sergey Senozhatsky wrote:
> > > -Examples::
> > > -
> > > -	printk("Going to call: %pF\n", gettimeofday);
> > > -	printk("Going to call: %pF\n", p->func);
> > > -	printk("%s: called from %pS\n", __func__, (void *)_RET_IP_);
> > > -	printk("%s: called from %pS\n", __func__,
> > > -				(void *)__builtin_return_address(0));
> > > -	printk("Faulted at %pS\n", (void *)regs->ip);
> > > -	printk(" %s%pB\n", (reliable ? "" : "? "), (void *)*stack);
> > 
> > Did you mean to delete the Examples completely?  Wouldn't it
> > be better to just update (s/%pF/%pS/g)?
> 
> good question. yes, I think I did it deliberately :) we still
> kinda have some sort of "examples", right at the beginning of
> section "Symbols/Function Pointers"

These extra examples were added just recently (v4.14-rc1)
by the commit fd46cd55fbc5a8e8c ("printk-formats.txt: Add examples
for %pF and %pS usage"). They were supposed to help using
%pF and %pS correctly according to the situation. But we
have a better solution now. %pF is obsoleted by this
patchset.

IMHO, it is perfectly fine to remove the extra examples.

Best Regards,
Petr
