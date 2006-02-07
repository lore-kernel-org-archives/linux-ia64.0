From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 07 Feb 2006 23:06:52 +0000
Subject: RE: [2.6 patch] IA64_GENERIC shouldn't select other stuff
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05A6D512@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060207221157.GA3524@stusta.de>
In-Reply-To: <20060207221157.GA3524@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Adrian Bunk <bunk@stusta.de>, Matthew Wilcox <matthew@wil.cx>
Cc: Keith Owens <kaos@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

> AFAIR your defconfig was intended for the "runs everywhere" case (with 
> the exception that in this case the bug that CONFIG_ITANIUM is not set 
> is still unfixed - would you accept a patch to fix this?).

Only die-hard early adopters are still using CONFIG_ITANIUM systems, and
they have the knowledge to turn this option on.  So no, I'm not looking
for a patch to add this to defconfig.

-Tony
