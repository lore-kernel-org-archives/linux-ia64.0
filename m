From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 06 May 2008 18:25:55 +0000
Subject: RE: [BUG?][2.6.25-mm1] sleeping during IRQ disabled
Message-Id: <1FE6DD409037234FAB833C420AA843EC0147BA82@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> attached my .config.
>
> Hmm, amazing..

Ah.  With that .config I see the "BUG:" too (on linus-latest).

Now to try to figure out what is different in that one
from the tiger_defconfig.

-Tony
