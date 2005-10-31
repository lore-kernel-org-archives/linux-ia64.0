From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 31 Oct 2005 18:03:33 +0000
Subject: RE: ia64 get_mmu_context patch - v2
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04D0179A@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200510300133.j9U1Xwg10988@unix-os.sc.intel.com>
In-Reply-To: <200510300133.j9U1Xwg10988@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Glad to see the range limit is back in.
>
>As for the printk I can remove it. 
>Do I put out a patch on top of yours?
>Not sure what the protocol is here, first time.

Can you roll your patch and Ken's fixes into just one
patch (just Ken's code change patch ... not the code
layout patch that makes it all 80-column friendly).

Re-submit the rolled up patch to the list:

1) With a "Signed-off-by" line (your orginal patch
submission is missing one of these).

2) With an updated description of how the new version
of the patch fixes the problem (high level summary, don't
put too much detail here ... it's what I'll include as
the changeset commentary).

3) Don't forget to credit Ken and Rohit for their changes.

-Tony
