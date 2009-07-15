From: Tejun Heo <tj@kernel.org>
Date: Wed, 15 Jul 2009 02:48:45 +0000
Subject: Re: [PATCH] linux-next arch/ia64/kernel/setup.c: Fix setup_per_cpu_areas()
Message-Id: <4A5D438D.2050106@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <A6AD88C3F2289247BE726C37303E1EB8B06CB5E9@orsmsx505.amr.corp.intel.com> <20090713200942.GA19606@linux-os.sc.intel.com>
In-Reply-To: <20090713200942.GA19606@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Fenghua Yu <fenghua.yu@intel.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-ia64@vger.kernel.org

Fenghua Yu wrote:
> Fix ia64 build setup_per_cpu_areas() redifinition issue in UP configuration
> 
> When compiling ia64 kernel in UP configuration, the following compilation errors
> are reported:
> 
> arch/ia64/kernel/setup.c:860: error: redefinition of 'setup_per_cpu_areas'
> include/linux/percpu.h:185: error: previous definition of 'setup_per_cpu_areas' was here
> 
> The patch fixes the issue in arch/ia64/kernel/setup.c
> 
> Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>

Committed to percpu#for-next.  Thanks.

-- 
tejun
