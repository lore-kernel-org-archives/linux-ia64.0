From: "Ross Ridge" <ross@sitraka.com>
Date: Thu, 09 Nov 2000 15:40:32 +0000
Subject: Re: [Linux-ia64] Performance Monitor Internals:
Message-Id: <marc-linux-ia64-105590678205675@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205661@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205661@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I am currently working on the perfmon support for Linux/ia64 as you
may
> have seen for the recent patches.  The goal is to support the entire
set
> of features of the Itanium PMU including EARS and BTB and not just
counting.
> Also support is planned for per process AND system-wide monitoring
on
> both UP and SMP systems.
>
> So I you have any ideas, concerns or want to contribute something,
please
> feel free to contact me.

I'm also interested in using the performance monitor, but my only
concern is if user processes will able to access the performance
counters directly with a "mov 1,PMD[r2]" instruction, instead of
having to use some sort of kernel service to access the counter.
Essentially, all I'm looking for is a replacement for the IA-32's
"RDTSC" instruction in the code I'm porting.

                                          Ross Ridge




