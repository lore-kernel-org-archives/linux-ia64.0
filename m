From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 06 Aug 2009 06:14:10 +0000
Subject: Re: [Patch 0/7] Implement crashkernel=auto
Message-Id: <m1bpmtqxjh.fsf@fess.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain>
	<m1eirqtmey.fsf@fess.ebiederm.org>
	<20090805140408.GJ7259@hmsreliant.think-freely.org>
	<m1skg5vpgg.fsf@fess.ebiederm.org> <4A7A3A78.7080200@redhat.com>
	<m1y6pxr737.fsf@fess.ebiederm.org> <4A7A506B.2060008@redhat.com>
	<m1ljlxsiox.fsf@fess.ebiederm.org> <4A7A70E5.2010204@redhat.com>
In-Reply-To: <4A7A70E5.2010204@redhat.com> (Amerigo Wang's message of "Thu\, 06 Aug 2009 13\:57\:57 +0800")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: Neil Horman <nhorman@redhat.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

Amerigo Wang <amwang@redhat.com> writes:

> Eric W. Biederman wrote:
>> Amerigo Wang <amwang@redhat.com> writes:
>>
>>   
>>>> No the crashdump mechanism is useless because user space is already
>>>> broken and unusable.
>>>>       
>>> Again, why broken?
>>>     
>>
>> To get a stock stat drive by hand I had to list about 5 kernel modules
>> in the right magic order in /etc/kdump.conf
>>
>> Neither mount by label or mount by uuid when specified in /etc/kdump.conf
>> I had to hack mkdumprd to get an initrd that even finds the proper disk
>> to mount.
>>   
>
> You are saying that there is some difficulty to make a initrd for kdump, but I
> am sorry that I can't see any relations between this and my patch. What is your
> point here?

You are trying to make it easier for end users.

I am saying the problem is in user space.

I am saying also that the kernel doesn't have a clue what you are
going to load with kexec on panic to handle panics.  Maybe it is a
custom stand alone binary that only needs 5K.  So the kernel doesn't
have a clue what the right size to reserve.

I think if what you were proposing was part of some coherent story for
a complete implementation I would consider it more.  Instead this just
appears to be a reaction to how frustrating the user space
implementation is, and fixing things in the kernel instead of in user
space.

The fact that user space is broken to the point of usability on fedora
simply reinforces the point to me that the problem is there not in the
kernel.  So I am pushing back and saying get your user space act together
and then this kernel option won't matter.

I am further saying that this selecting how much memory to use is the least
of your problems.

Eric
