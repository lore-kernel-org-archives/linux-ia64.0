From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 04 Dec 2003 19:44:04 +0000
Subject: RE: [patch] 2.6.0-test9 pal/sal/salinfo/mca
Message-Id: <marc-linux-ia64-107056722025753@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106978478405713@msgid-missing>
In-Reply-To: <marc-linux-ia64-106978478405713@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> As Keith mentioned, the current 2.4 and 2.6 MCA code should be
> essentially identical.

David deferred Keith's last MCA patch for 2.6.1 ... so the current
checked in 2.6 code doesn't have the latest goodies.

Keith's patch can be found here:
 http://marc.theaimsgroup.com/?l=linux-ia64&m6974968032730&w=2

Don't forget these all require a user level daemon to pick
up CMC and CPE reports and log them in all their glory.

Keith: did you post salinfo-0.4 yet?  I haven't seen it.

-Tony
