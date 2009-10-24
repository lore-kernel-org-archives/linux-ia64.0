From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 24 Oct 2009 00:55:27 +0000
Subject: Itanium spec update available.
Message-Id: <4ae2507f2822159c27@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is an update to the Itanium software developer manual available from:

http://download.intel.com/design/itanium/specupdt/248699.pdf

Section 4.5.1 on p.59 explains the use of ALAT to provide information to
hint@pause on the event that a cpu-thread is waiting for.  H/W support
to take notice of the ALAT in this way begins with Tukwila.

Next couple of posts will have patches to spin locks and spinaphores to
make use of this feature.

-Tony
