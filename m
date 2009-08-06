From: Amerigo Wang <amwang@redhat.com>
Date: Thu, 06 Aug 2009 02:05:44 +0000
Subject: Re: [Patch 0/7] Implement crashkernel=auto
Message-Id: <4A7A3A78.7080200@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain>	<m1eirqtmey.fsf@fess.ebiederm.org>	<20090805140408.GJ7259@hmsreliant.think-freely.org> <m1skg5vpgg.fsf@fess.ebiederm.org>
In-Reply-To: <m1skg5vpgg.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Neil Horman <nhorman@redhat.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

Eric W. Biederman wrote:
> Neil Horman <nhorman@redhat.com> writes:
>   
>> You could of
>> course boot the installer kernel with a crashkernel line pre-selected  suppose,
>> but then you have to go to the trouble of figuring that allocation size out each
>> time.  This gives you a nice convienent way to get a reasonable block of memory
>> without the need to do all that extra work.
>>     
>
> My big concern is that you are moving policy into the kernel, when it isn't at
> all clear that policy is the right thing to do, and the existing mechanisms give
> you enough rope to do this all in userspace.
>   


How? This doesn't remove the existing mechanism, just provides a new 
choice for user like me who doesn't know how much memory should be 
reserved, or who simply doesn't want to concern this since he/she has 
very enough memory.

> You also have to build (or at least load) the whole kdump image after
> the system boots, and configure someplace for this to be saved.
>
> What class of problems do you expect to catch with this?
>   

Again, try to save the user from choosing numbers for "crashkernel=".
> What has me puzzled is that the mkdumprd that ships with fedora isn't
> usable without patching, and it seems to be steadily getting worse.  

Please explain why it is not usable? The patch won't break the 
userspace, since it modifies the "crashkernel=" command line dynamically.

Thanks.

