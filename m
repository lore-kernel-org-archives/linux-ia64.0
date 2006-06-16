From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 16 Jun 2006 15:31:12 +0000
Subject: Re: FOR REVIEW: New x86-64 vsyscall vgetcpu()
Message-Id: <4492CEC0.2080102@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200606140942.31150.ak@suse.de> <44929CE6.4@sgi.com> <4492A5E4.9050702@bull.net> <200606161656.40930.ak@suse.de>
In-Reply-To: <200606161656.40930.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Jes Sorensen <jes@sgi.com>, Tony Luck <tony.luck@intel.com>, discuss@x86-64.org, linux-kernel@vger.kernel.org, libc-alpha@sourceware.org, vojtech@suse.cz, linux-ia64@vger.kernel.org

Andi Kleen wrote:

> That is not how user space TLS works. It usually has a base a register.

Can you please give me a real life (simplified) example?

> This means it cannot be cache colored (because you would need a static
> offset) and you couldn't share task_structs on a page.

I do not see the problem. Can you explain please?
E.g. the scheduler pulls a task instead of the current one. The CPU
will see "current->thread_info.cpu"-s of all the tasks at the same
offset anyway.

> Also you would make task_struct part of the userland ABI which
> seems like a very very bad idea to me. It means we couldn't change
> it anymore.

We can make some wrapper, e.g.:

	user_per_cpu_var(name, offset)

"vgetcpu()" would also be added to the ABI which we couldn't change
easily either.

Thanks,

Zoltan
