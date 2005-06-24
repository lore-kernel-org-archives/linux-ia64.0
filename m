From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 24 Jun 2005 21:25:08 +0000
Subject: RE: [patch] Memory Error Handling Improvement
Message-Id: <17084.31284.971413.220254@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
In-Reply-To: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 24 Jun 2005 14:20:17 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  >> Fine, but what about stores?

  Tony> Stores have too many extra levels of buffering to have much
  Tony> hope.  But just because we can't help the store case doesn't
  Tony> mean that we shouldn't do something about the load case.

Fine, but what about my suggestion of just presuming that the access
came for user-level unless you can prove otherwise?

	--david

