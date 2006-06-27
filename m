From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 27 Jun 2006 22:26:47 +0000
Subject: RE: [PATCH] ia64: change usermode HZ to 250
Message-Id: <617E1C2C70743745A92448908E030B2A27F855@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060627220139.3168.69409.sendpatchset@tomahawk.engr.sgi.com>
In-Reply-To: <20060627220139.3168.69409.sendpatchset@tomahawk.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, Jeremy Higdon <jeremy@sgi.com>

> -# define HZ 1024
> +# define HZ 250

Is every distribution just using the default 250? (How boring,
what't the use of CONFIG options if everyone makes the same choice).

No other architecture seems to want to be nice to applications,
I see "#define HZ 100" across most of them.  If this is going in,
it should fix all architectures.

Isn't the usual answer "applications should not include kernel
headers"?

-Tony
