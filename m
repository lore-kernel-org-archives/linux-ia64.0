From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 01 Aug 2002 15:00:42 +0000
Subject: [Linux-ia64] 64K pages on Itanium 1
Message-Id: <marc-linux-ia64-105590701905876@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A recent 2.4.18 ia64 patch removed 64K page support for Itanium 1, only
allowing it for McKinley.  What is the restriction on Itanium 1?  I
have a test case that needs 64K pages and I was hoping to run it on Big
Sur.  The simple test of allowing 64K for Itanium 1 breaks as soon as
it enters user space, during binfmt_elf processing.


