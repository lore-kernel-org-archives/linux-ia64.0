From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 18 Sep 2017 17:44:32 +0000
Subject: Re: [PATCH 0/5] [RFC] printk/ia64/ppc64/parisc64: let's deprecate %pF/%pf printk specifiers
Message-Id: <20170918174432.4fksyzco2g6gczwe@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170916035347.19705-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20170916035347.19705-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "James E . J . Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Sat, Sep 16, 2017 at 12:53:42PM +0900, Sergey Senozhatsky wrote:
> 	Hello
> 
> 	RFC
> 
> 	On some arches C function pointers are indirect and point to
> a function descriptor, which contains the actual pointer to the code.
> This mostly doesn't matter, except for cases when people want to print
> out function pointers in symbolic format, because the usual '%pS/%ps'
> does not work on those arches as expected. That's the reason why we
> have '%pF/%pf', but since it's here because of a subtle ABI detail
> specific to some arches (ppc64/ia64/parisc64) it's easy to misuse
> '%pF/%pf' and '%pS/%ps' (see [1], for example).

A few new warnings when building on ia64:

arch/ia64/kernel/module.c:931: warning: passing argument 1 of 'dereference_function_descriptor' makes pointer from integer without a cast
arch/ia64/kernel/module.c:931: warning: return makes integer from pointer without a cast
kernel/kallsyms.c:325: warning: assignment makes integer from pointer without a cast
kernel/kallsyms.c:325: warning: passing argument 1 of 'dereference_kernel_function_descriptor' makes pointer from integer without a cast

Tried out the module case with a simple Hello-world test case.
This code:

char buf[1];

int init_module(void)
{
	printk(KERN_INFO "Hello world 1.\n");

	printk("using %%p  my init_module is at %p\n", init_module);
	printk("using %%pF my init_module is at %pF\n", init_module);
	printk("using %%pS my init_module is at %pS\n", init_module);

	printk("using %%p  my buf is at %p\n", buf);
	printk("using %%pF my buf is at %pF\n", buf);
	printk("using %%pS my buf is at %pS\n", buf);

	return 0;
}

Gave this console output:

Hello world 1.
using %p  my init_module is at a000000203bf0328
using %pF my init_module is at init_module+0x0/0x140 [hello_1]
using %pS my init_module is at init_module+0x0/0x140 [hello_1]
using %p  my buf is at a000000203bf0648
using %pF my buf is at buf+0x0/0xfffffffffffffb58 [hello_1]
using %pS my buf is at buf+0x0/0xfffffffffffffb58 [hello_1]


Which looks like what you wanted. People unaware of the vagaries
of ppc64/ia64/parisc64 can use the wrong %p[SF] variant, but still
get the right output.

-Tony
