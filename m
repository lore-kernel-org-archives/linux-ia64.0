From: Chase Venters <chase.venters@clientec.com>
Date: Fri, 16 Jun 2006 21:12:05 +0000
Subject: Re: FOR REVIEW: New x86-64 vsyscall vgetcpu()
Message-Id: <Pine.LNX.4.64.0606161607240.23743@turbotaz.ourhouse>
List-Id: <linux-ia64.vger.kernel.org>
References: <200606140942.31150.ak@suse.de> <44929CE6.4@sgi.com>
 <4492A5E4.9050702@bull.net> <200606161656.40930.ak@suse.de> <4492CEC0.2080102@bull.net>
In-Reply-To: <4492CEC0.2080102@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: Andi Kleen <ak@suse.de>, Jes Sorensen <jes@sgi.com>, Tony Luck <tony.luck@intel.com>, discuss@x86-64.org, linux-kernel@vger.kernel.org, libc-alpha@sourceware.org, vojtech@suse.cz, linux-ia64@vger.kernel.org

On Fri, 16 Jun 2006, Zoltan Menyhart wrote:

> Andi Kleen wrote:
>
>>  That is not how user space TLS works. It usually has a base a register.
>
> Can you please give me a real life (simplified) example?
>
>>  This means it cannot be cache colored (because you would need a static
>>  offset) and you couldn't share task_structs on a page.
>
> I do not see the problem. Can you explain please?
> E.g. the scheduler pulls a task instead of the current one. The CPU
> will see "current->thread_info.cpu"-s of all the tasks at the same
> offset anyway.

Memory maps have to fall on page boundaries for lots of various reasons. 
Assuming a 16-word cache line, you've got plenty of spots you could align 
task_struct to within a page. (That number of spots is actually 
constrained by either sizeof(task_struct) or the number of colors).

The bottom line is that task_struct won't always be on a page boundary. If 
it's not on a page boundary in the physical page frames, it's not going to 
be on a page boundary in virtual memory either.

(Note also that if two task_structs shared a page, you'd have an 
information leak. I'm not sure with sizeof(task_struct) and cache 
alignment if task_structs are small enough for sharing, though. Definitely 
on hugepages.)

Thanks,
Chase
