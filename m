From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 16 Apr 2001 16:17:29 +0000
Subject: Re: [Linux-ia64] Re: Documentation for compiling IA64
Message-Id: <marc-linux-ia64-105590693005408@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005406@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005406@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 16 Apr 2001 11:31:16 -0400, Bill Nottingham <notting@redhat.com> said:

  Bill> McCaffity, Ray (ray.mccaffity@wcg.com) said:
  >> I downloaded the 2.4.3 kernel from Kernel.org and then the IA64
  >> patch from the ports directory.  I patched the Kernel with the
  >> 2.4.3-ia64 diff file.  I can do a 'make mrproper', and a 'make
  >> config' (It even recognizes the IA64 CPU), I can even do a 'make
  >> dep' but it doesn't let me do a make bzImage or even a make
  >> zImage.  I tried looking in the make.rules and makefile to see
  >> what targets were options, but didn't find anything.  What is the
  >> target make file?

  Bill> make vmlinux

Starting with 2.4.3, there is also "make compressed", which will build
vmlinux.gz and is the closest to the x86 "zImage" target.

Note: you'll need elilo.efi to boot 2.4.3!

	--david

