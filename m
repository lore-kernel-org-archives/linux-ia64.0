From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 23 Jul 2001 23:54:56 +0000
Subject: [Linux-ia64] updated Mozilla binaries available
Message-Id: <marc-linux-ia64-105590693005878@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest IA-64 binaries for mozilla can be found at:

 ftp://ftp.hpl.hp.com/pub/linux-ia64/mozilla-ia64-unknown-linux-010720.tar.gz

To run this binary, you'll need libgcc_s.so.1.  The easiest way to get
this library is to copy it from the gcc 3.0 release.  E.g., with the
gcc3.0 tar ball on ftp.hpl.hp.com, simply copy this library from
/opt/gcc3/lib/ to /usr/lib and run "ldconfig" and you should be all
set.

Mozilla is coming along quite nicely and i use it now for almost all
of my browsing tasks.  It still crashes on some web sites, but by and
large, it works well and is fast.

	--david

