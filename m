From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 19 Aug 2004 01:19:14 +0000
Subject: Re: page fault fastpath patch v2: fix race conditions, stats for
Message-Id: <Pine.LNX.4.58.0408181816330.8185@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0408181807500.15027-100000@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.44.0408181807500.15027-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hugh Dickins <hugh@veritas.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, "David S. Miller" <davem@redhat.com>, raybry@sgi.com, ak@muc.de, benh@kernel.crashing.org, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

> > - One could avoid pte locking by introducing a pte_cmpxchg. cmpxchg
> > seems to be supported by all ia64 and i386 cpus except the original 80386.
>
> I do think this will be a more fruitful direction than pte locking:
> just looking through the arches for spare bits puts me off pte locking.

Thanks for the support. Got a V3 here (not ready to post yet) that throws
out the locks and uses cmpxchg instead. It also removes the use of
page_table_lock completely from handle_mm_fault.
