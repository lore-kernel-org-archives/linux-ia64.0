From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 02 Nov 2004 22:07:18 +0000
Subject: RE: [PATCH] IA64 build broken... cond_syscall()... Fixes?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02510E27@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16774.62295.469676.663865@wombat.chubb.wattle.id.au>
In-Reply-To: <16774.62295.469676.663865@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Chubb <peterc@gelato.unsw.edu.au>, Andrew Morton <akpm@osdl.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org


>Andrew> Shouldn't we just bite the bullet and hoist all that
>Andrew> cond_syscall stuff out into its own .c file?
>
>OK.  Patch appended.
>
>Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>
>

Acked-by: Tony Luck

No surprise that Peter's fix works for me since I'm building
ia64 systems too.

-Tony
