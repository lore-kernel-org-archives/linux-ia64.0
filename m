From: Ken Pearlstein <pearlste@sgi.com>
Date: Fri, 17 May 2002 15:06:37 +0000
Subject: [Linux-ia64] Registers are incorrect in panic message
Message-Id: <marc-linux-ia64-105590701905583@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When the system panics, linux prints the contents of the register file.
Registers 0-31 are OK, the rest are garbage.  Has this problem been
addressed ?


--
Ken Pearlstein
650 933-3224




