From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Tue, 21 Oct 2003 11:55:07 +0000
Subject: Re: Rework arch/ia64/kernel/salinfo.c for 2.4
Message-Id: <marc-linux-ia64-106673742212300@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106664704821234@msgid-missing>
In-Reply-To: <marc-linux-ia64-106664704821234@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

(SOORRY, THE TAIL OF MY MAIL GOT LOST, HERE IT IS:)

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

If you start copy_to_user(buffer...) and in the mean time there is a
new MCA (recovered successfully), the the buffer gets overwritten.
We cannot lock out the MCA handler. We need to make sure that the copy
does not include e.g. the beginning of a previous MCA and the end of
the current one.

Regards,

Zoltan Menyhart
