From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 28 Oct 2009 16:58:37 +0000
Subject: RE: [PATCH -next] ia64/sn: fix percpu warnings
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3E34C018B@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091014163445.f0441473.sfr@canb.auug.org.au>
	 <20091014151003.0ef42973.randy.dunlap@oracle.com>
	 <4AD67C05.2030201@kernel.org>
 <12c511ca0910261124p64f2ad5emc88d00b9957482b3@mail.gmail.com>
 <57C9024A16AD2D4C97DC78E552063EA3E345953E@orsmsx505.amr.corp.intel.com>
 <4AE85D28.90809@kernel.org>
 <57C9024A16AD2D4C97DC78E552063EA3E34C0108@orsmsx505.amr.corp.intel.com>
 <4AE87344.6030708@kernel.org>
In-Reply-To: <4AE87344.6030708@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tejun Heo <tj@kernel.org>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, akpm <akpm@linux-foundation.org>

> DEFINE_PER_CPU(struct list_head [NR_SOFTIRQS], softirq_work_list);
> EXPORT_PER_CPU_SYMBOL(softirq_work_list);
>
> and it doesn't cause any warning on x86 neither does it on ia64 with
> defconfig.  softirq_work_list doesn't trigger any warning there,
> right?

Of the 10 EXPORT_PER_CPU_SYMBOL and 4 EXPORT_PER_CPU_SYMBOL_GPL
items on ia64, only __sn_cnodeid_to_nasid and softirq_work_list are
arrays.  The latter appears not to be actually used by any in-tree
modules (janitors: does it need to be exported?).

The CRC warning only shows up on a module that uses an exported
per-cpu array.  There seems to be nothing special about the
__sn_cnodeid_to_nasid.  When I hacked a module to make a random
use of softirq_work_list, it too gave a CRC error.

I just tried an x86_64 build with a module also modified to access
softirq_work_list.  It did NOT get a CRC error.  So the x86_64
toolchain doesn't seem to have the same issue as ia64.

-Tony
