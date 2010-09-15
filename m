From: Phil Carmody <ext-phil.2.carmody@nokia.com>
Date: Wed, 15 Sep 2010 12:48:31 +0000
Subject: Re: [PATCH 0/2] ia64: possible module unwind table optimisation
Message-Id: <20100915124831.GB27658@esdhcp04044.research.nokia.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1284115245-23876-1-git-send-email-ext-phil.2.carmody@nokia.com> <AANLkTi=RsA0tACWOg+8RTSuDHwa4LGOiyO-4TxpJ_rb5@mail.gmail.com>
In-Reply-To: <AANLkTi=RsA0tACWOg+8RTSuDHwa4LGOiyO-4TxpJ_rb5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ext Tony Luck <tony.luck@intel.com>
Cc: "fenghua.yu@intel.com" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 15/09/10 01:18 +0200, ext Tony Luck wrote:
> On Fri, Sep 10, 2010 at 3:40 AM, Phil Carmody
> <ext-phil.2.carmody@nokia.com> wrote:
> > Alas I have no way to test this patch.
> 
> Phil,
> 
> I have this built and booted on an ia64 ... what do you want me to measure? The
> number of iterations in:
> 
>   for (table = unw.tables; table; table = table->next)
> 
> before we find the right table to look?

Yes, that's the one. Sorry I wasn't more explicit.

Phil
