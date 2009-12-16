From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 16 Dec 2009 17:18:30 +0000
Subject: RE: [PATCH] implement early_io{re,un}map for ia64
Message-Id: <4BDB13256095B24D9644F65379E60426578D6948@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <89khjo$e5tirq@orsmga002.jf.intel.com>
In-Reply-To: <89khjo$e5tirq@orsmga002.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I'll push it, thanks. That keeps it very close to the commit which broke
> it, so bisection isn't hard.

Too late ... I bundled it with a pull request to Linus yesterday ... so
he will probably do the pull and get it into 2.6.33-rc1 (which will keep
it ahead of when Chris' iommu fix hits mainline).

-Tony
