From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Fri, 29 Sep 2017 16:05:45 +0000
Subject: [PATCH REBASED 0/6] rwsem: Implement down_read_killable()
Message-Id: <150670038738.23930.7190484711222807884.stgit@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, avagin@virtuozzo.com, peterz@infradead.org, heiko.carstens@de.ibm.com, hpa@zytor.com, gorcunov@virtuozzo.com, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, mingo@redhat.com, mattst88@gmail.com, fenghua.yu@intel.com, arnd@arndb.de, ktkhai@virtuozzo.com, ink@jurassic.park.msu.ru, tglx@linutronix.de, rth@twiddle.net, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, schwidefsky@de.ibm.com, davem@davemloft.net, rientjes@google.com, viro@zeniv.linux.org.uk

Hi,

this is resending of the series, I previously sent. There are no changes
in separate patches except of [4/6], which is rebased on recent tip.git.

Two patches from the previous sending are already applied by Peter,
so they are not in this series. They are:
83ced169d9a0 "locking/rwsem-xadd: Add killable versions of rwsem_down_read_failed()" and
0aa1125fa8bc "locking/rwsem-spinlock: Add killable versions of __down_read()"

Also, there is one patch more [6/6], which was sent separate in
the reply to the first series.

So, there is no changes (except [4/6]). Please, take a look.
---

The series introduces new down_read_killable() primitive, which
is similar to down_read(), but it may be interrupted by a signal.
The most touched is architectures code. Also, it marks a new user
of the primitive, which is iterate_dir().

---

Kirill Tkhai (6):
      alpha: Add __down_read_killable()
      ia64: Add __down_read_killable()
      s390: Add __down_read_killable()
      x86: Add __down_read_killable()
      rwsem: Add down_read_killable()
      fs: Use killable down_read() in iterate_dir()


 arch/alpha/include/asm/rwsem.h |   18 ++++++++++++++++--
 arch/ia64/include/asm/rwsem.h  |   22 +++++++++++++++++++---
 arch/s390/include/asm/rwsem.h  |   18 ++++++++++++++++--
 arch/x86/include/asm/rwsem.h   |   35 +++++++++++++++++++++++++----------
 arch/x86/lib/rwsem.S           |   12 ++++++++++++
 fs/readdir.c                   |   11 +++++------
 include/asm-generic/rwsem.h    |    8 ++++++++
 include/linux/rwsem.h          |    1 +
 kernel/locking/rwsem.c         |   16 ++++++++++++++++
 9 files changed, 118 insertions(+), 23 deletions(-)

--
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
