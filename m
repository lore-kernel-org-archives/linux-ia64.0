From: Tejun Heo <tj@kernel.org>
Date: Tue, 20 Oct 2009 06:14:08 +0000
Subject: Re: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <4ADD5530.3050107@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADB967A.4080707@suse.com> <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz> <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz> <4ADD48D1.1040701@kernel.org> <alpine.LSU.2.00.0910200756300.8582@wotan.suse.de> <4ADD54D4.70808@kernel.org>
In-Reply-To: <4ADD54D4.70808@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Kosina <jkosina@suse.cz>
Cc: Jeff Mahoney <jeffm@suse.com>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Tejun Heo wrote:
> Jiri Kosina wrote:
>> So how about something along the lines below? (completely untested as 
>> well)
>>
>> From: Jiri Kosina <jkosina@suse.cz>
>> Subject: sched: move rq_weight data array out of .percpu
>>
>> Commit 34d76c41 introduced percpu array update_shares_data, size of which
>> being proportional to NR_CPUS. Unfortunately this blows up ia64 for large
>> NR_CPUS configuration, as ia64 allows only 64k for .percpu section.
>>
>> Fix this by allocating this array dynamically and keep only pointer to it
>> percpu.
> 
> Looks good to me from percpu POV.

Oh... one thing.  If you're doing dynamic allocation you can use
nr_cpu_ids instead of NR_CPUS.

-- 
tejun
