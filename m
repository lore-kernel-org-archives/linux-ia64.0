From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 22 Apr 2015 15:35:29 +0000
Subject: [GIT PULL] PCI fixes for v4.1
Message-Id: <20150422153529.GH20701@google.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Mohit Kumar <mohit.kumar@st.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Hi Linus,

These fix an ia64 regression caused by tighter resource checking we merged
during the merge window and remove an invalid email address from
MAINTAINERS.

Bjorn


The following changes since commit 3be1b98e073bdd4c1bb3144201a927c4a21330ba:

  Merge tag 'pci-v4.1-changes' of git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci (2015-04-13 15:45:47 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci.git tags/pci-v4.1-fixes-1

for you to fetch changes up to 9fbbda5c8e0ab9c391e4160a0eb3a06260f9f668:

  ia64/PCI: Treat all host bridge Address Space Descriptors (even consumers) as windows (2015-04-21 15:29:39 -0500)

----------------------------------------------------------------
PCI updates for v4.1:

  Resource management
    - ia64: Treat all Address Space Descriptors as windows (Bjorn Helgaas)

  Miscellaneous
    - MAINTAINERS: Remove Mohit Kumar (email bounces) (Bjorn Helgaas)

----------------------------------------------------------------
Bjorn Helgaas (2):
      MAINTAINERS: Remove Mohit Kumar (email bounces)
      ia64/PCI: Treat all host bridge Address Space Descriptors (even consumers) as windows

 CREDITS             | 4 ++++
 MAINTAINERS         | 4 +---
 arch/ia64/pci/pci.c | 5 +----
 3 files changed, 6 insertions(+), 7 deletions(-)
