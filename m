From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 29 May 2003 20:49:53 +0000
Subject: RE: [Linux-ia64] SAL error record logging/decoding
Message-Id: <marc-linux-ia64-105590723706078@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705660@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705660@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Digging back in this thread to last Thursday ...

> > 2) I crashed my machine with an injected machine check, and
> > then rebooted.  All four of the /proc/sal/cpuX/mca files had
> > a copy of the same error record.  Echoing "clear" to one of
> > them made them all go away.
> 
> Hmm...  this sounds like a reflection of the underlying firmware
> behavior.  I tried this on a 2-way HP box, and the cpu0/mca
> file was different than cpu1/mca, and clearing one did not
> clear the other.
> 
> > I think this is normal ... but it may require some interesting
> > documentation to say why things work like this.
> 
> Why do you think that's normal?  It sounds pretty strange
> to me.

I asked a SAL expert here who said:

 "The SAL spec does not require that the SAL_GET_STATE_INFO API
  be called on the processor where the error was detected (for
  recoverable and fatal errors).  So in this case, the SAL has
  logged it to flash before handing off to the OS.  When the OS
  calls SAL_GET_STATE_INFO, it just retrieves the last error in
  the queue from the flash image.  The processor section of the
  error record has a field for the processsor LID --- so you can
  check if the right processor observed the error."


What error did you inject in the case that you describe above
where you saw different independent records in cpu0/mca and
cpu1/mca?

-Tony

