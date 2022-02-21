From: Kees Cook <keescook@chromium.org>
Date: Mon, 21 Feb 2022 07:42:13 +0000
Subject: Re: regression: Bug 215601 - gcc segv at startup on ia64
Message-Id: <03497313-A472-4152-BD28-41C35E4E824E@chromium.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <a3edd529-c42d-3b09-135c-7e98a15b150f@leemhuis.info> <823f70be-7661-0195-7c97-65673dc7c12a@leemhuis.info>
In-Reply-To: <823f70be-7661-0195-7c97-65673dc7c12a@leemhuis.info>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thorsten Leemhuis <regressions@leemhuis.info>, Anthony Yznaga <anthony.yznaga@oracle.com>
Cc: matoro_bugzilla_kernel@matoro.tk, Andrew Morton <akpm@linux-foundation.org>, "regressions@lists.linux.dev" <regressions@lists.linux.dev>, linux-ia64@vger.kernel.org, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>



On February 20, 2022 9:19:46 AM PST, Thorsten Leemhuis <regressions@leemhuis.info> wrote:
>[reply to get Anthony on board, I screwed up when copy and pasting his
>email address when sending below mail; sorry for the noise!]
>
>On 20.02.22 18:12, Thorsten Leemhuis wrote:
>> Hi, this is your Linux kernel regression tracker.
>> 
>> I noticed a regression report in bugzilla.kernel.org that afaics nobody
>> acted upon since it was reported about a week ago, that's why I'm hereby
>> forwarding it to the lists and the relevant people. To quote
>> https://bugzilla.kernel.org/show_bug.cgi?id=215601 :
>> 
>>> On ia64, after 5f501d555653f8968011a1e65ebb121c8b43c144, the gcc
>>> binary crashes with SIGSEGV at startup (i.e., during ELF loading).
>>> Only gcc exhibits the crash (including g++, etc), other toolchain
>>> components (such as ld, ldd, etc) do not, and neither does any other
>>> binary from what I can tell.  I also haven't observed the issue on
>>> any other architecture.
>>>
>>> Reverting this commit resolves the issue up to and including git tip,
>>> with no (visible) issues.
>>>
>>> Hardware:  HP Integrity rx2800 i2 Kernel config attached.
>> 
>> Could somebody take a look into this? Or was this discussed somewhere
>> else already? Or even fixed?
>> 
>> Anyway, to get this tracked:
>> 
>> #regzbot introduced: 5f501d555653f8968011a1e65ebb121c8b43c144
>> #regzbot from: matoro <matoro_bugzilla_kernel@matoro.tk>
>> #regzbot title: gcc segv at startup on ia64
>> #regzbot link: https://bugzilla.kernel.org/show_bug.cgi?id=215601

Does this fix it?

https://www.ozlabs.org/~akpm/mmotm/broken-out/elf-fix-overflow-in-total-mapping-size-calculation.patch

-Kees


>> 
>> Ciao, Thorsten (wearing his 'the Linux kernel's regression tracker' hat)
>> 
>> P.S.: As the Linux kernel's regression tracker I'm getting a lot of
>> reports on my table. I can only look briefly into most of them and lack
>> knowledge about most of the areas they concern. I thus unfortunately
>> will sometimes get things wrong or miss something important. I hope
>> that's not the case here; if you think it is, don't hesitate to tell me
>> in a public reply, it's in everyone's interest to set the public record
>> straight.
>> 

-- 
Kees Cook
