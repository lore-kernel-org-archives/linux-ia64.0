From: Jiri Kosina <jkosina@suse.cz>
Date: Tue, 20 Oct 2009 02:02:14 +0000
Subject: Re: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADB967A.4080707@suse.com>
In-Reply-To: <4ADB967A.4080707@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeff Mahoney <jeffm@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Sun, 18 Oct 2009, Jeff Mahoney wrote:

> Hi Peter -
> 
> Commit 34d76c41 introduced the update_shares_data percpu, but it ends up
> causing problems on large ia64 machines. Specifically, ia64 is limited
> to 64k in percpu vars and with NR_CPUS@96, that ends up being 32k by
> itself. It ends up causing link errors since that is how ia64 enforces
> the 64k limit.
> 
> I can take a deeper look at finding a workable solution but thought I'd
> mention it in case you had ideas already.

I am adding some IA64 CCs, as the failure is solely caused by the ia64 
percpu implementation/pagefault handler optimization which requires the 
.percpu section area not be larger than 64k, which blows up with 34d76c41 
and NR_CPUS high enoufh (due to introduction of percpu array being 
size-dependent on NR_CPUS).

-- 
Jiri Kosina
SUSE Labs, Novell Inc.

