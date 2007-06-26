From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 26 Jun 2007 19:13:07 +0000
Subject: RE: intercept trap when running a 32bit binary
Message-Id: <617E1C2C70743745A92448908E030B2A01C68A96@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070625221349.GA25054@bsd.hu>
In-Reply-To: <20070625221349.GA25054@bsd.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Here is the output http://humppa.hu/typescript

Nothing stands out there as totally off.  The program did open
and read /proc/cpuinfo shortly before it died, so it might have
found something that it didn't like in there (though it also read
it just after startup without apparent ill effects).

Then at the very end it failed to open "steam.cfg" ... perhaps
that was what it didn't like?

-Tony
