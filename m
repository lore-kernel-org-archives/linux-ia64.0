From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 18 Apr 2001 19:03:56 +0000
Subject: Re: [Linux-ia64] Endian problems when migrating program from HP-UX to RedHat Linux
Message-Id: <marc-linux-ia64-105590693005424@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005417@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005417@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Endianness is a feature of the system (CPU+OS).  You can not change it by
using a compiler option.

ia64-linux is little-endian.  If you want your program to run on ia64-linux,
then you have to make it work on little-endian systems.

It would be possible to create a big-endian ia64-linux OS, but that would be
a great deal of work, and is not a practical solution.

If you just want to run your program on IA-64 hardware, and don't care about
the OS, then you could use an ia64-hpux system, which is big-endian.

Jim

