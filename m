From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Fri, 19 Aug 2005 23:55:26 +0000
Subject: Re: Simulator bootloader fails with gcc 4
Message-Id: <17158.29038.870370.10020@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050720053139.GC13188@cse.unsw.EDU.AU>
In-Reply-To: <20050720053139.GC13188@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Stephane" = Stephane Eranian <eranian@hpl.hp.com> writes:

Stephane> Peter,
Stephane> Ok, this change seems to work for both gcc-4.0 and
Stephane> gcc-3.3.5. So what this is saying is that we got lucky with
Stephane> the older compilers that the variables were somehow laid out
Stephane> slightly differently on the stack.

>> I can't run ski at present to check it (it segfaults immediately)
>> 
Stephane> Well, that will be the next thing I need to check. It dies
Stephane> on both IA64 and I386?

Well, yes and no.

on IA64 it segfaults.  On IA32, I get `can't open console window',
because Ski appears to be passing a FD that's closed to xterm.
(It invokes xterm with -S/63 but fd 63 isn't open --- only fds 0, 1, 2
and 4, so xterm dies with:

Linux/ia64 Console: Error 12, errno 9: Bad file descriptor
Reason: main: ioctl() failed on F_GETFL


-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
