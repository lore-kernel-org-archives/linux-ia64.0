From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Mon, 30 Jul 2007 14:30:50 +0000
Subject: Re: [PATCH] flush icache before set_pte() take 5.
Message-Id: <46ADF61A.6000509@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070728150319.d19f531f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070728150319.d19f531f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>

KAMEZAWA Hiroyuki wrote:

> Considerations:
>   - I can add CONFIG_MONTECITO if necessary. But it will be confusing, I think.

What about this trick below?

identify_cpu() finds out the "c->family".
If any of the CPUs has c->family=32 (and the future versions...) then
set a global flag. And:

static inline void sync_icache_dcache(pte_t pte) {
        if (pte_exec(pte) && global_flag)
                __sync_icache_dcache(pte);
}

Thanks,

Zoltan
