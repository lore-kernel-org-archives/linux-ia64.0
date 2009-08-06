From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 06 Aug 2009 02:47:56 +0000
Subject: Re: [Patch 0/7] Implement crashkernel=auto
Message-Id: <m1y6pxr737.fsf@fess.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain>
	<m1eirqtmey.fsf@fess.ebiederm.org>
	<20090805140408.GJ7259@hmsreliant.think-freely.org>
	<m1skg5vpgg.fsf@fess.ebiederm.org> <4A7A3A78.7080200@redhat.com>
In-Reply-To: <4A7A3A78.7080200@redhat.com> (Amerigo Wang's message of "Thu\, 06 Aug 2009 10\:05\:44 +0800")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: Neil Horman <nhorman@redhat.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

Amerigo Wang <amwang@redhat.com> writes:

> Eric W. Biederman wrote:
>> Neil Horman <nhorman@redhat.com> writes:
>>   
>>> You could of
>>> course boot the installer kernel with a crashkernel line pre-selected  suppose,
>>> but then you have to go to the trouble of figuring that allocation size out each
>>> time.  This gives you a nice convienent way to get a reasonable block of memory
>>> without the need to do all that extra work.
>>>     
>>
>> My big concern is that you are moving policy into the kernel, when it isn't at
>> all clear that policy is the right thing to do, and the existing mechanisms give
>> you enough rope to do this all in userspace.
>>   
>
>
> How? This doesn't remove the existing mechanism, just provides a new choice for
> user like me who doesn't know how much memory should be reserved, or who simply
> doesn't want to concern this since he/she has very enough memory.

Having end users not caring is fine.  My problem with this patch is that it
appears that no one is stepping up and taking responsibility for the crahsdump
mechanism, ensuring it will work, ensuring it will work for users.  I see
us solving problems in the wrong place because people are not stepping
up and solving them in the proper place.

To actually use it there are much bigger problems then supplying the size
of the crashdump area.

My personal experience is that to make this work I had to list every kernel
module I needed in the order that they must be loaded, in /etc/kdump.conf
for my filesystem.  I had to modify mkdumprd so that it actually generated
a dump ramdisk, and I think I am forgetting some other manual hack that
I had to use as well.

So if you have to do something manually I think the problem is user space,
and not the kernel.

In general I figure that whoever builds the kernel and initrd should be
responsible for testing and figuring out the amount of memory needed.
The primary kernel has no idea what is going to loaded in there and
as such no real idea how much memory is needed.

>> You also have to build (or at least load) the whole kdump image after
>> the system boots, and configure someplace for this to be saved.
>>
>> What class of problems do you expect to catch with this?
>>   
>
> Again, try to save the user from choosing numbers for "crashkernel=".

The user being kernel developers?  Whoever builds the kernel and initrd
should be responsible for testing and figuring this out.

In a distro context installers etc should be able to setup good defaults
so end users don't have to worry about this.

>> What has me puzzled is that the mkdumprd that ships with fedora isn't
>> usable without patching, and it seems to be steadily getting worse.  
>
> Please explain why it is not usable? The patch won't break the userspace, since
> it modifies the "crashkernel=" command line dynamically.

No the crashdump mechanism is useless because user space is already
broken and unusable.  At least on fedora and I assume by extension
redhat.

Eric
