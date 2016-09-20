From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 20 Sep 2016 02:29:22 +0000
Subject: [PATCH v2 0/2] ia64: make use of new extable.h header
Message-Id: <20160920022924.9537-1-paul.gortmaker@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>

[v1 -> v2: de-pollute uaccess.h as per what Al Viro's comments implied]

We forked the exception table content out of module.h into a new
extable.h file[1].  We temporarily include extable.h into the module.h
itself.  Now we work our way across the arch independent and arch
specific files needing just exception table content, and move them
off module.h and onto extable.h

Once that is done, we can remove the extable.h from module.h and in
doing it like this, we avoid introducing build failures into the git
history.

Here we move ia64 onto using the new arch independent header, and in
doing so we also spin off some ia64 exception specific code from the
uaccess.h header into a new exception.h header -- based on comments
from the v1 review[2] suggesting uaccess.h was not the best place.

Build tested on the intermediate and final commit on top of linux-next,
but not runtime tested.

Paul.

[1] https://lkml.kernel.org/r/CA+55aFyDw_jK609LcjpWvVMTzCWuH6nLUXiZDeYC2tpSaZqhXA@mail.gmail.com
[2] https://lkml.kernel.org/r/20160817171546.GD2356@ZenIV.linux.org.uk
-- 

Paul Gortmaker (2):
  ia64: move ia64_done_with_exception out of asm/uaccess.h
  ia64: ensure exception table search users include extable.h

 arch/ia64/include/asm/exception.h | 35 +++++++++++++++++++++++++++++++++++
 arch/ia64/include/asm/uaccess.h   | 15 ---------------
 arch/ia64/kernel/kprobes.c        |  4 ++--
 arch/ia64/kernel/traps.c          |  4 +++-
 arch/ia64/kernel/unaligned.c      |  2 ++
 arch/ia64/mm/fault.c              |  2 ++
 6 files changed, 44 insertions(+), 18 deletions(-)
 create mode 100644 arch/ia64/include/asm/exception.h

-- 
2.10.0

