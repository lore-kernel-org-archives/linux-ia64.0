From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 12 Feb 2005 10:37:07 +0000
Subject: qemu on ia64 linux
Message-Id: <200502121037.j1CAb7es030843@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Not sure if there is much interest in this, but I was curious what it
would take to get qemu to work on ia64 and so I have been hacking on
it a bit in my spare time.  There are several still a couple of things
wrong about it, but I now got it to the point where it boots an i386
kernel.  Running on a 1GHz McKinley, /proc/cpuinfo claims it's a 1GHz
Pentium Pro with 1880 bogomips.  I'm sure that's entirely bogus, but
it definitely feels quite a bit faster than a pure interpreter such as
bochs.

I plan to clean up the patch as time permits but should anyone care,
let me know and I'll see about making it available sooner rather than
later.

	--david
