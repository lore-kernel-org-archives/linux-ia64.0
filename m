From: "Boehm, Hans" <hans.boehm@hp.com>
Date: Mon, 22 Nov 2004 23:01:27 +0000
Subject: RE: [Lse-tech] scalability of signal delivery for Posix Threads
Message-Id: <65953E8166311641A685BDF71D865826058B5F@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041122162214.GE21861@wotan.suse.de>
In-Reply-To: <20041122162214.GE21861@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Ray Bryant <raybry@sgi.com>, Andreas Schwab <schwab@suse.de>, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, lse-tech <lse-tech@lists.sourceforge.net>, holt@sgi.com, Dean Roe <roe@sgi.com>, Brian Sumner <bls@sgi.com>, John Hawkes <hawkes@tomahawk.engr.sgi.com>

Just to clarify:

I have no problem with special-casing signals sent to a specific
thread.  Our garbage collector uses pthread_kill, and thus should
also benefit from that change.  And it makes sense to me that this
kind of signal should be cheaper to deliver.

SIGSEGV delivery also matters to me.  But that should presumably
also fall into the same class.

I would prefer to avoid special handling for just SIGPROF.
If that was never proposed, please ignore my comments.

Hans

> -----Original Message-----
> From: Andi Kleen [mailto:ak@suse.de]
> Sent: Monday, November 22, 2004 1:35 PM
> To: Boehm, Hans
> Cc: Ray Bryant; Andi Kleen; Andreas Schwab; Kernel Mailing List;
> linux-ia64@vger.kernel.org; lse-tech; holt@sgi.com; Dean Roe; Brian
> Sumner; John Hawkes
> Subject: Re: [Lse-tech] scalability of signal delivery for 
> Posix Threads
> 
> 
> > I think this is a more general issue.  Special casing one
> 
> It just cannot be done in the general case without slowing
> down sigaction significantly. Or maybe it can, but nobody
> has proposed a way to do it so far. 
> 
> It's difficult to design for machines where a simple spinlock
> doesn't work properly anymore.
> 
> > piece of it is only going to make performance more surprising,
> > something I think should be avoided if at all possible.
> 
> The special case in particular would be signals directed to a 
> specific TID;
> compared to signals load balanced over the thread group which needs
> shared writable state. To simplify the fast path you could also make
> more simplications: no queueing (otherwise you would need to duplicate
> a lot of state to handle that into the task_struct) and probably
> no SIGCHILD which is also full of special cases.
> 
> -And
> 
