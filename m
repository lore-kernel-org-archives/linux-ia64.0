From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 17 Mar 2008 11:18:43 +0000
Subject: [2.6.25-rc5-mm1][regression] ia64: hackbench doesn't finish >12 hour
Message-Id: <20080317200924.7B4C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com

Hi

I tested following.

 % ./hackbench 130 process 500

 (this parameter mean consume all physical memory and 1G swap space)


2.6.25-rc3-mm1: works well
2.6.25-rc5:     works well
2.6.25-rc5-mm1: doesn't finish >12 hour 

my bisect indicate the cause of bug is git-ia64.patch.
and, git-ia64.patch of 2.6.25-rc5-mm1 contain following patches.

    [IA64] cleanup and improve fsys_gettimeofday
    [IA64] Multiple outstanding ptc.g instruction support
    [IA64] VIRT_CPU_ACCOUNTING (accurate cpu time accounting)


unfortunately, I don't know how investigate more ;-)
Please any suggestion.





