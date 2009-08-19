From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 19 Aug 2009 16:12:34 +0000
Subject: Re: [PATCH] Add minimal support for software performance counters
Message-Id: <20090819161234.GB31058@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <4A8C2290.3040707@redhat.com>
In-Reply-To: <4A8C2290.3040707@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: William Cohen <wcohen@redhat.com>, "Luck, Tony" <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Mackerras <paulus@samba.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>


* William Cohen <wcohen@redhat.com> wrote:

> The following patch adds minimal support for software 
> performance counters for ia64.

Nice!

> For the kernel the patch enables configuration of the 
> perf counter option, adds the perf_counter_open 
> syscall, and includes a minimal machine specific 
> asm/perf.h header file.
> 
> For the perf tool the header perf.h includes an ia64 
> specific section and the options used in the Makefile 
> were adjusted to allow compilation on ia64.  The 
> -Wcast-align gives "cast increases required alignment 
> of target type" warning for the list_for_each_entry() 
> macro. The "-fno-strict-aliasing" was used to avoid 
> warnings for "dereferencing type-punned pointer will 
> break strict-aliasing rules" warnings for sscanf() 
> functions in util/trace-event-parse.c

Tony, Fenghua Yu, this patch already depends on .32 
changes in the perfcounters tree - would be OK to you if 
we merged this patch into the perfcounters tree? Plus 
perhaps merge a syscall placeholder patch into the ia64 
tree?

Thanks,

	Ingo
