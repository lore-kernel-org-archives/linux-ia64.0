From: Christoph Lameter <cl@linux-foundation.org>
Date: Wed, 23 Sep 2009 17:17:10 +0000
Subject: Re: [PATCH 2/4] ia64: allocate percpu area for cpu0 like percpu
Message-Id: <alpine.DEB.1.10.0909231315310.4025@V090114053VZO-1>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253605214-23210-1-git-send-email-tj@kernel.org> <1253605214-23210-3-git-send-email-tj@kernel.org> <alpine.DEB.1.10.0909221856050.9410@V090114053VZO-1> <4AB983B6.6050203@kernel.org> <alpine.DEB.1.10.0909230941560.21821@V090114053VZO-1>
 <4ABA2A3A.6020308@kernel.org>
In-Reply-To: <4ABA2A3A.6020308@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tejun Heo <tj@kernel.org>
Cc: Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org

On Wed, 23 Sep 2009, Tejun Heo wrote:

> any special handling.  What problems are you seeing?

per cpu variable access on IA64 does not use the percpu_offset for the
calculation of the current per cpu data area. Its using a virtual mapping.

How does the new percpu allocator support this? Does it use different
methods of access for static and dynamic percpu access?


