From: roneng@ca.ibm.com
Date: Thu, 18 May 2000 19:25:50 +0000
Subject: [Linux-ia64] Shared memory
Message-Id: <marc-linux-ia64-105590678205096@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi,
Has anyone had a problem using the shmctl function to change the access
mode of a shared memory
block?

What I am doing is allocating shared memory using mode 666, and writing to
it, then I use shmctl to change its
mode to 600, switch to another userid using su, and try and read from the
shared memory block. on ia32 linux
I get an permission denied error, on ia64 with the latest turbolinux kernel
and glibc i can read from that memory
block.


Thank you,
Ronen Grosman
- Phone: Internal:778-4478     External: (416)-448-4478    Fax:
(416)448-4414
- e-mail roneng@ca.ibm.com




