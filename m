From: Matt_Domsch@Dell.com
Date: Wed, 18 Oct 2000 22:11:50 +0000
Subject: [Linux-ia64] iosapic.c NULL pointer deref
Message-Id: <marc-linux-ia64-105590678205597@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In the 2.4.0-test8 and -test9 IA-64 patch, the file arch/ia64/dig/iosapic.c,
function pci_for_each_dev(), the bridge pointer can be NULL, but gets
dereferenced anyhow, causing a nice tombstone.  I see this with an AMI
MegaRAID 471 card that happens to have two bridges on it.  Putting in tests
against NULL, that routine doesn't blow up any longer, but interrupts are
not properly assigned to that card then, and eventually all SCSI
reads/writes time out.

I'm happy to work with whomever is responsible for this code to have it
properly assign interrupts to these cards.

Thanks,
Matt
 

