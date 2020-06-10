From: Peter Xu <peterx@redhat.com>
Date: Wed, 10 Jun 2020 16:50:23 +0000
Subject: Re: Possible duplicate page fault accounting on some archs after commit 4064b9827063
Message-Id: <20200610165023.GA67179@xz-x1>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200610174811.44b94525@thinkpad>
In-Reply-To: <20200610174811.44b94525@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Michal Simek <monstr@monstr.eu>, linux-mips@vger.kernel.org, Nick Hu <nickhu@andestech.com>, Ley Foon Tan <ley.foon.tan@intel.com>, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, Guan Xuetao <gxt@pku.edu.cn>, linux-xtensa@linux-xtensa.org, Heiko Carstens <heiko.carstens@de.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Jun 10, 2020 at 05:48:11PM +0200, Gerald Schaefer wrote:
> Hi,

Hi, Gerald,

> 
> Some architectures have their page fault accounting code inside the fault
> retry loop, and rely on only going through that code once. Before commit
> 4064b9827063 ("mm: allow VM_FAULT_RETRY for multiple times"), that was
> ensured by testing for and clearing FAULT_FLAG_ALLOW_RETRY.
> 
> That commit had to remove the clearing of FAULT_FLAG_ALLOW_RETRY for all
> architectures, and introduced a subtle change to page fault accounting
> logic in the affected archs. It is now possible to go through the retry
> loop multiple times, and the affected archs would then account multiple
> page faults instead of just one.
> 
> This was found by coincidence in s390 code, and a quick check showed that
> there are quite a lot of other architectures that seem to be affected in a
> similar way. I'm preparing a fix for s390, by moving the accounting behind
> the retry loop, similar to x86. It is not completely straight-forward, so
> I leave the fix for other archs to the respective maintainers.

Sorry for not noticing this before.  The accounting part should definitely be
put at least into a check against fault_flag_allow_retry_first() to mimic what
was done before.  And I agree it would be even better to put it after the retry
logic, so if any of the page faults gets a major fault, it'll be accounted as a
major fault which makes more sense to me, just like what x86 is doing now with:

	major |= fault & VM_FAULT_MAJOR;

I'm not sure what's the preference of the arch maintainers, just let me know if
it's preferred to use a single series to address this issue for all affected
archs (or the archs besides s390), then I'll do.

Thanks!

-- 
Peter Xu
