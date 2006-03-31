From: Jes Sorensen <jes@sgi.com>
Date: Fri, 31 Mar 2006 16:18:57 +0000
Subject: Re: [patch] avoid unaligned access when accessing poll stack
Message-Id: <yq0odzmtwni.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0sloytyj5.fsf@jaguar.mkp.net> <200603311800.19364.ak@suse.de>
In-Reply-To: <200603311800.19364.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> "Andi" = Andi Kleen <ak@suse.de> writes:

Andi> On Friday 31 March 2006 17:38, Jes Sorensen wrote:
>> Hi,
>> 
>> Patch 70674f95c0a2ea694d5c39f4e514f538a09be36f [PATCH] Optimize
>> select/poll by putting small data sets on the stack resulted in the
>> poll stack being 4-byte aligned on 64-bit architectures, causing
>> misaligned accesses to elements in the array.
>> 
>> This patch fixes it by declaring the stack in terms of 'long'
>> instead of 'char'.

Andi> You should do that for poll too then.

I assume you mean select().

Updated patch attached.

Jes

Force alignment of poll and select stacks to long to avoid unaligned
access on 64 bit architectures.

Signed-off-by: Jes Sorensen <jes@sgi.com>

---
 fs/select.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

Index: linux-2.6/fs/select.c
=================================--- linux-2.6.orig/fs/select.c
+++ linux-2.6/fs/select.c
@@ -314,7 +314,7 @@
 	int ret, size, max_fdset;
 	struct fdtable *fdt;
 	/* Allocate small arguments on the stack to save memory and be faster */
-	char stack_fds[SELECT_STACK_ALLOC];
+	long stack_fds[SELECT_STACK_ALLOC/sizeof(long)];
 
 	ret = -EINVAL;
 	if (n < 0)
@@ -639,8 +639,10 @@
  	struct poll_list *walk;
 	struct fdtable *fdt;
 	int max_fdset;
-	/* Allocate small arguments on the stack to save memory and be faster */
-	char stack_pps[POLL_STACK_ALLOC];
+	/* Allocate small arguments on the stack to save memory and be
+	   faster - use long to make sure the buffer is aligned properly
+	   on 64 bit archs to avoid unaligned access */
+	long stack_pps[POLL_STACK_ALLOC/sizeof(long)];
 	struct poll_list *stack_pp = NULL;
 
 	/* Do a sanity check on nfds ... */
