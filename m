From: Jes Sorensen <jes@sgi.com>
Date: Fri, 26 May 2006 07:11:03 +0000
Subject: Re: dropping CONFIG_IA32_SUPPORT from ia64
Message-Id: <yq0d5e1w9a0.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200605241438.34303.bjorn.helgaas@hp.com>
In-Reply-To: <200605241438.34303.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:

Tony> Cc: list pruned to stop annoying the innocent bystanders ...
>> Or maybe the people using ia32 compatibility are just running big
>> apps like Firefox or Open Office that are non-trivial to build for
>> ia64, but may not care as much about shiny new syscalls.

Tony> Firefox has been ported ... it came as a native ia64 binary rpm
Tony> on the last OSD install disk that I put on my workstation.
Tony> Dunno about Open office though.

Yup, Firefox runs nicely, now we just need gnash to get there so it
can display some of those %#@%#$$@# sites that insist on using flash.

I took a look at trying to build Open Office about two month ago. All
I can say is YUCK! The build system is disgusting and the arch
specific bits are a nightmare to try and mess with - after wasting a
day on it I concluded that it wasn't worth waking up in the middle of
the night shaking and all soaked in sweat over it. Back to using
ia32el for it, which unfortunately makes an already utterly slow
application seem like it's running on my old C64.

Anyone who manages to get Open Office building natively is very brave
:)

Cheers,
Jes
