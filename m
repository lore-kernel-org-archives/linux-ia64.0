From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 11 Nov 2003 00:55:30 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <marc-linux-ia64-106851224727368@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105942507026161@msgid-missing>
In-Reply-To: <marc-linux-ia64-105942507026161@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/to-linus-2.5

This will update the files shown below.

This one fixes the mprotect() bug found by Russell King last week.
It's a critical bug fix because a knowledgable programmer could
abuse it to crash a machine.

Thanks!

	--david

 include/asm-ia64/pgtable.h |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

through these ChangeSets:

<davidm@tiger.hpl.hp.com> (03/11/10 1.1357)
   Fix pte_modify() bug which allowed mprotect() to change too many bits.
   Found by Russell King.

