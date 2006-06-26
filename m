From: Chuck Ebbert <76306.1226@compuserve.com>
Date: Mon, 26 Jun 2006 17:33:03 +0000
Subject: Re: 2.6.17.1 new perfmon code base, libpfm, pfmon available
Message-Id: <200606261336_MC3-1-C384-7981@compuserve.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060621142447.GA29389@frankl.hpl.hp.com>
In-Reply-To: <20060621142447.GA29389@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stephane Eranian <eranian@hpl.hp.com>
Cc: oprofile-list <oprofile-list@lists.sourceforge.net>, perfmon <perfmon@napali.hpl.hp.com>, linux-ia64 <linux-ia64@vger.kernel.org>, perfctr-devel <perfctr-devel@lists.sourceforge.net>, linux-kernel <linux-kernel@vger.kernel.org>

> Also a new version of pfmon, pfmon-3.2-060621, to take advantage of the update in libpfm:
> 
>       - support for 32-bit mode AMD64 processors
>       - updated event name parsing to prepare for separate
>         event unit mask management (Kevin Corry)
>       - fix the detection of unavailable PMC registers. it was causing crashes
>         when used with sampling.
> 
> Note that I have tested 32-bit compiled libpfm,pfmon running on an 64-bit AMD
> perfmon kernel. I have not tested on a 32-bit AMD linux kernel because I don't
> have such setup. I would appreciate any feedback on this.

32-bit works great.  Unfortunately, pfmon is far too limited for serious kernel
monitoring AFAICT.  E.g. you can't select edge counting instead of cycle
counting.  So you can count how many clock cycles were spent with interrupts
disabled but you can't count how many times they were disabled.  That's too bad
because using pfmon is so easy compared to writing a program.

And is someone working on kernel profiling tools that use the perfmon2
infrastructure on i386?  I'd like to see kernel-based profiling that lets
you use something like the existing 'readprofile' to retrieve results.  This
would be a lot better than the current timer-based profiling.

-- 
Chuck
 "You can't read a newspaper if you can't read."  --George W. Bush
