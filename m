From: Jack Carter <jcarter@johmar.engr.sgi.com>
Date: Wed, 02 May 2001 17:01:29 +0000
Subject: [Linux-ia64] ld --relax should be on by default
Message-Id: <marc-linux-ia64-105590693005510@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Users of our IA64 compiler which uses the Cygnus/GNU
linker keep hitting a link overflow problem which is
fixed by using --relax.

Why is this not on by default?

At a very minimum the linker should itself suggest
using the option when the overflow occurs.

Thanks,

Jack Carter jcarter@sgi.com

