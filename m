From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 31 Jul 2007 16:54:05 +0000
Subject: RE: regression on HP zx1 platform from ACPI autoload modulespatches
Message-Id: <617E1C2C70743745A92448908E030B2A020E3B4F@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1185900042.18821.213.camel@queen.suse.de>
In-Reply-To: <1185900042.18821.213.camel@queen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: trenn@suse.de
Cc: Doug Chapman <doug.chapman@hp.com>, Tony Luck <tony.luck@gmail.com>, Michal Piotrowski <michal.k.k.piotrowski@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

> Tony, it looks like the patch has not hit Linus tree yet:


Huh?  I can see it in his tree via gitweb.  Here's the patch:

	http://tinyurl.com/3csnu6

and the raw "blob" for sba_iommu.c:

	http://tinyurl.com/397cy6

[Scroll down to line 2018 and you'll see the new code in place].

Something very odd is happening.

-Tony
