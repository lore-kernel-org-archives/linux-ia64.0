From: Michael Madore <mmadore@turbolinux.com>
Date: Mon, 24 Jul 2000 19:41:59 +0000
Subject: [Linux-ia64] Internal Error compiling ddd
Message-Id: <marc-linux-ia64-105590678205226@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I get the following error when compiling ddd-3.2.1 on IA-64:

c++  -DHAVE_CONFIG_H -DNDEBUG -O2 -g -W -Wall -trigraphs  -c
-I. -I. -I./.. -isystem /usr/X11R6/include -o DataDisp.o DataDisp.C
BoxPoint.h: In function `void DataDisp::newCB (_WidgetRec *, void *, void
*)':
BoxPoint.h:1352: Internal compiler error in `fix_lexical_addr', at
function.c:5409
Please submit a full bug report.

The version of gcc is 2.9-ia64-000216-final.

Let me know if I can provide better info to debug this.

Mike Madore
Software Engineer
TurboLinux, Inc.



