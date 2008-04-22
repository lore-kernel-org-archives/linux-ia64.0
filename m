From: Jes Sorensen <jes@sgi.com>
Date: Tue, 22 Apr 2008 11:30:02 +0000
Subject: Re: [PATCH 04/15] ia64/pv_ops: introduce pv_info which describes
Message-Id: <480DCC3A.1010007@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12077165491881-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12077165491881-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dong, Eddie wrote:
>> Rather than making these binary patches, why not make them fast
>> syscalls and using a vdso page. Some of the priviledged instructions
>> are simply reads and we could have that information in a read-only
>> data page, so there is no need to do a context switch at all. Others
>> could benefit from a fast system call that doesn't do a full context
>> switch. 
> 
> The issue is we don't want to change Linux code a lot, otherwise it
> won't be accepted. If we use same logic with original Linux,
> but it is using indirect function call now, binary patching could help
> in performance.

Hi Eddie,

Sorry but this is a wrong assumption. If the code is correct then there
is no reason why it will not be accepted. It's far more important to
avoid ugly clutter that makes the code hard to maintain.

>> It would be nice if we could come up with a generic implementation for
>> such a vdso style interface that could be shared between
>> xen/kvm/lguest. 
>>
> Introducing a new mechanism to use it to replace Linux code to use them
> is another different story.

If someone starts doing a fast syscall implementation for hypercalls, it
is obvious the person(s) will be asked to make it generic on ia64.
Anything else would be silly, but it would definitely be a good thing to
do.

Cheers,
Jes

