From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 17 Oct 2003 01:04:52 +0000
Subject: Re: type 95 for .text?
Message-Id: <marc-linux-ia64-106635275209809@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106634361902844@msgid-missing>
In-Reply-To: <marc-linux-ia64-106634361902844@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 16 Oct 2003 17:32:23 -0700, 
Grant Grundler <iod00d@hp.com> wrote:
>On Fri, Oct 17, 2003 at 09:19:54AM +1000, Keith Owens wrote:
>> One or more of your modules was compiled with the wrong flags, it used
>> the kernel flags instead.  The ia64 kernel is compiled with
>> -mconstant-gp, modules must not use that flag.  Which module did you
>> add yourself?
>
>This is after a "make distclean" and copying in a .config file.
>I also did "rm -rf /lib/modules/2.4.23-pre6".
>I didn't copy anything else in by hand.
>But I will try to track down which modules got compiled wrong.
>It sounds like several (maybe all) did.

for i in $(find /lib/modules/2.4.23-pre6 -type f); do readelf -h $i 2>/dev/null | (grep 'constant gp' > /dev/null && echo $i has constant gp); done

