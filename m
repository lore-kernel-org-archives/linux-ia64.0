From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 13 Jan 2005 17:14:44 +0000
Subject: Re: page table lock patch V15 [0/7]: overview
Message-Id: <Pine.LNX.4.58.0501130912000.18742@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0501130258210.4577-100000@localhost.localdomain>
 <41E5EF2B.3050105@yahoo.com.au>
In-Reply-To: <41E5EF2B.3050105@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, ak@muc.de, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org

On Thu, 13 Jan 2005, Nick Piggin wrote:

> I'm still not too sure that all places read the pte atomically where needed.
> But presently this is not a really big concern because it only would
> really slow down i386 PAE if anything.

S/390 is also affected. And I vaguely recall special issues with sparc
too. That is why I dropped the arch support for that a long time ago from
the patchset. Then there was some talk a couple of months back to use
another addressing mode on IA64 that may also require 128 bit ptes. There
are significantly different ways of doing optimal SMP locking for these
scenarios.
