From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 15 Jan 2009 18:24:37 +0000
Subject: RE: [PATCH] ia64, xen: compilation fix caused by
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35CD259CC@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090115061655.GM1565%yamahata@valinux.co.jp>
In-Reply-To: <20090115061655.GM1565%yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > I assume that this patch will be pushed via the ia64 patch queue, no?
>
> I suppose that Tony would handle it. Tony?

Yes.  I'll put that in.

Yamahata-san: Would you please send me a .config file that
I can check in as arch/ia64/configs/xen_defconfig so I can
add a xen build to my regular regression run. Or more than
one if there are some interesting combinations of CONFIG
options that should be tested.  I'm not looking for complete
coverage of all the combinations, just the main sets that
are likely to be used in real systems.

Thanks.

-Tony
