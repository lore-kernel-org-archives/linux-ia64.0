From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 01 Aug 2001 23:15:43 +0000
Subject: Re: [Linux-ia64] Panic in linuxrc (2.4.7)
Message-Id: <marc-linux-ia64-105590693005985@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005983@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005983@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Do you have CONFIG_PERFMON enabled?  If not, try turning it on.

We are investigating the problem.  It looks to be a Heisenbug: the
problem gets triggered depending on what the exact code layout is.
Adding or removing a single bundle in the right place seems to make
the difference...

We'll keep you posted.

	--david

>>>>> On Wed, 01 Aug 2001 16:05:36 -0700, richard offer <offer@sgi.com> said:

  Richard> I've just got my first (secondhand) IA64 box, and I'm
  Richard> trying to get 2.4.7 running so port some other kernel code
  Richard> (loadable security modules) to the IA64.

  Richard> Taking a vanilla 2.4.7, applying the 0726 patch (#2) and
  Richard> the suggested compiler fix as I'm using stock RedHat 7.1, I
  Richard> get...


  Richard> Freeing initrd memory: 736kB freed VFS: Mounted root (ext2
  Richard> filesystem).  linuxrc[8]: IA-64 Illegal operation fault 0

  Richard> psr : 0000101008026018 ifs : 800000000000050c ip :
  Richard> [<e000000004721ee0>] unat: 0000000000000000 pfs :
  Richard> 0000000000000000 rsc : 0000000000000000 rnat:
  Richard> 0000000000000000 bsps: 0000000000000000 pr :
  Richard> 000000000000445b ldrs: 0000000000000000 ccv :
  Richard> 0000000000000001 fpsr: 0009804c0270033f b0 :
  Richard> e00000000440ef90 b6 : e000000004482060 b7 :
  Richard> e00000000440f810 f6 : 1003e0000000000001940 f7 :
  Richard> 1003e0000000000000040 f8 : 1003e0000000000000001 f9 :
  Richard> 1003efffffffffffffe08 r1 : e000000004927000 r2 :
  Richard> e0000000048be800 r3 : e0000000047798a9 r8 :
  Richard> 0000000000000000 r9 : 000000000000048c r10 :
  Richard> 0000000000000000 r11 : 000000000000038a r12 :
  Richard> 800000ffffffde80 r13 : e00000003f090000 r14 :
  Richard> 0000000000000100 r15 : 0000000000000409 r16 :
  Richard> 0000000000000806 r17 : 0000000000000100 r18 :
  Richard> e00000003f09f8d0 r19 : e00000003f0b2530 r20 :
  Richard> e00000003f0b24f0 r21 : e00000003f0b2538 r22 :
  Richard> 0000000000000001 r23 : 0000000000000001 r24 :
  Richard> e000000004bd14f0 r25 : e000000000023198 r26 :
  Richard> e000000000022fe8 r27 : e000000000023010 r28 :
  Richard> e000000004bd1488 r29 : e00000003e728000 r30 :
  Richard> e000000004be0000 r31 : 0000000000000c9c r32 :
  Richard> 0000000000000000 r33 : 0000000000000000 r34 :
  Richard> 0000000000000000 r35 : 0000000000000000 r36 :
  Richard> 0000000000000000 r37 : 0000000000000000 r38 :
  Richard> 0000000000000000 r39 : 0000000000000000 r40 :
  Richard> 0000000000000000 r41 : 0000000000000000 r42 :
  Richard> 0000000000000000 r43 : 0000000000000000

  Richard> Call Trace: [<e0000000044140b0>] sp=0x800000ffffffd9c0
  Richard> bsp=0xe00000003f090d70


  Richard> Running this through ksymoops gave

  Richard> Warning (Oops_read): Code line not seen, dumping what data
  Richard> is available

  >>> IP; e000000004721ee0 <long_do_clear+70/110> <=== b0;
  >>> e00000000440ef90 <do_linuxrc+d0/100> b6; e000000004482060
  >>> <generic_file_mmap+0/1a0> b7; e00000000440f810
  >>> <ia64_switch_to+b0/120>
  Richard> Trace; e0000000044140b0 <show_stack+50/c0>


  Richard> 1 warning issued.  Results may not be reliable.


  Richard> Any clues ?


  Richard> thanks

  Richard> richard.

  Richard> PS [ acid 2.4.3-#1 ] cat /proc/cpuinfo processor : 0 vendor
  Richard> : GenuineIntel family : IA-64 model : Itanium revision : 2
  Richard> archrev : 0 features : standard cpu number : 0 cpu regs : 4
  Richard> cpu MHz : 666.713040 itc MHz : 666.713040 BogoMIPS : 664.79



  Richard> _______________________________________________ Linux-IA64
  Richard> mailing list Linux-IA64@linuxia64.org
  Richard> http://lists.linuxia64.org/lists/listinfo/linux-ia64

