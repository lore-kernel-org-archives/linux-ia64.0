From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 08 May 2003 00:13:17 +0000
Subject: RE: [Linux-ia64] SAL error record logging/decoding
Message-Id: <marc-linux-ia64-105590723705667@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705660@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705660@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> From: Bjorn Helgaas [mailto:bjorn_helgaas@hp.com] 
> 
> The MCA/INIT/CMC/CPE log decoding currently in arch/ia64/kernel/mca.c
> has some problems:
> 
> 	- It doesn't know much about OEM-specific sections.
> 	- At boot-time, it sometimes takes so long to print
> 	  the log to the console that the BSP erroneously
> 	  assumes an AP is stuck.  This sometimes causes
> 	  *another* MCA.
> 	- The log goes ONLY to the console, where the output
> 	  may be lost.
> 
> So here's some fodder for discussion.  I don't claim that 
> this is ready
> for prime time; I just want to get some feedback on whether this
> is a reasonable approach.
> 
> The attached patch (against 2.4.21-rc1) makes the raw, binary
> error records straight from SAL available via files in /proc:
> 
> 	/proc/sal/cpu<n>/{mca,init,cmc,cpe}
> 
> If you read the file, you get the raw data.  If you write "clear" to
> it, you invalidate the current error record (which as I read the spec,
> may potentially make another, pending record available to be read).
> 
> The idea is that
> 
> 	- An rc script run at boot-time can save all the logs in
> 	  files, clearing each afterwards.
> 	- A user-level analysis tool can decode them as needed
> 	  (perhaps also run from the same rc script above).
> 	- The user-level analyzer need not be open-source, if
> 	  people are worried about IP in the OEM-specific sections.
> 	- A baseline open-source analyzer can provide at least the
> 	  functionality available today in the kernel decoder.
> 
> So, attached are the kernel patch against 2.4.21-rc1 and a simple
> user program ("salinfo") to decode the logs.  Note that the kernel
> patch removes the SAL clear_state_info calls from mca.c, so the error
> records will be preserved until the user program can read them.
> This feels like the right thing to me (only a user program
> can know that the logs have been saved somewhere safe), but
> no doubt there are issues here.
> 
> The user-space analyzer is derived from the current kernel code
> in mca.c and should produce identical output.  For now, I left
> all the code in the kernel as well, but ultimately it could be
> removed.

Definitely a step in the right direction.  SAL error records are
much too big, ugly and verbose to have them run through "printk"
to the console. Parsing in userland is great too.

I've also hit some issues with MCA recovery where printing the
error information from within the MCA handler tripped into other
problems (perhaps because of the time taken as you suggest).  So
I've been pondering some such mechanism too.

When to clear record from the SAL error log is a thorny question.
There are two conflicting goals:
1) Making sure that we minimize the chance that we lose error
information ... i.e. we would like to be sure that the error
record was saved to some permanent storage before we clear it

2) We need to clear records from the SAL log as soon as we can to
make space for subsequent records to be logged (and to reveal other
records that are already in the log).

I think that fact that we need to clear a record to see the next one
might force into taking a few risks of losing a message ... which
makes me believe that we need a mechanism to read and delete an error
record from the log and buffer it someplace until it can be picked up
from /proc (rather than using the "clear" command to the /proc
interface that you suggest).

-Tony


