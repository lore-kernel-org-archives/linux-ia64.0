From: Ray Bryant <raybry@engr.sgi.com>
Date: Sat, 02 Feb 2002 16:26:42 +0000
Subject: [Linux-ia64] cmpxchg patch
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------80154E65F2FCE62F52506545"
Message-Id: <marc-linux-ia64-105590698805982@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------80154E65F2FCE62F52506545
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

It seems to me that the size of the result of cmpxchg(ptr,old,new)
should depend on the size of *ptr and not the size of old.  For example,
see the following:


#include <stdio.h>
#define __SMP__
#define CONFIG_SMP 
#include <asm/system.h>
 
typedef unsigned long long uint64_t;
uint64_t  long lock=0xDEADBEEF00000000;
uint64_t  long result;
 
main()
{
        result = cmpxchg(&lock,0,1);
        if (result == 0) printf("failed!!\n");
        printf("sizeof(0)=%d sizeof(1)=%d\n",sizeof(0),sizeof(1));
        result = cmpxchg(&lock,(uint64_t)0,1);
        if (result != 0) printf("succeeded!!\n");
}

If you run this, you get 

failed!!
succeeded!!

The problem is that cmpxchg() returns 0xDEADBEEF00000000 but then gcc
generates a sxt4 to truncate the result down to an int, which is the
size of old.

This is incorrect as near as I can tell.

Attached is a patch to fix.

-- 
Best Regards,
Ray
-----------------------------------------------
Ray Bryant               SGI
512-453-9679 (work)      512-507-7807 (cell)
raybry@sgi.com           raybry@austin.rr.com
     Computers are like air conditioners.
   They stop working when you open Windows.
-----------------------------------------------
--------------80154E65F2FCE62F52506545
Content-Type: text/plain; charset=us-ascii;
 name="cmpxchg.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cmpxchg.diff"

--- ./include/asm-ia64/system.h	Sun Dec 23 02:58:36 2001
+++ /usr/people/raybry/tmp/system.h	Sat Feb  2 07:53:26 2002
@@ -345,7 +345,7 @@
 		_r_ = __cmpxchg_called_with_bad_pointer();				\
 		break;									\
 	}										\
-	(__typeof__(old)) _r_;								\
+	(__typeof__(*ptr)) _r_;								\
 })
 
 #define cmpxchg_acq(ptr,o,n)	ia64_cmpxchg("acq", (ptr), (o), (n), sizeof(*(ptr)))

--------------80154E65F2FCE62F52506545--


