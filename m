From: Umut Aymakoglu <umuta@us.ibm.com>
Date: Wed, 03 Sep 2003 00:33:15 +0000
Subject: SHMLBA on linux-ia64
Message-Id: <marc-linux-ia64-106254921222388@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org





Hi -
  The file /usr/include/sys/shm.h defines SHMLBA  as  __getpagesize() which
is 16K. whereas in /usr/include/asm/shmparam.h thereis another define of
SHMLBA as (1024*1024) and a comment saying on IA-64 architecture  due to
some performance problems it is better to use this alignment.

  We want to know what the recommended SHMLBA should be.

thanks in advance,
Umut

