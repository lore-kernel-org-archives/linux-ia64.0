From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 13 Sep 2004 19:46:09 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200409131946.i8DJk9732045@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/linux-ia64-release-2.6.9

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/Makefile                       |    2 
 arch/ia64/sn/io/machvec/pci_bus_cvlink.c |   15 ++
 arch/ia64/sn/kernel/sn2/sn_proc_fs.c     |  185 ++++++++++++++-----------------
 3 files changed, 101 insertions(+), 101 deletions(-)

through these ChangeSets:

<eranian@hpl.hp.com> (04/09/13 1.1803.144.1)
   [IA64] Makefile: fix for the PTRACE_SYSCALL corruption bug
   
   Thanks to David for his help in tracking it down.
   
     compile the kernel with sibling call optimization
     turned off. There is a problem with all functions
     using the optimization and the asmlinkage attribute.
     The compiler should not perform the optimization on
     these functions because it cannot preserve the syscall
     parameters in the callee. This caused SIGSEGV on programs
     traced with PTRACE_SYSCALL, for instance.
   
   signed-off-by: stephane eranian <eranian@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/09/09 1.1803.143.7)
   [IA64-SGI]: disable non-display ROM resources
    
   This patch is needed to correctly support the new sysfs rom file.  On sn2, we
   only allocate PIO space for display option ROMs since PIO space is a
   relatively scarce resource (we've seen exhaustion when running with several
   qla cards in the same domain).  And without this patch we won't zero out
   non-display ROM resources which can lead to panics if anyone tries to use the
   bogus addresses left over there from the generic PCI probing code.
   
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<markgw@sgi.com> (04/09/09 1.1803.143.6)
   [IA64-SGI] sn_proc_fs.c: convert to use seq_file API
   
   Signed-off-by: Mark Goodwin <markgw@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

