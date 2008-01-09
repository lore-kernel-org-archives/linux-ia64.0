From: Aron Griffis <aron@hp.com>
Date: Wed, 09 Jan 2008 03:29:35 +0000
Subject: [PATCH 0 of 3] cleanups for efi.c
Message-Id: <patchbomb.1199849375@jenkins.nashua>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

These trivial patches clean up efi.c.  There are no functionality
changes introduced by these patches.  This submission incorporates
feedback from my last post on Dec 12:

- merge forward to current tree
- Tony suggested leaving efi_guidcmp() alone
- Peter suggested punctuation/grammar fixes

1/3 - fix whitespace, fit in 80 columns, repair some indentation
2/3 - spelling and punctuation
3/3 - add /* never reached */ to a couple returns

1 file changed, 273 insertions(+), 230 deletions(-)
arch/ia64/kernel/efi.c |  503 ++++++++++++++++++++++++++----------------------


