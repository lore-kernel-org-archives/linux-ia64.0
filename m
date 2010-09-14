From: Tony Luck <tony.luck@intel.com>
Date: Tue, 14 Sep 2010 23:18:55 +0000
Subject: Re: [PATCH 0/2] ia64: possible module unwind table optimisation
Message-Id: <AANLkTi=RsA0tACWOg+8RTSuDHwa4LGOiyO-4TxpJ_rb5@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1284115245-23876-1-git-send-email-ext-phil.2.carmody@nokia.com>
In-Reply-To: <1284115245-23876-1-git-send-email-ext-phil.2.carmody@nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Phil Carmody <ext-phil.2.carmody@nokia.com>
Cc: fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Sep 10, 2010 at 3:40 AM, Phil Carmody
<ext-phil.2.carmody@nokia.com> wrote:
> Alas I have no way to test this patch.

Phil,

I have this built and booted on an ia64 ... what do you want me to measure? The
number of iterations in:

  for (table = unw.tables; table; table = table->next)

before we find the right table to look?

-Tony
