From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 08 Sep 2005 22:31:58 +0000
Subject: RE: [PATCH] altix: Add volatile qualifiers in places where it seems necessary
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0456EF71@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050902153612.8521.73623.91869@attica.americas.sgi.com>
In-Reply-To: <20050902153612.8521.73623.91869@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>+			__sn_clrq_relaxed(&ptr->tio.cp_control, bits);
>+			__sn_setq_relaxed(&ptr->tio.cp_control, bits);

Breaks the build for bigsur, generic and hpsim configs with several
"undefined reference to" link errors for these two symbols.

Probably means that the bigsur/hpsim defconfigs are dragging in
things that they shouldn't.  But the errors on the generic build
are more worrying.

-Tony
