From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 28 Sep 2012 22:15:22 +0000
Subject: Re: [RFC v9 PATCH 01/21] memory-hotplug: rename remove_memory() to offline_memory()/offline_pages()
Message-Id: <CAHGf_=oJ_Jmjqcdr4cPJghf7PX+vfmZe=CV2sdQQhS5agzG15w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com>
 <1346837155-534-2-git-send-email-wency@cn.fujitsu.com> <506509E4.1090000@gmail.com>
 <50651E68.3040208@jp.fujitsu.com>
In-Reply-To: <50651E68.3040208@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Ni zhan Chen <nizhan.chen@gmail.com>, wency@cn.fujitsu.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org

On Thu, Sep 27, 2012 at 11:50 PM, Yasuaki Ishimatsu
<isimatu.yasuaki@jp.fujitsu.com> wrote:
> Hi Chen,
>
>
> 2012/09/28 11:22, Ni zhan Chen wrote:
>>
>> On 09/05/2012 05:25 PM, wency@cn.fujitsu.com wrote:
>>>
>>> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>>
>>> remove_memory() only try to offline pages. It is called in two cases:
>>> 1. hot remove a memory device
>>> 2. echo offline >/sys/devices/system/memory/memoryXX/state
>>>
>>> In the 1st case, we should also change memory block's state, and notify
>>> the userspace that the memory block's state is changed after offlining
>>> pages.
>>>
>>> So rename remove_memory() to offline_memory()/offline_pages(). And in
>>> the 1st case, offline_memory() will be used. The function
>>> offline_memory()
>>> is not implemented. In the 2nd case, offline_pages() will be used.
>>
>>
>> But this time there is not a function associated with add_memory.
>
>
> To associate with add_memory() later, we renamed it.

Then, you introduced bisect breakage. It is definitely unacceptable.

NAK.
