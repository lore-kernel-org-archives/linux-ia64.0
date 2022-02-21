From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Mon, 21 Feb 2022 21:57:01 +0000
Subject: Re: regression: Bug 215601 - gcc segv at startup on ia64
Message-Id: <4e42e754-d87e-5f6b-90db-39b4700ee0f1@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <a3edd529-c42d-3b09-135c-7e98a15b150f@leemhuis.info>
 <823f70be-7661-0195-7c97-65673dc7c12a@leemhuis.info>
 <03497313-A472-4152-BD28-41C35E4E824E@chromium.org>
 <94c3be49-0262-c613-e5f5-49b536985dde@physik.fu-berlin.de>
 <9A1F30F8-3DE2-4075-B103-81D891773246@chromium.org>
In-Reply-To: <9A1F30F8-3DE2-4075-B103-81D891773246@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>, Thorsten Leemhuis <regressions@leemhuis.info>, Anthony Yznaga <anthony.yznaga@oracle.com>
Cc: matoro_bugzilla_kernel@matoro.tk, Andrew Morton <akpm@linux-foundation.org>, "regressions@lists.linux.dev" <regressions@lists.linux.dev>, linux-ia64@vger.kernel.org, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>

Hi Kees!

On 2/21/22 21:58, Kees Cook wrote:
>> I have applied this patch on top of 038101e6b2cd5c55f888f85db42ea2ad3aecb4b6 and it doesn't
>> fix the problem for me. Reverting 5f501d555653f8968011a1e65ebb121c8b43c144, however, fixes
>> the problem.
>>
>> FWIW, this problem doesn't just affect GCC but systemd keeps segfaulting with this change as well.
> 
> Very weird! Can you attached either of those binaries to bugzilla (or a URL I can fetch it from)? I can try to figure out where it is going weird...

Here's the initrd of that particular machine:

> https://people.debian.org/~glaubitz/initrd.img-5.17.0-rc5+

You should be able to extract the binaries from this initrd image and the "mount" command,
for example, should be one of the affected binaries.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
