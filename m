From: Mitchell Blank Jr <mitch@sfgoth.com>
Date: Sat, 01 Apr 2006 03:39:57 +0000
Subject: Re: [patch] avoid unaligned access when accessing poll stack
Message-Id: <20060401033957.GC3157@gaz.sfgoth.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0sloytyj5.fsf@jaguar.mkp.net> <200603311800.19364.ak@suse.de> <yq0odzmtwni.fsf@jaguar.mkp.net> <20060401023538.GB3157@gaz.sfgoth.com>
In-Reply-To: <20060401023538.GB3157@gaz.sfgoth.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Here's a slightly updated version of my patch: it changes the

		if (size < sizeof(stack_fds) / 6)
to:
		if (size <= sizeof(stack_fds) / 6)

Otherwise this is exactly the same as the version I just posted.  The old
code had this problem too but before it only mattered if SELECT_STACK_ALLOC
was a multiple of six.

Signed-off-by: Mitchell Blank Jr <mitch@sfgoth.com>

diff --git a/fs/select.c b/fs/select.c
index 071660f..c46d40c 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -311,7 +311,8 @@ static int core_sys_select(int n, fd_set
 {
 	fd_set_bits fds;
 	char *bits;
-	int ret, size, max_fdset;
+	int ret, max_fdset;
+	unsigned int size;
 	struct fdtable *fdt;
 	/* Allocate small arguments on the stack to save memory and be faster */
 	long stack_fds[SELECT_STACK_ALLOC/sizeof(long)];
@@ -335,8 +336,8 @@ static int core_sys_select(int n, fd_set
 	 */
 	ret = -ENOMEM;
 	size = FDS_BYTES(n);
-	if (6*size < SELECT_STACK_ALLOC)
-		bits = stack_fds;
+	if (size <= sizeof(stack_fds) / 6)
+		bits = (char *) stack_fds;
 	else
 		bits = kmalloc(6 * size, GFP_KERNEL);
 	if (!bits)
@@ -373,7 +374,7 @@ static int core_sys_select(int n, fd_set
 		ret = -EFAULT;
 
 out:
-	if (bits != stack_fds)
+	if (bits != (char *) stack_fds)
 		kfree(bits);
 out_nofds:
 	return ret;
