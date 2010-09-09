From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 09 Sep 2010 17:41:00 +0000
Subject: RE: [PATCH] fix siglock
Message-Id: <987664A83D2D224EAE907B061CE93D53015DB60B6A@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4c8911a2302651c5f3@agluck-desktop.sc.intel.com>
In-Reply-To: <4c8911a2302651c5f3@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> This patch boots ... just started the stress test - running for ten
> minutes (means nothing, it usually fails at about 1 hour for me).

But the system hung at 44 minutes :-(  I'm still pretty sure that
this fsys.S path is the problem ... just need to see why my patch
is still giving problems.

-Tony
