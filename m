From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Tue, 19 Sep 2017 02:08:13 +0000
Subject: Re: [PATCH 0/5] [RFC] printk/ia64/ppc64/parisc64: let's deprecate %pF/%pf printk specifiers
Message-Id: <20170919020812.GB16991@jagdpanzerIV.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170916035347.19705-1-sergey.senozhatsky@gmail.com>
 <20170918174432.4fksyzco2g6gczwe@intel.com>
In-Reply-To: <20170918174432.4fksyzco2g6gczwe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "James E . J . Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On (09/18/17 10:44), Luck, Tony wrote:
[..]
> 
> A few new warnings when building on ia64:
> 
> arch/ia64/kernel/module.c:931: warning: passing argument 1 of 'dereference_function_descriptor' makes pointer from integer without a cast
> arch/ia64/kernel/module.c:931: warning: return makes integer from pointer without a cast
> kernel/kallsyms.c:325: warning: assignment makes integer from pointer without a cast
> kernel/kallsyms.c:325: warning: passing argument 1 of 'dereference_kernel_function_descriptor' makes pointer from integer without a cast

got it, will address in v2.

[..]
> Which looks like what you wanted. People unaware of the vagaries
> of ppc64/ia64/parisc64 can use the wrong %p[SF] variant, but still
> get the right output.

thanks!

	-ss
