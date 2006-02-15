From: Keith Owens <kaos@sgi.com>
Date: Wed, 15 Feb 2006 02:40:46 +0000
Subject: Re: [Patch]IA64 kexec
Message-Id: <20963.1139971246@ocs3>
List-Id: <linux-ia64.vger.kernel.org>
References: <1131406068.2524.15.camel@linux-znh>
In-Reply-To: <1131406068.2524.15.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Horms (on Wed, 15 Feb 2006 11:10:57 +0900) wrote:
>On Tue, Feb 14, 2006 at 04:13:07PM +1100, Keith Owens wrote:
>> But what kexec can do is to register itself on the
>> notify_die() chain ...
>
>Thanks, that looks quite promising indeed. However, after poking round a
>bit more I'm a little confused about what the intent of using INIT is.
>
>Is the idea to intercept an INIT, produced by the front panel, a
>maintenence processor, (or perhaps an internal error), and then start
>kexecing? Or is the idea for kexec to use INIT internally to halt the
>processors.

kexec (or any other RAS tool) should avoid using INIT itself.  The ia64
INIT handlers are coded on the assumption that INIT is sent to all cpus
at the same time, or that INIT is issued as part of the MCA rendezvous.
In either case, the code assumes that the entire system is first
brought to a dead stop, with all cpus under MCA or INIT control, before
processing with the RAS code.  IOW, the user invokes INIT via a button
or BMC command, all cpus stop, then you start the debug process.

But there is still the problem of working out what the user means when
they send INIT.  Do they want a debugger or kexec to run, followed by
reboot?  Or do they just want a stack trace followed by resumption of
normal processing.  Some people want one option, some want another, and
they are mutually exclusive.

>Lastly, if INIT is being used to shut off the processors by kexec, is it
>reasonable to assume that an INIT will hit all processors, and thus the
>slave processors can halt themselves in the callback (using cpu_die()?).

The combination of MCA and INIT will hit all processors.  Both the MCA
and INIT handlers call ia64_wait_for_slaves(), so the monarch event
will not proceed until all slaves have been stopped, or we decide that
they are never going to stop and proceed anyway.  So kexec should run
off the monarch notifier.

Have you read linux/Documentation/ia64/mca.txt?

