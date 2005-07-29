From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 29 Jul 2005 17:30:12 +0000
Subject: RE: Delete scheduler SD_WAKE_AFFINE and SD_WAKE_BALANCE flags
Message-Id: <200507291730.j6THUCg15426@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20050729112616.GA24965@elte.hu>
References: <200507282308.j6SN8Tg01993@unix-os.sc.intel.com>
In-Reply-To: <200507282308.j6SN8Tg01993@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Ingo Molnar' <mingo@elte.hu>
Cc: 'Nick Piggin' <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Ingo Molnar wrote on Friday, July 29, 2005 4:26 AM
> * Chen, Kenneth W <kenneth.w.chen@intel.com> wrote:
> > To demonstrate the problem, we turned off these two flags in the cpu 
> > sd domain and measured a stunning 2.15% performance gain!  And 
> > deleting all the code in the try_to_wake_up() pertain to load 
> > balancing gives us another 0.2% gain.
> 
> another thing: do you have a HT-capable ia64 CPU, and do you have 
> CONFIG_SCHED_SMT turned on? If yes then could you try to turn off 
> SD_WAKE_IDLE too, i found it to bring further performance improvements 
> in certain workloads.

The scheduler experiments done so far are on non-SMT CPU (Madison processor).
We have another db setup with multi-thread capable ia64 cpu (montecito, and to
be precise, it is SOEMT capable).  We are just about to do scheduler experiments
on that setup.


