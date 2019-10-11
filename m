From: hpa@zytor.com
Date: Fri, 11 Oct 2019 01:38:03 +0000
Subject: Re: [PATCH 00/29] vmlinux.lds.h: Refactor EXCEPTION_TABLE and NOTES
Message-Id: <A020A6D1-C7DB-480B-826E-AE18308CD3E5@zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190926175602.33098-1-keescook@chromium.org> <20191010180331.GI7658@zn.tnic> <201910101657.234CB71E53@keescook>
In-Reply-To: <201910101657.234CB71E53@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>, Borislav Petkov <bp@alien8.de>
Cc: Thomas Gleixner <tglx@linutronix.de>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michal Simek <monstr@monstr.eu>, linux-parisc@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, linux-kernel@vger.kernel.org

On October 10, 2019 4:57:36 PM PDT, Kees Cook <keescook@chromium.org> wrote:
>On Thu, Oct 10, 2019 at 08:03:31PM +0200, Borislav Petkov wrote:
>> On Thu, Sep 26, 2019 at 10:55:33AM -0700, Kees Cook wrote:
>> > This series works to move the linker sections for NOTES and
>> > EXCEPTION_TABLE into the RO_DATA area, where they belong on most
>> > (all?) architectures. The problem being addressed was the discovery
>> > by Rick Edgecombe that the exception table was accidentally marked
>> > executable while he was developing his execute-only-memory series.
>When
>> > permissions were flipped from readable-and-executable to
>only-executable,
>> > the exception table became unreadable, causing things to explode
>rather
>> > badly. :)
>> > 
>> > Roughly speaking, the steps are:
>> > 
>> > - regularize the linker names for PT_NOTE and PT_LOAD program
>headers
>> >   (to "note" and "text" respectively)
>> > - regularize restoration of linker section to program header
>assignment
>> >   (when PT_NOTE exists)
>> > - move NOTES into RO_DATA
>> > - finish macro naming conversions for RO_DATA and RW_DATA
>> > - move EXCEPTION_TABLE into RO_DATA on architectures where this is
>clear
>> > - clean up some x86-specific reporting of kernel memory resources
>> > - switch x86 linker fill byte from x90 (NOP) to 0xcc (INT3), just
>because
>> >   I finally realized what that trailing ": 0x9090" meant -- and we
>should
>> >   trap, not slide, if execution lands in section padding
>> 
>> Yap, nice patchset overall.
>
>Thanks!
>
>> > Since these changes are treewide, I'd love to get
>architecture-maintainer
>> > Acks and either have this live in x86 -tip or in my own tree,
>however
>> > people think it should go.
>> 
>> Sure, I don't mind taking v2 through tip once I get ACKs from the
>> respective arch maintainers.
>
>Okay, excellent. I've only had acks from arm64, but I'll call it out
>again in v2. Thanks for the review!

I would like to once again advocate for the generalized link table mechanism. It is nuts that each individual table should need vmlinux.lds hacking across architectures.
-- 
Sent from my Android device with K-9 Mail. Please excuse my brevity.
