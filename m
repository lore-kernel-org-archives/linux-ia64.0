From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 03 Aug 2005 17:17:36 +0000
Subject: RE: 2.6.13-rc5 does not boot on Tiger4
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F040F6ED1@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeoe8fyrfb.fsf@sykes.suse.de>
In-Reply-To: <jeoe8fyrfb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>I can't get 2.6.13-rc5 to boot, it crashes very early without any sign of
>life, not even kdb can catch it.  Any idea?

Bother ... looks like generic-smp kernel is hosed.  Boots ok with tiger-defconfig
(which is what I've been testing for the past couple of weeks).

-Tony
