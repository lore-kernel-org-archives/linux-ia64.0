From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 15 Apr 2002 16:55:28 +0000
Subject: RE: [Linux-ia64] determining read or write on a page fault
Message-Id: <marc-linux-ia64-105590701905455@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905163@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905163@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 14 Apr 2002 15:08:54 -0700, "Neelakantam, NaveenX" <naveenx.neelakantam@intel.com> said:

  Naveen> It turns out that we have been running into a cc code
  Naveen> generation bug.  Changing the si_code = 0 case from "write"
  Naveen> to "read" happened to make the bug go away.

  Naveen> We have rewritten our code to workaround the bug, and
  Naveen> everything works as expected.  Sorry for the false alarm.

By "cc" do you mean gcc?  If so, what version?  Can you check whether
the bug still occurs with the latest version of gcc (gcc3.0 or, better
still, gcc3.1-prelease) or provide a test-case?

Thanks,

	--david

