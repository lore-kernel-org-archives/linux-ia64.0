From: KOCHI Takayoshi <t-kouchi@mvf.biglobe.ne.jp>
Date: Fri, 07 Sep 2001 17:49:07 +0000
Subject: [Linux-ia64] AT Keyboard not present?
Message-Id: <marc-linux-ia64-105590698805137@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Recently I noticed

keyboard: Timeout - AT keyboard not present?

message appears when the kernel tries to control keyboard LEDs
(i.e. CAPS, NumLock, ScrLock).
I don't see any symptoms in X environment, this is only at
VGA console.  I remember this was the behavior of ia64 linux of
very early days, but fixed at some point.

Does someone have ideas?

Regards,
-- 
KOCHI Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


