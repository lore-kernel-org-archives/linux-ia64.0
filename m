From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 25 Feb 2004 17:32:34 +0000
Subject: MCA bad unwind info
Message-Id: <16444.56370.794788.158418@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Could somebody please look into cleaning up mca_asm.S so it doesn't
trigger any unwind-check errors?  If it's difficult to provide correct
unwind info _and_ it can be proved that we'll never have to unwind
through the offending code, it might be OK for now to simply omit the
unwind info.  In my opinion it's unacceptable to have knowingly bad
unwind info in mca_asm.S---I'm sure we'll get
bug-reports/worry-reports about this sooner or later because unwcheck
is now run on a regular basis.

	--daivd

