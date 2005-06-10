From: Christoph Lameter <christoph@lameter.com>
Date: Fri, 10 Jun 2005 15:11:42 +0000
Subject: Re: [RFD] Separating struct task and the kernel stacks
Message-Id: <Pine.LNX.4.62.0506100807180.9151@graphe.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <9712.1118384111@kao2.melbourne.sgi.com>
In-Reply-To: <9712.1118384111@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 10 Jun 2005, Keith Owens wrote:

> I have the MCA/INIT per cpu stack code to the point where I can
> reliably enter mca.c using an MCA/INIT stack that is different from the
> normal kernel stack.  However these separate stacks are now getting
> problems because struct task is embedded in the kernel stack.

How frequent are these MCA events?

> Switching stacks requires that struct task is copied from the original
> "current" to the MCA/INIT stack, then change current to point to the
> new stack.  Even that is not enough, there are still places that are
> using the old value of "current".  The main problem is the scheduler,
> it tracks tasks by the address of their struct task, not by the kernel
> stack address.  When debugging an MCA/INIT, the mismatch between the
> new value of current and the old task addresses in various structures
> can lead to some very confusing results.  The kernel is not designed to
> have struct task move around on the fly.

Could you just move the stack? Put a pointer to the stack in task_info. By 
default this is pointing to the stack in task_info. If you have to switch
point it elsewhere.
 
> i386 handles multiple kernel stacks by moving struct task to a slab
> allocator and leaving just struct thread_info in the stack.  Switching
> a process from one kernel stack to another does not require any changes
> to current nor to any task pointers.  Just copy thread_info from the
> old to the new stack, add a back pointer to the previous stack and
> continue processing.

Using the slab allocator generates a certain amount of overhead during 
process creation. I believe the page allocator would be faster. Also there 
needs to be no separate allocation of memory for the stack.

> I can continue trying to handle the MCA/INIT stacks with various
> kludges in ia64 and common code, but it is not nice.  Separating struct
> task from the kernel stack is a lot cleaner.  Before I go too far down
> this path, are there any violent objections to moving struct task out
> of the kernel stack?

I would suggest just to add a pointer so that the stack does not have to 
be in the page we allocate.

> This change would remove the last vestige of
> __HAVE_ARCH_TASK_STRUCT_ALLOCATOR from the kernel.  Only ia64 defines
> that symbol, every other architecture uses separate struct tasks.

I know of an architecture that is planning to switch to do the same as 
ia64 does now in order to increase the efficiency of task creation.
