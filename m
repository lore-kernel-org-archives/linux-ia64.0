From: Roman Zippel <zippel@linux-m68k.org>
Date: Wed, 05 Jan 2005 11:51:34 +0000
Subject: Re: page fault scalability patch V14 [3/7]: i386 universal cmpxchg
Message-Id: <200501051251.36879.zippel@linux-m68k.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain> <Pine.LNX.4.58.0501041129030.805@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0501041136350.805@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0501041136350.805@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

On Tuesday 04 January 2005 20:37, Christoph Lameter wrote:

>         * Provide emulation of cmpxchg suitable for uniprocessor if
>    build and run on 386.
>         * Provide emulation of cmpxchg8b suitable for uniprocessor
>    systems if build and run on 386 or 486.

I'm not sure that's such a good idea. This emulation is more expensive as it 
has to disable interrupts and you already have emulation functions using 
spinlocks anyway, so why not use them? This way your patch would not just 
scale up, but also still scale down.

bye, Roman

