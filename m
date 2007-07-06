From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 06 Jul 2007 09:41:38 +0000
Subject: Re: [BUGFIX]{PATCH] flush icache on ia64 take2
Message-Id: <468E0E52.2060705@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070706112901.16bb5f8a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070706112901.16bb5f8a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "tony.luck@intel.com" <tony.luck@intel.com>, nickpiggin@yahoo.com.au, mike@stroyan.net, dmosberger@gmail.com, GOTO <y-goto@jp.fujitsu.com>

KAMEZAWA Hiroyuki wrote:

>  Note1: icache flush is called only when VM_EXEC flag is on and 
>         PG_arch_1 is not set.

If you have not got the page in the cache, then the new page will
be allocated with PG_arch_1 bit off.
You are going to flush pages which are read by HW DMA, i.e. the L2I
of Montecito does not keep old lines for those pages anyway.

...->a_ops->readpage() of "L2I safe" file systems should set PG_arch_1
if the CPU is ia64 and it has got separate L2I.

On the other hand, arch. independent file systems should not play with
PG_arch_1.
The base kernel should export a macro for the file systems...

Thanks,

Zoltan Menyhart


