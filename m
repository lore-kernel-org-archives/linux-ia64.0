From: Umut Aymakoglu <umuta@us.ibm.com>
Date: Tue, 30 Sep 2003 22:38:34 +0000
Subject: ia64_cmpxchg on United Linux 1.0
Message-Id: <marc-linux-ia64-106496180632562@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org





Hi -
   The macro used for test_and_set (ia64_cmpxchg) asm/atomic.h or
asm/spinlock.h on United Linux 1.0 is under #ifdef _KERNEL_  and therefore
can not be used in  user applications.  In RHAT 2.1 it was not under #ifdef
_KERNEL_ . Is there another macro for test_and_set  that user applications
can use?

thanks,
Umut

