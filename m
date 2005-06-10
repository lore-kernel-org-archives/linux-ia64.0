From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 10 Jun 2005 17:20:30 +0000
Subject: Re: [RFD] Separating struct task and the kernel stacks
Message-Id: <17065.52190.305295.375915@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <9712.1118384111@kao2.melbourne.sgi.com>
In-Reply-To: <9712.1118384111@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 10 Jun 2005 18:13:41 +0100, Matthew Wilcox <matthew@wil.cx> said:

  Matthew> On Fri, Jun 10, 2005 at 08:11:42AM -0700, Christoph Lameter wrote:
  >> Using the slab allocator generates a certain amount of overhead during 
  >> process creation. I believe the page allocator would be faster. Also there 
  >> needs to be no separate allocation of memory for the stack.

  Matthew> While speed of process creation is certainly an important
  Matthew> benchmark, speed of scheduling is more important.  I was
  Matthew> under the impression that the reason x86 moved the
  Matthew> task_struct from the bottom of the stack to its own slab
  Matthew> was that the scheduler had bad cache effects due to all
  Matthew> task_structs being on the same 4k boundary.

That was only a secondary effect.  We can do task-coloring/"cache-line
randomization" for ia64 tasks without having to split them up (unlike
on x86, we have separate task and stack pointers and we never rely on
masking/alignment to compute one from the other, as is done on x86).

	--david
