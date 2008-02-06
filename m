From: Robin Holt <holt@sgi.com>
Date: Wed, 06 Feb 2008 10:44:39 +0000
Subject: Re: [patch] Fix large MCA bootmem allocation
Message-Id: <20080206104438.GE3875@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080205193232.GA8834@sgi.com>
In-Reply-To: <20080205193232.GA8834@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 06, 2008 at 12:50:11PM +0900, Hidetoshi Seto wrote:
> Hidetoshi Seto wrote:
>> Then, I suppose we need a CPU_UP_PREPARE callback to allocate memory
>> before hot-added CPU enters cpu_init().
>
> Ah, we cannot allocate bootmem later, so it would be better to make
> the callback to return NOTIFY_BAD if (!__per_cpu_mca[hcpu]).
>

bootmem is only used for the first cpu.  The other cpus use regular
allocations.  So we should be able to do a CPU_UP_PREPARE.

Comparing the severity of allocating a ton of extra memory with the
chance that we fail on an allocation and given that there are likely
other things in the cpu_init path which are not checked, do you see the
lack of check as a show-stopper for this patch or would you accept this
patch with the plan being fixup the cpu_init path later?

Thanks,
Robin
