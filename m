From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 15 Aug 2001 18:37:58 +0000
Subject: Re: [Linux-ia64] rwlock and atomic_sub on ia64
Message-Id: <marc-linux-ia64-105590698805082@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805063@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805063@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 14 Aug 2001 16:00:39 -0500, Noah Romer <nromer@lsil.com> said:

  Noah> David Mosberger wrote:

  Jes> I'll leave the question about rwsem's to David ;)

  >>  We're using the generic implementation on ia64.

Oops, Noah was actually talking about the rwlocks, not about rwsem.
For rwlocks, we have our own implementation.

  Noah> Yes, but how do I get to it? I finally found the ia64
  Noah> implementation of write_lock and read_lock for SMP systems
  Noah> (which is what I'm compiling on).(1) However, when I try to
  Noah> compile the driver I get a

  Noah>    warning: implicit declaration of function `rwlock_init'

  Noah> message. I have <linux/spinlock.h> included, and that's been
  Noah> enough up until now. Is there someother include file I need
  Noah> under the ia64 arch?

No, that seems to be a genuine omission.  rwlock_init() was added in
the 2.4.0 test series and I seem to have missed that.  There aren't
too many drivers that use it.  Anyhow, the fix is trivial.  Something
along the lines of:

--- include/asm-ia64/spinlock.h~	Tue Aug 14 00:06:43 2001
+++ include/asm-ia64/spinlock.h	Wed Aug 15 11:31:24 2001
@@ -108,6 +108,8 @@
 } rwlock_t;
 #define RW_LOCK_UNLOCKED (rwlock_t) { 0, 0 }
 
+#define rwlock_init(x) do { *(x) = RW_LOCK_UNLOCKED; } while(0)
+
 #define read_lock(rw)								\
 do {										\
 	int tmp = 0;								\

should do the trick.

	--david

