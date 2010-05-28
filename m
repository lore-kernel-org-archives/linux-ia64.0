From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 28 May 2010 21:57:28 +0000
Subject: RE: [git pull] Fix ia64 build breakage
Message-Id: <987664A83D2D224EAE907B061CE93D530113501FCF@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4bff019827164eea63@agluck-desktop.sc.intel.com>
In-Reply-To: <4bff019827164eea63@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Can I get your .config?  I thought I tested ia64 !NUMA, but I see now
>that when I edit the .config and 'make silentoldconfig', IA64_GENERIC
>just selects NUMA again.

One of the configs that failed was arch/ia64/configs/tiger_defconfig.

> Even 'make allnoconfig' on ia64 generates a .config with NUMA=y.

Yup, that's definitely an anomaly (since SMP=n). It catches some
strange stuff :-)

> I'll send an update patch when I get it figured out.

That would drop the ugly #ifdefs that I added. Good!

Thanks

-Tony
