From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 26 Dec 2012 03:47:35 +0000
Subject: Re: [PATCH v5 07/14] memory-hotplug: move pgdat_resize_lock into sparse_remove_one_section()
Message-Id: <50DA7357.109@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-8-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1356350964-13437-8-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

(2012/12/24 21:09), Tang Chen wrote:
> In __remove_section(), we locked pgdat_resize_lock when calling
> sparse_remove_one_section(). This lock will disable irq. But we don't need
> to lock the whole function. If we do some work to free pagetables in
> free_section_usemap(), we need to call flush_tlb_all(), which need
> irq enabled. Otherwise the WARN_ON_ONCE() in smp_call_function_many()
> will be triggered.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>

If this is a bug fix, call-trace in your log and BUGFIX or -fix- in patch title
will be appreciated, I think.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


