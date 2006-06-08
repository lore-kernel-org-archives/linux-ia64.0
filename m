From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 08 Jun 2006 06:29:00 +0000
Subject: Re: [PATCH] printing support for MCA/INIT
Message-Id: <4487C3AC.2020803@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4486BE32.80100@jp.fujitsu.com>
In-Reply-To: <4486BE32.80100@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
>> I guess there are only 2 cases actually needs to display its progress,
>> long time wait on rendezvous and INIT-monarch. 
> 
> In the MCA case, something bad has already happened to the system,
> it is possible that we will not complete printing all of the
> messages, but if they are streaming directly to the console, then
> at least we will see the first part of the messages.  If you buffer
> them to be printed later, there may be no "later", and all the
> information will be lost.
> 
> -Tony
> 

Please look my patch.

@@ -1067,6 +1170,9 @@ ia64_mca_handler(struct pt_regs *regs, s
          rh->severity = sal_log_severity_corrected;
          ia64_sal_clear_state_info(SAL_INFO_TYPE_MCA);
          sos->os_status = IA64_MCA_CORRECTED;
+    } else {
+        /* Dump buffered message to console */
+        ia64_mlogbuf_break();
      }
      if (notify_die(DIE_MCA_MONARCH_LEAVE, "MCA", regs, (long)&nd, 0, recover)
              = NOTIFY_STOP)

If MCA handler cannot recovery the error, then try to printk
all buffered messages before returning to SAL.

Isn't it enough?

H.Seto

