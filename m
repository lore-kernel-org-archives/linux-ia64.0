From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 27 Oct 2004 10:59:04 +0000
Subject: RE: What does unwcheck.pl do?
Message-Id: <16767.32632.170379.90015@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <523c02d87l.fsf@topspin.com>
In-Reply-To: <523c02d87l.fsf@topspin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 26 Oct 2004 16:53:48 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  >> Tony, below is a patch that fixes the unwind info enough that the
  >> warning/error goes away.  The unwind-info may not be 100% correct
  >> though.  Someone who can test/exercise this code may want to check on
  >> that.

  Tony> I tried the patch ... but the error message is still there
  Tony> intermittently.  I saw it on the build for my zx2000
  Tony> (zx1_defconfig with SMP=n), but not for the tiger
  Tony> (tiger_defconfig).

Works fine here.  Are you sure you're not seeing the effect of a
not-quite-up-to-date toolchain?

	--david
