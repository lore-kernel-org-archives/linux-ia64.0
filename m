From: roneng@ca.ibm.com
Date: Tue, 22 Aug 2000 18:23:53 +0000
Subject: [Linux-ia64] C++ compatible include files
Message-Id: <marc-linux-ia64-105590678205375@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi,

I was wondering if there are plans to make the ia64 kernel include files
C++ compatible. In particular
the ::: in the embedded assembly in system.h and atomic.h seems to prevent
these files,
and the files that include them (e.g. fs.h) from being included in C++
programs.

Thanks,
Ronen Grosman
roneng@ca.ibm.com



