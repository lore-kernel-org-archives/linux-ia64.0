From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Fri, 05 Jan 2018 12:23:34 +0000
Subject: Re: [PATCH 00/13] replace print_symbol() with printk()-s
Message-Id: <20180105122334.GB417@jagdpanzerIV>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
 <20180105100300.j3svmcvvpfe2iows@pathway.suse.cz>
 <20180105102105.GB471@jagdpanzerIV>
 <20180105120131.GA417@jagdpanzerIV>
In-Reply-To: <20180105120131.GA417@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On (01/05/18 21:01), Sergey Senozhatsky wrote:
[..]
> but, print_symbol() is compiled out on !CONFIG_KALLSYMS systems. so,
> basically, we compile out some of errors print outs; even more, on ia64
> ia64_do_show_stack() does nothing when there is no CONFIG_KALLSYMS [all
> ia64 defconfigs have KALLSYMS_ALL enabled]. printk(%pS), unlike
> print_symbol(), is not compiled out and prints the function address
> when symbolic name is not available. but, at a glance, print_symbol()
> in most of the cases has printk(registers) next to it or before it, so
> it doesn't look like we are introducing a regression here by switching
> to printk(%pS).

well, if this is a problem, then we can have

static inline void print_symbol(const char *fmt, unsigned long addr)
{
       printk(fmt, addr);
}

for CONFIG_KALLSYMS builds, and an empty print_symbol() for !CONFIG_KALLSYMS
builds.


but we still have tons printk(%pS) in the kernel and even print_ip_sym()
(which is not compiled out on !CONFIG_KALLSYMS). so it seems to me that
we can drop print_symbol()/__print_symbol() and switch to printk(%pS)
after all.

	-ss
