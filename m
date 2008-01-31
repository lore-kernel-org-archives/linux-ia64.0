From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 31 Jan 2008 10:27:49 +0000
Subject: [PATCH] [00]Patch set to enable kvm on ia64 platforms
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCD31FC3@pdsmsx415.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: kvm-devel@lists.sourceforge.net, kvm-ia64-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

Hi, Avi/Tony
	We have rebased kvm/ia64 code to latest kvm. In this version, we
have fixed coding style issues, and all patches can pass checkpatch.pl,
except one assembly header file, which is copyied from kernel, so we
didn't change its issues. 
Compared with last version, we implemented smp guest support, and
addressed two stability issues which only take on with smp guests.  Now,
based on our own test results, it has good stability, and good
performance. Please review and help to commit them before linux 2.6.25
merge :)
 
[01]  Appoint Maintainter for kvm/ia64. 
[02]  Change srlz.d to srlz.i for ia64_set_psr to save unnecessary
srlz.d, since kvm need to use it frequently.
[03]  Export three symbos for module use.
[04]  Add API for allocating TR resouce. 
For patch04, We want to add a comment TR resource API for kernel. It is
not just used by kvm module.  Our idea is that the first two pari of TRs
are used as a fixed way, and we don't need to touch them.  This API only
manages TR resource for dynamic use.  
Based on Tony's comments, we changed its implementation, and optimized
it for checking overlap.  Thank you,  Tony!.

Since the above four patches touch the source code out of kvm world,
they need Tony's Ack and Sign-off-by :)

[05] Add kvm.h, kvm_host.h kvm_para.h for kvm/ia64
[06] Add kvm arch-specific core code for kvm/ia64.
[07] Add kvm sal/pal virtulization support.
[08] Add local head files for kvm/ia64

The above four patches implement arch-specific code for kvm/ia64

[09] Add VMM module interfaces.
[10] Add TLB virtulization support.
[11] Add mmio decoder for kvm/ia64.
[12] Add interruption vector table for vmm.
[13] Add trampoline for guest/host mode switch.
[14] Add processor virtulization support.
[15] add optimization for some virtulization faults
[16] Generate offset values for assembly code use.
[17] Add guest interruption injection support.

The above patches implement GVMM code.

[18] Add Kconfig for kvm configuration.
[19] Add Makefile for kvm files compile.
[20] Update IA64 Kconfig and Makefile to include kvm build.
[21] Readme for kvm/ia64 

Update Makefile/Kconfig for kvm build, and write a howto for making
kvm/ia64.

Thanks
Xiantao
