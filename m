From: Kees Cook <keescook@chromium.org>
Date: Mon, 21 Feb 2022 20:58:22 +0000
Subject: Re: regression: Bug 215601 - gcc segv at startup on ia64
Message-Id: <9A1F30F8-3DE2-4075-B103-81D891773246@chromium.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <a3edd529-c42d-3b09-135c-7e98a15b150f@leemhuis.info> <823f70be-7661-0195-7c97-65673dc7c12a@leemhuis.info> <03497313-A472-4152-BD28-41C35E4E824E@chromium.org> <94c3be49-0262-c613-e5f5-49b536985dde@physik.fu-berlin.de>
In-Reply-To: <94c3be49-0262-c613-e5f5-49b536985dde@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Thorsten Leemhuis <regressions@leemhuis.info>, Anthony Yznaga <anthony.yznaga@oracle.com>
Cc: matoro_bugzilla_kernel@matoro.tk, Andrew Morton <akpm@linux-foundation.org>, "regressions@lists.linux.dev" <regressions@lists.linux.dev>, linux-ia64@vger.kernel.org, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>



On February 21, 2022 11:49:20 AM PST, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de> wrote:
>Hi Kees!
>
>On 2/21/22 08:42, Kees Cook wrote:
>>>>> Reverting this commit resolves the issue up to and including git tip,
>>>>> with no (visible) issues.
>>>>>
>>>>> Hardware:  HP Integrity rx2800 i2 Kernel config attached.
>>>>
>>>> Could somebody take a look into this? Or was this discussed somewhere
>>>> else already? Or even fixed?
>>>>
>>>> Anyway, to get this tracked:
>>>>
>>>> #regzbot introduced: 5f501d555653f8968011a1e65ebb121c8b43c144
>>>> #regzbot from: matoro <matoro_bugzilla_kernel@matoro.tk>
>>>> #regzbot title: gcc segv at startup on ia64
>>>> #regzbot link: https://bugzilla.kernel.org/show_bug.cgi?id=215601
>> 
>> Does this fix it?
>> 
>> https://www.ozlabs.org/~akpm/mmotm/broken-out/elf-fix-overflow-in-total-mapping-size-calculation.patch
>
>I have applied this patch on top of 038101e6b2cd5c55f888f85db42ea2ad3aecb4b6 and it doesn't
>fix the problem for me. Reverting 5f501d555653f8968011a1e65ebb121c8b43c144, however, fixes
>the problem.
>
>FWIW, this problem doesn't just affect GCC but systemd keeps segfaulting with this change as well.

Very weird! Can you attached either of those binaries to bugzilla (or a URL I can fetch it from)? I can try to figure out where it is going weird...

-- 
Kees Cook
