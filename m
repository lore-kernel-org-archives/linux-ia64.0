From: Scott Hankin <shankin@rational.com>
Date: Wed, 15 Nov 2000 17:59:50 +0000
Subject: Re: [Linux-ia64] Recommended compiler for compiling kernels
Message-Id: <marc-linux-ia64-105590678205725@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205680@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205680@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>On Mon, Nov 13, 2000 at 03:01:56PM -0800, Jim Wilson wrote:
>>  >I'm trying to build the 2.4.0-test10 kernel with the ia64 patch.  We
>>  >recently upgaded the hardware on one of our boxes to B1 stepping, and
>>  >now it won't boot.  I'm hoping the newer kernel will work better.
>>
>>  The Red Hat August Linux OS release won't boot on a B1.  This was due to a
>>  misapplied kernel patch, and was fixed immediately after the problem was
>>  discovered, which was unfortunately a couple of days after the OS release.
>>
>>  There is a kernel update available from Red Hat that fixes this, but it is
>>  a little tricky to install the kernel update if the machine doesn't boot.
>>  Since you presumably still have A step machines, you should be 
>>able to install
>>  the kernel update on an Ax machine, and then move a hard disk over to the B1
>>  machine, and then it should boot.
>>  ftp://ftp.redhat.com/pub/redhat/ia64/updates/RPMS
>>
>
>That is what happened to me when my machine was upgraded to B1. I
>wound up putting a working kernel on the RedHat ia64 bootable LS120
>floppy and booted it with root=.... It assumes you have RedHat already
>installed on your machine befor upgrade.
>
>--
>H.J. Lu (hjl@valinux.com)

Howdy -

Precisely how did you do that?  I can currently boot from the LS120 disk
I made from the Red Hat CD, but when I mount it, the directory listing
is garbage, leading me to believe that the format is not that of a Linux
filesystem.  I have a new kernel - what do I do to get it on the LS120?

- Scott

-----------------------------
Scott Hankin                  In the beginning, there was nothing, then
Rational Software             God said, "Let there be light."  And there
20 Maguire Road               was light.  There was still nothing, but
Lexington, MA 02421           you could see it a lot better.

