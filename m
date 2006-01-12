From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 12 Jan 2006 01:38:14 +0000
Subject: Bug in ia64 specific down() function??
Message-Id: <200601120138.k0C1cEg03582@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The memory order semantics for include/asm-ia64/semaphore.h:down()
doesn't look right.  It is using atomic_dec_return, which eventually
translate into ia64_fetch_and_add() that uses release semantics.
Shouldn't it use acquire semantics?

- Ken

