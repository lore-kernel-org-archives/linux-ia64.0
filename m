From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Wed, 30 Jan 2002 06:21:53 +0000
Subject: Re: [Linux-ia64] What's taking all the system time..?
Message-Id: <marc-linux-ia64-105590698805951@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805950@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805950@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Duraid,

> 
> 	I've got a big (production) code that depends on a simple 'graph'
> library in C++. To try it out on Itanium, I stripped it down and whipped up
> a tiny 'benchmark' of the graph library. When I tried this on an Itanium
> system here (2.4.9-SMP, gcc/g++ 2.96/3.0.3 and intel c++ 6.0) the code runs
> for about 30 seconds, 20 of which is reported as 'system' time. The thing
> is, this is (supposed to be) a CPU-bound job: on my home x86 system, it runs
> in about 3 seconds, and with negligible system time.
> 
> 	'top' and 'time' show the gobs of system time being used, but
> 'strace' picks up nothing out of the ordinary (0.014 seconds system time,
> dominated by calls to brk() (this is expected).
> 
Just by curiosity, have you looked at the system log in /var/log/messages?
I am guessing your program does some floating point operations.
Have you seen something about floating-point software assist? Another 
potential cause could be unaligned accesses. That you can also see 
in the system log.

-- 
-Stephane

