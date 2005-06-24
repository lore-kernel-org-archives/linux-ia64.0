From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 24 Jun 2005 21:36:18 +0000
Subject: RE: [patch] Memory Error Handling Improvement
Message-Id: <17084.31954.385948.362059@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
In-Reply-To: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 24 Jun 2005 14:31:28 -0700, "Luck, Tony" <tony.luck@Intel.com> said:

  >> Fine, but what about my suggestion of just presuming that the access
  >> came for user-level unless you can prove otherwise?

  Tony> If the presumption is wrong, then you'll kill an innocent user process.

As opposed to panic'ing the kernel?  That doesn't strike me as a big
problem. ;-)

  Tony> Worse, you will let a corrupted kernel carry on running.

It'd boil down to the question of what the likelihood is that the
kernel would be touching a user-mapped page whose contents it depends
on for correct operation. (If it is not a user-mapped page, you'd
obviously _not_ conclude that the MCA was triggered by user-level.)

	--david
