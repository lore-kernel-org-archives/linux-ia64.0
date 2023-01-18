From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Wed, 18 Jan 2023 12:26:29 +0000
Subject: Boot regression on ia64 with 6.1
Message-Id: <77eacc0d-086f-505d-37ea-30611b0b35e2@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi!

There is a boot regression on ia64 with 6.1 that causes the machine to reset
during boot. I haven't bisected the bad commit yet, this will happen later today:

[    1.296316] Unpacking initramfs...
[    1.313806] Entered OS MCA handler. PSP 010000fff21320 cpu=2 monarch=1
[    1.313806] 6All OS MCA slaves have reached rendezvous
[    1.313806] mlogbuf_finish: printing switched to urgent mode, MCA/INIT might be dodgy or fail.
[    1.313806] Delaying for 5 seconds...

Just in case anyone already has an idea.

Adrian

-- 
  .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer
`. `'   Physicist
   `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
