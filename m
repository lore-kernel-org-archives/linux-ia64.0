From: Erich Focht <focht@ess.nec.de>
Date: Mon, 15 Jan 2001 17:57:56 +0000
Subject: Re: [Linux-ia64] /proc/pid/mem and stack variables
Message-Id: <marc-linux-ia64-105590693005042@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005037@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005037@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A small patch for the file fs/proc/base.c implementing llseek for
/proc/PID/mem is appended. It's the same as for /dev/kmem therefore it
does only SEEK_SET and SEEK_CUR, not SEEK_END. 

It works for reading from stack pages, positioning is ok but the return
value is -1 (which is wrong). Probably because the offsets seem to be
negative... Can anybody please tell me why I'm getting the -1 error return
though I should get back the huge negative offset?

Thanks in advance,
Erich


On Mon, 15 Jan 2001, Maciej Golebiewski wrote:

> On Fri, Jan 12, 2001 at 06:29:33PM -0800, David Mosberger wrote:
> > >>>>> On Fri, 12 Jan 2001 13:45:10 -0500, Pete Wyckoff <pw@osc.edu> said:
> > Yes, implementing llseek for fs/proc/base.c:proc_mem_operations is the
> > right solution.  /dev/kmem already has its own llseek (which treats
> > the offset as unsigned) but, for some reason, was left out of the
> > /proc/pid/mem support.
> > 
> > Don, can you add this to the TODO list so we won't forget about it?
> 
> Thanks a lot for help. It seems that the solution is simpler than I
> was expecting. Anyway, I don't have a root access to the IA64 machine
> in question, so I can't test it myself, but one of the guys with root
> access told me he'll try to find some time and try it out.



*** linux-2.4.0test12/fs/proc/base.c.orig1      Mon Jan 15 13:12:36 2001
--- linux-2.4.0test12/fs/proc/base.c    Mon Jan 15 13:14:49 2001
***************
*** 396,402 ****
--- 396,417 ----
  }
  #endif
  
+ static loff_t mem_lseek(struct file * file, loff_t offset, int orig)
+ {
+         switch (orig) {
+                 case 0:
+                         file->f_pos = offset;
+                         return file->f_pos;
+                 case 1:
+                         file->f_pos += offset;
+                         return file->f_pos;
+                 default:
+                         return -EINVAL;
+         }
+ }
+ 
  static struct file_operations proc_mem_operations = {
+       llseek:         mem_lseek,
        read:           mem_read,
        write:          mem_write,
  };



