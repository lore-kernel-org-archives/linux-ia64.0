From: Matthew Wilcox <willy@debian.org>
Date: Wed, 23 Jul 2003 12:00:15 +0000
Subject: Re: [PATCH] don't use ld.bias
Message-Id: <marc-linux-ia64-105896175111168@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883179830025@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883179830025@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jul 22, 2003 at 09:40:02PM -0700, Mallick, Asit K wrote:
> It does make sense to not use the ld.bias in the spinlock, it will make
> more cacheline bouncing in a larger SMP system.

it certainly makes a mockery of the comment:

 * Streamlined test_and_set_bit(0, (x)).  We use test-and-test-and-set
 * rather than a simple xchg to avoid writing the cache-line when
 * there is contention.

since there's no real advantage (AIUI) to have the cacheline
clean-exclusive vs dirty-exclusive.

but why not delete this code?  it's under #else /* !NEW_LOCK */ and
NEW_LOCK looks to be the better code as well as the default in 2.5.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
