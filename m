From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 06 Jan 2009 00:42:01 +0000
Subject: RE: [PATCH 5/5] IA64 dynamic ftrace support
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35CB94F54@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> In this way, only one instruction is changed to convert code between nop
> and call. This should meet dyn-ftrace's requirement.
> But this requires CPU support brl instruction, so dyn-ftrace isn't
> supported for old Itanium system. Assume there are quite few such old
> system running.

Perhaps very few old Merced systems are used for development
and performance tuning (the kind of work where ftrace is useful).
So not having ftrace support on them might not be too big a loss.

-Tony
