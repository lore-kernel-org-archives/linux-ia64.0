From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 04 Feb 2003 02:53:43 +0000
Subject: [Linux-ia64] _raw_write_trylock() missing
Message-Id: <marc-linux-ia64-105590709805809@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When I try to build 2.5.59 for an SMP machine, I see that
 _raw_write_trylock() is undefined.  As the read-write spin locks are
all implemented as magic assembler, I don't feel competent to create
it...

Peter C

