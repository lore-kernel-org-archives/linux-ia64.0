From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 23 Sep 2004 23:23:54 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200409232323.i8NNNsU16234@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/linux-ia64-release-2.6.9

This will update the file shown below.

Thanks!

-Tony

 arch/ia64/kernel/salinfo.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletion(-)

through these ChangeSets:

<tony.luck@intel.com> (04/09/23 1.1950)
   [IA64] When we exhaust the supply of records to read, clear the event status.
   
   Patch written by Ben Woodard.  Sanity checked by Jesse Barnes.
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

