From: Tony Luck <tony.luck@intel.com>
Date: Wed, 18 Aug 2004 22:09:38 +0000
Subject: IA64 bitkeeper trees (again)
Message-Id: <4123D3A2.2050609@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

After I posted my description of how I'm using Bitkeeper trees
to manage the ia64 part of Linux I got some feedback.  Len Brown
kindly talked me through how he runs a 2-phase/2-stage set of
trees for ACPI ... and after a while it began to make sense (the
layout of the trees, not ACPI :-).  So I've set up a similar set
of four trees:


          +--------------+     +-----------------+
          | test-2.6.9   |     | release-2.6.9   |
          +--------------+     +-----------------+
                  ^                     ^
                  |                     |
          +--------------+     +-----------------+
          | test-2.6.8.1 | ->  | release-2.6.8.1 |
          +--------------+     +-----------------+

Work begins at the bottom left, which is a clone of Linus's tree when he
applied the v2.6.8.1 label.  I apply patches there, and do whatever
compile/boot tests I need to make me feel comfortable about the patches.
I can then push/pull them up to the test-2.6.9 tree which is based on
Linus's latest (by pulling each day) and re-compile there to make sure
that the changes don't conflict with other changes to the base.  Andrew
Morton can then pull from the upper left tree to feed into "-mm"
expose the changes to a wider test audience.

Once the changes are suitably aged, I'll pull them over to the "release"
trees, which are the staging area for Linus to pull from.

The actual names all have "linux-ia64-" prepended.  E.g.

   http://lia64.bkbits.net/linux-ia64-test-2.6.9

The names of the trees all change when Linus makes a release.

Len also gave me a script to create plain patches for non-BK
users ... I'll make the tweaks to the pathnames and get those
running soon.

-Tony


