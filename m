From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 17 Oct 2003 03:36:25 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <marc-linux-ia64-106636180115387@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105942507026161@msgid-missing>
In-Reply-To: <marc-linux-ia64-105942507026161@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

Argh, a stupid typo snuck in, which breaks Itanium 1 build.  Please
do:

	bk pull http://lia64.bkbits.net/to-linus-2.5

Sorry about that.

Thanks!

	--david

 arch/ia64/kernel/perfmon.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

through these ChangeSets:

<rusty@linux.co.intel.com> (03/10/16 1.1537)
   [PATCH] ia64: fix perfmon typo that broke Itanium build
