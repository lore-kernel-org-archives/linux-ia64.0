From: Paolo Bonzini <pbonzini@redhat.com>
Date: Thu, 20 Nov 2014 06:36:24 +0000
Subject: Re: [PATCH] KVM: ia64: remove
Message-Id: <546D8BE8.5080003@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416431143-31843-1-git-send-email-pbonzini@redhat.com> <546D40D8.2030407@intel.com>
In-Reply-To: <546D40D8.2030407@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Tiejun" <tiejun.chen@intel.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>



On 20/11/2014 02:16, Chen, Tiejun wrote:
> On 2014/11/20 5:05, Paolo Bonzini wrote:
>> KVM for ia64 has been marked as broken not just once, but twice even,
>> and the last patch from the maintainer is now roughly 5 years old.
>> Time for it to rest in piece.
>>
>> Signed-off-by: Paolo Bonzini <pbonzini@redhat.com>
>> ---
> 
> I think we also need to sync this in Documentation:
> 
> Documentation: virtual: kvm: remove ia64
> 
> kvm/ia64 would be gone so just clean Documentation.
> 
> Signed-off-by: Tiejun Chen <tiejun.chen@intel.com>
> ---
>  Documentation/ia64/kvm.txt          | 83
> -------------------------------------
>  Documentation/ia64/paravirt_ops.txt |  8 ++--
>  Documentation/virtual/kvm/api.txt   | 45 ++++++++++----------
>  3 files changed, 26 insertions(+), 110 deletions(-)
>  delete mode 100644 Documentation/ia64/kvm.txt
> 
> diff --git a/Documentation/ia64/kvm.txt b/Documentation/ia64/kvm.txt
> deleted file mode 100644
> index ffb5c80..0000000
> --- a/Documentation/ia64/kvm.txt
> +++ /dev/null
> @@ -1,83 +0,0 @@
> -Currently, kvm module is in EXPERIMENTAL stage on IA64. This means that
> -interfaces are not stable enough to use. So, please don't run critical
> -applications in virtual machine.
> -We will try our best to improve it in future versions!
> -
> -                               Guide: How to boot up guests on kvm/ia64
> -
> -This guide is to describe how to enable kvm support for IA-64 systems.
> -
> -1. Get the kvm source from git.kernel.org.
> -       Userspace source:
> -               git clone
> git://git.kernel.org/pub/scm/virt/kvm/kvm-userspace.git
> -       Kernel Source:
> -               git clone
> git://git.kernel.org/pub/scm/linux/kernel/git/xiantao/kvm-ia64.git
> -
> -2. Compile the source code.
> -       2.1 Compile userspace code:
> -               (1)cd ./kvm-userspace
> -               (2)./configure
> -               (3)cd kernel
> -               (4)make sync LINUX= $kernel_dir (kernel_dir is the
> directory of kernel source.)
> -               (5)cd ..
> -               (6)make qemu
> -               (7)cd qemu; make install
> -
> -       2.2 Compile kernel source code:
> -               (1) cd ./$kernel_dir
> -               (2) Make menuconfig
> -               (3) Enter into virtualization option, and choose kvm.
> -               (4) make
> -               (5) Once (4) done, make modules_install
> -               (6) Make initrd, and use new kernel to reboot up host
> machine.
> -               (7) Once (6) done, cd $kernel_dir/arch/ia64/kvm
> -               (8) insmod kvm.ko; insmod kvm-intel.ko
> -
> -Note: For step 2, please make sure that host page size =
> TARGET_PAGE_SIZE of qemu, otherwise, may fail.
> -
> -3. Get Guest Firmware named as Flash.fd, and put it under right place:
> -       (1) If you have the guest firmware (binary) released by Intel
> Corp for Xen, use it directly.
> -
> -       (2) If you have no firmware at hand, Please download its source
> from
> -               hg clone http://xenbits.xensource.com/ext/efi-vfirmware.hg
> -           you can get the firmware's binary in the directory of
> efi-vfirmware.hg/binaries.
> -
> -       (3) Rename the firmware you owned to Flash.fd, and copy it to
> /usr/local/share/qemu
> -
> -4. Boot up Linux or Windows guests:
> -       4.1 Create or install a image for guest boot. If you have xen
> experience, it should be easy.
> -
> -       4.2 Boot up guests use the following command.
> -               /usr/local/bin/qemu-system-ia64 -smp xx -m 512 -hda
> $your_image
> -               (xx is the number of virtual processors for the guest,
> now the maximum value is 4)
> -
> -5. Known possible issue on some platforms with old Firmware.
> -
> -In the event of strange host crash issues, try to solve it through
> either of the following ways:
> -
> -(1): Upgrade your Firmware to the latest one.
> -
> -(2): Applying the below patch to kernel source.
> -diff --git a/arch/ia64/kernel/pal.S b/arch/ia64/kernel/pal.S
> -index 0b53344..f02b0f7 100644
> ---- a/arch/ia64/kernel/pal.S
> -+++ b/arch/ia64/kernel/pal.S
> -@@ -84,7 +84,8 @@ GLOBAL_ENTRY(ia64_pal_call_static)
> -       mov ar.pfs = loc1
> -       mov rp = loc0
> -       ;;
> --      srlz.d                          // serialize restoration of psr.l
> -+      srlz.i                  // serialize restoration of psr.l
> -+      ;;
> -       br.ret.sptk.many b0
> - END(ia64_pal_call_static)
> -
> -6. Bug report:
> -       If you found any issues when use kvm/ia64, Please post the bug
> info to kvm-ia64-devel mailing list.
> -       https://lists.sourceforge.net/lists/listinfo/kvm-ia64-devel/
> -
> -Thanks for your interest! Let's work together, and make kvm/ia64
> stronger and stronger!
> -
> -
> -                                                               Xiantao
> Zhang <xiantao.zhang@intel.com>
> -                 2008.3.10
> diff --git a/Documentation/ia64/paravirt_ops.txt
> b/Documentation/ia64/paravirt_ops.txt
> index 39ded02..3a1f36b 100644
> --- a/Documentation/ia64/paravirt_ops.txt
> +++ b/Documentation/ia64/paravirt_ops.txt
> @@ -12,7 +12,7 @@ paravirt_ops (pv_ops in short) is a way for
> virtualization support of
>  Linux kernel on x86. Several ways for virtualization support were
>  proposed, paravirt_ops is the winner.
>  On the other hand, now there are also several IA64 virtualization
> -technologies like kvm/IA64, xen/IA64 and many other academic IA64
> +technologies like xen/IA64 and many other academic IA64
>  hypervisors so that it is good to add generic virtualization
>  infrastructure on Linux/IA64.
> 
> @@ -69,9 +69,9 @@ But paravirt_ops approach was taken because
>    and the overhead of paravirt_ops on native environment should be as
>    small as possible.
> 
> -- for full virtualization technology, e.g. KVM/IA64 or
> -  Xen/IA64 HVM domain, the result would be
> -  (the emulated platform machine vector. probably dig) + (pv_ops).
> +- for full virtualization technology, e.g. Xen/IA64 HVM domain, the
> +  result would be (the emulated platform machine vector. probably
> +  dig) + (pv_ops).
>    This means that the virtualization support layer should be under
>    the machine vector layer.
> 
> diff --git a/Documentation/virtual/kvm/api.txt
> b/Documentation/virtual/kvm/api.txt
> index 7a943c2..80bfe59 100644
> --- a/Documentation/virtual/kvm/api.txt
> +++ b/Documentation/virtual/kvm/api.txt
> @@ -607,7 +607,7 @@ struct kvm_fpu {
>  4.24 KVM_CREATE_IRQCHIP
> 
>  Capability: KVM_CAP_IRQCHIP, KVM_CAP_S390_IRQCHIP (s390)
> -Architectures: x86, ia64, ARM, arm64, s390
> +Architectures: x86, ARM, arm64, s390
>  Type: vm ioctl
>  Parameters: none
>  Returns: 0 on success, -1 on error
> @@ -615,7 +615,7 @@ Returns: 0 on success, -1 on error
>  Creates an interrupt controller model in the kernel.  On x86, creates a
> virtual
>  ioapic, a virtual PIC (two PICs, nested), and sets up future vcpus to
> have a
>  local APIC.  IRQ routing for GSIs 0-15 is set to both PIC and IOAPIC;
> GSI 16-23
> -only go to the IOAPIC.  On ia64, a IOSAPIC is created. On ARM/arm64, a
> GIC is
> +only go to the IOAPIC.  On ARM/arm64, a GIC is
>  created. On s390, a dummy irq routing table is created.
> 
>  Note that on s390 the KVM_CAP_S390_IRQCHIP vm capability needs to be
> enabled
> @@ -625,7 +625,7 @@ before KVM_CREATE_IRQCHIP can be used.
>  4.25 KVM_IRQ_LINE
> 
>  Capability: KVM_CAP_IRQCHIP
> -Architectures: x86, ia64, arm, arm64
> +Architectures: x86, arm, arm64
>  Type: vm ioctl
>  Parameters: struct kvm_irq_level
>  Returns: 0 on success, -1 on error
> @@ -679,7 +679,7 @@ struct kvm_irq_level {
>  4.26 KVM_GET_IRQCHIP
> 
>  Capability: KVM_CAP_IRQCHIP
> -Architectures: x86, ia64
> +Architectures: x86
>  Type: vm ioctl
>  Parameters: struct kvm_irqchip (in/out)
>  Returns: 0 on success, -1 on error
> @@ -701,7 +701,7 @@ struct kvm_irqchip {
>  4.27 KVM_SET_IRQCHIP
> 
>  Capability: KVM_CAP_IRQCHIP
> -Architectures: x86, ia64
> +Architectures: x86
>  Type: vm ioctl
>  Parameters: struct kvm_irqchip (in)
>  Returns: 0 on success, -1 on error
> @@ -994,7 +994,7 @@ for vm-wide capabilities.
>  4.38 KVM_GET_MP_STATE
> 
>  Capability: KVM_CAP_MP_STATE
> -Architectures: x86, ia64, s390
> +Architectures: x86, s390
>  Type: vcpu ioctl
>  Parameters: struct kvm_mp_state (out)
>  Returns: 0 on success; -1 on error
> @@ -1008,16 +1008,15 @@ uniprocessor guests).
> 
>  Possible values are:
> 
> - - KVM_MP_STATE_RUNNABLE:        the vcpu is currently running [x86, ia64]
> + - KVM_MP_STATE_RUNNABLE:        the vcpu is currently running [x86]
>   - KVM_MP_STATE_UNINITIALIZED:   the vcpu is an application processor (AP)
> -                                 which has not yet received an INIT
> signal [x86,
> -                                 ia64]
> +                                 which has not yet received an INIT
> signal [x86]
>   - KVM_MP_STATE_INIT_RECEIVED:   the vcpu has received an INIT signal,
> and is
> -                                 now ready for a SIPI [x86, ia64]
> +                                 now ready for a SIPI [x86]
>   - KVM_MP_STATE_HALTED:          the vcpu has executed a HLT
> instruction and
> -                                 is waiting for an interrupt [x86, ia64]
> +                                 is waiting for an interrupt [x86]
>   - KVM_MP_STATE_SIPI_RECEIVED:   the vcpu has just received a SIPI (vector
> -                                 accessible via KVM_GET_VCPU_EVENTS)
> [x86, ia64]
> +                                 accessible via KVM_GET_VCPU_EVENTS) [x86]
>   - KVM_MP_STATE_STOPPED:         the vcpu is stopped [s390]
>   - KVM_MP_STATE_CHECK_STOP:      the vcpu is in a special error state
> [s390]
>   - KVM_MP_STATE_OPERATING:       the vcpu is operating (running or halted)
> @@ -1025,7 +1024,7 @@ Possible values are:
>   - KVM_MP_STATE_LOAD:            the vcpu is in a special load/startup
> state
>                                   [s390]
> 
> -On x86 and ia64, this ioctl is only useful after KVM_CREATE_IRQCHIP.
> Without an
> +On x86, this ioctl is only useful after KVM_CREATE_IRQCHIP. Without an
>  in-kernel irqchip, the multiprocessing state must be maintained by
> userspace on
>  these architectures.
> 
> @@ -1033,7 +1032,7 @@ these architectures.
>  4.39 KVM_SET_MP_STATE
> 
>  Capability: KVM_CAP_MP_STATE
> -Architectures: x86, ia64, s390
> +Architectures: x86, s390
>  Type: vcpu ioctl
>  Parameters: struct kvm_mp_state (in)
>  Returns: 0 on success; -1 on error
> @@ -1041,7 +1040,7 @@ Returns: 0 on success; -1 on error
>  Sets the vcpu's current "multiprocessing state"; see KVM_GET_MP_STATE for
>  arguments.
> 
> -On x86 and ia64, this ioctl is only useful after KVM_CREATE_IRQCHIP.
> Without an
> +On x86, this ioctl is only useful after KVM_CREATE_IRQCHIP. Without an
>  in-kernel irqchip, the multiprocessing state must be maintained by
> userspace on
>  these architectures.
> 
> @@ -1068,7 +1067,7 @@ documentation when it pops into existence).
>  4.41 KVM_SET_BOOT_CPU_ID
> 
>  Capability: KVM_CAP_SET_BOOT_CPU_ID
> -Architectures: x86, ia64
> +Architectures: x86
>  Type: vm ioctl
>  Parameters: unsigned long vcpu_id
>  Returns: 0 on success, -1 on error
> @@ -1261,7 +1260,7 @@ The flags bitmap is defined as:
>  4.48 KVM_ASSIGN_PCI_DEVICE
> 
>  Capability: none
> -Architectures: x86 ia64
> +Architectures: x86
>  Type: vm ioctl
>  Parameters: struct kvm_assigned_pci_dev (in)
>  Returns: 0 on success, -1 on error
> @@ -1311,7 +1310,7 @@ Errors:
>  4.49 KVM_DEASSIGN_PCI_DEVICE
> 
>  Capability: none
> -Architectures: x86 ia64
> +Architectures: x86
>  Type: vm ioctl
>  Parameters: struct kvm_assigned_pci_dev (in)
>  Returns: 0 on success, -1 on error
> @@ -1330,7 +1329,7 @@ Errors:
>  4.50 KVM_ASSIGN_DEV_IRQ
> 
>  Capability: KVM_CAP_ASSIGN_DEV_IRQ
> -Architectures: x86 ia64
> +Architectures: x86
>  Type: vm ioctl
>  Parameters: struct kvm_assigned_irq (in)
>  Returns: 0 on success, -1 on error
> @@ -1370,7 +1369,7 @@ Errors:
>  4.51 KVM_DEASSIGN_DEV_IRQ
> 
>  Capability: KVM_CAP_ASSIGN_DEV_IRQ
> -Architectures: x86 ia64
> +Architectures: x86
>  Type: vm ioctl
>  Parameters: struct kvm_assigned_irq (in)
>  Returns: 0 on success, -1 on error
> @@ -1385,7 +1384,7 @@ KVM_ASSIGN_DEV_IRQ. Partial deassignment of host
> or guest IRQ is allowed.
>  4.52 KVM_SET_GSI_ROUTING
> 
>  Capability: KVM_CAP_IRQ_ROUTING
> -Architectures: x86 ia64 s390
> +Architectures: x86 s390
>  Type: vm ioctl
>  Parameters: struct kvm_irq_routing (in)
>  Returns: 0 on success, -1 on error
> @@ -1444,7 +1443,7 @@ struct kvm_irq_routing_s390_adapter {
>  4.53 KVM_ASSIGN_SET_MSIX_NR
> 
>  Capability: none
> -Architectures: x86 ia64
> +Architectures: x86
>  Type: vm ioctl
>  Parameters: struct kvm_assigned_msix_nr (in)
>  Returns: 0 on success, -1 on error
> @@ -1466,7 +1465,7 @@ struct kvm_assigned_msix_nr {
>  4.54 KVM_ASSIGN_SET_MSIX_ENTRY
> 
>  Capability: none
> -Architectures: x86 ia64
> +Architectures: x86
>  Type: vm ioctl
>  Parameters: struct kvm_assigned_msix_entry (in)
>  Returns: 0 on success, -1 on error

Right, thanks!

Paolo
