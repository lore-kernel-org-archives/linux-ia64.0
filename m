From: William Lee Irwin III <wli@holomorphy.com>
Date: Tue, 17 Aug 2004 15:51:25 +0000
Subject: Re: page fault fastpath patch v2: fix race conditions, stats for 8,32 and 512 cpu SMP
Message-Id: <20040817155125.GQ11200@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408150630560.324@schroedinger.engr.sgi.com> <20040815130919.44769735.davem@redhat.com> <Pine.LNX.4.58.0408151552280.3370@schroedinger.engr.sgi.com> <20040815165827.0c0c8844.davem@redhat.com> <Pine.LNX.4.58.0408151703580.3751@schroedinger.engr.sgi.com> <20040815185644.24ecb247.davem@redhat.com> <Pine.LNX.4.58.0408151924250.4480@schroedinger.engr.sgi.com> <20040816143903.GY11200@holomorphy.com> <Pine.LNX.4.58.0408170804430.8365@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0408170804430.8365@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: "David S. Miller" <davem@redhat.com>, raybry@sgi.com, ak@muc.de, benh@kernel.crashing.org, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Aug 17, 2004 at 08:28:44AM -0700, Christoph Lameter wrote:
> This is the second release of the page fault fastpath path. The fast path
> avoids locking during the creation of page table entries for anonymous
> memory in a threaded application running on a SMP system. The performance
> increases significantly for more than 4 threads running concurrently.
> Changes:
> - Insure that it is safe to call the various functions without holding
> the page_table_lock.
> - Fix cases in rmap.c where a pte could be cleared for a very short time
> before being set to another value by introducing a pte_xchg function. This
> created a potential race condition with the fastpath code which checks for
> a cleared pte without holding the page_table_lock.
> - i386 support
> - Various cleanups
> Issue remaining:
> - The fastpath increments mm->rss without acquiring the page_table_lock.
> Introducing the page_table_lock even for a short time makes performance
> drop to the level before the patch.

Hmm. I'm suspicious but I can't immediately poke a hole in it as it
leaves most uses of ->page_table_lock in place. I can't help thinking
there's a more comprehensive attack on the locking in this area, either.

-- wli
