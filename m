From: Mike Rapoport <rppt@kernel.org>
Date: Thu, 03 Sep 2020 14:54:38 +0000
Subject: [GIT PULL] Fix min_low_pfn/max_low_pfn build errors on ia64 and microblaze
Message-Id: <20200903145438.GA1781636@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Fenghua Yu <fenghua.yu@intel.com>, Michal Simek <michal.simek@xilinx.com>, Michal Simek <monstr@monstr.eu>, Randy Dunlap <rdunlap@infradead.org>, Tony Luck <tony.luck@intel.com>, kernel test robot <lkp@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Linus,

The following changes since commit f75aef392f869018f78cfedf3c320a6b3fcfda6b:

  Linux 5.9-rc3 (2020-08-30 16:01:54 -0700)

are available in the Git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/rppt/memblock.git tags/fixes-2020-09-03

for you to fetch changes up to 5f7b81c18366c38446f6eedab570b98dbdc07cff:

  ia64: fix min_low_pfn/max_low_pfn build errors (2020-09-01 19:34:11 +0300)

----------------------------------------------------------------
Fix min_low_pfn/max_low_pfn build errors on ia64 and microblaze

Some configurations of ia64 and microblaze use min_low_pfn and
max_low_pfn in pfn_valid(). This causes build failures for modules that
use pfn_valid().

The fix is to add EXPORT_SYMBOL() for these variables on ia64 and
microblaze.

----------------------------------------------------------------
Randy Dunlap (2):
      microblaze: fix min_low_pfn/max_low_pfn build errors
      ia64: fix min_low_pfn/max_low_pfn build errors

 arch/ia64/kernel/ia64_ksyms.c | 2 +-
 arch/microblaze/mm/init.c     | 3 +++
 2 files changed, 4 insertions(+), 1 deletion(-)

-- 
Sincerely yours,
Mike.
