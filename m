From: "Luming Yu" <luming.yu@gmail.com>
Date: Fri, 13 Jun 2008 16:22:10 +0000
Subject: Re: kdump regression: /proc/vmcore is 0 after kdump
Message-Id: <3877989d0806130922p1f36a3bes9914144ac8c42266@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0806050058u3159e7b5x3113f63b3e0f3d8f@mail.gmail.com>
	<20080605081633.GA6713@verge.net.au>
In-Reply-To: <20080605081633.GA6713@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Petr Tesarik <ptesarik@suse.cz>, linux-ia64@vger.kernel.org, Kexec Mailing List <kexec@lists.infradead.org>, Roland McGrath <roland@redhat.com>

On Thu, Jun 5, 2008 at 4:16 PM, Simon Horman <horms@verge.net.au> wrote:
> On Thu, Jun 05, 2008 at 03:58:40PM +0800, Luming Yu wrote:
>> On Tue, Jun 3, 2008 at 2:02 PM, Luming Yu <luming.yu@gmail.com> wrote:
>> >> I'm trying upstream kdump to get more detailed data for help analysis
>> >> the scenario..
>> > Upstream kdump doesn't work! don't know what cause the regression,
>> > possibly kexec-tools...
>> > Need investigation here!
>> >
>>
>> I tested mainline kernel from 2.6.20 to 2.6.26-rc4 on my tiger4..
>> whatever I try, /proc/vmcore is always 0 !
>>
>> Then I managed to get Nan hai's original patch against 2.6.19..
>> http://marc.info/?l=linux-ia64&m6521104831321&w=2
>> This patch doesn't have zero-vmcore problem.
>>
>> Given the age of the kdump feature and so many upstream releases since
>> 2.6.20, I'm in doubt why I don't see this kind of bug report on ia64
>> mailing list before?
>>
>> PS. Now I can start to capture info for the strace problem with 2.6.19
>> kernel +Nahai's 2.6.19 kdump patch, hope the problem is still
>> reproducible.
>
> Which version of kexec-tools are you using?
> If you haven't done so already, could you try the latest version, 20080324.
>
> http://www.eu.kernel.org/pub/linux/kernel/people/horms/kexec-tools/
>

Yes, this resolves one of my kdump problem.
But there seems to have a regression introduced into upstream probably
starting from 2.6.25.
The last kernel with kdump working on this box is 2.6.24. I don't have
time to start bisection to find out which patch causes that regression
right now.Maybe someone on this list can give me some hint..
Thanks,
Luming
