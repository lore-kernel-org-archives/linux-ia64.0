From: "John Hawkes" <hawkes@sgi.com>
Date: Fri, 16 Dec 2005 18:39:34 +0000
Subject: Re: [PATCH] ia64: disable preemption in udelay()
Message-Id: <007001c60270$1066c0c0$6f00a8c0@comcast.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051216024252.27639.63120.sendpatchset@tomahawk.engr.sgi.com> <20051216122854.GA10375@lnx-holt.americas.sgi.com> <20051216173342.GA12205@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Robin Holt <holt@sgi.com>
Cc: Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Keith Owens <kaos@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>

From: "Luck, Tony" <tony.luck@intel.com>
...
> A good question ... I'm going to put John's change in as-is for now so
> that 2.6.15 can benefit from the reduced code size of the out-of-line
> and avoid the ugly bug when preemption is enabled on a drifty system.

Okay, but I'll propose some changes to that soon, probably using Robin Holt's
suggestions.  I'm concerned about the impact of interrupts outside of the
inner loop and inside the outer loop, which would increase the effective delay
time.

John Hawkes

