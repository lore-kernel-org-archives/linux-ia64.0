From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 07 Aug 2006 15:57:51 +0000
Subject: RE: Silent data corruption caused by XPC.
Message-Id: <617E1C2C70743745A92448908E030B2A57CF0B@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060807154608.GC15674@lnx-holt.americas.sgi.com>
In-Reply-To: <20060807154608.GC15674@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> and verified it works.  I also added DBUG_ON statements to help catch
> this if a similar situation is encountered.

Can you just do this once at alloc time rather than at every use?

-Tony
