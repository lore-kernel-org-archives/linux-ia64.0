From: Paul Jackson <pj@sgi.com>
Date: Fri, 15 Jul 2005 03:50:50 +0000
Subject: Re: [NUMA] Display and modify the memory policy of a process
Message-Id: <20050714205050.3823ddb8.pj@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0507141838090.418@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0507141838090.418@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org

This patch puzzles me.  Some of my questions are probably answered
by the code, but I tend to read the commentary and comments first,
to "get my bearings."  I failed to get said bearings ... as you
shall soon realize.

How does this patch relate to Andi's mbind/mempolicy support?

How does it relate to cpusets?

What are the essential feature(s) not provided by the above which
this patch adds?

What are some situations/scenarios in which this facility or additional
features would be useful, and how would it be used therein?

Why yet another parser/displayer for lists of numbers, rather than
use lib/bitmap.c: bitmap_scnlistprintf, bitmap_parselist?

This patch seems to be closely related to the mempolicy work (does
it just provide another way to manipulate and display such)?  But it
uses a file system interface, rather than a system call interface.
Until now, mempolicy has used system calls, and cpusets file system
style API's.  This patch seems to remove this nice, simple, albeit
inessential, distinction.

The comment:
	/* Check here for cpuset restrictions on nodes */
doesn't seem to be followed by any code involving cpusets.  I guess
this is an "XXX" (open issue) comment, and not a comment on the code
that seems to follow it.

The key question I have is thus: this seems to be more additional
detail in an API and implementing code than I understand the
requirement for.  To repeat one of the questions above - what are
the essential feature(s) this patch adds?

What are the options that one could consider for the API style,
and how do you end up recommending this particular choice?

Could you speak to the motivation for setting this policy per-task,
rather than per-cpuset?  I suspect that there is good motivation for
this choice, but I'd like to see it spelled out.

I'd like to think that someway could be found to accomplish this
patch with quite a bit less "fussy parsing" code.  Such code is a
pretty much guaranteed pain in the backside, both to code to from
user space and to maintain the kernel code.

I'm a little surprised one can just force the mempolicy of another
task's vma without any interlocking/synchronization that I noticed:

+static ssize_t numa_vma_policy_write(struct file *file, const char __user *buf,
+                                size_t count, loff_t *ppos)
+{
...
+	old_policy = vma->vm_policy;
+
+	if (!mpol_equal(pol, old_policy)) {
+		if (pol->policy = MPOL_DEFAULT)
+			pol = NULL;
+
+		vma->vm_policy = pol;
+		mpol_free(old_policy);
+	} else
+		mpol_free(pol);

But I'm no expert in this code, so perhaps the above is safe.

How many ways do we end up with to query a tasks mempolicy?
Superficially, it seems to include get_mempolicy, last weeks
numa_maps patch and this patch's support for reading the
new /proc/<pid>/numa_policy files.  Are all three mechanisms
needed, and do they each provide something valuable and unique?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
