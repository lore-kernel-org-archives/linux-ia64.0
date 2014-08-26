From: Tejun Heo <tj@kernel.org>
Date: Tue, 26 Aug 2014 18:13:53 +0000
Subject: Re: [PATCH 24/35] [PATCH 24/36] ia64: Replace __get_cpu_var uses
Message-Id: <20140826181353.GH31659@mtj.dyndns.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140817173023.439660246@linux.com>
 <20140817173036.664195653@linux.com>
In-Reply-To: <20140817173036.664195653@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Sun, Aug 17, 2014 at 12:30:47PM -0500, Christoph Lameter wrote:
> __get_cpu_var() is used for multiple purposes in the kernel source. One of
> them is address calculation via the form &__get_cpu_var(x).  This calculates
> the address for the instance of the percpu variable of the current processor
> based on an offset.
> 
> Other use cases are for storing and retrieving data from the current
> processors percpu area.  __get_cpu_var() can be used as an lvalue when
> writing data or on the right side of an assignment.
...
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: linux-ia64@vger.kernel.org
> Signed-off-by: Christoph Lameter <cl@linux.com>

(Please disregard the ones I posted for v1 of the patch series)

Applied to percpu/for-3.18-consistent-ops.  Please let me know if this
patch should be routed differently.  Note that this patch was to be
applied to percpu/for-3.17 but delayed due to build issues caused by
cpumask_var_t.

Thanks.

-- 
tejun
