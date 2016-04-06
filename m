From: Jonas Rabenstein <ve92mose@stud.informatik.uni-erlangen.de>
Date: Wed, 06 Apr 2016 23:12:58 +0000
Subject: [PATCH 0/3] ia64: remove unused header files
Message-Id: <cover.1459983613.git.jonas.rabenstein@studium.uni-erlangen.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jonas Rabenstein <jonas.rabenstein@studium.uni-erlangen.de>

From: Jonas Rabenstein <jonas.rabenstein@studium.uni-erlangen.de>

This patchset removes three unreferenced and unused header files of the ia64
architecture. Also some #include directives would resolve to the files I propose
for removal, the dependencies defined by kconfig for those files do not allow
their usage together with ia64.

I detected the issue with chimaera, a tool I currently develop for my bachelor
thesis extending the undertaker tool suite to take the relation of files based
on #include directives into account (https://undertaker.cs.fau.de).

Jonas Rabenstein (3):
  ia64: remove unused asm/segment.h
  ia64: remove unused asm/idle.h
  ia64: remove unused asm/mc146818rtc.h

 arch/ia64/include/asm/idle.h        |  7 -------
 arch/ia64/include/asm/mc146818rtc.h | 10 ----------
 arch/ia64/include/asm/segment.h     |  6 ------
 3 files changed, 23 deletions(-)
 delete mode 100644 arch/ia64/include/asm/idle.h
 delete mode 100644 arch/ia64/include/asm/mc146818rtc.h
 delete mode 100644 arch/ia64/include/asm/segment.h

-- 
1.9.1

