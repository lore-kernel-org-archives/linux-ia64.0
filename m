From: "Mattox, Dave" <DMattox@UNITECH.COM>
Date: Tue, 17 Oct 2000 16:51:51 +0000
Subject: [Linux-ia64] Instruction Execution
Message-Id: <marc-linux-ia64-105590678205577@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I just got my Itanium Machine in and after installing Linux (no problems
with that, good work guys), I tried some timings.

I ran a loop 666,000,000 times and it appears that each bundle is taking 3
seconds to execute. So this means 3 cycles per bundle,
or 1 cycle per instruction. Is the Lion SDV Machine executing instructions
serially? If it is, is it Linux setting this, or are the beta chips disabled
in some manner?

Thanks in advance for help on this,
Dave Mattox

