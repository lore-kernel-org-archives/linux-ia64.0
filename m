From: Christian Hildner <christian.hildner@hob.de>
Date: Tue, 29 Oct 2002 13:42:40 +0000
Subject: [Linux-ia64] RAW dependency in ivt.S
Message-Id: <marc-linux-ia64-105590709805283@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

testing the kernel 2.4.18 I found a RAW dependency (for P8) in ivt.S in
entry alt_dtlb_miss. The lines are

    cmp.ne p8,p0=r0,r23
(p8)    br.cond.spnt page_fault

Why I'am not providing a (simple) patch: I' am wondering about taking
the privilege level for the decision about taking a page fault or
inserting the identity mapped TLB entry. For my understanding there
should be checked for region 7.

Christian


