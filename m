From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 17 Mar 2004 19:14:46 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <16472.41894.115058.240594@napali.hpl.hp.com>
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

This fixes an important bug which was tracked down by Luming You.

Thanks!

	--david

 include/asm-ia64/gcc_intrin.h |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

through these ChangeSets:

<davidm@tiger.hpl.hp.com> (04/03/17 1.1667)
   ia64: Prevent GCC from clobbering r13.  Found by Luming You.

   Without this change, GCC thinks it's OK to clobber r13.  It doesn't do it
   very often, but it's enough if it does it once and it turns out
   acpi_bus_receive_event() had code that would trigger this issue.
   Fix by declaring r13 as a global register variable.

