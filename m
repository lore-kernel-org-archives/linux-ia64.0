From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 10 Jun 2022 14:21:47 +0000
Subject: Re: [PATCH] x86: Change the return type of acpi_map_cpu2node to void
Message-Id: <YqNTewtUzizxovJO@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220610104423.201739-1-kunyu@nfschina.com>
 <7eb4762e-723b-51e8-3d70-1c28568ac4f5@intel.com>
In-Reply-To: <7eb4762e-723b-51e8-3d70-1c28568ac4f5@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <dave.hansen@intel.com>
Cc: Li kunyu <kunyu@nfschina.com>, chenhuacai@kernel.org, rafael@kernel.org, len.brown@intel.com, pavel@ucw.cz, mingo@redhat.com, bp@alien8.de, tglx@linutronix.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org

On Fri, Jun 10, 2022 at 05:35:29AM -0700, Dave Hansen wrote:
> On 6/10/22 03:44, Li kunyu wrote:
> > Reduce eax register calls by removing unused return values.
> 
> Please stop sending these patches, at least with these repetitive,
> inaccurate descriptions.

Dave, just add them to the /dev/null mailbox.
