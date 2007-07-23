From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 23 Jul 2007 20:42:10 +0000
Subject: RE: Linus' tree broken?
Message-Id: <617E1C2C70743745A92448908E030B2A01FEC3EC@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46A4B026.9030307@sgi.com>
In-Reply-To: <46A4B026.9030307@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > Could be, but it sounds like there's something fishy in the current
> > tree - Doug Chapman is having problems as well, presumably on zx1 boxes.
>
> I am seeing the panic on HP zx1 and zx2 systems.  Currently doing a git
> bisect to narrow it down.

2.6.23-rc1 booted OK on my rx2620.  On the zx2000 too (though X is currently
behaving weirdly, I think that might be some other issue though).

-Tony
