From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 22 Oct 2008 19:05:11 +0000
Subject: Re: [PATCH 1/2] Allow rwlocks to re-enable interrupts
Message-Id: <20081022190510.GH26094@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1224664414.4430.33.camel@elijah.suse.cz> <1224664476.4430.38.camel@elijah.suse.cz> <1224665128.15448.4.camel@twins> <1224665899.4430.48.camel@elijah.suse.cz> <1224696271.20069.8.camel@twins>
In-Reply-To: <1224696271.20069.8.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Petr Tesarik <ptesarik@suse.cz>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tee@sgi.com, Ingo Molnar <mingo@elte.hu>

On Wed, Oct 22, 2008 at 07:24:31PM +0200, Peter Zijlstra wrote:
> > No problem. I could then also use it for _spin_lock_irqsave, if the
> > answer to the above question is use CONFIG_LOCK_STAT there as well.
> 
> If you create LOCK_CONTEDED_FLAGS() the whole issue goes away nicely.

Should it also be used for _spin_lock_irq()?  I'm puzzled why it's only
used for _irqsave().

(should _spin_lock_bh() re-enable BHs while waiting?  Is it just not big
enough of a deal?)

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
