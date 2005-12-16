From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 16 Dec 2005 01:04:40 +0000
Subject: Re: [PATCH] ia64: disable preemption in udelay()
Message-Id: <20051216010440.GA9886@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051214232526.9039.15753.sendpatchset@tomahawk.engr.sgi.com> <20051215225040.GA9086@agluck-lia64.sc.intel.com>
In-Reply-To: <20051215225040.GA9086@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hawkes@sgi.com
Cc: Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Keith Owens <kaos@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>

On Thu, Dec 15, 2005 at 02:50:40PM -0800, Luck, Tony wrote:
> This does make the function a bit big for an "inline" though.  Does
> it really need to be inline?  Do we care how fast our delay loops
> are?

Moving the current slim-line udelay() out of line would save 41 Kbytes
of text in the generic vmlinux, plus making any modules that use
udelay smaller too. Savings run from a 128-160 bytes for drivers
with just one call to a max of 9 Kbytes for qla2xxx.ko.

Being out-of-line would reduce accuracy, but this would only be
significant when the sleep is for a very small number of microseconds.

So if we need to add more code to udelay(), I think that it
should be moved out-of-line too (into arch/ia64/kernel/time.c).

alpha, m68knommu, powerpc and sh64 already have out of line udelay().

-Tony
