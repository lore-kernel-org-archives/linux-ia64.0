From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 09 Aug 2004 18:09:41 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01D0C8DA@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

I think this one needs to be in 2.6.8  With PREEMPT enabled
a dozen copies of:

	while true;do f=`mktemp`;touch $f;rm $f;done;

will crash a 4-way Tiger in under 2 minutes.

Please do a

        bk pull http://lia64.bkbits.net/to-base-2.6

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/mm/init.c        |    2 ++
 include/asm-ia64/pgalloc.h |   20 ++++++++++++++++++--
 2 files changed, 20 insertions(+), 2 deletions(-)

through these ChangeSets:

<yanmin.zhang@intel.com> (04/08/09 1.1841)
   init.c, pgalloc.h:
     Disable pre-emption around access to pgtable_cache_size,
pgd_quicklist,
     and pmd_quicklist.

     Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>
     Signed-off-by: Zou Nanhai <nanhai.zou@intel.com>
     Signed-off-by: Tony Luck <tony.luck@intel.com>
