From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Tue, 18 Jan 2005 23:34:30 +0000
Subject: Re: pipe performance regression on ia64
Message-Id: <41ED9D06.1070301@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501181741.j0IHfGf30058@unix-os.sc.intel.com> <Pine.LNX.4.58.0501180951050.8178@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0501180951050.8178@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Linus Torvalds wrote:
> 
> On Tue, 18 Jan 2005, Luck, Tony wrote:
> 
>>David Mosberger:
>>
>>>So, when we run bw_pipe on a low load SMP machine, the kernel running in
>>>a way load balancer always trying to spread out 2 processes while the
>>>wake_up_interruptible_sync() is always trying to draw them back into
>>>1 cpu.
>>>
>>>Linus's patch will reduce the change to call wake_up_interruptible_sync()
>>>a lot.
>>>
>>>For bw_pipe writer or reader, the buffer size is 64k.  In a 16k page
>>>kernel. The old kernel will call wake_up_interruptible_sync 4 times but
>>>the new kernel will call wakeup only 1 time.
> 
> 
> Yes, it will depend on the buffer size, and on whether the writer actually 
> does any _work_ to fill it, or just writes it.
> 
> The thing is, in real life, the "wake_up()" tends to be preferable, 
> because even though we are totally synchronized on the pipe semaphore 
> (which is a locking issue in itself that might be worth looking into), 
> most real loads will actually do something to _generate_ the write data in 
> the first place, and thus you actually want to spread the load out over 
> CPU's.
> 
> The lmbench pipe benchmark is kind of special, since the writer literally 
> does nothing but write and the reader does nothing but read, so there is 
> nothing to parallellize.
> 
> The "wake_up_sync()" hack only helps for the special case where we know 
> the writer is going to write more. Of course, we could make the pipe code 
> use that "synchronous" write unconditionally, and benchmarks would look 
> better, but I suspect it would hurt real life.
> 
> The _normal_ use of a pipe, after all, is having a writer that does real
> work to generate the data (like 'cc1'), and a sink that actually does real
> work with it (like 'as'), and having less synchronization is a _good_ 
> thing.
> 
> I don't know how to make the benchmark look repeatable and good, though.  
> The CPU affinity thing may be the right thing.
> 

Regarding scheduler balancing behaviour:

The problem could also be magnified in recent -bk kernels by the
"wake up to an idle CPU" code in sched.c:try_to_wake_up(). To turn
this off, remove SD_WAKE_IDLE from include/linux/topology.h:SD_CPU_INIT
and include/asm/topology.h:SD_NODE_INIT

David I remember you reporting a pipe bandwidth regression, and I had
a patch for it, but that hurt other workloads, so I don't think we
ever really got anywhere. I've recently begun having another look at
the multiprocessor balancer, so hopefully I can get a bit further with
it this time.

