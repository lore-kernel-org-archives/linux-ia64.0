From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 29 May 2003 21:31:27 +0000
Subject: Re: [Linux-ia64] SAL error record logging/decoding
Message-Id: <marc-linux-ia64-105590723706079@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705660@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705660@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 29 May 2003 2:49 pm, Luck, Tony wrote:
> Digging back in this thread to last Thursday ...
> 
> > > 2) I crashed my machine with an injected machine check, and
> > > then rebooted.  All four of the /proc/sal/cpuX/mca files had
> > > a copy of the same error record.  Echoing "clear" to one of
> > > them made them all go away.
> > 
> > > I think this is normal ... but it may require some interesting
> > > documentation to say why things work like this.
> > 
> > Why do you think that's normal?  It sounds pretty strange
> > to me.
> 
> I asked a SAL expert here who said:
> 
>  "The SAL spec does not require that the SAL_GET_STATE_INFO API
>   be called on the processor where the error was detected (for
>   recoverable and fatal errors).  So in this case, the SAL has
>   logged it to flash before handing off to the OS.  When the OS
>   calls SAL_GET_STATE_INFO, it just retrieves the last error in
>   the queue from the flash image.  The processor section of the
>   error record has a field for the processsor LID --- so you can
>   check if the right processor observed the error."

The SAL spec says

  In an MP environment, processor record information pertains to the
  processor on which this call is executed and the platform information
  pertains to the platform.

I interpret this to mean that a GET_STATE_INFO call can return
platform information no matter which CPU makes the call, but that
processor information can only be returned on the processor that
took the error.

So if you injected a platform MCA that created no processor
error sections, it makes sense to me that you'd see the same
thing in each file, and that clearing one would clear them all.

The salinfo code only sets the "event_ready" flag for the CPU
that calls salinfo_log_wakeup(), so assuming that only one CPU
calls ia64_mca_ucmc_handler(), the user's poll(2) will indicate
only one file ready to read.  The daemon would read that file
and clear it.  So it would see only one error record, which is
probably what everybody expects.

> What error did you inject in the case that you describe above
> where you saw different independent records in cpu0/mca and
> cpu1/mca?

I just did my usual "dd if=/dev/mem of=/dev/null".  This MCAs
when we walk into a memory hole, but the MCA is detected by
the processor, not the platform.  So I'm guessing what I see is
that one CPU returns both platform and processor sections,
and the other returns only platform sections.  It's not clear
to me why the other CPU has a platform error section, or
how it should work to clear these.

Bjorn

