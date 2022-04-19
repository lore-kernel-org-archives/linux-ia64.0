From: Wupeng Ma <mawupeng1@huawei.com>
Date: Tue, 19 Apr 2022 06:42:49 +0000
Subject: [PATCH 0/2] Add support to relocate kernel image to mirrored region
Message-Id: <20220419070150.254377-1-mawupeng1@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAMj1kXGSStDgj9ABmUaTLnBmpQFksh3wx4tx=mJohum4GQe3Gg@mail.gmail.com>
In-Reply-To: <CAMj1kXGSStDgj9ABmUaTLnBmpQFksh3wx4tx=mJohum4GQe3Gg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, catalin.marinas@arm.com, will@kernel.org, corbet@lwn.net
Cc: ardb@kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, dvhart@infradead.org, andy@infradead.org, rppt@kernel.org, paulmck@kernel.org, peterz@infradead.org, jroedel@suse.de, songmuchun@bytedance.com, macro@orcam.me.uk, frederic@kernel.org, W_Armin@gmx.de, john.garry@huawei.com, seanjc@google.com, tsbogend@alpha.franken.de, anshuman.khandual@arm.com, chenhuacai@kernel.org, david@redhat.com, gpiccoli@igalia.com, mark.rutland@arm.com, wangkefeng.wang@huawei.com, mawupeng1@huawei.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org

From: Ma Wupeng <mawupeng1@huawei.com>

Now system image will perfer to be located to mirrored regions both KASLR
on and off.

Ma Wupeng (2):
  arm64/boot/KASLR: Add support to relocate kernel image to mirrored
    region
  arm64/boot: Add support to relocate kernel image to mirrored region
    without kaslr

 drivers/firmware/efi/libstub/arm64-stub.c  | 62 +++++++++++++++++++++-
 drivers/firmware/efi/libstub/efistub.h     |  7 ++-
 drivers/firmware/efi/libstub/randomalloc.c | 14 ++++-
 3 files changed, 79 insertions(+), 4 deletions(-)

-- 
2.25.1
