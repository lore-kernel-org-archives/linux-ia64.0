From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Fri, 11 Sep 2020 16:27:41 +0000
Subject: Re: [PATCH 3/3] mm: don't panic when links can't be created in sysfs
Message-Id: <3713153c-d239-e6f9-fc1a-a3e4357ee069@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200911134831.53258-1-ldufour@linux.ibm.com>
 <20200911134831.53258-4-ldufour@linux.ibm.com>
 <20200911140100.GA3812164@kroah.com>
In-Reply-To: <20200911140100.GA3812164@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: akpm@linux-foundation.org, David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>, mhocko@kernel.org, linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Le 11/09/2020 à 16:01, Greg Kroah-Hartman a écrit :
> On Fri, Sep 11, 2020 at 03:48:31PM +0200, Laurent Dufour wrote:
>> At boot time, or when doing memory hot-add operations, if the links in
>> sysfs can't be created, the system is still able to run, so just report the
>> error in the kernel log.
>>
>> Since the number of memory blocks managed could be high, the messages are
>> rate limited.
>>
>> As a consequence, link_mem_sections() has no status to report anymore.
>>
>> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
>> Cc: David Hildenbrand <david@redhat.com>
>> ---
>>   drivers/base/node.c  | 25 +++++++++++++++++--------
>>   include/linux/node.h | 17 ++++++++---------
>>   mm/memory_hotplug.c  |  5 ++---
>>   3 files changed, 27 insertions(+), 20 deletions(-)
>>
>> diff --git a/drivers/base/node.c b/drivers/base/node.c
>> index 862516c5a5ae..749a1c8ea992 100644
>> --- a/drivers/base/node.c
>> +++ b/drivers/base/node.c
>> @@ -811,12 +811,21 @@ static int register_mem_sect_under_node(struct memory_block *mem_blk,
>>   		ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
>>   					&mem_blk->dev.kobj,
>>   					kobject_name(&mem_blk->dev.kobj));
>> -		if (ret)
>> -			return ret;
>> +		if (ret && ret != -EEXIST)
>> +			pr_err_ratelimited(
>> +				"can't create %s to %s link in sysfs (%d)\n",
>> +				kobject_name(&node_devices[nid]->dev.kobj),
>> +				kobject_name(&mem_blk->dev.kobj), ret);
> 
> dev_err_ratelimited()?

Thanks Greg, I was not aware about this.

> Same elsewhere in this patch.
> 
> thanks,
> 
> greg k-h
> 
