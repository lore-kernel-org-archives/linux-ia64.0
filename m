From: Ben Woodard <ben@zork.net>
Date: Wed, 24 Dec 2003 01:37:48 +0000
Subject: Re: [PATCH 2.4] salinfo patch
Message-Id: <marc-linux-ia64-107223047626426@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107214192720071@msgid-missing>
In-Reply-To: <marc-linux-ia64-107214192720071@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thank you for explaining this to me.

On Mon, 2003-12-22 at 18:12, Keith Owens wrote:
> On Mon, 22 Dec 2003 17:04:38 -0800, 
> Ben Woodard <ben@zork.net> wrote:
> >It looks to me like the salinfo.c and mca.c code can try to clear CPEs
> >and CMCs twice the first time in ia64_mca_log_sal_error_record and then
> >later when the clear message is sent to the /proc/sal/{cpe,cmc}/data
> >file. Did I miss something?
> >
> >Here is a trivially little patch that fixes it one way. 
> >
> >diff -u -r1.1.24.1.68.1 salinfo.c
> >--- salinfo.c   16 Dec 2003 22:14:31 -0000      1.1.24.1.68.1
> >+++ salinfo.c   23 Dec 2003 00:51:27 -0000
> >@@ -448,7 +450,10 @@
> >                data->saved_num = 0;
> >                spin_unlock_irqrestore(&data_saved_lock, flags);
> >        }
> >-       call_on_cpu(cpu, salinfo_log_clear_cpu, data);
> >+
> >+       if (!data->type = SAL_INFO_TYPE_CPE && !data->type = SAL_INFO_TYPE_CMC)
> >+         /*  ia64_mca_log_sal_error_record already cleared CPE and CMC errors */
> >+         call_on_cpu(cpu, salinfo_log_clear_cpu, data);
> >  
> >        /* clearing a record may make a new record visible */
> >        salinfo_log_new_read(cpu, data);
> 
> It was originally that way, but broke when a machine generated a
> CMC/CPE record but mca.c did not have a chance to clear it due to other
> problems.  On reboot, there was already a CMC/CPE record in prom, SAL
> does not generate an interrupt for that case so mca.c was not called
> and did not clear the CMC/CPE record.  Without the second clear in
> salinfo, it could not read any more records.

Wouldn't a better way to fix this potential problem to add:

diff -u -r1.1.24.1.68.1 salinfo.c
--- salinfo.c   16 Dec 2003 22:14:31 -0000      1.1.24.1.68.1
+++ salinfo.c   24 Dec 2003 01:19:15 -0000
@@ -356,6 +358,8 @@
 {
        struct salinfo_data *data = context;
        data->log_size = ia64_sal_get_state_info(data->type, (u64 *) data->log_buffer);
+       if (data->type = SAL_INFO_TYPE_CPE || data->type = SAL_INFO_TYPE_CMC)
+              ia64_sal_clear_state_info(data->type);
 }
  
 static void
@@ -448,7 +452,9 @@
                data->saved_num = 0;
                spin_unlock_irqrestore(&data_saved_lock, flags);
        }
-       call_on_cpu(cpu, salinfo_log_clear_cpu, data);
+       if (!data->type = SAL_INFO_TYPE_CPE && !data->type = SAL_INFO_TYPE_CMC)
+         /*  ia64_mca_log_sal_error_record already cleared CPE and CMC errors */
+         call_on_cpu(cpu, salinfo_log_clear_cpu, data);
  
        /* clearing a record may make a new record visible */
        salinfo_log_new_read(cpu, data);


That way each and every ia64_sal_get_state_info() has a corresponding
ia64_sal_clear_state_info().

The one in mca.c will clear all the CPEs and CMCs that come in through
the interrupt handlers and the one that I'm proposing adding will clear
all the ones fetched post-reboot. All the other types of events are
cleared by salinfo_log_clear().

That way there is no potential data loss.


> 
> Calling ia64_sal_clear_state_info() twice runs the small risk of
> clearing two records instead of one and losing data.  That will only
> occur if there are two CMC/CPE events very close together on the same
> cpu, in which case the first is more useful anyway.  I did the double
> call to ensure that records were always cleared and salinfo could
> proceed, accepting a small risk of lost and non-critical data.

The reason why I have been so focused on this piece of code is we
believe that we are seeing this data loss at least in our test
environment. So I would argue that this is not quite as unlikely as you
suspect.

> 
> >Another way to fix it would be to remove the clearing the SAL error in
> >ia64_mca_log_sal_error_record. Though, I have to say I am extremely
> >uncomfortable depending on and waiting for something in user space to
> >acknowledge system problems before other errors can be reported.
> 
> CMC/CPE records have to be copied and cleared before returning from the
> interrupt handler.  When the record is not cleared in the interrupt
> handler, I have seen the CMC/CPE interrupt immediately reasserted
> again, for the same record.

Ah yes. We have seen exactly this problem on our tiger 4 nodes. That is
why I tried to fix it over in salinfo.c rather than in the mca.c

Happy holidays.
-ben


> 
> >While I'm at it, something that I've been completely unable to
> >understand is why salinfo.c provides two distinct files, event and data.
> >It seems like the event file is virtually useless. Why not just have the
> >same blocking read on the data file?
> 
> Having separate files simplifies the state transitions.  Try coding
> salinfo.c to use a single file, and worry about when to return data,
> when to return EOF, and when to block.  Do not forget to cater for code
> that does lseek() on the data file after hitting EOF.  Separate event
> and data source follows the poll() model, which also separates events
> and data.

