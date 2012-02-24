From: Jiri Slaby <jslaby@suse.cz>
Date: Fri, 24 Feb 2012 22:44:37 +0000
Subject: Re: [PATCH 1/4] IA64: hpsim, fix SAL handling in fw-emu
Message-Id: <4F4812D5.7060606@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1330081818-15517-1-git-send-email-jslaby@suse.cz> <CA+8MBbKtQZkp0RzsP366PgzdN2jvX73njFr1avSoE_CFDv=jNg@mail.gmail.com>
In-Reply-To: <CA+8MBbKtQZkp0RzsP366PgzdN2jvX73njFr1avSoE_CFDv=jNg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Jiri Slaby <jirislaby@gmail.com>, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On 02/24/2012 11:32 PM, Tony Luck wrote:
> Are these four patches the only things needed to get the kernel
> running on the simulator?  I've been building sim_defconfig as
> part of my regular "did things break" cycle. But I haven't tried to
> boot in well over five years.

Yes, it works fine for me. I'm using busybox as userspace. From SLES 11
SP2. I was using it to test tty patches applied to simserial.

My .config differs from sim_defconfig though. I didn't know there is a
defconfig for HP simulator. So I configured the kernel from scratch with
help of menuconfig.

thanks,
-- 
js
suse labs
