From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 16 Jun 2006 12:48:33 +0000
Subject: Re: FOR REVIEW: New x86-64 vsyscall vgetcpu()
Message-Id: <4492A8A1.5000101@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200606140942.31150.ak@suse.de> <200606161209.25266.ak@suse.de> <44928FB1.5070107@sgi.com> <200606161317.19296.ak@suse.de> <44929CE6.4@sgi.com> <4492A5E4.9050702@bull.net> <4492A6E6.3090805@sgi.com>
In-Reply-To: <4492A6E6.3090805@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Tony Luck <tony.luck@intel.com>, discuss@x86-64.org, linux-kernel@vger.kernel.org, libc-alpha@sourceware.org, vojtech@suse.cz, linux-ia64@vger.kernel.org

Jes Sorensen wrote:
> Zoltan Menyhart wrote:
> 
>>Just to make sure I understand it correctly...
>>Assuming I have allocated per CPU data (numa control, etc.) pointed at by:
> 
> 
> I think you misunderstood - vgetcpu is for userland usage, not within
> the kernel.
> 
> Cheers,
> Jes
> 
I did understand it as a user land stuff.
This is why I want to map the current task structure into the user space.
In user code, we could see the actual value of the "current->thread_info.cpu".
My "#define current ((struct task_struct *) 0x...)" is not the same as
the kernel's one.

Thanks,

Zoltan
