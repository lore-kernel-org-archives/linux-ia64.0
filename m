From: Tejun Heo <tj@kernel.org>
Date: Wed, 28 Oct 2009 14:59:31 +0000
Subject: Re: [PATCH 1/2] percpu: allow pcpu_alloc() to be called with IRQs
Message-Id: <4AE85C53.7020400@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.LSU.2.00.0910271328340.19847@wotan.suse.de> <4AE6EDBF.7040905@kernel.org>
In-Reply-To: <4AE6EDBF.7040905@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Kosina <jkosina@suse.cz>
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Jeff Mahoney <jeffm@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Comment added why irqsave/restore are used in alloc path and queued in
percpu#for-linus.  I'll send pull request in a few hours.

Thanks.

--
tejun
