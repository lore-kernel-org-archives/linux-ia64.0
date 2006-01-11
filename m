From: Adrian Bunk <bunk@stusta.de>
Date: Wed, 11 Jan 2006 23:41:33 +0000
Subject: 2.6.15-mm3: arch/ia64/sn/kernel/sn2/sn_proc_fs.c compile error
Message-Id: <20060111234133.GI29663@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060111042135.24faf878.akpm@osdl.org>
In-Reply-To: <20060111042135.24faf878.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>, Arjan van de Ven <arjan@infradead.org>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, edwardsg@sgi.com, linux-altix@sgi.com

Arjan, it seems the following compile error on ia64 is caused by a patch 
of you that makes some stuff static:

<--  snip  -->

...
  CC      arch/ia64/sn/kernel/sn2/sn_proc_fs.o
arch/ia64/sn/kernel/sn2/sn_proc_fs.c: In function 'sn_procfs_create_entry':
arch/ia64/sn/kernel/sn2/sn_proc_fs.c:104: warning: passing argument 1 of 'memset' discards qualifiers from pointer target type
arch/ia64/sn/kernel/sn2/sn_proc_fs.c:105: error: assignment of read-only member 'open'
arch/ia64/sn/kernel/sn2/sn_proc_fs.c:106: error: assignment of read-only member 'read'
arch/ia64/sn/kernel/sn2/sn_proc_fs.c:107: error: assignment of read-only member 'llseek'
arch/ia64/sn/kernel/sn2/sn_proc_fs.c:108: error: assignment of read-only member 'release'
arch/ia64/sn/kernel/sn2/sn_proc_fs.c: In function 'register_sn_procfs':
arch/ia64/sn/kernel/sn2/sn_proc_fs.c:140: error: assignment of read-only member 'write'
make[3]: *** [arch/ia64/sn/kernel/sn2/sn_proc_fs.o] Error 1

<--  snip  -->

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

