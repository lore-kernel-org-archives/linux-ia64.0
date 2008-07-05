From: Matthew Wilcox <matthew@wil.cx>
Date: Sat, 05 Jul 2008 02:03:51 +0000
Subject: Re: the printk problem
Message-Id: <20080705020350.GN14894@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080625131101.GA6205@digi.com> <20080704104634.GA31634@digi.com> <20080704111540.ddffd241.akpm@linux-foundation.org> <alpine.LFD.1.10.0807041147450.2815@woody.linux-foundation.org> <alpine.LFD.1.10.0807041250220.2815@woody.linux-foundation.org> <20080704132716.f1e12554.akpm@linux-foundation.org> <20080704204252.GM14894@parisc-linux.org> <20080704150100.1f7b8a65.akpm@linux-foundation.org>
In-Reply-To: <20080704150100.1f7b8a65.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Anvin <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org

On Fri, Jul 04, 2008 at 03:01:00PM -0700, Andrew Morton wrote:
> (heck, let's cc lkml - avoid having to go through all this again)
> 
> It would be excellent if gcc had an extension system so that you could
> add new printf control chars and maybe even tell gcc how to check them.
> But of course, if that were to happen, we couldn't use it for 4-5 years.

I believe NetBSD added that as an extension many years ago.  Dunno if
they still have it.

> What I had initially proposed was to abuse %S, which takes a wchar_t*. 
> gcc accepts `unsigned long *' for %S.
> 
[...]
> - there's a cast, so you could accidentally do
> 
> 	printk("here is an inode: %Si\n", (unsigned long *)dentry);
> 
> - there's a cast, and they're ugly
> 
> - gcc cannot of course check that the arg matches the control string
> 
> Unfortunately (and this seems weird), gcc printf checking will not
> accept a void* for %S: it _has_ to be wchar_t*, and the checker won't
> permit void* substitution for that.

Presumably that's the compiler getting rid of the first and third
downside ;-)

> Anyway, Linus took all that and said "let's abuse %p instead".  It
> _will_ accept any pointer so we can instead do:
> 
> 	printk("here is an inode: %pi\n", inode);
> 
> which is nicer.

Yes.  It's possible to confuse it, of course.

	printk("Function %pSucks\n", sys_open);

but I really doubt we have such a usage in the kernel today.

> > u64 is easy to fix, and I don't know why we haven't.  Just make it
> > unsigned long long on all architectures.
> 
> Yeah.  Why don't we do that?

Patch ...

[PATCH] Make u64 long long on all architectures

It is currently awkward to print a u64 type.  Some architectures use
unsigned long while others use unsigned long long.  Since unsigned long
long is 64-bit for all existing Linux architectures, change those that
use long to use long long.  Note that this applies only within the
kernel.  If u64 is being used in a C++ method definition, the symbol
mangling would change.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>

diff --git a/include/asm-generic/int-l64.h b/include/asm-generic/int-l64.h
index 2af9b75..32f07bd 100644
--- a/include/asm-generic/int-l64.h
+++ b/include/asm-generic/int-l64.h
@@ -23,8 +23,13 @@ typedef unsigned short __u16;
 typedef __signed__ int __s32;
 typedef unsigned int __u32;
 
+#ifdef __KERNEL__
+typedef __signed__ long long __s64;
+typedef unsigned long long __u64;
+#else
 typedef __signed__ long __s64;
 typedef unsigned long __u64;
+#endif
 
 #endif /* __ASSEMBLY__ */
 

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
