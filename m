From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Tue, 19 Sep 2017 10:31:54 +0000
Subject: Re: [PATCH 3/5] powerpc64: Add .opd based function descriptor dereference
Message-Id: <20170919103154.GC401@jagdpanzerIV.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170916035347.19705-1-sergey.senozhatsky@gmail.com>
 <20170916035347.19705-4-sergey.senozhatsky@gmail.com>
 <20170916094345.d332z3odceqiyrll@naverao1-tp.localdomain>
 <87shfjkmxe.fsf@concordia.ellerman.id.au>
In-Reply-To: <87shfjkmxe.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "James E . J . Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Petr Mladek <pmladek@suse.com>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, linux-kernel@vger.kernel.org, Jessica Yu <jeyu@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Nicholas Piggin <npiggin@gmail.com>

On (09/19/17 20:22), Michael Ellerman wrote:
> > On 2017/09/16 12:53PM, Sergey Senozhatsky wrote:
> >> We are moving towards separate kernel and module function descriptor
> >> dereference callbacks. This patch enables it for powerpc64.
> >> 
> >> For pointers that belong to the kernel
> >> -  Added __start_opd and __end_opd pointers, to track the kernel
> >>    .opd section address range;
> >> 
> >> -  Added dereference_kernel_function_descriptor(). Now we
> >>    will dereference only function pointers that are within
> >>    [__start_opd, __end_opd];
> >> 
> >> For pointers that belong to a module
> >> -  Added dereference_module_function_descriptor() to handle module
> >>    function descriptor dereference. Now we will dereference only
> >>    pointers that are within [module->opd.start, module->opd.end].
> >
> > Would it be simpler to just use kernel_text_address() and dereference 
> > everything else? See commit 83e840c770f2c5 ("powerpc64/elfv1: Only 
> > dereference function descriptor for non-text symbols") for a related 
> > patch.
> 
> Yeah that would be a lot simpler and probably work perfectly well.

unlike ppc_function_entry(), printk() can get called on any symbol,
not just function pointers.

for example,

cat /proc/kallsyms | grep shrinker_rwsem
ffffffff81a4b1e0 d shrinker_rwsem

or

cat /proc/kallsyms | grep vm_total_pages
ffffffff81dcd418 B vm_total_pages


and so on.

	-ss
