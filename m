From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 18 Jun 2008 20:47:35 +0000
Subject: RE: [PATCH 10/27] ia64/xen: xencomm conversion functions for
Message-Id: <57C9024A16AD2D4C97DC78E552063EA306213664@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12130840431594-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12130840431594-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> On ia64/xen, pointer arguments for hypercall is passed
> by pseudo physical address(guest physical address.)
> So such hypercalls needs address conversion functions.
> This patch implements concreate conversion functions for
s/concreate/concrete/

-Tony
