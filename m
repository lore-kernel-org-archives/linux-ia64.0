From: Bill Nottingham <notting@redhat.com>
Date: Mon, 03 Sep 2001 01:43:15 +0000
Subject: [Linux-ia64] Re: lilo in IA64
Message-Id: <marc-linux-ia64-105590698805113@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Eric Wang (ericwang25@hotmail.com) said: 
> I am porting some script source code from Linux IA32 to Linux IA64 
> environment. I am using RedHat 7.1 OS. When I run a command:
> 
> lilo -r /mnt
> 
> It could not run. The error message is: command not found.

Well, yes, because we use a different bootloader. You don't
need to re-run anything on config file changes.

Bill

