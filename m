From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 03 May 2004 22:58:25 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <16534.52881.260763.547549@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/to-linus-2.5

This will update the files shown below.  Just a small bug fix.

Thanks!

	--david

 arch/ia64/kernel/head.S |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

through these ChangeSets:

<davidm@tiger.hpl.hp.com> (04/05/03 1.1609)
   ia64: Avoid ".save rp, r0" since the kernel unwinder doesn't support it yet.
   
   Once we switch to a libunwind-based kernel unwinder, this code can be
   re-enabled again.
