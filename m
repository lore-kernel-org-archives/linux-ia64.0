From: Randolph Chung <randolph@tausq.org>
Date: Fri, 21 Feb 2003 06:53:34 +0000
Subject: [Linux-ia64] ski and gcc-3.x
Message-Id: <marc-linux-ia64-105590709805894@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

hi,

two questions really....

1. is linux-2.5.x on ski supposed to work?
2. is there a version of ski that works with gcc-3.2?

the latest ski i can find (0.94311) doesn't work with gcc-3.2 built
kernels. On startup it gives:
BFD: Dwarf Error: Invalid or unhandled FORM value: 14.

iirc this is a DWARF debug directive that was introduced in gcc
around gcc-3.1 or so....

randolph
-- 
Randolph Chung
Debian GNU/Linux Developer, hppa/ia64 ports
http://www.tausq.org/

