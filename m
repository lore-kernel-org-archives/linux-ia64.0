From: Keith Owens <kaos@sgi.com>
Date: Wed, 08 Oct 2003 07:08:14 +0000
Subject: Why does salinfo_log_read_cpu use kmalloc?
Message-Id: <marc-linux-ia64-106559698807998@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Why does arch/ia64/kernel/salinfo.c::salinfo_log_read_cpu() use
kmalloc() for the log buffer?  The code is running virtual with
interrupts enabled, SAL_GET_STATE_INFO has no special requirements for
the buffer attributes, so why not use vmalloc()?

