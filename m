From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 12 Jan 2005 16:49:06 +0000
Subject: Re: page table lock patch V15 [0/7]: overview
Message-Id: <20050112164906.GA4935@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0411221429050.20993@ppc970.osdl.org> <Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0412011545060.5721@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0501041129030.805@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0501041137410.805@schroedinger.engr.sgi.com> <m1652ddljp.fsf@muc.de> <Pine.LNX.4.58.0501110937450.32744@schroedinger.engr.sgi.com> <41E4BCBE.2010001@yahoo.com.au> <20050112014235.7095dcf4.akpm@osdl.org> <Pine.LNX.4.58.0501120833060.10380@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0501120833060.10380@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, torvalds@osdl.org, ak@muc.de, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org

On Wed, Jan 12, 2005 at 08:39:21AM -0800, Christoph Lameter wrote:
> The future is in higher and higher SMP counts since the chase for the
> higher clock frequency has ended. We will increasingly see multi-core
> cpus etc. Machines with higher CPU counts are becoming common in business.

An they still are absolutely in the minority.  In fact with multicore
cpus it becomes more and more important to be fast for SMP systtems with
a _small_ number of CPUs, while really larget CPUs will remain a small
nische for the forseeable future.

