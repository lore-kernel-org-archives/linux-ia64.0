From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 12 Aug 2009 01:51:52 +0000
Subject: Re: [RFC Patch 1/2] kexec: show memory info in /proc/iomem
Message-Id: <m1eirhlryf.fsf@fess.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090811104144.5154.77871.sendpatchset@localhost.localdomain>
	<m163cub067.fsf@fess.ebiederm.org> <4A82182C.1080501@redhat.com>
In-Reply-To: <4A82182C.1080501@redhat.com> (Amerigo Wang's message of "Wed\, 12 Aug 2009 09\:17\:32 +0800")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>

Amerigo Wang <amwang@redhat.com> writes:

>> Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>
>>
>> We can inspect the image we are going to load to get this information.
>> In fact /sbin/kexec already inspects the image we are going to load
>> to get this information.  Putting this in the kernel adds kernel
>> complexity for no gain.
>>   
>
> /sbin/kexec is supported to know this, of course. But this is not for
> /sbin/kexec, this is for user (or other programs) to observe the memory
> information, so that he can know the memory he reserved is too much or not.

> Without this, it is a little hard to use patch 2/2.

So add on option to /sbin/kexec.

Furthermore none of this does a good job of predicting how much
memory /sbin/fsck will require to check the filesystem before we
write a crash dump.

The only way I know of reliably obtaining that kind of information is
testing your crash userspace with different amounts of memory and
understanding what is going on.

Eric
