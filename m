From: Amerigo Wang <amwang@redhat.com>
Date: Thu, 06 Aug 2009 09:11:48 +0000
Subject: Re: [Patch 0/7] Implement crashkernel=auto
Message-Id: <4A7A9E54.60705@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain>	<m1eirqtmey.fsf@fess.ebiederm.org>	<20090805140408.GJ7259@hmsreliant.think-freely.org>	<m1skg5vpgg.fsf@fess.ebiederm.org> <4A7A3A78.7080200@redhat.com>	<m1y6pxr737.fsf@fess.ebiederm.org> <4A7A506B.2060008@redhat.com>	<m1ljlxsiox.fsf@fess.ebiederm.org> <4A7A70E5.2010204@redhat.com>	<m1bpmtqxjh.fsf@fess.ebiederm.org> <4A7A7A0F.6070906@redhat.com> <m1iqh1nxv3.fsf@fess.ebiederm.org>
In-Reply-To: <m1iqh1nxv3.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Neil Horman <nhorman@redhat.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>, Andi Kleen <andi@firstfloor.org>

Eric W. Biederman wrote:
> Amerigo Wang <amwang@redhat.com> writes:
>   
>> Yes, exactly, in fact I am doing another part which will allow us to take back
>> of the reserved memory at run-time.
>>     
>
> Alright. Let's look at that.
>
> I would make the restriction you can't resize the area while a kexec
> on panic image is loaded, and growing the area would not be a
> realistic option.
>
>   
Sure, I have no plan to do growing reserved memory at run-time... only 
freeing  or shrinking it...

> If crash_kernel=auto happens in the context of being able to shrink
> the area from user space the definition is simple.  We reserve as much
> memory as we think we can without affecting performance, stability,
> reliability.
>
> We can use an initial approximation of perhaps 1/32nd of low memory
> (aka directly mapped memory), and I don't see a point in making the
> code arch dependent at all.  We should run the size approximation past
> the folks on linux-mm as they are more likely to know how much memory
> reduction we can tolerate without problems.
>
>   

Yup, agreed.

> We can then plan on user space saying hey that is more than I need:
> shrink that, and load the kexec on panic kernel.
>   

Exactly... but the interface still needs to be discussed...

Currently, we have two options:

1) add a new flag to kexec_load(2) to tell the kernel to shrink the memory;
2) use /proc/iomem, let the user to decide which and how much of the 
reserved memory should be removed.

Any thoughts?

Thanks.


