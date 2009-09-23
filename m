From: Tejun Heo <tj@kernel.org>
Date: Wed, 23 Sep 2009 14:01:30 +0000
Subject: Re: [PATCH 2/4] ia64: allocate percpu area for cpu0 like percpu areas
Message-Id: <4ABA2A3A.6020308@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253605214-23210-1-git-send-email-tj@kernel.org> <1253605214-23210-3-git-send-email-tj@kernel.org> <alpine.DEB.1.10.0909221856050.9410@V090114053VZO-1> <4AB983B6.6050203@kernel.org> <alpine.DEB.1.10.0909230941560.21821@V090114053VZO-1>
In-Reply-To: <alpine.DEB.1.10.0909230941560.21821@V090114053VZO-1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org

Hello,

Christoph Lameter wrote:
> You did not answer my question.

Hmmm...

> The local percpu variables are accessed via a static per cpu
> virtual mapping. You cannot place per cpu variables outside of that
> virtual address range of PERCPU_PAGE_SIZE.
> 
> What happens if the percpu allocator allocates more data than available in
> the reserved area?

I still don't understand your question.  Static percpu variables are
always allocated from the first chunk inside that PERCPU_PAGE_SIZE
area.  Dynamic allocations can go outside of that but they don't need
any special handling.  What problems are you seeing?

-- 
tejun
