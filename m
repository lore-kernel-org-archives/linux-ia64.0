From: Keith Owens <kaos@sgi.com>
Date: Thu, 08 Dec 2005 15:17:32 +0000
Subject: No ia64 version of read_trylock
Message-Id: <24697.1134055052@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is no ia64 specific version of read_trylock().  Instead it maps
to generic__raw_read_trylock() which actually waits for the lock and
always returns 1.  There is an ia64 version of write_trylock(), why no
read_trylock()?

