From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 31 Jul 2007 00:29:28 +0000
Subject: Re: [PATCH] flush icache before set_pte() take 5.
Message-Id: <20070731092928.c6da9f25.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070728150319.d19f531f.kamezawa.hiroyu@jp.fujitsu.com>
	<46ADF61A.6000509@bull.net>
In-Reply-To: <46ADF61A.6000509@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>

On Mon, 30 Jul 2007 16:30:50 +0200
Zoltan Menyhart <Zoltan.Menyhart@bull.net> wrote:

> KAMEZAWA Hiroyuki wrote:
> 
> > Considerations:
> >   - I can add CONFIG_MONTECITO if necessary. But it will be confusing, I think.
> 
> What about this trick below?
> 
> identify_cpu() finds out the "c->family".
> If any of the CPUs has c->family=32 (and the future versions...) then
> set a global flag. And:
> 
> static inline void sync_icache_dcache(pte_t pte) {
>         if (pte_exec(pte) && global_flag)
>                 __sync_icache_dcache(pte);
> }
> 
Hmm...maybe better for old cpus even if cache miss occurs here.
I'll add add-on patch in take6.

Thanks,
-Kame

