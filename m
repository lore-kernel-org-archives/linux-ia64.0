From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 02 Sep 2008 15:19:10 +0000
Subject: RE: Kernel now broken on Ski simulator
Message-Id: <57C9024A16AD2D4C97DC78E552063EA30A006CBA@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87hc8yddun.wl%peter@chubb.wattle.id.au>
In-Reply-To: <87hc8yddun.wl%peter@chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Until Ski is fixed to implement IPIs, you need to boot with the
> force_pal_cache_flush argument to the kernel.

We could #ifndef CONFIG_IA64_HP_SIM around the test (since the
simulator presumably doesn't have the SAL cache flush bug :-)

-Tony
