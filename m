From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 25 Aug 2008 18:29:25 +0000
Subject: RE: [Patch] Export cpu_core_map.
Message-Id: <57C9024A16AD2D4C97DC78E552063EA309EDEAE8@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080824125202.GC9501@sgi.com>
In-Reply-To: <20080824125202.GC9501@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I realize there was discussion about topology_core_siblings being the
> wrong thing for the SFC driver to use.  I think this change is justified
> despite that discussion.  This also gets an allmodconfig to build again
> for ia64.  This patch merely brings parity between x86 and ia64.

Robin,

Ok, I give in ... I've queued this locally and I'll push and
ask Linus to pull in the next few days.

-Tony
