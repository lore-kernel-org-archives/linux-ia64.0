From: "Broadfoot, Ken P" <ken.p.broadfoot@intel.com>
Date: Wed, 01 Aug 2001 23:16:23 +0000
Subject: RE: [Linux-ia64] Panic in linuxrc (2.4.7)
Message-Id: <marc-linux-ia64-105590693005984@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005983@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005983@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

My guess is that you are using a B1 processor. ( Revision 2 )

You HAVE to use kernel 2.4.4 in my experience to stop the panics.

2.5.5 is good on B3's and C0's I ssume 2.4.7 would be fine here too.



--ken

-----Original Message-----
From: richard offer [mailto:offer@sgi.com]
Sent: Wednesday, August 01, 2001 4:06 PM
To: linux-ia64@linuxia64.org
Subject: [Linux-ia64] Panic in linuxrc (2.4.7)



I've just got my first (secondhand) IA64 box, and I'm trying to get 2.4.7
running so port some other kernel code (loadable security modules) to the
IA64.

Taking a vanilla 2.4.7, applying the 0726 patch (#2) and the suggested
compiler fix as I'm using stock RedHat 7.1, I get...


Freeing initrd memory: 736kB freed
VFS: Mounted root (ext2 filesystem).
linuxrc[8]: IA-64 Illegal operation fault 0

psr : 0000101008026018 ifs : 800000000000050c ip  : [<e000000004721ee0>]
unat: 0000000000000000 pfs : 0000000000000000 rsc : 0000000000000000
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 000000000000445b
ldrs: 0000000000000000 ccv : 0000000000000001 fpsr: 0009804c0270033f
b0  : e00000000440ef90 b6  : e000000004482060 b7  : e00000000440f810
f6  : 1003e0000000000001940 f7  : 1003e0000000000000040
f8  : 1003e0000000000000001 f9  : 1003efffffffffffffe08
r1  : e000000004927000 r2  : e0000000048be800 r3  : e0000000047798a9
r8  : 0000000000000000 r9  : 000000000000048c r10 : 0000000000000000
r11 : 000000000000038a r12 : 800000ffffffde80 r13 : e00000003f090000
r14 : 0000000000000100 r15 : 0000000000000409 r16 : 0000000000000806
r17 : 0000000000000100 r18 : e00000003f09f8d0 r19 : e00000003f0b2530
r20 : e00000003f0b24f0 r21 : e00000003f0b2538 r22 : 0000000000000001
r23 : 0000000000000001 r24 : e000000004bd14f0 r25 : e000000000023198
r26 : e000000000022fe8 r27 : e000000000023010 r28 : e000000004bd1488
r29 : e00000003e728000 r30 : e000000004be0000 r31 : 0000000000000c9c
r32 : 0000000000000000 r33 : 0000000000000000 r34 : 0000000000000000
r35 : 0000000000000000 r36 : 0000000000000000 r37 : 0000000000000000
r38 : 0000000000000000 r39 : 0000000000000000 r40 : 0000000000000000
r41 : 0000000000000000 r42 : 0000000000000000 r43 : 0000000000000000

Call Trace: [<e0000000044140b0>] sp=0x800000ffffffd9c0
bsp=0xe00000003f090d70


Running this through ksymoops gave

Warning (Oops_read): Code line not seen, dumping what data is available

>>IP;  e000000004721ee0 <long_do_clear+70/110>   <==>>b0;  e00000000440ef90 <do_linuxrc+d0/100>
>>b6;  e000000004482060 <generic_file_mmap+0/1a0>
>>b7;  e00000000440f810 <ia64_switch_to+b0/120>
Trace; e0000000044140b0 <show_stack+50/c0>


1 warning issued.  Results may not be reliable.


Any clues ?


thanks

richard.

PS
[ acid 2.4.3-#1 ] cat /proc/cpuinfo 
processor  : 0
vendor     : GenuineIntel
family     : IA-64
model      : Itanium
revision   : 2
archrev    : 0
features   : standard
cpu number : 0
cpu regs   : 4
cpu MHz    : 666.713040
itc MHz    : 666.713040
BogoMIPS   : 664.79



_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

