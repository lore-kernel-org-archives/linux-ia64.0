From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 03 Jul 2003 06:29:19 +0000
Subject: Reliably creating MCA on white box Itanium-1
Message-Id: <marc-linux-ia64-105721395828393@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is there a way of reliably creating an MCA on a white box Itanium 1?
B3 processors, firmware is B117A.  Failing that, what about creating an
MCA on a white box Itanium-2?

Loading a duplicate ITC is no good, I need an MCA that actually enters
ia64_mca_ucmc_handler in mca.c.  A working example using
PAL_CACHE_WRITE would be nice.

