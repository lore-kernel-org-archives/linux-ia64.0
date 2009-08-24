From: Amerigo Wang <amwang@redhat.com>
Date: Mon, 24 Aug 2009 01:36:42 +0000
Subject: Re: [Patch 1/8] kexec: allow to shrink reserved memory
Message-Id: <4A91EEAA.4070200@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090821065637.4855.32234.sendpatchset@localhost.localdomain>	<20090821065650.4855.53279.sendpatchset@localhost.localdomain> <20090821171738.304fe91e.akpm@linux-foundation.org>
In-Reply-To: <20090821171738.304fe91e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, nhorman@redhat.com, ebiederm@xmission.com, andi@firstfloor.org, mingo@elte.hu, bernhard.walle@gmx.de, fenghua.yu@intel.com, kamezawa.hiroyu@jp.fujitsu.com, avorontsov@ru.mvista.com

Andrew Morton wrote:
> On Fri, 21 Aug 2009 02:54:25 -0400
> Amerigo Wang <amwang@redhat.com> wrote:
>
>   
>> +size_t get_crash_memory_size(void)
>> +int shrink_crash_memory(unsigned long new_size)
>>     
>
> These aren't particualrly well-chosen global identifiers.  It would be
> better if they were called crash_*() or kexec_*(), to make it clear
> which subsystem they belong to.
>
>   

Ah, good poi nt!

How about crash_get_memory_size() and crash_shrink_memory()?

Thanks!



