From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 09 Dec 2008 18:50:56 +0000
Subject: RE: next-20081104 - kernel panic on ia64 box, at
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35C7EEAA3@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081204200745.eff0ac87.sfr@canb.auug.org.au>
 <20081209070730.GA12102@linux.vnet.ibm.com>
In-Reply-To: <20081209070730.GA12102@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

>       next-20081204 kernel panic's, while booting up on ia64 box. This panic
> was not reproducible with the latest next-20081208 kernel.

I saw that too ... it was preceeded by an "impossible" WARN_ON message,
so I put it down to some experimental/untested code in linux-next.

-Tony
