From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 21 Oct 2009 06:11:09 +0000
Subject: Re: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <20091021061109.GA27195@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADB967A.4080707@suse.com> <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz> <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz> <4ADD48D1.1040701@kernel.org> <alpine.LSU.2.00.0910200756300.8582@wotan.suse.de> <4ADD54D4.70808@kernel.org> <4ADD5530.3050107@kernel.org> <alpine.LSU.2.00.0910200826220.8582@wotan.suse.de> <4ADDC69A.5000701@suse.com> <4ADDCDED.6060706@suse.com>
In-Reply-To: <4ADDCDED.6060706@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeff Mahoney <jeffm@suse.com>
Cc: Jiri Kosina <jkosina@suse.cz>, Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org


* Jeff Mahoney <jeffm@suse.com> wrote:

> This version fixes a build issue (__alignof__(unsigned long)) and 
> fixes the percpu lookup to be usd = percpu array pointer, usd[i] = 
> actual variable.

Before applying this part-workaround i'd like to see confirmation that 
the IA64 limitation is being fixed. It would be bad for such bugs to pop 
up again and again in the future, with a 2 months bug fixing latency.

	Ingo
