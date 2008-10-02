From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 02 Oct 2008 22:30:03 +0000
Subject: RE: [patch 2/4] ia64 use trace hook
Message-Id: <57C9024A16AD2D4C97DC78E552063EA352D49484@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080917082022.191956457@sli10-desk.sh.intel.com>
In-Reply-To: <20080917082022.191956457@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I don't really follow the ia64 asm.  But looks OK to me, assuming that int
> return values are sign-extended in the register (I think syscall functions
> always return long instead).

int values do get sign-extended ... but you are right, it would be better
to declare syscall_trace_enter() as "long" to match normal syscall style
and remove all doubts about the return value being 64-bits when the asm
code checks it.

Thanks for looking at my patch.

-Tony
