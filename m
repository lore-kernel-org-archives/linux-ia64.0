From: Takao Indoh <indou.takao@soft.fujitsu.com>
Date: Mon, 08 Nov 2004 12:14:21 +0000
Subject: Re: [PATCH] make INIT# handler call panic
Message-Id: <8AC4C58C7A7909indou.takao@soft.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1099662943.913.180.camel@clarsen>
In-Reply-To: <1099662943.913.180.camel@clarsen>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

On Fri, 05 Nov 2004 17:57:29 -0500, Cliff Larsen wrote:

>> I don't have an opinion about whether calling panic from
>> init_handler_platform() is the right thing to do or not.
>> Certainly it is a good place for some sort of hook for a
>> debugger and/or crashdump.
>
>My major motivation was to get to a crashdump hook and get 
>to restart, and panic does both, so I chose it.

IIRC, LKCD is invoked by panic_notifier_list in the panic(), so
LKCD may work correctly. But diskdump/netdump may not. They
are called via BUG(). For example, netdump is called from the following
BUG().

NORET_TYPE void panic(const char * fmt, ...)
{
(snipped)
	bust_spinlocks(1);
	va_start(args, fmt);
	vsprintf(buf, fmt, args);
	va_end(args);
	printk(KERN_EMERG "Kernel panic: %s\n",buf);
	if (netdump_func)
		BUG();

Normally BUG() invokes exception handler and dump function is called.
But, I am not sure exception handler is correctly invoked from the INIT
context.


>> My personal preference would be something like this:
>>    1) dump register state (for all CPUs, not just the INIT monarch)
>>       on the console
>>    2) print backtraces (maybe just for currently-running tasks;
>>       currently we do the task on the INIT monarch plus all other
>>       non-running tasks, which is definitely non-optimal)
>>    3) optional debugger/crashdump hook
>>    4) call panic (maybe)
>>    5) optional timeout, then reboot (if not calling panic)
>> 
>> Part 5 would be trivial and probably not *too* controversial.
>> Part 1 is harder but extremely useful, and I think someone (Zoltan?)
>> posted a start.  Part 2 should be simple given part 1.
>
>I'll see what I can do about most of these. Part 1 would be
>difficult since the hardware/firmware we've currently got 
>available makes both processors the monarch on INIT.

Even if crashdump hook is added into the init_handler, dump does not
work correctly because of single INIT stack. Therefore Russ Anderson's
patch which separates INIT stack is also indispensable.

Regards,
Takao Indoh
