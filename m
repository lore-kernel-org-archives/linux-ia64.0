From: Takao Indoh <indou.takao@soft.fujitsu.com>
Date: Thu, 11 Nov 2004 00:55:16 +0000
Subject: Re: [PATCH] make INIT# handler call panic
Message-Id: <8FC4C7891B9A9Dindou.takao@soft.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1099662943.913.180.camel@clarsen>
In-Reply-To: <1099662943.913.180.camel@clarsen>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 10 Nov 2004 10:53:38 -0500, Philip R Auld wrote:

>> Normally BUG() invokes exception handler and dump function is called.
>> But, I am not sure exception handler is correctly invoked from the INIT
>> context.
>
>This doesn't currently do much in ia64 as far as I can tell. It ends up 
>in die via die_if_kernel, but that doesn't look like it will ever get to a 
>machine restart, much less a crash dump or even a for(;;) loop. I may be 
>missing something though. I'm pretty new to Itanium. 
>
>In i386 there is panic_on_oops in die which can at least get to the 
>panic call chain (as there used to be in ia64).
>
>None of the dump stuff is in the stock kernels yet is it?

There is not dump stuff. 


>> >> My personal preference would be something like this:
>> >>    1) dump register state (for all CPUs, not just the INIT monarch)
>> >>       on the console
>> >>    2) print backtraces (maybe just for currently-running tasks;
>> >>       currently we do the task on the INIT monarch plus all other
>> >>       non-running tasks, which is definitely non-optimal)
>> >>    3) optional debugger/crashdump hook
>> >>    4) call panic (maybe)
>> >>    5) optional timeout, then reboot (if not calling panic)
>> >> 
>> >> Part 5 would be trivial and probably not *too* controversial.
>> >> Part 1 is harder but extremely useful, and I think someone (Zoltan?)
>> >> posted a start.  Part 2 should be simple given part 1.
>> >
>> >I'll see what I can do about most of these. Part 1 would be
>> >difficult since the hardware/firmware we've currently got 
>> >available makes both processors the monarch on INIT.
>> 
>> Even if crashdump hook is added into the init_handler, dump does not
>> work correctly because of single INIT stack. Therefore Russ Anderson's
>> patch which separates INIT stack is also indispensable.
>> 
>
>We are still mostly a working with 2.4 (rhel3 which has netdump_func hooks) 
>and this all worked fine. A crashdump hook, a call to panic, or a call 
>to BUG each worked.

Crashdump itself succeeds, but isn't there any problem in analyzing
dump? Backtrace of "current" on each cpu seem to not work because
switch_stack is not saved correctly.


Regards,
Takao Indoh
