From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 30 Apr 2004 17:49:29 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <16530.37289.444097.580591@napali.hpl.hp.com>
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

This will update the files shown below.  This is an urgent fix: it
undoes a BUG_ON(irqs_disabled()) in smp_call_function().  The patch is
correct, but it turns out there are drivers (such as SCSI generic)
that rely on the being able to run the risk of deadlock.

Keith, my suggestion is that the patch be resubmitted after 2.6.7
opens up.  Probably it would be best to add the BUG_ON() to _all_
platforms.

Thanks!

	--david

 arch/ia64/kernel/smp.c |    2 --
 1 files changed, 2 deletions(-)

through these ChangeSets:

<davidm@tiger.hpl.hp.com> (04/04/30 1.1608)
   Cset exclude: davidm@tiger.hpl.hp.com|ChangeSet|20040427053149|28511

