From: Andi Kleen <ak@muc.de>
Date: Sun, 15 Aug 2004 23:53:09 +0000
Subject: Re: page fault fastpath: Increasing SMP scalability by introducing
Message-Id: <m31xi8dkm2.fsf@averell.firstfloor.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <2ttIr-2e4-17@gated-at.bofh.it> <2tzE4-6sw-25@gated-at.bofh.it>
	<2tCiw-8pK-1@gated-at.bofh.it>
In-Reply-To: <2tCiw-8pK-1@gated-at.bofh.it> (Christoph Lameter's message of
 "Mon, 16 Aug 2004 01:10:04 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Christoph Lameter <clameter@sgi.com> writes:

> On Sun, 15 Aug 2004, David S. Miller wrote:
>
>>
>> Is the read lock in the VMA semaphore enough to let you do
>> the pgd/pmd walking without the page_table_lock?
>> I think it is, but just checking.
>
> That would be great.... May I change the page_table lock to
> be a read write spinlock instead?

That's probably not a good idea. r/w locks are extremly slow on 
some architectures. Including ia64.

Just profile cat /proc/net/tcp on a machine with a lot of memory
and you'll notice.

-Andi

