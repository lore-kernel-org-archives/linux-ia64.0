From: "Luming Yu" <luming.yu@gmail.com>
Date: Tue, 03 Jun 2008 06:04:39 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a race
Message-Id: <3877989d0806022304w35764b17p9d4c3c95eceae0f5@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	 <20080523041940.39E8726FA24@magilla.localdomain>
	 <3877989d0805222224n77ce36b6wdf15c4bab330a0f8@mail.gmail.com>
	 <20080526001527.81E1126FA9E@magilla.localdomain>
	 <3877989d0805251830w70f19e4cu46fbc32148217749@mail.gmail.com>
	 <3877989d0805262031i29db16bcjfa31652afc746b49@mail.gmail.com>
	 <20080527040454.053C526FA9E@magilla.localdomain>
	 <3877989d0805262249yab130cbyfc5f5e54065cec5c@mail.gmail.com>
	 <20080527061209.9A24426FAA6@magilla.localdomain>
	 <1211869515.29836.2.camel@elijah.suse.cz>
In-Reply-To: <1211869515.29836.2.camel@elijah.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Petr Tesarik <ptesarik@suse.cz>
Cc: Roland McGrath <roland@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Tue, May 27, 2008 at 2:25 PM, Petr Tesarik <ptesarik@suse.cz> wrote:
> On Mon, 2008-05-26 at 23:12 -0700, Roland McGrath wrote:
>> >  [<a00000010000a9f0>] skip_rbs_switch+0xe0/0x110
>> >                                 sp=E000000141c9fe30 bsp=E000000141c90c=
f8
>> >  [<a000000000010740>] __kernel_syscall_via_break+0x0/0x20
>> >                                 sp=E000000141ca0000 bsp=E000000141c90c=
f8
>
> Indeed, there seems to be a large hole here. So, this is either a bug in
> the unwinder, or a bug in the RBS synchronization, which causes
> corruption. My test machine currently needs some work to run 2.6.25
> again, but I'll try your test case as soon as I re-install it later this
> week.

Just want to check if the test case works for you?
