From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 12 Mar 2004 18:02:41 +0000
Subject: RE: cat /proc/acpi/events bad for your system's health!
Message-Id: <16465.64321.446507.50408@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16455.50905.681007.50048@napali.hpl.hp.com>
In-Reply-To: <16455.50905.681007.50048@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 12 Mar 2004 23:15:01 +0800, "Yu, Luming" <luming.yu@intel.com> said:

  Luming> I confirm this issue here on tiger with 2.6.4-rc3 kernel ,
  Luming> but 2.4 is ok.  Not sure this is a regression.

  >>  OK.  I assume you (or Len) will take care of it?


  Luming> The following patch make crash on my tiger gone.  However I
  Luming> didn't dig out the true culprit.  Maybe this is due to
  Luming> excessive optimization.

  Luming> BTW, my gcc version is 3.2.3 .

The patch is fine as a temporary workaround, but surely we need to
find out the root cause of this problem.  It sounds like there is a
race somewhere.  I suppose it's possible that it's a compiler problem,
but I rather doubt it.  Are you doing to dig deeper into it?  If not,
please let me know.

	--david
