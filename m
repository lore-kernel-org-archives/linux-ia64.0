From: Keith Owens <kaos@ocs.com.au>
Date: Mon, 20 Oct 2003 14:53:54 +0000
Subject: Re: Rework arch/ia64/kernel/salinfo.c for 2.4
Message-Id: <marc-linux-ia64-106666184604506@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106664704821234@msgid-missing>
In-Reply-To: <marc-linux-ia64-106664704821234@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 20 Oct 2003 16:38:54 +0200, 
Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org> wrote:
>Keith,
>
>I did see an uncorrectable cache error (MCA) and a corrected
>memory error (CMC) in a single SAL error log record.
>Can you sort out such a case ?

That depends on your SAL implementation.  Does it pass one or two
records to the OS and how does it pass them?  The OS just does what SAL
says.

>Is there any use to show the log of INIT ?

When the kernel is spinning on a disabled spinlock, the only way to get
its attention is to send INIT.  The registers at the time of INIT tell
you where it was spinning and on which lock.

>/* save last 5 records from mca.c, must be < 255 */
>struct salinfo_data: struct salinfo_data_saved data_saved[5]; :
>
>It would be much more safe for the MCA stuff to reserve a data
>buffer for each CPU. As there is no mutual exclusion with the
>MCA handler:

Unless I misread the SAL spec, you can only have one MCA event in the
OS at a time.  MCA rendezvous is a normal interrupt that does not
generate a record.  At the moment the first MCA is catastrophic and
requires a reboot, which means that the MCA record is not picked up
until after the reboot.  If we ever do recovery from MCA then the
interrupt handler will need to be reviewed but without knowing what the
recovery model is, it is premature to code for it.

>- do not "clear" nor "shift" MCA logs
>- the MCA handler can overwrite the buffer of the CPU on which
>  it executes
>- for the "read <n>" command, you may:
>  + calculate a CRC32 of the buffer[n]
>  + copy_to_user(buffer[n],...)
>  + calculate again the CRC32 of the buffer[n] and restart
>    if it is not the same as before

Doing a CRC at "read <n>" time is too late, the CRC would have to be
taken in the interrupt handler.  In any case, the record ID is supposed
to be unique and is the first field in the record.  Checking that the
ID is unchanged after taking a copy is sufficient and is much cheaper
than a CRC check.

>Assuming I've got a CPE, can I read its SAL log on any CPU ?

Reading SAL records has to be done from the same cpu,
SAL_GET_STATE_INFO does not take a cpu parameter.  The code takes care
of that, see salinfo_log_read_cpu().  Once the record has been copied
into user space, you can decode it from anywhere.

>Can I clear this SAL log on a different CPU ?

Same as read, SAL_CLEAR_STATE_INFO does not take a cpu parameter.  See
salinfo_log_clear_cpu().

>If a CMC's SAL log includes some Platform ... Error Info
>structures and another CPU can pinch the platform related
>error information (and it can clear it too), how can the CPU
>causing the error know what has happened ?

All information must be in the record.  Anything not in the record can
be lost.  Remember that some of these records are not extracted from
prom until after a reboot, so any volatile data is lost.

>Assuming I've got a CMC / CPE, I read its log but I do not clear it.
>Assuming I've got another CMC / CPE and I read the log: are the
>new / old errors merged ?

SAL requires you to clear the current log before you can see the next
one.  SAL_GET_STATE_INFO reads the top record of the defined type on
the current cpu.

My rework has not changed any of the SAL requirements or processing,
just the OS code that tracks the records and extracts them to user
space.

