From: alext@fc.hp.com (Alex Tsariounov)
Date: Fri, 30 May 2003 16:48:31 +0000
Subject: [Linux-ia64] Re: hp_simserial_driver required for real kernel
Message-Id: <marc-linux-ia64-105590723706089@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 29 May 2003 17:49:30 -0400, Will Cohen writes:
> Subject: [Linux-ia64] hp_simserial_driver required for real kernel
>
> I am starting with the linux-2.5.69.tar.bz2 and 
> linux-2.5.69-ia64-030521.diff.bz2 to generate kernel sources. It appears 
...
> CONFIG_IA64_GENERIC=y
...
> Certainly when building for a real machine there should be no need for 
> the simulator serial port. Is there a fix for this? Has anyone 
> successfully built the  2.5.69 kernel with the patch for a real machine?

Will,

If you set the processor type to ZX1 (of course onlyh if you are on
a Longs Peak machine) you bypass this dependancy and 2.5.69 builds.

Regards,
Alex


