From: Al Stone <ahs3@redhat.com>
Date: Fri, 19 Aug 2016 23:28:48 +0000
Subject: [PATCH 0/2] minor ia64 source code changes
Message-Id: <1471649330-32415-1-git-send-email-ahs3@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: ahs3@redhat.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, trivial@kernel.org

Really trivial changes: one for whitespace, and a second for a compilation
error that can occur due to a use before a definition without a forward
declaration.

Al Stone (2):
  ia64: remove extraneous white space
  ia64: fix compilation error when using struct before defining it

 arch/ia64/sn/kernel/sn2/sn2_smp.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

-- 
2.7.4

