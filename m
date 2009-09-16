From: Tim Abbott <tabbott@ksplice.com>
Date: Wed, 16 Sep 2009 16:42:41 +0000
Subject: [PATCH v2 0/3] Linker script cleanup patches for ia64
Message-Id: <1253119364-19359-1-git-send-email-tabbott@ksplice.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-kernel@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>, Tim Abbott <tabbott@ksplice.com>

This is an updated version of the patch series I sent in late July
cleaning up the ia64 architecture's linker scripts.  The only change is
that it is rebased on top of Linus's current master.

This cross-architecture linker script cleanup project is in
preparation for adding support for building the kernel with
-ffunction-sections -fdata-sections, which is a prerequisite for
Ksplice.

	-Tim Abbott

Nelson Elhage (2):
  ia64: Use standard macros for page-aligned data.
  ia64: Clean up linker script using standard macros.

Tim Abbott (1):
  ia64: Use .ref.text, not .text.init for start_ap.

 arch/ia64/kernel/head.S        |    4 +-
 arch/ia64/kernel/vmlinux.lds.S |  112 +++++-----------------------------------
 2 files changed, 15 insertions(+), 101 deletions(-)

