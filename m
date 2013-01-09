From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 09 Jan 2013 22:50:31 +0000
Subject: Re: [PATCH v6 05/15] memory-hotplug: introduce new function arch_remove_memory() for removing page t
Message-Id: <20130109145031.210505d0.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
	<1357723959-5416-6-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1357723959-5416-6-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

On Wed, 9 Jan 2013 17:32:29 +0800
Tang Chen <tangchen@cn.fujitsu.com> wrote:

> For removing memory, we need to remove page table. But it depends
> on architecture. So the patch introduce arch_remove_memory() for
> removing page table. Now it only calls __remove_pages().
> 
> Note: __remove_pages() for some archtecuture is not implemented
>       (I don't know how to implement it for s390).

Can this break the build for s390?


