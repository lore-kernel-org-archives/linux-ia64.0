From: "Jim Hollenback" <jholly@cup.hp.com>
Date: Thu, 08 Nov 2001 17:54:42 +0000
Subject: [Linux-ia64] gcc 3.0 questions.
Message-Id: <marc-linux-ia64-105590698805456@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm trying to build a glibc, other libraries and an application using
gcc 3.0.  Stuff seems to build and link okay, but when I go to run
the application I get

 error while loading shared libraries: /home/jholly/lib/libgcc_s.so.1:
  undefined symbol: __ia64_app_header

Any clues to the reason for the error would be appreciated.

I'm doing this using NUE and the tarball put together by Stephane Eranian
and running it on my RH 7.1 box.

Thanks!

Jim Hollenback

