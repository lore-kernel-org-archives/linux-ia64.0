From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Mon, 10 Sep 2001 17:47:45 +0000
Subject: [Linux-ia64] large binary question
Message-Id: <marc-linux-ia64-105590698805157@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

We tried to compile a "large" application on Linux/IA64, and get get this:

/usr/bin/ld: ../FOO.05.x: short data segment overflowed (0x7a4588 >0x400000)

when trying to link it.  Running "size" on all the .o files, it looks like
the combined text segment is about 15x10^6 bytes, as well as (more modest)
460K data and 60K BSS between all the object files.

Any ideas on how to link it?  Would it help to compile some of the files
into a library first: would PIC code avoid the limit?

Thanks,
Kevin Van Maren

