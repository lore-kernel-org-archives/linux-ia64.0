From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 16 Aug 2000 16:06:39 +0000
Subject: Re: [Linux-ia64] [PATCH] fix for modules_install
Message-Id: <marc-linux-ia64-105590678205338@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205329@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205329@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 15 Aug 2000 20:20:04 -0700, 
Uros Prestor <uros@turbolinux.com> wrote:
>Keith Owens wrote:
>
>> On Tue, 15 Aug 2000 16:43:39 -0700,
>> Uros Prestor <uros@turbolinux.com> wrote:
>> >This trivial patch against 2.4.0-test6 + 000812 fixes a problem with
>> >modules_install target.
>> >
>> >-.PHONY: all modules
>> >+.PHONY: all modules modules_install
>>
>> What problem does it fix?
>
>File arch/ia64/tools/Makefile didn't have a target modules_install so
>`make modules_install' returned an error.  This patch adds a phony
>target which does nothing.

arch/ia64/tools/Makefile should include Rules.make instead of adding
its own target and .PHONY rules.  see arch/mips/tools/Makefile.  AFAICT
there is no reason not to include Rules.make.


