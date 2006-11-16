From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 16 Nov 2006 16:28:01 +0000
Subject: Re: KDB blindly reads keyboard port
Message-Id: <200611160928.02064.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <23616.1163649739@kao2.melbourne.sgi.com>
In-Reply-To: <23616.1163649739@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wednesday 15 November 2006 21:02, Keith Owens wrote:
> I implemented this in my kdb tree, but it has a very nasty side effect,
> it stops you from debugging that part of the boot process between kdb
> startup and when the i8042 is probed.  KDB starts up very early so we
> can debug the boot process.  Not being able to use the PC keyboard
> until later in boot is not acceptable.  People using USB keyboards
> already suffer from this problem and it is very frustrating.
> 
> Adding a "kdb_use_keyboard" flag means all existing systems have to
> change if they want a debugger during boot, just to workaround a few
> systems that get an error when reading from non-existent legacy I/O
> ports.  So I am going back to my original idea, add 'kdb_skip_keyboard'
> which is only required on the problem machines.

Hold on a minute.  These "problem machines" are completely compliant
with all the relevant ia64 specs in this area.  There is no spec that
says a keyboard controller must be present or that reading a non-
existent I/O port should be safe.

What about the FADT iapc_boot_arch bit?  Did you determine that isn't
sufficient for some reason?  That's available very early.

Bjorn
