From: Linus Torvalds <torvalds@transmeta.com>
Date: Fri, 19 Jul 2002 17:28:34 +0000
Subject: [Linux-ia64] Re: [PATCH]: scheduler complex macros fixes
Message-Id: <marc-linux-ia64-105590701905790@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905791@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Sat, 20 Jul 2002, Ingo Molnar wrote:
>
> well, SCHED_BATCH is in fact ready, so we might as well put it in. All the
> suggestions mentioned on lkml (or in private) are now included, there are
> no pending (known) problems, no objections, and a number of people are
> using it with success.

Well, I do actually have objections, mainly because I think it modifies
code that I'd rather have cleaned up in other ways _first_ (ie the return
path to user mode, which has pending irq_count/bh_count/preempt issues
that I consider to be about a million times more important than batch
scheduling).

So I'd rather have the non-batch stuff done first and independently.

			Linus


