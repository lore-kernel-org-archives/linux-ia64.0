From: Petr Mladek <pmladek@suse.com>
Date: Tue, 28 Nov 2017 15:47:10 +0000
Subject: Re: [PATCHv4 0/6] printk/ia64/ppc64/parisc64: let's deprecate %pF/%pf printk specifiers
Message-Id: <20171128154710.ytqixlioc3hrcbl3@pathway.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171109234830.5067-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171109234830.5067-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Fri 2017-11-10 08:48:24, Sergey Senozhatsky wrote:
> 	Hello,
> 
> 	A reworked version. There is a new dereference_symbol_descriptor()
> function now, where "the magic happens", so I don't touch kallsyms_lookup()
> and module_address_lookup() anymore.

The new version looks good to me. Thanks a lot for reworking it.
I feel much better now. For the whole series:

Reviewed-by: Petr Mladek <pmladek@suse.com>

> 	All Ack-s/Tested-by-s were dropped, since the patch set has been
> reworked. I'm kindly asking arch-s maintainers and developers to test it
> once again. Sorry for any inconveniences and thanks for your help in
> advance.

I see that it was tested on all affected architectures. Thanks a lot
all testers.

It seems that we are ready to go. I am going to push this into
for-4.16 branch in printk.git.

Best Regards,
Petr
