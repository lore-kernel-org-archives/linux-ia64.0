From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 23 May 2003 00:24:11 +0000
Subject: Re: [Linux-ia64] SAL error record logging/decoding
Message-Id: <marc-linux-ia64-105590723705990@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705660@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705660@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 21 May 2003 3:51 pm, Luck, Tony wrote:
> Some minor issues with the "salinfo" tool.
> 
> 1) It doesn't compile :-(

I compiled for me (on debian), but I'll add the prototype.

> 2) I crashed my machine with an injected machine check, and
> then rebooted.  All four of the /proc/sal/cpuX/mca files had
> a copy of the same error record.  Echoing "clear" to one of
> them made them all go away.

Hmm...  this sounds like a reflection of the underlying firmware
behavior.  I tried this on a 2-way HP box, and the cpu0/mca
file was different than cpu1/mca, and clearing one did not
clear the other.

> I think this is normal ... but it may require some interesting
> documentation to say why things work like this.

Why do you think that's normal?  It sounds pretty strange
to me.

> 3) The salinfo tool uses exponential increases in the size of the
> read that it tries from the /proc/sal/cpuX/mca file.  
> ...
> A hypothetically large enough record would result in salinfo reading
> more than a page in one piece through /proc, which I think breaks the
> way arch/ia64/kernel/salinfo.c is interfacing with /proc.

I actually expected that to be a problem, but I copied the
code from the /proc/acpi/dsdt stuff, and it seems to be
able to export over 40K of data on my x86 laptop just fine.
So maybe both ACPI and my salinfo stuff are broken, but
I haven't seen any complaints about the ACPI version.
(A weak argument, I know; I just don't know very much
about doing things in /proc :-)

> 4) Reading this way is also kind of weird in that every partial read
> results in the kernel going back to re-fetch the data from the SAL
> with another call to ia64_sal_get_state_info().  One kludgy fix would
> be to have the salinfo tool use "getpagesize()" as the initial size
> and increment for the buffer it uses (at least for kernels with a 16k
> page size ... error records should generally be small enough for a
> single slurp). Though we'd still do one extra call to get the nbytes=0
> return to signify the EOF (unless we assume the partial read got us
> all the data?)

I think making the initial size 8K or 16K seems reasonable.  I
wanted to minimize the management of the kernel buffer, but
I suppose we could do the allocate/get_state_info at open-time,
and deallocate in close.  I'll look at that tomorrow.

Bjorn

