From: Joe Perches <joe@perches.com>
Date: Wed, 25 Jul 2012 18:41:58 +0000
Subject: RE: [PATCH] ia64: rename platform_* to ia64_platform_*
Message-Id: <1343241718.7045.3.camel@joe2Laptop>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120725080653.GA18233@localhost>
	 <1343204319.1693.6.camel@joe2Laptop> <20120725133950.GA30512@localhost>
	 <3908561D78D1C84285E8C5FCA982C28F1937113E@ORSMSX104.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F1937113E@ORSMSX104.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "Wu, Fengguang" <fengguang.wu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "alsa-devel@alsa-project.org" <alsa-devel@alsa-project.org>

On Wed, 2012-07-25 at 18:37 +0000, Luck, Tony wrote:
> >> Is platform_name particularly special?
> 
> Yes. It is the symbol that is currently colliding with other subsystem namespace.
> 
> >> Perhaps it's be better to rename all the other
> >> platform_<foo> uses to ia64_platform_<foo>
> >
> > That's good point in general, oh well I just wanted to make the minimal change..
> 
> Following that logic there isn't anything special about symbols starting with
> "platform" ... and we should hunt down every global symbol in every architecture
> that is local to the architecture and replace it with $arch_$symbol.
> 
> I think I'll just take the minimal patch to fix "platform_name" and continue to
> use a "fix as problems occur" algorithm to the namespace pollution problem.

That can lead to a lot of naming inconsistencies.

