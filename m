From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Tue, 21 Oct 2003 11:49:18 +0000
Subject: Re: Rework arch/ia64/kernel/salinfo.c for 2.4
Message-Id: <marc-linux-ia64-106673692111884@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106664704821234@msgid-missing>
In-Reply-To: <marc-linux-ia64-106664704821234@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> >I did see an uncorrectable cache error (MCA) and a corrected
> >memory error (CMC) in a single SAL error log record.
> >Can you sort out such a case ?
> 
> That depends on your SAL implementation.  Does it pass one or two
> records to the OS and how does it pass them?  The OS just does what SAL
> says.

It was on an Intel's Tiger box. I asked for an MCA SAL log record and
I got a single record including a corrected memory error.
I just wanted to warn you that things happen...

> Unless I misread the SAL spec, you can only have one MCA event in the
> OS at a time. MCA rendezvous is a normal interrupt that does not
> generate a record.  At the moment the first MCA is catastrophic and
> requires a reboot, which means that the MCA record is not picked up
> until after the reboot.  If we ever do recovery from MCA then the
> interrupt handler will need to be reviewed but without knowing what the
> recovery model is, it is premature to code for it.

We are thinking of :-) implementing some MCA recovery.
Two cases have been identified:
- translation register errors
- "consuming" poisoned memory data / uncorrectable memory error
They are local, they can happen physically parallel on more than one CPUs.
We cannot clear the SAL log inside of the OS_MCA handler, because we cannot
save the error log in an MCA context. If we did and if the recovery failed,
we would lose this information.
Whatever synchronization is used (e.g. rendezvous) another CPU can start its
MCA processing in the mean time.
We have to re-fetch the SAL log in a process context later, save it and
clear the SAL log. If there are more than non cleared SAL logs there,
their platform related information can be mixed up - see App. note 11763
page 3-3. 

> >- do not "clear" nor "shift" MCA logs
> >- the MCA handler can overwrite the buffer of the CPU on which
> >  it executes
> >- for the "read <n>" command, you may:
> >  + calculate a CRC32 of the buffer[n]
> >  + copy_to_user(buffer[n],...)
> >  + calculate again the CRC32 of the buffer[n] and restart
> >    if it is not the same as before
> 
> Doing a CRC at "read <n>" time is too late, the CRC would have to be
> taken in the interrupt handler.  In any case, the record ID is supposed
> to be unique and is the first field in the record.  Checking that the
> ID is unchanged after taking a copy is sufficient and is much cheaper
> than a CRC check.
