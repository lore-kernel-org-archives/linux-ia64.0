From: Christoph Lameter <cl@linux-foundation.org>
Date: Wed, 23 Sep 2009 13:44:33 +0000
Subject: Re: [PATCH 2/4] ia64: allocate percpu area for cpu0 like percpu
Message-Id: <alpine.DEB.1.10.0909230941560.21821@V090114053VZO-1>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253605214-23210-1-git-send-email-tj@kernel.org> <1253605214-23210-3-git-send-email-tj@kernel.org> <alpine.DEB.1.10.0909221856050.9410@V090114053VZO-1> <4AB983B6.6050203@kernel.org>
In-Reply-To: <4AB983B6.6050203@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tejun Heo <tj@kernel.org>
Cc: Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org

On Wed, 23 Sep 2009, Tejun Heo wrote:

> On ia64, the first chunk is fixed at PERCPU_PAGE_SIZE.  It's something
> hardwired into the page fault logic and the linker script.  Build will
> fail if the static + reserved area goes over PERCPU_PAGE_SIZE and in
> that case ia64 will need to update the special case page fault logic
> and increase PERCPU_PAGE_SIZE.  The area reserved above is interim
> per-cpu area for cpu0 which is used between head.S and proper percpu
> area setup and will be ditched once initialization is complete.

You did not answer my question.

The local percpu variables are accessed via a static per cpu
virtual mapping. You cannot place per cpu variables outside of that
virtual address range of PERCPU_PAGE_SIZE.

What happens if the percpu allocator allocates more data than available in
the reserved area?

