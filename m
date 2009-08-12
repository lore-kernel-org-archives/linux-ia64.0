From: Amerigo Wang <amwang@redhat.com>
Date: Wed, 12 Aug 2009 01:17:32 +0000
Subject: Re: [RFC Patch 1/2] kexec: show memory info in /proc/iomem
Message-Id: <4A82182C.1080501@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090811104144.5154.77871.sendpatchset@localhost.localdomain> <m163cub067.fsf@fess.ebiederm.org>
In-Reply-To: <m163cub067.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>

Eric W. Biederman wrote:
> Amerigo Wang <amwang@redhat.com> writes:
>
>   
>> This patch implements showing kexec memory area via /proc/iomem.
>> For example, with this patch we can see:
>>
>> # cat /proc/iomem
>> ...
>> 00100000-7ffeffff : System RAM
>>   01000000-012e1424 : Kernel code
>>   012e1425-015f1aff : Kernel data
>>   0166b000-01b4b88f : Kernel bss
>>   02000000-083fffff : Crash kernel
>>     02000000-028fffff : Used
>>     02900000-083fffff : Unused
>> ...
>>
>> So that user can know how much memory the kernel uses for crash kernel.
>>     
>
> Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>
>
> We can inspect the image we are going to load to get this information.
> In fact /sbin/kexec already inspects the image we are going to load
> to get this information.  Putting this in the kernel adds kernel
> complexity for no gain.
>   

/sbin/kexec is supported to know this, of course. But this is not for 
/sbin/kexec, this is for user (or other programs) to observe the memory 
information, so that he can know the memory he reserved is too much or not.

Without this, it is a little hard to use patch 2/2.

