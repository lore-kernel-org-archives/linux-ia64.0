From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 30 Jul 2004 21:17:39 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01C02ED8@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

        bk pull http://lia64.bkbits.net/to-base-2.6

This will update the files shown below.

Thanks! (and thanks to those who provided bk help and scripts to make
         these changesets prettier and less painful than my first
         attempt at this).

-Tony

 arch/ia64/sn/io/sn2/bte_error.c |    9 +++++++++
 arch/ia64/sn/kernel/bte.c       |   11 ++++-------
 drivers/serial/sn_console.c     |   27 +++++++++++++++------------
 3 files changed, 28 insertions(+), 19 deletions(-)

through these ChangeSets:

<holt@sgi.com> (04/07/30 1.1832)
   bte_error.c:
   bte.c:
     After working with the chip designer some more, we have determined
one
     more hardware register we were supposed to write to ensure the SHUB
     chip was ready for future transfers.  This patch fixes that.  This
also
     allowed us to eliminate a udelay which was working around the
problem.

     During retesting, we uncovered a race condition where transfer
status
     was changed by a different cpu after we were expecting one value
which
     cascaded to additional problems.  This patch uses a local variable
to
     also eliminate that race.

     Signed-off-by: Robin Holt <holt@sgi.com>
     Signed-off-by: Tony Luck <tony.luck@intel.com>

<pfg@sgi.com> (04/07/30 1.1831)
   sn_console.c:
     move sn_debug_printf to only compile for DEBUG
     early printk needs to handle missing carriage returns
     Signed-off-by: Pat Gefre <pfg@sgi.com>
     Signed-off-by: Tony Luck <tony.luck@intel.com>
