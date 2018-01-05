From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Fri, 05 Jan 2018 12:01:31 +0000
Subject: Re: [PATCH 00/13] replace print_symbol() with printk()-s
Message-Id: <20180105120131.GA417@jagdpanzerIV>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
 <20180105100300.j3svmcvvpfe2iows@pathway.suse.cz>
 <20180105102105.GB471@jagdpanzerIV>
In-Reply-To: <20180105102105.GB471@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On (01/05/18 19:21), Sergey Senozhatsky wrote:
> >     print_symbol() is an old weird API. It has been
> >     obsoleted by printk() and %pS format specifier.
> 
> I wouldn't. let's drop the "weird" part.

hm...

you are right, it is weird. and the weird part here is that
print_symbol() is used for things like __show_regs()

       print_symbol("PC is at %s\n", instruction_pointer(regs));
       print_symbol("LR is at %s\n", regs->ARM_lr);
       printk("pc : [<%08lx>]    lr : [<%08lx>]    psr: %08lx\n",
              regs->ARM_pc, regs->ARM_lr, regs->ARM_cpsr);

or for EMERG error reporting

        pr_emerg("unexpected fault for address: 0x%08lx, last fault for address: 0x%08lx\n",
                 addr, my_reason->addr);
        print_pte(addr);
       print_symbol(KERN_EMERG "faulting IP is at %s\n", regs->ip);
       print_symbol(KERN_EMERG "last faulting IP was at %s\n", my_reason->ip);
 #ifdef __i386__
        pr_emerg("eax: %08lx   ebx: %08lx   ecx: %08lx   edx: %08lx\n",
                 regs->ax, regs->bx, regs->cx, regs->dx);

or for error reporting in sysfs

               print_symbol("fill_read_buffer: %s returned bad count\n",
                       (unsigned long)ops->show);

and so on.

but, print_symbol() is compiled out on !CONFIG_KALLSYMS systems. so,
basically, we compile out some of errors print outs; even more, on ia64
ia64_do_show_stack() does nothing when there is no CONFIG_KALLSYMS [all
ia64 defconfigs have KALLSYMS_ALL enabled]. printk(%pS), unlike
print_symbol(), is not compiled out and prints the function address
when symbolic name is not available. but, at a glance, print_symbol()
in most of the cases has printk(registers) next to it or before it, so
it doesn't look like we are introducing a regression here by switching
to printk(%pS).

	-ss
