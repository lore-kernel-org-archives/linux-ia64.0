From: Evan Felix <evan.felix@pnl.gov>
Date: Wed, 19 Nov 2003 17:10:34 +0000
Subject: qla2xxxx driver for IA64
Message-Id: <marc-linux-ia64-106926349321842@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andrew, I downloaded the qla2xxx-src-v8.00.00b6.tar.bz2 driver from
sourceforge, and had a few issues getting it woking under IA64 on a
rx2600 system.  We have two dual channel qla2312 cards. 

- I had to add '#include <vmalloc.h>' to qla_os.c
- the IA64 ioctl.h file did not hav the _IOXX_BAD macros, and i added
them, i'm not sure how safe that was, but it compiled.

The driver then built fine, and we have been testing it for a couple
days now.

Evan
-- 
-------------------------
Evan Felix
Administrator of Supercomputer #5 in Top 500, Nov 2003
Environmental Molecular Sciences Laboratory
Pacific Northwest National Laboratory
Operated for the U.S. DOE by Battelle
