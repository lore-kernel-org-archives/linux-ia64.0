From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 18 Jun 2008 22:13:13 +0000
Subject: RE: [PATCH 26/27] ia64/pv_ops: update Kconfig for paravirtualized
Message-Id: <57C9024A16AD2D4C97DC78E552063EA306213776@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1213084044647-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1213084044647-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> introduce CONFIG_PARAVIRT_GUEST, CONFIG_PARAVIRT for
> paravirtualized guest.
> introduce CONFING_XEN, CONFIG_IA64_XEN for xen.

s/CONFING_XEN/CONFIG_XEN/

Would it make sense to rename CONFIG_IA64_XEN to be
CONFIG_IA64_XEN_GUEST?  The comments you add to
arch/ia64/Kconfig say that this is what it means.

-Tony
