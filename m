From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 21 May 2003 18:06:20 +0000
Subject: RE: [Linux-ia64] SAL error record logging/decoding
Message-Id: <marc-linux-ia64-105590723705973@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705660@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705660@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> From: Bjorn Helgaas [mailto:bjorn_helgaas@hp.com]
> 
> I'd like to make some sort of forward progress on this issue
> before releasing a 2.4.21 ia64 patch.  By default this will
> be to apply the original patch I posted on May 7.
> 
> I'm not trying to railroad anything here, but 2.4.21 is
> getting close, and I'd rather not wait until 2.4.22.  So
> if there are any major issues with the proposal, please
> raise them!  The only real issue so far has been when
> the error records should cleared from the firmware log,
> and I'm certainly open to more discussion on that.
> 
> As for 2.5, I'm willing to turn it into a filesystem if
> that's the Right Thing (though it feels like all the
> existing /proc/pal, /proc/sal, and /proc/efi stuff should
> be converted at the same time, which is more than I really
> had in mind).  In any case, it will take me some time to
> learn about how that infrastructure works.

My only reservation with this is making sure that we deal
with error records in a rapid manner, so that a sequence
of errors occurring in quick succession have less chance
of overflowing the SAL log.

Is there any easy way to get a notification that there is
a record waiting in one of the /proc/sal/cpuX/* files ...
so that a daemon process can wake promptly to pick up the
error, log it, and issue the "clear" to free space for the
next error?  Does /proc support a poll/select mechanism that
could be used here?  Or perhaps there could be a top level
file /proc/sal/error which blocks on read from the daemon
and doesn't return until there's a record to be read? Maybe
the returned data from the read would be the cpu and error
class to tell the daemon which file to read?

Without some such method, the daemon needs to keep reading
all the /proc/sal/cpuX/* files at regular intervals.  This
doesn't look like it scales well. A hypothetical 256 cpu
machine has 1024 such files that need to be checked, so even
with a poll interval of 10 seconds for each file, we'd need
to issue 102 reads per second from the daemon.

-Tony

