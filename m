From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 05 Dec 2000 00:46:01 +0000
Subject: [Linux-ia64] No unwind data for ivt.S
Message-Id: <marc-linux-ia64-105590678205783@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is no unwind data in arch/ia64/kernel/ivt.S nor minstate.h (patch
2.4.0-test10-ia64-001115) which makes it impossible to unwind past an
interrupt.  Before I start on this code, has anybody already added
unwind data to ivt.S?


