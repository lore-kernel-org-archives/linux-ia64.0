From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 22 May 2002 03:08:08 +0000
Subject: [Linux-ia64] NTP broken?
Message-Id: <marc-linux-ia64-105590701905591@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

NTP on Linux 2.4.17/IA64 appears broken.   ntpd never seems to be able
to pull the PLL into sync, even after using ntpdate to set the clock
to the correct server time.

What are other peoples' experiences with NTP on IA64?  

Peter C

