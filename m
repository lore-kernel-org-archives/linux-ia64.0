From: Keith Owens <kaos@sgi.com>
Date: Thu, 09 Dec 2004 12:23:14 +0000
Subject: [RFC] Change the effect of SAL_{GET,CLEAR}_STATE_INFO for MCA/INIT records
Message-Id: <12433.1102594994@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I propose a small change to the effect of SAL_{GET,CLEAR}_STATE_INFO.
This change will only apply when there are multiple MCA or INIT records
being stored for a single cpu.  The change requirement has been
triggered by the recent kernel changes to recover from more MCA events.


Rational
====

The SAL specification only provides access to the top record in the SAL
record stack.  This is fine for logging purposes (via salinfo_decode),
and is also fine when there is a single MCA or INIT record outstanding
on a cpu.  It causes problems when there are multiple MCA or INIT
records stored on a cpu and we are trying to recover from some MCA
events.

The OS MCA and, to a lesser extent, the INIT handlers have to decide if
the MCA/INIT is recoverable or not.  To make that decision, the OS
handlers need the current MCA/INIT record because that is the only
record that contains the data needed to make the decision.  If there
are multiple MCA/INIT records stored for a cpu then SAL_GET_STATE_INFO
returns the top record every time, resulting in bad data and invalid
decisions about recovery.

The current kernel code does not clear the recoverable MCA/INIT record
immediately.  Instead it is delayed until salinfo_timeout() runs, which
means that the record can stay around for a while, currently up to 5
minutes.

I have two outstanding patches that [1]run salinfo_timeout more
frequently and [2]clear all recoverable error records immediately.
With those patches, this problem is significantly reduced, but it is
not completely removed.  There are two cases when the OS MCA/INIT
handlers still get invalid data :-

1) Take a fatal MCA.  Reboot.  Before salinfo_decode has a chance to
   run and delete teh fatal MCA record, get a recoverable MCA.  The OS
   MCA handler reads the data from the fatal MCA, sees it cannot
   recover and gives up.  The system dies on reboot.  This will be more
   and more of a problem as memory sizes get larger.

2) Sites that do not run salinfo_decode at all.  salinfo_decode is not
   a critical system task, a site can choose not to run it.  Any fatal
   MCA records will not be cleared, which prevents all recoverable MCAs
   from working.  This will also occur when you boot in single user
   mode.

The problem of invalid data being passed to the OS MCA and INIT handler
has been caused by the combination of moving salinfo processing out to
user space together with the addition of recoverable MCA and INIT
events.  Both features are good, but now we have to cope with some side
effects that were not anticipated in the SAL specification.


Change
===

Change SAL_{GET,CLEAR}_STATE_INFO to be context sensitive for MCA and
INIT records.  If the OS MCA or INIT handler is in control then these
routines operate on the current record.  Outside the OS MCA or INIT
handler, we revert the old behaviour and operate on record on the top
of the stack.

I believe that this change is in keeping with the spirit of the
existing SAL specification.  It clearly intends that the MCA and INIT
handler should be able to access data about the current event.  For
requests for these records outside the MCA or INIT handlers, it only
makes sense to process the top record on the stack.

Making these calls context sensitive is a small change to SAL.  The SAL
MCA/INIT handlers have already constructed and stored the required
record before calling the OS handler.  All SAL has to do is :-

* Save the address of the current record on this cpu.
* Call the OS handler.
* On return from the OS handler, clear the pointer to the current
  record.
* SAL_GET_STATE_INFO - if the current record pointer is set then return
  that record, otherwise do existing processing.
* SAL_CLEAR_STATE_INFO - if the current record pointer is set then
  clear that record and the current record pointer, otherwise do
  existing processing.

This change is backwards compatible.  A new kernel running on an old
SAL will get the top of stack record, as before.  The worst case is
that it gets invalid data, which is the current situation.  An old
kernel running on a new SAL will get the current record in the OS MCA
and INIT handlers, which is exactly what we want.  This SAL change does
not require any kernel changes, although we should still apply patches
[1] and [2].

[1] http://marc.theaimsgroup.com/?l=linux-ia64&m0187223423867&w=2
[2] http://marc.theaimsgroup.com/?l=linux-ia64&m0222038404547&w=2

