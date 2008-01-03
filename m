From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 03 Jan 2008 22:14:57 +0000
Subject: RE: [patch 1/3] IA64: Slim down __clear_bit_unlock
Message-Id: <1FE6DD409037234FAB833C420AA843EC388F7E@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200711212258.lALMwPnR013399@imap1.linux-foundation.org>
In-Reply-To: <200711212258.lALMwPnR013399@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> - I removed the useless "volatile" stuff from the non-atomic versions
>   of the bit operations.

This is the correct thing to do ... but I wonder how we can validate
that there are no callers that were depending on the extra ordering
that the old volatile versions were providing.  Clearly any such callers
are broken ... but finding them the hard way (by executing the kernel
and waiting to see if something stange happens) is going to be unpleasant.

-Tony
