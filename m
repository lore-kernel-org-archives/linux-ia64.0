From: Tejun Heo <tj@kernel.org>
Date: Wed, 21 Oct 2009 15:19:45 +0000
Subject: Re: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <4ADF2691.7070304@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADB967A.4080707@suse.com> <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz> <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz> <4ADD48D1.1040701@kernel.org> <alpine.LSU.2.00.0910200756300.8582@wotan.suse.de> <4ADD54D4.70808@kernel.org> <4ADD5530.3050107@kernel.org> <alpine.LSU.2.00.0910200826220.8582@wotan.suse.de> <4ADDC69A.5000701@suse.com> <4ADDCDED.6060706@suse.com> <20091021061109.GA27195@elte.hu>
In-Reply-To: <20091021061109.GA27195@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: Jeff Mahoney <jeffm@suse.com>, Jiri Kosina <jkosina@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Ingo Molnar wrote:
> * Jeff Mahoney <jeffm@suse.com> wrote:
> 
>> This version fixes a build issue (__alignof__(unsigned long)) and 
>> fixes the percpu lookup to be usd = percpu array pointer, usd[i] = 
>> actual variable.
> 
> Before applying this part-workaround i'd like to see confirmation that 
> the IA64 limitation is being fixed. It would be bad for such bugs to pop 
> up again and again in the future, with a 2 months bug fixing latency.

I talked with Christoph earlier and he basically said that the
constant can just be bumped up without any ill effect (it would be
great if Tony Luck can confirm this).  So, it's an annoying thing and
in the long term removing would be a good idea but I don't think it's
anything major as long as it blows up during build not runtime.

Thanks.

-- 
tejun
