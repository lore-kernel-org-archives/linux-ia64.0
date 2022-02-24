From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Thu, 24 Feb 2022 09:33:20 +0000
Subject: Re: regression: Bug 215601 - gcc segv at startup on ia64
Message-Id: <7e3a93e7-1300-8460-30fb-789180a745eb@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <a3edd529-c42d-3b09-135c-7e98a15b150f@leemhuis.info>
 <823f70be-7661-0195-7c97-65673dc7c12a@leemhuis.info>
 <03497313-A472-4152-BD28-41C35E4E824E@chromium.org>
 <94c3be49-0262-c613-e5f5-49b536985dde@physik.fu-berlin.de>
 <9A1F30F8-3DE2-4075-B103-81D891773246@chromium.org>
 <4e42e754-d87e-5f6b-90db-39b4700ee0f1@physik.fu-berlin.de>
 <202202232030.B408F0E895@keescook>
In-Reply-To: <202202232030.B408F0E895@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: Thorsten Leemhuis <regressions@leemhuis.info>, Anthony Yznaga <anthony.yznaga@oracle.com>, matoro_bugzilla_kernel@matoro.tk, Andrew Morton <akpm@linux-foundation.org>, "regressions@lists.linux.dev" <regressions@lists.linux.dev>, linux-ia64@vger.kernel.org, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>

Hi Kees!

On 2/24/22 06:16, Kees Cook wrote:
>> You should be able to extract the binaries from this initrd image and the "mount" command,
>> for example, should be one of the affected binaries.
> 
> In dmesg, do you see any of these reports?
> 
>                 pr_info("%d (%s): Uhuuh, elf segment at %px requested but the memory is mapped already\n",
>                         task_pid_nr(current), current->comm, (void *)addr);

I'll check that.

> I don't see anything out of order in the "mount" binary from the above
> initrd. What does "readelf -lW" show for the GCC you're seeing failures
> on?

I'm not 100% sure whether it's the mount binary that is affected. What happens is that once init takes over,
I'm seeing multiple "Segmentation Fault" message on the console until I'm dropped to the initrd shell.

I can check what dmesg says.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
