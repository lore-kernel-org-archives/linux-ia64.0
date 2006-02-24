From: Christian Hildner <christian.hildner@hob.de>
Date: Fri, 24 Feb 2006 10:08:00 +0000
Subject: Re: [patch 1/2] remove per-cpu ia64_phys_stacked_size_p8
Message-Id: <43FEDB00.2090407@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602240233.k1O2Xeg05945@unix-os.sc.intel.com>
In-Reply-To: <200602240233.k1O2Xeg05945@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kenneth,

self-modifing code isn't the straight forward way of programming. So 
wouldn't it be an idea to let the code crash instead of silently work 
with a potentially wrong number of registers here, if by any reason the 
patch mechanism doesn't work. I suppose the usage of a break instruction 
(with non_syscall number) to indicate failing/missing patch here. That 
would add another level of security here.

Christian

Chen, Kenneth W schrieb:

>It's not efficient to use a per-cpu variable just to store
>how many physical stack register a cpu has.  Ever since the
>incarnation of ia64 up till upcoming Montecito processor, that
>variable has "glued" to 96. Having a variable in memory means
>that the kernel is burning an extra cacheline access on every
>syscall and kernel exit path.  Such "static" value is better
>served with the instruction patching utility exists today.
>Convert ia64_phys_stacked_size_p8 into dynamic insn patching.
>
>This also has a pleasant side effect of eliminating access to
>per-cpu area while psr.ic=0 in the kernel exit path. (fixable
>for per-cpu DTC work, but why bother?)
>
>There are some concerns with the default value that the instruc-
>tion encoded in the kernel image.  It shouldn't be concerned.
>The reasons are:
>
>(1) cpu_init() is called at CPU initialization.  In there, we
>    find out physical stack register size from PAL and patch
>    two instructions in kernel exit code.  The code in question
>    can not be executed before the patching is done.
>
>(2) current implementation stores zero in ia64_phys_stacked_size_p8,
>    and that's what the current kernel exit path loads the value with.
>    With the new code, it is equivalent that we store reg size 96
>    in ia64_phys_stacked_size_p8, thus creating a better safety net.
>    Given (1) above can never fail, having (2) is just a bonus.
>
>
>All in all, this patch allow one less memory reference in the kernel
>exit path, thus reducing syscall and interrupt return latency; and
>avoid polluting potential useful data in the CPU cache.
>
>  
>


