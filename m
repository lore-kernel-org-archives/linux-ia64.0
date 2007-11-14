From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 14 Nov 2007 23:39:35 +0000
Subject: RE: [patch 1/1] ia64: increase .data.patch offset
Message-Id: <617E1C2C70743745A92448908E030B2A02F193F3@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200711130855.lAD8tBWd002649@imap1.linux-foundation.org>
In-Reply-To: <200711130855.lAD8tBWd002649@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> What I'll do today, is try a number of different compiler version
> (it's realtively easy for me to do this), and email tomorrow which
> ones compile a generic  kernel, and if I have time, which ones boot.

Are some versions of the compiler actually broken (and generating spurious stuff so
overflowing this section) ... or are we just skating close to the edge so that minor
differences in generated code push us over the limit.

If the only reason to reject a compiler version can be fixed by Andrew's patch to
change the 0x500 to 0x600 in gate.lds.S, then that seems a reasonable thing
to do.

-Tony
