From: Olof Johansson <olof@lixom.net>
Date: Fri, 23 Dec 2005 21:59:16 +0000
Subject: Re: [PATCH] - Fix memory ordering problem in wake_futex()
Message-Id: <20051223215915.GE24601@pb15.lixom.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051223163816.GA30906@sgi.com> <20051223204822.GC24601@pb15.lixom.net> <20051223213216.GA29541@sgi.com>
In-Reply-To: <20051223213216.GA29541@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jack Steiner <steiner@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Fri, Dec 23, 2005 at 03:32:16PM -0600, Jack Steiner wrote:

> On IA64, the "sync" instructions are actually part of the ld.acq ot st.rel
> instructions that are used to set/clear spinlocks.
[...]
> IA64 implements fencing of ld.acq or st.rel instructions as one-directional
> barriers.

So ia64 spin_unlock doesn't do store-store ordering across it. I'm
surprised this is the first time this causes problems. Other architectures
seem to order:

* sparc64 does a membar StoreStore|LoadStore
* powerpc does lwsync or sync, depending on arch
* alpha does an mb();

* x86 is in-order

So, sounds to me like you need to fix your lock primitives, not add
barriers to generic code?


-Olof
