From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 06 Jan 2005 21:31:35 +0000
Subject: RE: fixing 2.6.10 UP builds
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02A6775A@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050106201427.GA6009@jale>
In-Reply-To: <20050106201427.GA6009@jale>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Debian is putting together 2.6.10 packages, and we noticed 
>that we still need to forward port Jesse's patches.  Attached is the patch 
>Ubuntu forward ported, and Debian is including.  It would be great to get 
>this merged upstream so we don't need to port it for each release.

2.6.10 built as UP for me (I have it running on zx2000).

Can you provide some changelog information on what this is doing.  It
also looks like this might be better separated back into a couple (or
more) patches ... I see that arch/ia64/kernel/numa.c is being patched
twice by this patch.

A "Signed-off-by:" line (or lines) is needed too.

-Tony
