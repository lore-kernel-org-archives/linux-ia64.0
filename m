From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 07 Nov 2007 16:30:25 +0000
Subject: RE: [PATCH] Move dmi_scan_machine() call ealier
Message-Id: <617E1C2C70743745A92448908E030B2A02E22687@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1194370267.31834.176.camel@bling>
In-Reply-To: <1194370267.31834.176.camel@bling>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   Thanks for the review Simon.  Is the patch below more like what
> you're thinking?  I agree that check_bugs doesn't initial seem like the
> most appropriate place to setup DMI, but think about what DMI is
> typically used for in the kernel.

Then re-name check_bugs() to something more suited to the things that
it is now doing. [I think that was what Simon was hinting at].

-Tony
