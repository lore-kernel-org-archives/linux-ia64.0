From: Bill Nottingham <notting@redhat.com>
Date: Thu, 19 Apr 2001 12:48:14 +0000
Subject: [Linux-ia64] Re: Detecting SMP in user space
Message-Id: <marc-linux-ia64-105590693005429@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andreas Schwab (schwab@suse.de) said: 
> |> How about simply running 'top' or a 'dmesg | grep CPU'?
> 
> As I already said, I'm running a UP kernel, thus top only ever sees one
> CPU.  The latter fails if the boot messages have already been cleared from
> the kernel log.

I believe the ACPI boot messages on ia64 tell you how many processors
it found.

Bill

