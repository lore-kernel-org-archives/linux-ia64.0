From: Keith Owens <kaos@sgi.com>
Date: Thu, 30 Oct 2003 22:50:48 +0000
Subject: Re: [patch 0/4] kernel salinfo changes
Message-Id: <marc-linux-ia64-106755440714961@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106750258117748@msgid-missing>
In-Reply-To: <marc-linux-ia64-106750258117748@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 30 Oct 2003 15:16:23 -0700, 
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
>On Thursday 30 October 2003 1:28 am, Keith Owens wrote:
>> patch 1 - Print the header from INIT records, correct typo in sal.h.
>> patch 2 - Clean up kernel salinfo state checking.
>> patch 3 - Add the ability for user space salinfo to ask kernel salinfo
>>           and/or the prom to decode the oem data sections of SAL records.
>
>As for patch 3, that's an interesting concept.  My initial reaction
>is that it seems sort of backwards to put this sort of "binary ->
>ASCII" decoding mechanism into the kernel or the prom.
>
>I can see that it might be convenient to be able to stash all
>that secret IP in the prom, and it certainly does address the
>problem of version skew, but it just seems wrong to get the
>kernel in the middle, ferrying data back and forth.

Up until 2.4.21 we had the ability to call SAL to assist with decoding
the oemdata and that feature was being used by modifying
platform_mem_dev_err_print and friends.  Moving salinfo to user space
removed that ability, patch 3 just reinstates it.

The SAL record is already in the kernel.  User space reads the raw
record and, before clearing the record from SAL, asks the kernel/prom
to decode the oem data.  Then user space clears the record.  The data
is not being fed from user space back into the kernel; think of it as
the kernel delivering existing data in a different format.

>HP has the same problem, of course, with wanting to protect
>the meaning of the OEM data, so I had imagined some sort
>of binary-only user-level decoder, or perhaps a generic
>open-source decoder to which one could add proprietary
>plugins.

That is skating close to a GPL violation.  Any binary only user level
decoder would have to be written from scratch, not using any of the GPL
headers or code.  A plugin might work, but it still has the problem of
version skew between user space and the kernel.

>If you really want the decoding in the prom, what about a
>module that allowed you to make arbitrary SAL calls from
>user-land?

The raw record would have to be fed back from user space into the
kernel.  Security and the integrity of the record is a worry, even with
programs that can only be called by root.  The module would have to
support its own interface to user space, requiring another /proc or
/dev entry.  It would end up duplicating the code that is already in
kernel salinfo.c and would require additional checks to verify the
record format before passing it to SAL.  A big advantage of patch 3 is
that the record never leaves the kernel so SAL knows the record is
valid.

Security, code reuse and minimum overhead all say to extend the
existing interface rather than add a new interface.

