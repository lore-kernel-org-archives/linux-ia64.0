From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Mon, 27 Mar 2006 12:56:22 +0000
Subject: atomic_ops.txt vs. test_and_set_bit()
Message-Id: <4427E0F6.20308@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I had a look at the atomic_ops.txt:

"      int test_and_set_bit(unsigned long nr, volatils unsigned long *addr);
       int test_and_clear_bit(unsigned long nr, volatils unsigned long *addr);
       int test_and_change_bit(unsigned long nr, volatils unsigned long *addr);
[...]

These routines, like the atomic_t counter operations returning values,
require explicit memory barrier semantics around their execution.  All
memory operations before the atomic bit operation call must be made
visible globally before the atomic bit operation is made visible.
Likewise, the atomic bit operation must be visible globally before any
subsequent memory operation is made visible.  For example:

       obj->dead = 1;
       if (test_and_set_bit(0, &obj->flags))
               /* ... */;
       obj->killed = 1;

The implementation of test_and_set_bit() must guarentee that
"obj->dead = 1;" is visible to cpus before the atomic memory operation
done by test_and_set_bit() becomes visible.  Likewise, the atomic
memory operation done by test_and_set_bit() must become visible before
"obj->killed = 1;" is visible."

The implementation of "test_and_set_bit()" does not meet this
requirement. It's a bad news.
If the description in atomic_ops.txt were not quite up to date... :-)

Regards,

Zoltan 
