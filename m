From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 12 Nov 2003 07:18:12 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <marc-linux-ia64-106862150802884@msgid-missing>
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

Thanks!

	--david

 arch/ia64/kernel/signal.c     |    4 +++-
 include/asm-ia64/sn/nodepda.h |    2 +-
 2 files changed, 4 insertions(+), 2 deletions(-)

through these ChangeSets:

<davidm@wailua.hpl.hp.com> (03/11/11 1.1361)
   ia64: From Linus: Always disable system call restart when invoking a
   	signal handler.  Otherwise, a restarted system call that gets
   	interrupted before the restart has taken effect by _another_
   	signal will potentially restart the wrong system call.

<steiner@sgi.com> (03/11/11 1.1360)
   [PATCH] ia64: fix is_headless_node() for SN
   
   Without this patch, SN machines which have nodes that contain memory only (no
   CPUs will hang.

