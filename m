From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 08 May 2003 19:32:52 +0000
Subject: Re: [Linux-ia64] SAL error record logging/decoding
Message-Id: <marc-linux-ia64-105590723705693@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705660@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705660@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 07 May 2003 6:13 pm, Luck, Tony wrote:
> When to clear record from the SAL error log is a thorny question.
> There are two conflicting goals:
> 1) Making sure that we minimize the chance that we lose error
> information ... i.e. we would like to be sure that the error
> record was saved to some permanent storage before we clear it
> 
> 2) We need to clear records from the SAL log as soon as we can to
> make space for subsequent records to be logged (and to reveal other
> records that are already in the log).
> 
> I think that fact that we need to clear a record to see the next one
> might force into taking a few risks of losing a message ... which
> makes me believe that we need a mechanism to read and delete an error
> record from the log and buffer it someplace until it can be picked up
> from /proc (rather than using the "clear" command to the /proc
> interface that you suggest).

I actually implemented such a read/buffer/clear mechanism, but
the buffer management makes it much more complicated and I couldn't
see any benefit, based on the following reasoning:

There's always a window between SAL_CHECK (where the error records
are created, consuming buffer space) and SAL_CLEAR_STATE_INFO (where
the buffer space is freed).  Information about events that occur in
that window may be lost, regardless of whether the error records are
cleared by the kernel or by a user application.

I'm unconvinced by the argument that the kernel should call
SAL_CLEAR_STATE_INFO in order to reduce (but not eliminate)
the window.

Here's a likely scenario that shows why I think we have to make
sure the log gets to stable storage before we clear it:

	- MCA occurs
	- Linux reboots
	- Kernel calls SAL_GET_STATE_INFO, copies records to buffer
	- Kernel calls SAL_CLEAR_STATE_INFO
	- Kernel panics because MCA corrupted root filesystem

Now the MCA error records are lost, and it's not even because SAL
ran out of buffer space!  We might argue that for this reason, the
kernel ought to decode the records to the console, but even then
the console output might not be logged, and vital OEM data might
not be decoded at all.

With my proposal, we at least have the possibility of dumping the
error records from the EFI user interface, even if we can no longer
boot the kernel.

Bjorn


