From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 29 Jul 2005 11:26:16 +0000
Subject: Re: Delete scheduler SD_WAKE_AFFINE and SD_WAKE_BALANCE flags
Message-Id: <20050729112616.GA24965@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <200507282308.j6SN8Tg01993@unix-os.sc.intel.com>
In-Reply-To: <200507282308.j6SN8Tg01993@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Nick Piggin' <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


* Chen, Kenneth W <kenneth.w.chen@intel.com> wrote:

> To demonstrate the problem, we turned off these two flags in the cpu 
> sd domain and measured a stunning 2.15% performance gain!  And 
> deleting all the code in the try_to_wake_up() pertain to load 
> balancing gives us another 0.2% gain.

another thing: do you have a HT-capable ia64 CPU, and do you have 
CONFIG_SCHED_SMT turned on? If yes then could you try to turn off 
SD_WAKE_IDLE too, i found it to bring further performance improvements 
in certain workloads.

	Ingo
