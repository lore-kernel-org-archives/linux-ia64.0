From: Rich Altmaier <richa@engr.sgi.com>
Date: Fri, 22 Dec 2000 18:19:57 +0000
Subject: [Linux-ia64] PRO64 compiler store ordering for drivers
Message-Id: <marc-linux-ia64-105590678205875@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205862@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205862@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Since Jes Sorensen asked a few questions around store ordering and device
drivers, I thought I would send out a definition of the behavior of the
PRO64 compiler (which is based on our MIPSPro compiler and IRIX OS
history).   Of course these rules illustrate that correctness demands the use
of the C volatile attribute, for any code doing uncached load/store (such
as kernel code, or user level graphics code).
Thanks, Rich
Rich Altmaier
SGI
richa@sgi.com


PRO64 compiler handling of store ordering cases:

 Case 1:
        *(unsigned int *)p1 = 1;
         *(unsigned int *)p2 = 2;
         *(unsigned int *)p3 = 3;
Because the compiler doesn't know where p1, p2,
and p3 point to (maybe the same location) the stores are done in the order
coded.

Case 2
         *(unsigned int *)p1 = 1;
         *(unsigned int *)p2 = 2;
         *(unsigned int *)p3 = 3;
         another_example();
If another_example() happens to be a procedure call, all the updates will
happen prior to the call. If another_example() happens to be inlined,
such update guarantees are not present.
Except that using -ipa potentially
gives the compiler the smarts to decide whether or not to move the stores after
the call to another_example (even if it is not inlined).

Case 3
        *(unsigned int *)p1 = 1;
        intvar = *(unsigned int *)p1;

Under optimization the load of "*(unsigned int *)p1" can be optimized away.
But the store will still be done.


Case 4:
        *(volatile unsigned int *)p1 = 1;
        intvar = *(volatile unsigned int *)p1;
Under optimizer the load of "*(volatile unsigned int *)p1" can NOT be
optimized away.  That is what volatile does for you.  It keeps the compiler
from removing the load operation.


Case 5:
        void foo(int *p1, int choice) {
        int localint1, localint2, localint3;
        int *p2;

        switch (choice) {
        case 1: p2 = &localint1; break;
        case 2: p2 = &localint2; break;
        case 3: p2 = &localint3; break;
        }
        ...

        *p1 = 1;
        *p2 = 2;

In this case the order may or may not be preserved.  The key is that p1 and
p2 can not point to the same object.  p2 is assigned addresses of local to foo
variables.  p1 has an address of some non-local to foo variable.  Thus
the order is not preserved.
Changing p1, p2, or both p1 and p2 to volatile does not affect the ordering
in this case.






