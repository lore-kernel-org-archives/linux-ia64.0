From: Jes Sorensen <jes@trained-monkey.org>
Date: Thu, 06 Nov 2003 20:11:48 +0000
Subject: Re: [DMESG] cpumask_t in action
Message-Id: <marc-linux-ia64-106814962918778@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106807117402763@msgid-missing>
In-Reply-To: <marc-linux-ia64-106807117402763@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Matthew" = Matthew Wilcox <willy@debian.org> writes:

Matthew> On Wed, Nov 05, 2003 at 02:22:02PM -0800, Jesse Barnes wrote:

Matthew> There's a number of things here that annoy me.  One is the
Matthew> stupid "Processor 8192/1 is spinning up".  I would expect
Matthew> "Processor 2/96 is spinning up", but why have this line at
Matthew> all?  I'd also like to see "Bringing up 3", "Processor 1 has
Matthew> spun up..." and "CPU 1 IS NOW UP!" go away.  That'd cut us
Matthew> down to:

>> CPU 3: 61 virtual and 50 physical address bits CPU 3: nasid 2,
>> slice 2, cnode 1 CPU 3: base freq 0.000MHz, ITC ratio/2, ITC
>> freq00.000MHz+/--1ppm Calibrating delay loop... 2241.08 BogoMIPS
>> CPU3: CPU has booted.  Starting migration thread for cpu 3

Matthew> A 40% reduction in per-cpu verbosity ;-)

Why not turn it the other way and just report the success of booted
CPUs and more detailed results for the CPUs that failed? I know there
are cases where you want the debug info in case of tracking kernel
bugs, but one could stick a compile time debug flag into the code for
that case, 960 - 40% = 576 lines of guff is still way too much IMHO,
especially over a serial console.

Cheers,
Jes
