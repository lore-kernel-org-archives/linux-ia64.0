From: Bill Nottingham <notting@redhat.com>
Date: Mon, 16 Apr 2001 15:31:16 +0000
Subject: [Linux-ia64] Re: Documentation for compiling IA64
Message-Id: <marc-linux-ia64-105590693005406@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

McCaffity, Ray (ray.mccaffity@wcg.com) said: 
> I downloaded the 2.4.3 kernel from Kernel.org and then the IA64 patch from
> the ports directory.
> I patched the Kernel with the 2.4.3-ia64 diff file.
> I can do a 'make mrproper', and a 'make config' (It even recognizes the IA64
> CPU), I can even do a
> 'make dep' but it doesn't let me do a make bzImage or even a make zImage.  I
> tried looking in the 
> make.rules and makefile to see what targets were options, but didn't find
> anything.  What is the target 
> make file?

make vmlinux

> One other thing I noticed.  With x86 version, you can select how much memory
> the Kernel will recognize
> (4GB, 64GB, etc..)  There is 16GB in this server.  Will the Kernel recognize
> all of it? 

Yes.

> Right now I have to
> do a mem=2G from the ELI loader.

Why?

Bill

