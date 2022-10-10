From: Masahiro Yamada <masahiroy@kernel.org>
Date: Mon, 10 Oct 2022 19:29:36 +0000
Subject: Re: [kbuild] b3830bad81: System_halted
Message-Id: <CAK7LNASUhDMo72eNge_GvdfbmOkpBCJA88Xw=_V69jcf+_072Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220928063947.299333-3-masahiroy@kernel.org> <202210090942.a159fe4-yujie.liu@intel.com>
In-Reply-To: <202210090942.a159fe4-yujie.liu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel test robot <yujie.liu@intel.com>
Cc: lkp@lists.01.org, lkp@intel.com, linux-kbuild@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Ard Biesheuvel <ardb@kernel.org>, Nicolas Pitre <npitre@baylibre.com>, Michal Marek <michal.lkml@markovi.net>, Nick Desaulniers <ndesaulniers@google.com>

On Sun, Oct 9, 2022 at 10:21 AM kernel test robot <yujie.liu@intel.com> wrote:
>
> Greeting,
>
> FYI, we noticed the following commit (built with gcc-11):
>
> commit: b3830bad81e872632431363853c810c5f652a040 ("[PATCH v3 2/8] kbuild: rebuild .vmlinux.export.o when its prerequisite is updated")
> url: https://github.com/intel-lab-lkp/linux/commits/Masahiro-Yamada/Unify-linux-export-h-and-asm-export-h-remove-EXPORT_DATA_SYMBOL-faster-TRIM_UNUSED_KSYMS/20220928-144539
> base: https://git.kernel.org/cgit/linux/kernel/git/masahiroy/linux-kbuild.git for-next
> patch link: https://lore.kernel.org/linux-kbuild/20220928063947.299333-3-masahiroy@kernel.org
>
> in testcase: boot
>
> on test machine: qemu-system-x86_64 -enable-kvm -cpu SandyBridge -smp 2 -m 16G
>
> caused below changes (please refer to attached dmesg/kmsg for entire log/backtrace):


I think this is a false-positive alarm.

As I replied before [1], I know my patch set is broken.
I think 0day bot is testing the patch set I had already retracted.

I only picked up low-hanging fruits with fixes to my tree,
and did boot tests.

Please let me know if linux-next is broken.


[1] : https://lore.kernel.org/linux-kbuild/CAK7LNATcD6k+R66YFVg_mhe7-FGNc0nYaTPuORCcd34Qw3ra2g@mail.gmail.com/T/#t










>
> early console in setup code
> Probing EDD (edd=off to disable)... ok
> No EFI environment detected.
> early console in extract_kernel
> input_data: 0x0000000002e5740d
> input_len: 0x000000000099c37e
> output: 0x0000000001000000
> output_len: 0x000000000234aa00
> kernel_total_size: 0x0000000002828000
> needed_size: 0x0000000002a00000
> trampoline_32bit: 0x000000000009d000
>
> Decompressing Linux... Parsing ELF...
>
> Alignment of LOAD segment isn't multiple of 2MB
>
>  -- System haltedBUG: kernel hang in boot stage
>
>
>
> 61682ee38a ("kbuild: move modules.builtin(.modinfo) rules to Makefile.vmlinux_o")
> b3830bad81 ("kbuild: rebuild .vmlinux.export.o when its prerequisite is updated")
>
> +----------------+------------+------------+
> |                | 61682ee38a | b3830bad81 |
> +----------------+------------+------------+
> | boot_successes | 24         | 0          |
> | boot_failures  | 0          | 18         |
> | System_halted  | 0          | 18         |
> +----------------+------------+------------+
>
>
> If you fix the issue, kindly add following tag
> | Reported-by: kernel test robot <yujie.liu@intel.com>
> | Link: https://lore.kernel.org/r/202210090942.a159fe4-yujie.liu@intel.com
>
>
> To reproduce:
>
>         # build kernel
>         cd linux
>         cp config-6.0.0-rc7-00038-gb3830bad81e8 .config
>         make HOSTCC=gcc-11 CC=gcc-11 ARCH=x86_64 olddefconfig prepare modules_prepare bzImage modules
>         make HOSTCC=gcc-11 CC=gcc-11 ARCH=x86_64 INSTALL_MOD_PATH=<mod-install-dir> modules_install
>         cd <mod-install-dir>
>         find lib/ | cpio -o -H newc --quiet | gzip > modules.cgz
>
>
>         git clone https://github.com/intel/lkp-tests.git
>         cd lkp-tests
>         bin/lkp qemu -k <bzImage> -m modules.cgz job-script # job-script is attached in this email
>
>         # if come across any failure that blocks the test,
>         # please remove ~/.lkp and /lkp dir to run from a clean state.
>
>
> --
> 0-DAY CI Kernel Test Service
> https://01.org/lkp



-- 
Best Regards
Masahiro Yamada
