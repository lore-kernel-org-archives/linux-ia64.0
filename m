From: Manfred Spraul <manfred@colorfullife.com>
Date: Tue, 02 Oct 2001 15:46:41 +0000
Subject: [Linux-ia64] Re: deadlock in crashed multithreaded job
Message-Id: <marc-linux-ia64-105590698805291@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805288@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805288@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Erich Focht wrote:
> 
> The question that remains is how to deal with nested locks on the same
> resource that can lead to deadlocks. Is there any (un)written rule that
> one should avoid them in the Linux Kernel? Or are there any approaches to
> deal with them (which are not yet included in the Kernel)?
>

Yes, semaphores and spinlocks are not recursive. There is one exception
for rw spinlocks, they can recurse on read. I'm not aware that there are
any plans to change that.

My patch avoids calling copy_from_user in elf_core_dump, Andrea adds a 
limited recursion support and uses that to prevent the deadlock.
With his patch you can recurse on on down_read() if you pass special
parameters.

But full recursion support is not planned.

--
	Manfred

