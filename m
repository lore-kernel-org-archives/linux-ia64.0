From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 17 Jun 2008 23:45:23 +0000
Subject: RE: [PATCH 06/27] ia64/xen: define NET_SKB_NET to 18 if xen.
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3061C5C2E@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12130840432829-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12130840432829-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Resolve it by increasing NET_SKB_NET from the default value 16 to 18.

Typo?  You mean NET_SKB_PAD here?

But in include/linux/skbuff.h it says: "It must be a power of 2".

Explain why 18 is ok.

-Tony
