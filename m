From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 11 Oct 2004 20:49:31 +0000
Subject: RE: [PATCH] 2.6 SGI Altix I/O code reorganization
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F022BEF32@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410042157.i94Lv7UC104750@fsgi900.americas.sgi.com>
In-Reply-To: <200410042157.i94Lv7UC104750@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick Gefre <pfg@sgi.com>
Cc: Colin Ngam <cngam@sgi.com>, Jesse Barnes <jbarnes@engr.sgi.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>We came to a resolution on the pci_root-ops issue, Jesse is OK 
>with the code, Jes and Christoph are 
>fine with the qla mod. I've added a couple of fixes from us as 
>well as removing a redundant check 
>pointed out in the review - see the full list below. So the 
>code is ready to go.
>
>Can you take this now Tony ?

Yes.  I applied those seven changesets to an local tree.  If any other
bug fixes turn up between now and 2.6.9-final you can send an 008-patch
that sits on top of those.

Yesterday on LKML Linus says he's aiming for 2.6.9 in a week or so.
When that happens I'll pull this into my tree and push to him (I don't
want to put it into my bkbits tree yet ... just in case I have some
other critical patch for ia64 that needs to go into 2.6.9).

-Tony
