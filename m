From: "H. J. Lu" <hjl@lucon.org>
Date: Tue, 22 Jun 2004 22:08:13 +0000
Subject: Does parallel make work for modules?
Message-Id: <20040622220813.GA306@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux kernel <linux-kernel@vger.kernel.org>
Cc: linux ia64 kernel <linux-ia64@vger.kernel.org>

When building 2.6.7 on a 4way Linux/ia64, "make -j4 modules" doesn't
spawn 4 jobs. I got

 5756 pts/0    S      0:00 make -s -j4 modules
 5868 pts/0    S      0:00 make -f scripts/Makefile.build obj=fs
 7240 pts/0    S      0:00 make -f scripts/Makefile.build obj=fs/nfs
 7269 pts/0    S      0:00 /bin/sh -c set -e; ?   gcc -Wp,-MD,fs/nfs/.pagelist.o. 
 7270 pts/0    S      0:00 gcc -Wp,-MD,fs/nfs/.pagelist.o.d -nostdinc -iwithprefi
 7271 pts/0    S      0:00 /usr/gcc-3.4/libexec/gcc/ia64-unknown-linux-gnu/3.4.1/
 7272 pts/0    R      0:00 as -x -o fs/nfs/pagelist.o -

2.4 kernel module build work fine. Any ideas?


H.J.
