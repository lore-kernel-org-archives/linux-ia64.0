From: Keith Owens <kaos@sgi.com>
Date: Wed, 13 Mar 2002 03:53:31 +0000
Subject: [Linux-ia64] Exception handling and recovery
Message-Id: <marc-linux-ia64-105590701905250@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Unlike i386, the ia64 exception table code only recovers from invalid
user space addresses.  kdb can get other faults which EX() does not
currently allow recovery from.  Is there any reason why I should not
add exception table handling to ia64_fault(), to generalize the fault
recovery mechanism?


