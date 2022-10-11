From: Yujie Liu <yujie.liu@intel.com>
Date: Tue, 11 Oct 2022 09:36:11 +0000
Subject: Re: [kbuild] b3830bad81: System_halted
Message-Id: <f09f2fb1-ae86-5419-4361-bdd8f8a22e11@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220928063947.299333-3-masahiroy@kernel.org>
 <202210090942.a159fe4-yujie.liu@intel.com>
 <CAK7LNASUhDMo72eNge_GvdfbmOkpBCJA88Xw=_V69jcf+_072Q@mail.gmail.com>
In-Reply-To: <CAK7LNASUhDMo72eNge_GvdfbmOkpBCJA88Xw=_V69jcf+_072Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <masahiroy@kernel.org>
Cc: lkp@lists.01.org, lkp@intel.com, linux-kbuild@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Ard Biesheuvel <ardb@kernel.org>, Nicolas Pitre <npitre@baylibre.com>, Michal Marek <michal.lkml@markovi.net>, Nick Desaulniers <ndesaulniers@google.com>

On 10/11/2022 03:29, Masahiro Yamada wrote:
> On Sun, Oct 9, 2022 at 10:21 AM kernel test robot <yujie.liu@intel.com> wrote:
>>
>> Greeting,
>>
>> FYI, we noticed the following commit (built with gcc-11):
>>
>> commit: b3830bad81e872632431363853c810c5f652a040 ("[PATCH v3 2/8] kbuild: rebuild .vmlinux.export.o when its prerequisite is updated")
>> url: https://github.com/intel-lab-lkp/linux/commits/Masahiro-Yamada/Unify-linux-export-h-and-asm-export-h-remove-EXPORT_DATA_SYMBOL-faster-TRIM_UNUSED_KSYMS/20220928-144539
>> base: https://git.kernel.org/cgit/linux/kernel/git/masahiroy/linux-kbuild.git for-next
>> patch link: https://lore.kernel.org/linux-kbuild/20220928063947.299333-3-masahiroy@kernel.org
>>
>> in testcase: boot
>>
>> on test machine: qemu-system-x86_64 -enable-kvm -cpu SandyBridge -smp 2 -m 16G
>>
>> caused below changes (please refer to attached dmesg/kmsg for entire log/backtrace):
> 
> 
> I think this is a false-positive alarm.
> 
> As I replied before [1], I know my patch set is broken.
> I think 0day bot is testing the patch set I had already retracted.
> 
> I only picked up low-hanging fruits with fixes to my tree,
> and did boot tests.
> 
> Please let me know if linux-next is broken.
> 
> 
> [1] : https://lore.kernel.org/linux-kbuild/CAK7LNATcD6k+R66YFVg_mhe7-FGNc0nYaTPuORCcd34Qw3ra2g@mail.gmail.com/T/#t
> 

Sorry for this false-positive report.

Thanks for the info, we noticed that this patch has been merged into
linux-next, so we tested below commits:

b9f85101cad33 (tag: next-20221011, linux-next/master) Add linux-next specific files for 20221011
5d4aeffbf7092 kbuild: rebuild .vmlinux.export.o when its prerequisite is updated

They all passed the boot tests.

--
Best Regards,
Yujie
