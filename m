From: Christoph Lameter <christoph@lameter.com>
Date: Sun, 15 Aug 2004 23:55:57 +0000
Subject: Re: page fault fastpath: Increasing SMP scalability by introducing
Message-Id: <Pine.LNX.4.58.0408151654240.4346@server.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <2ttIr-2e4-17@gated-at.bofh.it> <2tzE4-6sw-25@gated-at.bofh.it>
 <2tCiw-8pK-1@gated-at.bofh.it> <m31xi8dkm2.fsf@averell.firstfloor.org>
In-Reply-To: <m31xi8dkm2.fsf@averell.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@muc.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 16 Aug 2004, Andi Kleen wrote:

> Christoph Lameter <clameter@sgi.com> writes:
>
> > On Sun, 15 Aug 2004, David S. Miller wrote:
> >
> >>
> >> Is the read lock in the VMA semaphore enough to let you do
> >> the pgd/pmd walking without the page_table_lock?
> >> I think it is, but just checking.
> >
> > That would be great.... May I change the page_table lock to
> > be a read write spinlock instead?
>
> That's probably not a good idea. r/w locks are extremly slow on
> some architectures. Including ia64.

I was thinking about a read write spinlock not an readwrite
semaphore. Look at include/asm-ia64/spinlock.h.
The implementations are almost the same. Are you sure
about this?

