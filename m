From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 10 Oct 2003 16:42:35 +0000
Subject: Re: [PATCH_TAKE_2] now < last_tick problem
Message-Id: <marc-linux-ia64-106580483320515@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106575925709435@msgid-missing>
In-Reply-To: <marc-linux-ia64-106575925709435@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ian,

Just a quick note (got to run): I think you correctly identified the
race causing the now < last_tick problem.  Purely from (bad) memory, I
think the problem was introduced when xtime_lock was converted from an
irq-safe spinlock to a seq-lock.  In theory, xtime_lock still protects
get_offset(), but the theory only holds as long as the seq-lock body
is "transactional" (no side-effects until read_seqretry() returns 0).
I think the source of the probem is that we consider the value
returned by get_offset() to be valid EVEN when read_seqretry() returns
1.  Because of that, we'll end up updating last_nsec_offset with a
potentialy bad value.

	--david
