From: Andi Kleen <ak@suse.de>
Date: Fri, 16 Jun 2006 14:56:40 +0000
Subject: Re: FOR REVIEW: New x86-64 vsyscall vgetcpu()
Message-Id: <200606161656.40930.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200606140942.31150.ak@suse.de> <44929CE6.4@sgi.com> <4492A5E4.9050702@bull.net>
In-Reply-To: <4492A5E4.9050702@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: Jes Sorensen <jes@sgi.com>, Tony Luck <tony.luck@intel.com>, discuss@x86-64.org, linux-kernel@vger.kernel.org, libc-alpha@sourceware.org, vojtech@suse.cz, linux-ia64@vger.kernel.org

On Friday 16 June 2006 14:36, Zoltan Menyhart wrote:
> Just to make sure I understand it correctly...
> Assuming I have allocated per CPU data (numa control, etc.) pointed at by:
> 
> 	void *per_cpu[MAXCPUS];


That is not how user space TLS works. It usually has a base a register.

> 
> Assuming a per CPU variable has got an "offset" in each per CPU data area.
> Accessing this variable can be done as follows:
> 
> 	err = vgetcpu(&my_cpu, ...);
> 	if (err)
> 		goto ....
> 	pointer = (typeof pointer) (per_cpu[my_cpu] + offset);
> 	// use "pointer"...
> 
> It is hundred times more long than "__get_per_cpu(var)++".

14 cycles is not a 100 times longer.

> My idea is to map the current task structure at an arch. dependent
> virtual address into the user space (obviously in RO).
> 
> 	#define current	((struct task_struct *) 0x...)

This means it cannot be cache colored (because you would need a static
offset) and you couldn't share task_structs on a page.

Also you would make task_struct part of the userland ABI which
seems like a very very bad idea to me. It means we couldn't change
it anymore.

-Andi
