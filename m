From: Keith Owens <kaos@sgi.com>
Date: Tue, 30 Sep 2003 07:53:48 +0000
Subject: gcc generates invalid ia64 unwind for -pg
Message-Id: <marc-linux-ia64-106490847203705@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

FYI.  While trying to profile the kernel with -pg, I found that gcc
(all versions up to and including today's CVS) generate invalid unwind
data for -pg.

http://gcc.gnu.org/bugzilla/show_bug.cgi?id455

