From: Amerigo Wang <amwang@redhat.com>
Date: Thu, 06 Aug 2009 01:39:17 +0000
Subject: Re: [Patch 0/7] Implement crashkernel=auto
Message-Id: <4A7A3445.60903@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain> <m1eirqtmey.fsf@fess.ebiederm.org>
In-Reply-To: <m1eirqtmey.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

Eric W. Biederman wrote:
> Amerigo Wang <amwang@redhat.com> writes:
>
>   
>> This series of patch implements automatically reserved memory for crashkernel,
>> by introducing a new boot option "crashkernel=auto". This idea is from Neil.
>>
>> In case of breaking user-space applications, it modifies this boot option after
>> it decides how much memory should be reserved.
>>
>> On different arch, the threshold and reserved memory size is different. Please
>> refer patch 7/7 which contains an update for the documentation.
>>
>> Note: This patchset was only tested on x86_64 with differernt memory sizes.
>>     
>
> This seems like a silly hard code. Especially for a feature distros don't
> care enough about to implement a working initrd for.
>
> Has anyone bothered to justify those large amounts of memory?
> Where does the 128M go?
>   

If 128M is too big, we can make it to be 64M, that is no problem.
I am very open to this. :)

> Please pardon me for being a cynic but I don't see the command line option
> being the bottleneck for real users to make this work.
>
>   
Well, take /me as an example, to be honest, I still have no idea how 
much memory I should reserve for s390/sh, if I would use kdump on sh, it 
*is* my bottleneck.

Thanks.


