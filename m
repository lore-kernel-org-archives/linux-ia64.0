From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 09 Jan 2013 22:49:05 +0000
Subject: Re: [PATCH v6 04/15] memory-hotplug: remove /sys/firmware/memmap/X sysfs
Message-Id: <20130109144905.8993886a.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
	<1357723959-5416-5-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1357723959-5416-5-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

On Wed, 9 Jan 2013 17:32:28 +0800
Tang Chen <tangchen@cn.fujitsu.com> wrote:

> When (hot)adding memory into system, /sys/firmware/memmap/X/{end, start, type}
> sysfs files are created. But there is no code to remove these files. The patch
> implements the function to remove them.
> 
> Note: The code does not free firmware_map_entry which is allocated by bootmem.
>       So the patch makes memory leak. But I think the memory leak size is
>       very samll. And it does not affect the system.

Well that's bad.  Can we remember the address of that memory and then
reuse the storage if/when the memory is re-added?  That at least puts an upper
bound on the leak.

