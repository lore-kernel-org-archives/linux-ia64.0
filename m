From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 02 Jan 2008 22:03:08 +0000
Subject: RE: I have a problem about changing a bundle, help!
Message-Id: <1FE6DD409037234FAB833C420AA843EC3885AC@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>	If the statements are unsafe, how can i change a bundle safely?

If you are on a cpu that supports "st16" (Montecito or later) then you can
use that to update the whole bundle in a single atomic write rather than
using memcpy().

Without st16, I think the only safe way to update the bundle is to ensure
that no processor is executing it while the update is occuring.

-Tony
