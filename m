From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 14 Sep 2004 18:42:30 +0000
Subject: RE: INIT dumps broken?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F020060F3@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
In-Reply-To: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>I noticed that with kernel v2.6.9-rc1 INIT dumps appear not to work
>anymore.  The machine just hangs, without ever (visibly) control
>reaching the OS INIT handler.  v2.6.7-rc3 was OK.  Anybody know what
>broke?

Nothing immediately obvious.  mca_asm.S hasn't been touched in that
interval.  mca.c has had a few changes for cpe polling, and some
cleanup in the split of things between mca_init() and mca_late_init(),
but the INIT handlers are registered in mca_init() before any code
changes to that routine.

-Tony
