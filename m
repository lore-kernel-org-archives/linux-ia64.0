From: Ben Woodard <ben@zork.net>
Date: Tue, 23 Dec 2003 01:04:38 +0000
Subject: [PATCH 2.4] salinfo patch
Message-Id: <marc-linux-ia64-107214192720071@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It looks to me like the salinfo.c and mca.c code can try to clear CPEs
and CMCs twice the first time in ia64_mca_log_sal_error_record and then
later when the clear message is sent to the /proc/sal/{cpe,cmc}/data
file. Did I miss something?

Here is a trivially little patch that fixes it one way. 

diff -u -r1.1.24.1.68.1 salinfo.c
--- salinfo.c   16 Dec 2003 22:14:31 -0000      1.1.24.1.68.1
+++ salinfo.c   23 Dec 2003 00:51:27 -0000
@@ -448,7 +450,10 @@
                data->saved_num = 0;
                spin_unlock_irqrestore(&data_saved_lock, flags);
        }
-       call_on_cpu(cpu, salinfo_log_clear_cpu, data);
+
+       if (!data->type = SAL_INFO_TYPE_CPE && !data->type = SAL_INFO_TYPE_CMC)
+         /*  ia64_mca_log_sal_error_record already cleared CPE and CMC errors */
+         call_on_cpu(cpu, salinfo_log_clear_cpu, data);
  
        /* clearing a record may make a new record visible */
        salinfo_log_new_read(cpu, data);

Another way to fix it would be to remove the clearing the SAL error in
ia64_mca_log_sal_error_record. Though, I have to say I am extremely
uncomfortable depending on and waiting for something in user space to
acknowledge system problems before other errors can be reported.

While I'm at it, something that I've been completely unable to
understand is why salinfo.c provides two distinct files, event and data.
It seems like the event file is virtually useless. Why not just have the
same blocking read on the data file?

-ben


