From: Aron Griffis <aron@hp.com>
Date: Wed, 12 Dec 2007 15:07:47 +0000
Subject: [PATCH 0 of 4] cleanups for efi.c
Message-Id: <patchbomb.1197472067@jenkins.nashua>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

These trivial patches clean up efi.c.  There are no functionality
changes introduced by these patches.

1/4 - fix whitespace, fit in 80 columns, repair some indentation
2/4 - spelling and punctuation
3/4 - add /* never reached */ to a couple returns
4/4 - use a #define to reduce code duplication

Of these, I only intended to create 1/4, the others were just
byproducts...  In particular, I'm ambivalent about 4/4.  It reduces
code duplication and makes things easier to read, but does so by
introducing a #define, so it's a bit of a toss-up.

Aron

