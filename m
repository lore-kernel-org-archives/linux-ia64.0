From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 10 Jan 2013 08:39:54 +0000
Subject: Re: [PATCH v6 00/15] memory-hotplug: hot-remove physical memory
Message-Id: <50EE7E5A.9090402@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com> <20130109142314.1ce04a96.akpm@linux-foundation.org> <50EE24A4.8020601@cn.fujitsu.com> <50EE6A48.7060307@parallels.com> <50EE6E50.3040609@jp.fujitsu.com> <50EE73DE.30208@parallels.com> <50EE7A6B.7020005@jp.fujitsu.com> <50EE7D75.8080100@parallels.com>
In-Reply-To: <50EE7D75.8080100@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Glauber Costa <glommer@parallels.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

(2013/01/10 17:36), Glauber Costa wrote:
  
>> BTW, shrink_slab() is now node/zone aware ? If not, fixing that first will
>> be better direction I guess.
>>
> It is not upstream, but there are patches for this that I am already
> using in my private tree.
>

Oh, I see. If it's merged, it's worth add "shrink_slab() if ZONE_NORMAL"
code.

Thanks,
-Kame

