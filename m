From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 29 Jul 2005 01:39:22 +0000
Subject: RE: Delete scheduler SD_WAKE_AFFINE and SD_WAKE_BALANCE flags
Message-Id: <200507290139.j6T1dNg03701@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <42E98582.2080406@yahoo.com.au>
References: <200507282308.j6SN8Tg01993@unix-os.sc.intel.com>
In-Reply-To: <200507282308.j6SN8Tg01993@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Nick Piggin' <nickpiggin@yahoo.com.au>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Nick Piggin wrote on Thursday, July 28, 2005 6:25 PM
> Well pipes are just an example. It could be any type of communication.
> What's more, even the synchronous wakeup uses the wake balancing path
> (although that could be modified to only do wake balancing for synch
> wakeups, I'd have to be convinced we should special case pipes and not
> eg. semaphores or AF_UNIX sockets).


Why is the normal load balance path not enough (or not be able to do the
right thing)?  The reblance_tick and idle_balance ought be enough to take
care of the imbalance.  What makes load balancing in wake up path so special?

Oh, I'd like to hear your opinion on what to do with these two flags, make
them runtime configurable? (I'm of the opinion to delete them altogether)

- Ken

