From: Keith Owens <kaos@ocs.com.au>
Date: Sat, 28 Jul 2001 05:18:57 +0000
Subject: Re: [Linux-ia64] Ksymoops
Message-Id: <marc-linux-ia64-105590693005947@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005944@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005944@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 27 Jul 2001 10:08:11 -0400, 
"peck, william" <peck_william@emc.com> wrote:
>Has anyone here used ksymoops on ia64?

All the time.

>I get lots of warnings on my System.map.

Send me the ksymoops output, I will see if the System.map warnings are
user error (wrong System.map) or something else.

>I also get the complaint that it
>can't find my /lib/qla1280.o scsi module but I know thats because it came
>from an initrd image.  (Does anyone else think thats a bug?  Should the
>initrd library be at the same path as the real module when the system is
>loaded? ie /lib/modules/2.4.4/kernel/drivers/scsi/qla1280.o)

It is a bug, and will be fixed in the next ksymoops release, but only
if you supply an extra flag to ksymoops.  The extra flag will ignore
the path part of __insmod_..O names, instead it will look for the named
object in your current /lib/modules.  The assumption is that
/lib/modules always contains the same objects as used when mkinitrd was
run.  I hope to release the new ksymoops later this weekend.


