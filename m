From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 12 Jan 2005 17:52:53 +0000
Subject: Re: page table lock patch V15 [0/7]: overview
Message-Id: <Pine.LNX.4.58.0501120951140.10806@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0412011545060.5721@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0501041129030.805@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0501041137410.805@schroedinger.engr.sgi.com> <m1652ddljp.fsf@muc.de>
 <Pine.LNX.4.58.0501110937450.32744@schroedinger.engr.sgi.com>
 <41E4BCBE.2010001@yahoo.com.au> <20050112014235.7095dcf4.akpm@osdl.org>
 <Pine.LNX.4.58.0501120833060.10380@schroedinger.engr.sgi.com>
 <20050112164906.GA4935@infradead.org> <Pine.LNX.4.58.0501120931460.10697@schroedinger.engr.sgi.com>
 <20050112174101.GA5838@infradead.org>
In-Reply-To: <20050112174101.GA5838@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, torvalds@osdl.org, ak@muc.de, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org

On Wed, 12 Jan 2005, Christoph Hellwig wrote:

> These smaller systems are more likely x86/x86_64 machines ;-)

But they will not have been build in 1998 either like the machine I used
for the i386 tests. Could you do some tests on contemporary x86/x86_64
SMP systems with large memory?
