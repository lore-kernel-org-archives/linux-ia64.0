From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 23 Feb 2010 23:16:07 +0000
Subject: RE: [2.6.33-rcX][regression] commit e8c93f breaks sn2 build
Message-Id: <987664A83D2D224EAE907B061CE93D53125BDF4F@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100223012511.GB24871@berriche.co.uk>
In-Reply-To: <20100223012511.GB24871@berriche.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

-DEFINE_PER_CPU(short [MAX_COMPACT_NODES], __sn_cnodeid_to_nasid);
+DEFINE_PER_CPU(short, __sn_cnodeid_to_nasid[MAX_COMPACT_NODES]);


This form was claimed to be syntactically less desirable in the
e-mail threads you quoted ... but it wasn't ever specified what
the problems with it were.

Can you confirm that an sn2 kernel built with this change
boots, and does the right things with this data structure?

If so, send me the patch with a "Signed-off-by" on it and
I'll apply it.

-Tony
