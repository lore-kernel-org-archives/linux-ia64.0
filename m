From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 17 Feb 2004 19:41:04 +0000
Subject: suspicious riva/fbdev.c pointer casting
Message-Id: <16434.28240.798764.399492@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I see the following suspicious warnings when building the riva/fbdev in 2.6:

drivers/video/riva/fbdev.c:503: warning: cast to pointer from integer of differe
nt size
drivers/video/riva/fbdev.c:503: warning: cast from pointer to integer of differe
nt size
drivers/video/riva/fbdev.c:505: warning: cast to pointer from integer of differe
nt size
drivers/video/riva/fbdev.c:505: warning: cast from pointer to integer of differe
nt size

I'm pretty sure those point to real errors (the variable which is
being accessed appears to sit on the stack, so it's address is
guaranteed not to fit in a u32).  I don't have suitable hardware to
test this at the moment.  Can someone else look into fixing this?

	--david
