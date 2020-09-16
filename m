From: David Hildenbrand <david@redhat.com>
Date: Wed, 16 Sep 2020 07:52:30 +0000
Subject: Re: [PATCH v3 1/3] mm: replace memmap_context by meminit_context
Message-Id: <95005625-b159-0d49-8334-3c6cdbb7f27a@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200915121541.GD4649@dhcp22.suse.cz>
 <20200915132624.9723-1-ldufour@linux.ibm.com>
 <20200916063325.GK142621@kroah.com>
 <0b3f2eb1-0efa-a491-c509-d16a7e18d8e8@linux.ibm.com>
 <20200916074047.GA189144@kroah.com>
 <9e8d38b9-3875-0fd8-5f28-3502f33c2c34@linux.ibm.com>
In-Reply-To: <9e8d38b9-3875-0fd8-5f28-3502f33c2c34@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Laurent Dufour <ldufour@linux.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: akpm@linux-foundation.org, Oscar Salvador <osalvador@suse.de>, mhocko@suse.com, linux-mm@kvack.org, "Rafael J . Wysocki" <rafael@kernel.org>, nathanl@linux.ibm.com, cheloha@linux.ibm.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On 16.09.20 09:47, Laurent Dufour wrote:
> Le 16/09/2020 à 09:40, Greg Kroah-Hartman a écrit :
>> On Wed, Sep 16, 2020 at 09:29:22AM +0200, Laurent Dufour wrote:
>>> Le 16/09/2020 à 08:33, Greg Kroah-Hartman a écrit :
>>>> On Tue, Sep 15, 2020 at 03:26:24PM +0200, Laurent Dufour wrote:
>>>>> The memmap_context enum is used to detect whether a memory operation is due
>>>>> to a hot-add operation or happening at boot time.
>>>>>
>>>>> Make it general to the hotplug operation and rename it as meminit_context.
>>>>>
>>>>> There is no functional change introduced by this patch
>>>>>
>>>>> Suggested-by: David Hildenbrand <david@redhat.com>
>>>>> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
>>>>> ---
>>>>>    arch/ia64/mm/init.c    |  6 +++---
>>>>>    include/linux/mm.h     |  2 +-
>>>>>    include/linux/mmzone.h | 11 ++++++++---
>>>>>    mm/memory_hotplug.c    |  2 +-
>>>>>    mm/page_alloc.c        | 10 +++++-----
>>>>>    5 files changed, 18 insertions(+), 13 deletions(-)
>>>>
>>>> <formletter>
>>>>
>>>> This is not the correct way to submit patches for inclusion in the
>>>> stable kernel tree.  Please read:
>>>>       https://www.kernel.org/doc/html/latest/process/stable-kernel-rules.html
>>>> for how to do this properly.
>>>>
>>>> </formletter>
>>>
>>> Hi Greg,
>>>
>>> I'm sorry, I read that document few days ago before sending the series and
>>> again this morning, but I can't figure out what I missed (following option
>>> 1).
>>>
>>> Should the "Cc: stable@vger.kernel.org" tag be on each patch of the series
>>> even if the whole series has been sent to stable ?
>>
>> That should be on any patch you expect to show up in a stable kernel
>> release.
>>
>>> Should the whole series sent again (v4) instead of sending a fix as a reply to ?
>>
>> It's up to the maintainer what they want, but as it is, this patch is
>> not going to end up in stable kernel release (which it looks like is the
>> right thing to do...)
> 
> Thanks a lot Greg.
> 
> I'll send that single patch again with the Cc: stable tag.

I think Andrew can add that when sending upstream.

While a single patch to fix + backport would be nicer, I don't see an
easy (!ugly) way to achieve the same without this cleanup.

1. We could rework patch #2 to pass a simple boolean flag, and a
follow-on patch to pass the context. Not sure if that's any better.

2. We could rework patch #2 to pass memmap_context first, and modify
patch #1 to also rename this instance.

Maybe 2. might be reasonable (not sure if worth the trouble). @Greg any
preference?

> 
> I don't think the patch 3 need to be backported, it doesn't fix any issue and 
> with the patch 1 and 2 applied, the BUG_ON should no more be triggered easily.

Agreed.


-- 
Thanks,

David / dhildenb
