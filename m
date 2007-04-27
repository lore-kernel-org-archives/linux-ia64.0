From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 27 Apr 2007 18:49:54 +0000
Subject: RE: Inquiry about brl statement
Message-Id: <617E1C2C70743745A92448908E030B2A0166A137@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200704271716.57969.christian.kandeler@hob.de>
In-Reply-To: <200704271716.57969.christian.kandeler@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> As I remember it, a taken branch acts as a stop whereas a non-taken
> branch doesn't (so if no explicit stop bit is following a branch, then
> it must be OK for the entire group to be executed in parallel).  I
> suppose it's possible the definition changed or that my (admittedly
> bad) memory is playing tricks on me. ;-)

The SDM page for "brl" doesn't look to have any get-out-of stop-bits-free
option.  It says:

 "This instruction must be immediately followed by a stop; otherwise
  its behaviour is undefined."

-Tony
