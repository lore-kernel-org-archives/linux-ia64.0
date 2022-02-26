From: Kees Cook <keescook@chromium.org>
Date: Sat, 26 Feb 2022 11:52:27 +0000
Subject: Re: regression: Bug 215601 - gcc segv at startup on ia64
Message-Id: <202202260344.63C15C3356@keescook>
List-Id: <linux-ia64.vger.kernel.org>
References: <a3edd529-c42d-3b09-135c-7e98a15b150f@leemhuis.info>
 <823f70be-7661-0195-7c97-65673dc7c12a@leemhuis.info>
 <03497313-A472-4152-BD28-41C35E4E824E@chromium.org>
 <94c3be49-0262-c613-e5f5-49b536985dde@physik.fu-berlin.de>
 <9A1F30F8-3DE2-4075-B103-81D891773246@chromium.org>
 <4e42e754-d87e-5f6b-90db-39b4700ee0f1@physik.fu-berlin.de>
 <202202232030.B408F0E895@keescook>
 <7e3a93e7-1300-8460-30fb-789180a745eb@physik.fu-berlin.de>
 <65ed8ab4fad779fadf572fb737dfb789@matoro.tk>
In-Reply-To: <65ed8ab4fad779fadf572fb737dfb789@matoro.tk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: matoro <matoro_mailinglist_kernel@matoro.tk>
Cc: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Thorsten Leemhuis <regressions@leemhuis.info>, Anthony Yznaga <anthony.yznaga@oracle.com>, matoro_bugzilla_kernel@matoro.tk, Andrew Morton <akpm@linux-foundation.org>, regressions@lists.linux.dev, linux-ia64@vger.kernel.org, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>

On Thu, Feb 24, 2022 at 09:22:04AM -0500, matoro wrote:
> Hi Kees, I can provide live ssh access to my system exhibiting the issue.
> My system is a lot more stable due to using openrc rather than systemd, for
> me GCC seems to be the only binary affected.  Would that be helpful?

Thanks for this access! I think I see the problem. Non-PIE (i.e. normal
ET_EXEC) ia64 binaries appear to have two very non-contiguous virtual
memory PT_LOAD segments that are file-offset adjacent. As seen in
readelf -lW:

  LOAD           0x000000 0x4000000000000000 0x4000000000000000 0x00b5a0 0x00b5a0 R E 0x10000
  LOAD           0x00b5a0 0x600000000000b5a0 0x600000000000b5a0 0x0005ac 0x000710 RW  0x10000
                 ^^^^^^^^ ^^^^^^^^^^^^^^^^^^

When the kernel tries to map these with a combined allocation, it asks
for a giant mmap of the file, but the file is, of course, not at all
that large, and the mapping is rejected.

So... I'm trying to think about how best to deal with this. If I or
anyone else can't think of an elegant solution, I'll send a revert for
the offending patch next week.

In the meantime now I've got another dimension to regression test. ;)

-- 
Kees Cook
