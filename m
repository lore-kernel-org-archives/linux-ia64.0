From: Russell Mok <rmok@algorithmics.com>
Date: Fri, 19 May 2000 19:07:30 +0000
Subject: [Linux-ia64] problem building gnu tool
Message-Id: <marc-linux-ia64-105590678205100@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I download the source on a redhat 5.2 machine and try to build a cross
compiler for ia64.  The build fails because unistd.h and other system
headers are missing.  I tried to make configure to think I don't have
any system headers using --with-headers=empty-dir and
--without-headers but neither worked.

Basically I'm asking a way to generate a cross-compiler for ia64 linux
on a 32-bit linux host.  Thanks.

Russell



