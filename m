From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 16 Feb 2005 18:18:37 +0000
Subject: RE: [rfc] generic allocator and mspec driver
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02EA1AAD@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I'm also not thrilled about mem.c being cloned into arch/ia64.

Looking more closely at what you did, things aren't as bad as I first
thought.  Strike that comment from the record.

But the PG_arch_1 dual usage issue remains.

-Tony
