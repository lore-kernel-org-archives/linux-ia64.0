From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 25 Oct 2002 05:35:37 +0000
Subject: [Linux-ia64] quick ia64 patch for 2.5.44 (UP only)
Message-Id: <marc-linux-ia64-105590709805243@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A quick patch that gets 2.5.44 (mostly) working on ia64 is now at
ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/ in file:

	linux-2.5.44-ia64-021024.diff.gz

With this patch, the kernel should work on Itanium 1, Itanium 2, and
the Ski simulator, PROVIDED you use the "nosmp" option with SMP
kernels.  Without "nosmp", the kernel crashes when starting up the
application processors.  It appears that the crash is caused by
something calling a NULL function pointer.

Kernel profiling is currently disabled (I haven't sorted out yet what
should be done with respect to the new profiling infrastructure).

Another caveat is that Itanium 1 machines need to have reasonably
recent firmware with correct ACPI information.  For Big Sur (e.g.,
i2000 machines), firmware 117C seems to be good enough (this firmware
is available from hp's workstation support web site, for example).
I'm not exactly sure what the earliest firmware version is that will
work properly.  But if you're encoutering interrupt routine problems,
the culprit is probably bad firmware.

I apologize for releasing such an incomplete patch, but I'm in the
middle of a family emergency which is keeping me from working
full-time.  I expect things to be back to normal sometime later next
week.  In the meantime, I appreciate (as always) all help to improve
the ia64 kernel.

Thanks,

	--david

