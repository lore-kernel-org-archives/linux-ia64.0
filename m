From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Wed, 01 Aug 2001 23:27:04 +0000
Subject: RE: [Linux-ia64] Panic in linuxrc (2.4.7)
Message-Id: <marc-linux-ia64-105590693005987@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005983@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005983@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I've just got my first (secondhand) IA64 box, and I'm trying 
> to get 2.4.7
> running so port some other kernel code (loadable security 
> modules) to the
> IA64.
> 
> Taking a vanilla 2.4.7, applying the 0726 patch (#2) and the suggested
> compiler fix as I'm using stock RedHat 7.1, I get...

> Freeing initrd memory: 736kB freed
> VFS: Mounted root (ext2 filesystem).
> linuxrc[8]: IA-64 Illegal operation fault 0

> Running this through ksymoops gave
> 
> Warning (Oops_read): Code line not seen, dumping what data is 
> available
> 
> >>IP;  e000000004721ee0 <long_do_clear+70/110>   <==> >>b0;  e00000000440ef90 <do_linuxrc+d0/100>
> >>b6;  e000000004482060 <generic_file_mmap+0/1a0>
> >>b7;  e00000000440f810 <ia64_switch_to+b0/120>
> Trace; e0000000044140b0 <show_stack+50/c0>

> Any clues ?

I sent an email about this on 7/28, but didn't get a reply (but you sent
more info than I did):

  I tried upgrading to 2.4.7+IA64-010726, but when I did that, "init" dies:
    init[1]: IA-64 Illegal operation fault 0
  [...]
    Kernel panic: Attempted to kill init!

The 2.4.5 kernel boots with the 6/26 patches, but I'd like to run a newer
kernel too :-)

Kevin

