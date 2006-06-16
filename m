From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 16 Jun 2006 12:36:52 +0000
Subject: Re: FOR REVIEW: New x86-64 vsyscall vgetcpu()
Message-Id: <4492A5E4.9050702@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200606140942.31150.ak@suse.de> <200606161209.25266.ak@suse.de> <44928FB1.5070107@sgi.com> <200606161317.19296.ak@suse.de> <44929CE6.4@sgi.com>
In-Reply-To: <44929CE6.4@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Tony Luck <tony.luck@intel.com>, discuss@x86-64.org, linux-kernel@vger.kernel.org, libc-alpha@sourceware.org, vojtech@suse.cz, linux-ia64@vger.kernel.org

Just to make sure I understand it correctly...
Assuming I have allocated per CPU data (numa control, etc.) pointed at by:

	void *per_cpu[MAXCPUS];

Assuming a per CPU variable has got an "offset" in each per CPU data area.
Accessing this variable can be done as follows:

	err = vgetcpu(&my_cpu, ...);
	if (err)
		goto ....
	pointer = (typeof pointer) (per_cpu[my_cpu] + offset);
	// use "pointer"...

It is hundred times more long than "__get_per_cpu(var)++".

As we do not know when we can be moved to another CPU,
"vgetcpu()" has to be called again after a "reasonable short" time.

My idea is to map the current task structure at an arch. dependent
virtual address into the user space (obviously in RO).

	#define current	((struct task_struct *) 0x...)

No more need to for "vgetcpu()" at all. The example above becomes:

	pointer = (typeof pointer) (per_cpu[current->thread_info.cpu] + offset);
	// use "pointer"...

As obtaining "pointer" does not cost much, it can be re-calculated at
each usage => no problem to know when to recheck it, there is less chance for
using the data of a neighbor.

Regards,

Zoltan Menyhart
