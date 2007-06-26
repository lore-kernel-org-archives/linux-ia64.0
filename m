From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 26 Jun 2007 16:30:25 +0000
Subject: RE: intercept trap when running a 32bit binary
Message-Id: <617E1C2C70743745A92448908E030B2A01C68715@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070625221349.GA25054@bsd.hu>
In-Reply-To: <20070625221349.GA25054@bsd.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I've set the pagesize to 4096 in the kernel but that did not
> solve the problem.

Bother.  Another thing to try might be to use strace (the x86 version
in your chroot subtree) to see how far the program gets before it
dies.  If you have a native x86 system to compare this strace output
with what is supposed to happen, that would be even better.

-Tony
