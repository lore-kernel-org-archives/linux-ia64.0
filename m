From: Bill Nottingham <notting@redhat.com>
Date: Mon, 12 Feb 2001 15:35:27 +0000
Subject: [Linux-ia64] Re: Pagesize bug vs. libpthread bug :(
Message-Id: <marc-linux-ia64-105590693005134@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Francis Galiegue (fg@mandrakesoft.com) said: 
> I've succeeded in compiling and installing the CVS version of glibc dated
> 20010208, but since then all programs using libpthread segfault. This includes
> all fileutils, among others. Fortunately I have a "stable" glibc installed in
> my chroot and so can export LD_LIBRARY_PATH to point to them, so my system is
> still usable.

Take a later snapshot. Using pthreads was broken for a few days.

Bill

