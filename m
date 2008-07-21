From: Matthew Wilcox <matthew@wil.cx>
Date: Mon, 21 Jul 2008 00:19:09 +0000
Subject: Re: [PATCH 9/22] ia64: Introducing asm/syscalls.h
Message-Id: <20080721001909.GA24246@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1216592500.3679.14.camel@jaswinder.satnam> <1216592798.3679.22.camel@jaswinder.satnam> <1216592879.3679.24.camel@jaswinder.satnam> <1216593035.3679.27.camel@jaswinder.satnam> <1216596035.3679.95.camel@jaswinder.satnam> <1216596106.3679.98.camel@jaswinder.satnam> <1216596325.3679.104.camel@jaswinder.satnam> <1216596669.3679.112.camel@jaswinder.satnam> <1216596749.3679.115.camel@jaswinder.satnam> <1216596835.3679.117.camel@jaswinder.satnam>
In-Reply-To: <1216596835.3679.117.camel@jaswinder.satnam>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jaswinder Singh <jaswinder@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, kernelnewbies <kernelnewbies@nl.linux.org>, David Woodhouse <dwmw2@infradead.org>, tony.luck@intel.com, linux-ia64@vger.kernel.org

On Mon, Jul 21, 2008 at 05:03:55AM +0530, Jaswinder Singh wrote:
> Declaring arch-dependent syscalls for ia64 architecture
> +#ifndef CONFIG_PCI
> +asmlinkage long sys_pciconfig_read(unsigned long, unsigned long,
> +				   unsigned long, unsigned long, void *);
> +asmlinkage long sys_pciconfig_write(unsigned long, unsigned long,
> +				    unsigned long, unsigned long, void *);
> +#endif /* CONFIG_PCI */

These are already declared in linux/syscalls.h

And frankly, we should just make these return -ENOSYS always.  Any
software that uses them is stuffed on machines with multiple domains.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
