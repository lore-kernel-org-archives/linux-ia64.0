From: Matthew Wilcox <matthew@wil.cx>
Date: Sun, 03 Aug 2008 01:44:09 +0000
Subject: Re: [patch] IA64: suppress return value of down_trylock() in salinfo_work_to_do()
Message-Id: <20080803014408.GC26461@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080803000654.GA30659@verge.net.au> <20080803013159.GB26461@parisc-linux.org>
In-Reply-To: <20080803013159.GB26461@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Keith Owens <kaos@ocs.com.au>

On Sat, Aug 02, 2008 at 07:32:00PM -0600, Matthew Wilcox wrote:
> I can't say that I think this is a good idea.  Has anyone looked at what
> it would take to actually track this?  For example, could we ever have
> the situation where:

Looking at this a bit more deeply, it seems to be a simple abuse of a
semaphore.

It's used both to exclude other tasks in salinfo_event_read() and as a
wake queue from interrupt context.  I think what we want is something
more like this:

	spin_lock(&data_saved_lock);
	if (!worktodo) {
		if (O_NONBLOCK)
			spin_unlock()
			return;
		else
			add to wait queue
			spin_unlock()
			schedule()
			spin_lock()
	}

Then we can just use wake_up() from interrupt context.

Thoughts?  I don't have any idea how to generate salinfo events, so I
wouldn't be able to test.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
