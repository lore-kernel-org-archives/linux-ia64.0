From: "Neelakantam, NaveenX" <naveenx.neelakantam@intel.com>
Date: Tue, 16 Apr 2002 20:18:15 +0000
Subject: RE: [Linux-ia64] determining read or write on a page fault
Message-Id: <marc-linux-ia64-105590701905458@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905163@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905163@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yes, I meant gcc (version 2.96 20000731).  I've verified that the bug still
exists in gcc3.0, but I haven't been able to create a testcase yet.

Naveen

-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
Sent: Monday, April 15, 2002 11:55 AM
To: Neelakantam, NaveenX
Cc: Hoeflinger, Jay P; 'davidm@hpl.hp.com'; 'linux-ia64@linuxia64.org'
Subject: RE: [Linux-ia64] determining read or write on a page fault


>>>>> On Sun, 14 Apr 2002 15:08:54 -0700, "Neelakantam, NaveenX"
<naveenx.neelakantam@intel.com> said:

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

