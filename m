From: roneng@ca.ibm.com
Date: Tue, 18 Apr 2000 22:47:38 +0000
Subject: [Linux-ia64] Kernel long branch support
Message-Id: <marc-linux-ia64-105590678205018@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi,
I am getting an illegal instruction fault from the kernel after using the
latest linker
which supports long branches (i.e. branches greater then 16M) to compile
large shared libraries.
I was wondering if anyone knows if the latest kernels 2.3.51/or 2.3.50
support
long branches, or if anyone is working on long branch support for the
kernel.

Thank you,
Ronen Grosman
- e-mail roneng@ca.ibm.com




