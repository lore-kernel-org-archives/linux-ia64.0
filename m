From: Mike Rapoport <rppt@kernel.org>
Date: Mon, 18 Jan 2021 11:34:11 +0000
Subject: [GIT PULL] ia64: fix build regression
Message-Id: <20210118113411.GM1106298@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Linus,

The following changes since commit 7c53f6b671f4aba70ff15e1b05148b10d58c2837:

  Linux 5.11-rc3 (2021-01-10 14:34:50 -0800)

are available in the Git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/rppt/memblock tags/fixes-2021-01-18

for you to fetch changes up to 32c2bc8f2d855d4415c9a05b727e34649397bfbe:

  ia64: fix build failure caused by memory model changes (2021-01-17 13:31:09 +0200)

----------------------------------------------------------------
ia64: fix build failure caused by memory model changes

----------------------------------------------------------------
Mike Rapoport (1):
      ia64: fix build failure caused by memory model changes

 arch/ia64/include/asm/sparsemem.h | 1 +
 1 file changed, 1 insertion(+)

-- 
Sincerely yours,
Mike.
