From: Einar Saltnes <eisa@scali.no>
Date: Mon, 12 Feb 2001 16:40:47 +0000
Subject: Re: [Linux-ia64] Serial console during linux boot
Message-Id: <marc-linux-ia64-105590693005136@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005123@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005123@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane Eranian wrote:
> 
> You are missing the quotes around the console= command here also.
> Here is the valid command:
> 
> lilo -a -i initrd-2.4.0-0.43smp.img vmlinux-2.4.0-0.43smp root=/dev/sda2
> console=tty0 console="ttyS0,115200n8"
> 
> Hope this fixes it this time !
> 
Thanks!
The quotes made the trick!
Now I get the kernel messages on both the local monitor and on the
serial console at the same time! Great!

Mike Sklar wrote:
>
> last I checked with a 2.4.0-test10 kernel on ia64 I was using only
> ttyS0,115200 and getting kernel startup messages. No 'n8' included, but
> perhaps that doesn't matter at all. You might want to try checkout redhats
> 1/31/01 release, I've found it to be of much higher quality than the
> december beta which I quickly stopped using.
>
Thanks for the advice! I will download the newer "Fisher" distro and
check it out soon.

-
Einar
-- 
| Einar Saltnes          |         Scali AS         |
| mailto:eisa@scali.no   |   http://www.scali.com   |
| Phone:+47 22 62 89 50  |  Scalable Linux Systems  |
| Fax  :+47 22 62 89 51  |      and Technology      |

