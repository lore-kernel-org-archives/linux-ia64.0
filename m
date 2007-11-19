From: Simon Horman <horms@verge.net.au>
Date: Mon, 19 Nov 2007 04:34:43 +0000
Subject: Re: [PATCH 1/9] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <20071119043441.GA1735@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <4714BDC7.1070702@jp.fujitsu.com>
In-Reply-To: <4714BDC7.1070702@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Oct 16, 2007 at 10:33:59PM +0900, Hidetoshi Seto wrote:
> > [1/9] ia64_add_config_virt_cpu_accounting.patch
> 
> The VIRT_CPU_ACCOUNTING option is already implemented s390
> and powerpc archs.
> 
> By enabling this option, the arch can hook a function named
> account_system_vtime() to irq_enter(), irq_exit(), and
> head and tail of do_softirq().
> 
> This patch just add the Kconfig option to ia64, and enable
> to hook ia64 specific account_system_vtime() function,
> currently nop as generic one.

Hi,

When I apply this patch and enable VIRT_CPU_ACCOUNTING I get
the following build error. Perhaps the fragment that creates
account_process_tick in arch/ia64/kernel/time.c is missing?

kernel/built-in.o: In function `update_process_times': undefined
reference to `account_process_tick'

-- 
Horms

