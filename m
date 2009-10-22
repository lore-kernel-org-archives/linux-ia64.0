From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 22 Oct 2009 22:24:53 +0000
Subject: RE: Commit 34d76c41 causes linker errors on ia64 with NR_CPUS=4096
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3E337D94C@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4ADB967A.4080707@suse.com>
 <alpine.LRH.2.00.0910200356340.20992@twin.jikos.cz>
 <alpine.LRH.2.00.0910200651510.20992@twin.jikos.cz>
 <4ADD48D1.1040701@kernel.org>
 <alpine.LSU.2.00.0910200756300.8582@wotan.suse.de>
 <4ADD54D4.70808@kernel.org> <4ADD5530.3050107@kernel.org>
 <alpine.LSU.2.00.0910200826220.8582@wotan.suse.de>
 <4ADDC69A.5000701@suse.com> <4ADDCDED.6060706@suse.com>
 <20091021061109.GA27195@elte.hu> <4ADF2691.7070304@kernel.org>
 <57C9024A16AD2D4C97DC78E552063EA3E337CF79@orsmsx505.amr.corp.intel.com>
 <alpine.LSU.2.00.0910221640430.8582@wotan.suse.de>
In-Reply-To: <alpine.LSU.2.00.0910221640430.8582@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Kosina <jkosina@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, Jeff Mahoney <jeffm@suse.com>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

> Tony, is the change that will eventually have to be made to ia64 pagefault 
> handler too intrusive for -rc6, and should we rather go with my workaround 
> instead, and try to find something proper for 2.6.33?

Using __alloc_percpu() rather than static declaration looks to be
the right fix here.  Not a "workaround".

-Tony
