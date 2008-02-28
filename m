From: "Dong, Eddie" <eddie.dong@intel.com>
Date: Thu, 28 Feb 2008 17:21:27 +0000
Subject: RE: [PATCH 0/5] RFC: ia64/pv_ops: ia64 intrinsics paravirtualization
Message-Id: <10EA09EFD8728347A513008B6B0DA77A02D767E9@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12041926372068-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12041926372068-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Isaku Yamahata wrote:
> Hi. Thank you for comments on asm code paravirtualization.
> Its direction is getting clear. Although it hasn't been finished yet,
> I'd like to start discussion on ia64 intrinsics paravirtualization.
> This patch set is just for discussion so that it is a subset of
> xen Linux/ia64 domU paravirtualization, not self complete.
> You can get the full patched tree by typing
> git clone
> http://people.valinux.co.jp/~yamahata/xen-ia64/linux-2.6-xen-ia64.git/
>=20
>=20
> A paravirtualized guest wants to replace ia64 intrinsics, i.e.
> the operations defined in include/asm-ia64/gcc_instrin.h or
> include/asm-ia64/intel_instrin.h, with its own version.
> (At least xenLinux/ia64 does.)
> So we need a sort of interface to do so.
> I want to discuss on which direction to go for, please comment.
>=20
>=20
> This paravirtualization corresponds to the part of x86 pv_ops,
>   Performance critical code written in C. They are basically indirect
>   function call via pv_xxx_ops. For performance, each pv instance is
>   allowed to binary patch in order to replace function call
>   instruction with their predefined instructions in place.
>   The ia64 intrinsics corresonds to this kind of interface.
>=20
> The discussion points so far are
> - binary patching should be mandatory or optional?
>   The current patch requires binary patch, but some people think
>   requiring binary patch for pv instances is a bad idea.
>   I think by providing reasonable helper functions set, binary patch
>   won't be burden for pv instances.
>=20
> - How differ from x86 pv_ops?
>   Some people think that the very similarity to x86 pv_ops is
>   important. I guess they're thinking so considering maintenance
>   cost. Anyway ia64 is already different from x86, so such difference
>   doesn't matter as long as ia64 paravirtualization interface is
> clean enough for maintenance.=20
>=20
> Note: the way can differ from one operation from another, but it
> might cause some inconsistency.
> The following ways are proposed so far.
>=20
>=20
> * Option 1: the current way
> The code would look like
>         static inline unsigned long
>         paravirt_get_cpuid(int index)
>         {
>                 register __u64 ia64_intri_res asm ("r8");
>                 register __u64 __index asm ("r8") =3D index;
>                 asm volatile (paravirt_alt_inst("mov %0=3Dcpuid[%r1]",
>                                            PARAVIRT_INST_GET_CPUID):
>                               "=3Dr"(ia64_intri_res): "0O"(__index));
>                 return ia64_intri_res;
>         }
>         #define ia64_get_cpuid  paravirt_get_cpuid
>=20
>         note:
>         Using r8 is derived from xen hypercall abi.
>         We have to define which register should be used or can be
> clobbered.=20
>=20
>   Pros:
>   - in-place binary patch is possible.
>     (We may want to pad with nop. How many?)
>   - native case performance is good.
>   - native case doesn't need any modification.
>=20
>   Cons:
>   - binary patch is required for pv instances.
>   - Probably current implementation might be too xen-biased.
>     Reviewing them would be necessary for hypervisor neutrality.
>=20
> * Option 2: direct branch
> The code would look like
>         static inline unsigned long
>         paravirt_get_cpuid(int index)
>         {
>                register __u64 ia64_intri_res asm ("r8");
>                register __u64 __index asm ("r8") =3D index;
>                register __u64 ret_addr asm ("r9");
>                asm volatile (paravirt_alt_inst(
>                         "br.cond b0=3Dnative_get_cpuid",
>                         /* or brl.cond for fast hypercall */
>                          PARAVIRT_INST_GET_CPUID):
>                              "=3Dr"(ia64_intri_res), "=3Dr"(ret_addr):
>                              "0O"(__index)"
>                              "b0");
>                return ia64_intri_res;
>         }
>         #define ia64_get_cpuid  paravirt_get_cpuid
>=20
>         note:
>         Using r8 is derived from xen hypercall abi.
>         We have to define which register should be used or can be
> clobbered.=20
>=20
>   Pros:
>   - in-place binary patch is possible.
>     (We may want to pad with nop. How many?)
>   - so that performance would be good for native case using it.
>=20
>   Cons:
>   - binary patch is required for pv instances.
>   - native case needs binary patch for optimal performance.
>=20
> * Option 3: indirect branch
> The code would look like
>         static inline unsigned long
>         paravirt_get_cpuid(int index)
>         {
>                register __u64 ia64_intri_res asm ("r8");
>                register __u64 __index asm ("r8") =3D index;
>                register __u64 func asm ("r9");
>                asm volatile (paravirt_alt_inst(
>                         "mov %1 =3D pv_cpu_ops"
>                         "add %1 =3D %1, PV_CPU_GET_CPUID_OFFSET"
>                         "ld8 %1 =3D [%1]"
>                         "mov b1 =3D %1"
>                         "br.cond b0=B1"
>                          PARAVIRT_INST_GET_CPUID):
>                              "=3Dr"(ia64_intri_res),
>                              "=3Dr"(func):
>                              "0O"(__index):
>                              "b0", "b1");
>                return ia64_intri_res;
>         }
>         #define ia64_get_cpuid  paravirt_get_cpuid
>=20
>         note:
>         Using r8 is derived from xen hypercall abi.
>         We have to define which register should be used or can be
> clobbered.=20
>=20
>   Pros:
>   - binary patching isn't required for pv instances.
>   - in-place binary patch is possible
>     (We may want to pad with nop. How many?)
>   - so that performance would be good for native case using it.
>=20
>   Cons:
>   - use more spaces than the option #2.
>   - For optimal performance binary patch is necessary anyway.
>=20
> * Option 4: indirect function call
> The code would look like
>         struct pv_cpu_ops {
>                 unsigned long (*get_cpuid)(unsigned long index)
>                 ....
>         };
>         extern struct pv_cpu_ops pv_cpu_ops;
>         ...
>         static inline unsigned long
>         paravirt_get_cpuid(unsigned long index)
>         {
>                 return pv_cpu_ops->get_cpuid(index);
>         }
>         #define ia64_get_cpuid  paravirt_get_cpuid
>=20
>   Pros:
>   - Binary patch isn't required.
>   - indirect function call is the very way x86 pv_ops adopted.
>   - If hypervisor supports fast hypercall using gate page,
>     it may want to use function call.
>=20
>   Cons:
>   - Binary patch is difficult.
>     ia64 function call uses stacked registers, so that marking br.call
>     instruction is difficult.
>   - so that the performance is suboptimal especially for native case.
>=20

I am not sure if this statement is true. We can still patching it. For
example
using same inline asm code for paravirt_get_cpuid definition and it
could be
exactly same with X86.

>   Possibly the alternative is direct function call. At boot time,
>   scan all text detecting branch instructions which jumps to given
>   functions and binary patch branch target.
>=20
>=20
> My current preference is option #1 or #2 making abi more hypervisor
> neutral.=20
>=20
> thanks,

