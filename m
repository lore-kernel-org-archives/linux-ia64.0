From: John Levon <levon@movementarian.org>
Date: Wed, 08 Oct 2003 19:46:49 +0000
Subject: Re: OProfile vs. Perfmon
Message-Id: <marc-linux-ia64-106564249926532@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106556940523002@msgid-missing>
In-Reply-To: <marc-linux-ia64-106556940523002@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 08, 2003 at 10:40:30AM -0700, Stephane Eranian wrote:

> Again, different tools have different goals. The important point
> is that I believe we can provide that kind of flexibility while still using 
> a single kernel interface.

Absolutely agreed, it is not sensible to have multiple interfaces to the
same thing, and flexibility in the type of performance counting is
important.

> If you looked at the default format (perfmon_default_smpl.c), you see how this 
> can be implemented.  As for buffer management, again, perfmon-2 gives you a 
> choice. You can have perfmon-2 allocates and remap the buffer into the address 
> space of the tool OR you can do this yourself, i.e., allocate you own buffer 
> AND export it in ANY WAY you want.

Sounds great.

> The idea is that the user space tools would go through the perfmonctl() system
> call to setup the counters for a system-wide session. You do NOT need to use
> pfmlib if you already have your own libary to handle the IA-64 events and
> their encodings. In fact, the upcoming version 3.0 of the libpfm library is 
> TOTALLY disconnected from the kernel interface. In any case, Keep in mind 
> that the library DOES NOT call perfmonctl(), it is just here to help you 
> figure out what values to program into the PMC registers given what you want to
> measure.

We do have our own stuff but it would certainly make sense for us to use
pfmlib for the allocation/setup.

> The tool simply needs to fork/pthread_create a worker task for each CPU
> it wants to measure on and it must pinned the task. The system-wide perfmon 
> context will be bound to the CPU is was created on. The creator task can 
> later migrate to other CPUs, but the context can only be accessed from tasks 
> running on its CPU. I realize that this is not the model you have chosen, but
> I believe you can fairly easily hide the difference into some small library.

OK, thanks for clarifying. It's certainly not much code to fork off N
tasks and pin them to each CPU before calling the stuff to create a
context.

I'll get hacking :)

thanks,
john

-- 
Khendon's Law:
If the same point is made twice by the same person, the thread is over.
