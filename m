From: Aaron Burt <aaron@osdl.org>
Date: Thu, 31 Jan 2002 00:45:53 +0000
Subject: Re: [Linux-ia64] 2.4.17 on Azusa box
Message-Id: <marc-linux-ia64-105590698805971@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805969@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805969@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 30 Jan 2002, Robert Williamson wrote:
> I'm sure the answer to this has been posted before, but I couldn't find it
> in the archives.  Is there any issues with ACPI and the 16-way Azusa boxes,
> because I cannot get the kernel to boot.  I'm currently running an old
> 2.4.3-12 kernel.

Some AzusA kernel notes:
- You must have SAL v1.23.  Though I've a patch for 2.4.10's setup.c that
   lets earlier SAL versions work.
- The kernel page size needs to be 16KB.
- The interrupt tables can overwhelm the kernel, but this only happens
   in 2.4.[7-9].  Earlier and later versions are fine.  I've patches
   for the affected versions nonetheless.
- You'll get TickOOPS messages during bootup, but they're harmless.
- NEC hardware engineering says to disable USB in the kernel.


Oh, and we've a 16-way AzusA here at the OSDL available for scalability-
related projects.  It's currently running Linux 2.4.16-ia64 with Red Hat
7.1.  IIRC we've also got SuSE and TurboLinux on it, but Mandrake and
Debian's installers gave me fits. (boo!)


