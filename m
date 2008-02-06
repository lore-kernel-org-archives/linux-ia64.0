From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 06 Feb 2008 12:39:42 +0000
Subject: Re: [patch] Fix large MCA bootmem allocation
Message-Id: <47A9AA8E.2010604@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080205193232.GA8834@sgi.com>
In-Reply-To: <20080205193232.GA8834@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote:
> On Wed, Feb 06, 2008 at 12:50:11PM +0900, Hidetoshi Seto wrote:
>> Hidetoshi Seto wrote:
>>> Then, I suppose we need a CPU_UP_PREPARE callback to allocate memory
>>> before hot-added CPU enters cpu_init().
>> Ah, we cannot allocate bootmem later, so it would be better to make
>> the callback to return NOTIFY_BAD if (!__per_cpu_mca[hcpu]).
> 
> bootmem is only used for the first cpu.  The other cpus use regular
> allocations.  So we should be able to do a CPU_UP_PREPARE.

OK, it's my suggestion.

> Comparing the severity of allocating a ton of extra memory with the
> chance that we fail on an allocation and given that there are likely
> other things in the cpu_init path which are not checked, do you see the
> lack of check as a show-stopper for this patch or would you accept this
> patch with the plan being fixup the cpu_init path later?

Which other stuff in the cpu_init path would cause a panic on hot-added CPU?
The per-cpu pages are ready for NR_CPUS. ia64_setreg(), ia64_set_kr() and
kin would be work properly...

I'm afraid that for hot-added CPU there might be nothing dangerous than
this allocation in the path.
That's why I want to hire a CPU_UP_PREPARE at least for this allocation.

Thanks,
H.Seto

