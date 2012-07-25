From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 25 Jul 2012 18:37:22 +0000
Subject: RE: [PATCH] ia64: rename platform_* to ia64_platform_*
Message-Id: <3908561D78D1C84285E8C5FCA982C28F1937113E@ORSMSX104.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120725080653.GA18233@localhost>
 <1343204319.1693.6.camel@joe2Laptop> <20120725133950.GA30512@localhost>
In-Reply-To: <20120725133950.GA30512@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Wu, Fengguang" <fengguang.wu@intel.com>, Joe Perches <joe@perches.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "alsa-devel@alsa-project.org" <alsa-devel@alsa-project.org>

>> Is platform_name particularly special?

Yes. It is the symbol that is currently colliding with other subsystem namespace.

>> Perhaps it's be better to rename all the other
>> platform_<foo> uses to ia64_platform_<foo>
>
> That's good point in general, oh well I just wanted to make the minimal change..

Following that logic there isn't anything special about symbols starting with
"platform" ... and we should hunt down every global symbol in every architecture
that is local to the architecture and replace it with $arch_$symbol.

I think I'll just take the minimal patch to fix "platform_name" and continue to
use a "fix as problems occur" algorithm to the namespace pollution problem.

-Tony

