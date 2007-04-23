From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 23 Apr 2007 20:31:04 +0000
Subject: RE: [PATCH] i386: fix stack alignment for signal handlers (ia64)
Message-Id: <617E1C2C70743745A92448908E030B2A0162D9A1@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A0162D7DA@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A0162D7DA@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Markus,

Thanks for the test program.

Before fix:
$ ./test_sigframe_alignment
in main      : sp = 0xbffffad0
in test      : sp = 0xbffffac0
in sighandler: sp = 0xbffff7ac
All done.

With fix applied:
$ ./test_sigframe_alignment
in main      : sp = 0xbffffad0
in test      : sp = 0xbffffac0
in sighandler: sp = 0xbffff7a0
All done.

Which looks correct.  Thanks for the fix, I'll push it in soon.

-Tony
