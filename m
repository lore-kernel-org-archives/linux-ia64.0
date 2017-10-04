From: Petr Mladek <pmladek@suse.com>
Date: Wed, 04 Oct 2017 09:05:26 +0000
Subject: Re: [PATCHv3 3/7] ia64: Add .opd based function descriptor dereference
Message-Id: <20171004090526.GE20084@pathway.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170930025319.987-1-sergey.senozhatsky@gmail.com>
 <20170930025319.987-4-sergey.senozhatsky@gmail.com>
In-Reply-To: <20170930025319.987-4-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Sat 2017-09-30 11:53:15, Sergey Senozhatsky wrote:
> We are moving towards separate kernel and module function descriptor
> dereference callbacks. This patch enables it for IA64.
> 
> For pointers that belong to the kernel
> -  Added __start_opd and __end_opd pointers, to track the kernel
>    .opd section address range;
> 
> -  Added dereference_kernel_function_descriptor(). Now we
>    will dereference only function pointers that are within
>    [__start_opd, __end_opd];
> 
> For pointers that belong to a module
> -  Added dereference_module_function_descriptor() to handle module
>    function descriptor dereference. Now we will dereference only
>    pointers that are within [module->opd.start, module->opd.end].
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Tested-by: Helge Deller <deller@gmx.de> # parisc64
> Tested-by: Santosh Sivaraj <santosh@fossix.org> # powerpc64
> Acked-by: Michael Ellerman <mpe@ellerman.id.au> # powerpc64
> Tested-by: Tony Luck <tony.luck@intel.com> # ia64

Looks good to me.

Reviewed-by: Petr Mladek <pmladek@suse.com>

Best Regards,
Petr
