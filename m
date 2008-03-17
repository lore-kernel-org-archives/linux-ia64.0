From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 17 Mar 2008 11:51:54 +0000
Subject: Re: [2.6.25-rc5-mm1][regression] ia64: hackbench doesn't finish >12 hour
Message-Id: <20080317204810.7B4F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080317200924.7B4C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080317200924.7B4C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

Hi Tony-san,

seto-san teach me method of more investigate.
and I found the root cause is contained by following patch.

   [IA64] Multiple outstanding ptc.g instruction support


Could you please revert that patch from ia64?
I dislike its strong regression.

- kosaki

>     [IA64] cleanup and improve fsys_gettimeofday
>     [IA64] Multiple outstanding ptc.g instruction support
>     [IA64] VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
> 
> unfortunately, I don't know how investigate more ;-)
> Please any suggestion.



