From: Tang Chen <tangchen@cn.fujitsu.com>
Date: Thu, 10 Jan 2013 06:15:04 +0000
Subject: Re: [PATCH v6 04/15] memory-hotplug: remove /sys/firmware/memmap/X sysfs
Message-Id: <50EE5C68.4030402@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com> <1357723959-5416-5-git-send-email-tangchen@cn.fujitsu.com> <20130109151920.fb9b4029.akpm@linux-foundation.org>
In-Reply-To: <20130109151920.fb9b4029.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

Hi Andrew,

On 01/10/2013 07:19 AM, Andrew Morton wrote:
>> ...
>>
>> +	entry = firmware_map_find_entry(start, end - 1, type);
>> +	if (!entry)
>> +		return -EINVAL;
>> +
>> +	firmware_map_remove_entry(entry);
>>
>> ...
>>
>
> The above code looks racy.  After firmware_map_find_entry() does the
> spin_unlock() there is nothing to prevent a concurrent
> firmware_map_remove_entry() from removing the entry, so the kernel ends
> up calling firmware_map_remove_entry() twice against the same entry.
>
> An easy fix for this is to hold the spinlock across the entire
> lookup/remove operation.
>
>
> This problem is inherent to firmware_map_find_entry() as you have
> implemented it, so this function simply should not exist in the current
> form - no caller can use it without being buggy!  A simple fix for this
> is to remove the spin_lock()/spin_unlock() from
> firmware_map_find_entry() and add locking documentation to
> firmware_map_find_entry(), explaining that the caller must hold
> map_entries_lock and must not release that lock until processing of
> firmware_map_find_entry()'s return value has completed.

Thank you for your advice, I'll fix it soon.

Since you have merged the patch-set, do I need to resend all these
patches again, or just send a patch to fix it based on the current
one ?

Thanks. :)

>

