From: Rusty Russell <rusty@rustcorp.com.au>
Date: Wed, 23 Sep 2009 11:22:55 +0000
Subject: Re: [PATCH 5/5] percpu: kill legacy percpu allocator
Message-Id: <200909232040.55878.rusty@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253682382-24740-1-git-send-email-tj@kernel.org> <1253682382-24740-6-git-send-email-tj@kernel.org>
In-Reply-To: <1253682382-24740-6-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tejun Heo <tj@kernel.org>
Cc: Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org

On Wed, 23 Sep 2009 02:36:22 pm Tejun Heo wrote:
> With ia64 converted, there's no arch left which still uses legacy
> percpu allocator.  Kill it.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Christoph Lameter <cl@linux-foundation.org>

Delightedly-acked-by: Rusty Russell <rusty@rustcorp.com.au>

Thanks!
Rusty.
