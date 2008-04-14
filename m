From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 14 Apr 2008 20:49:54 +0000
Subject: RE: [2.6 patch] add SGI_IOC4 hardware dependencies
Message-Id: <1FE6DD409037234FAB833C420AA843EC011AFF01@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080413181543.GF2182@cs181133002.pp.htv.fi>
In-Reply-To: <20080413181543.GF2182@cs181133002.pp.htv.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Brent,

I'll hold off on this.  Adrian's commit comment is incorrect (I
guess that he was unaware of the out of tree driver).  Making
life hard for an out of tree GPL driver doesn't sound like the
right direction for us to take.

-Tony
