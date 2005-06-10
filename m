From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 10 Jun 2005 17:13:41 +0000
Subject: Re: [RFD] Separating struct task and the kernel stacks
Message-Id: <20050610171341.GG24611@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <9712.1118384111@kao2.melbourne.sgi.com>
In-Reply-To: <9712.1118384111@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jun 10, 2005 at 08:11:42AM -0700, Christoph Lameter wrote:
> Using the slab allocator generates a certain amount of overhead during 
> process creation. I believe the page allocator would be faster. Also there 
> needs to be no separate allocation of memory for the stack.

While speed of process creation is certainly an important benchmark,
speed of scheduling is more important.  I was under the impression that
the reason x86 moved the task_struct from the bottom of the stack to
its own slab was that the scheduler had bad cache effects due to all
task_structs being on the same 4k boundary.  Obviously, ia64 has slightly
different caches from x86, but I just wanted to point out that it isn't
necessarily all bad to move the task_struct off the stack.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
