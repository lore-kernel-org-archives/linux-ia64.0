From: Andi Kleen <ak@suse.de>
Date: Mon, 22 Nov 2004 21:34:48 +0000
Subject: Re: [Lse-tech] scalability of signal delivery for Posix Threads
Message-Id: <20041122213448.GA16153@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <65953E8166311641A685BDF71D865826058B5C@cacexc12.americas.cpqcorp.net>
In-Reply-To: <65953E8166311641A685BDF71D865826058B5C@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Boehm, Hans" <hans.boehm@hp.com>
Cc: Ray Bryant <raybry@sgi.com>, Andi Kleen <ak@suse.de>, Andreas Schwab <schwab@suse.de>, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, lse-tech <lse-tech@lists.sourceforge.net>, holt@sgi.com, Dean Roe <roe@sgi.com>, Brian Sumner <bls@sgi.com>, John Hawkes <hawkes@tomahawk.engr.sgi.com>

> I think this is a more general issue.  Special casing one

It just cannot be done in the general case without slowing
down sigaction significantly. Or maybe it can, but nobody
has proposed a way to do it so far. 

It's difficult to design for machines where a simple spinlock
doesn't work properly anymore.

> piece of it is only going to make performance more surprising,
> something I think should be avoided if at all possible.

The special case in particular would be signals directed to a specific TID;
compared to signals load balanced over the thread group which needs
shared writable state. To simplify the fast path you could also make
more simplications: no queueing (otherwise you would need to duplicate
a lot of state to handle that into the task_struct) and probably
no SIGCHILD which is also full of special cases.

-And
