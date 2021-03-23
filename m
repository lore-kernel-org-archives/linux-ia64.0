From: Frank Scheiner <frank.scheiner@web.de>
Date: Tue, 23 Mar 2021 15:14:14 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <52397fc7-a701-7bcf-ea74-1fd2875a62ac@web.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Adrian,

On 23.03.21 16:02, John Paul Adrian Glaubitz wrote:
> Hi!
>
> On 6/25/19 8:40 AM, John Paul Adrian Glaubitz wrote:
>> On 6/21/19 10:08 PM, Frank Scheiner wrote:
>>> recent testing of a Debian v4.19.37 kernel showed a problem on my rx2800
>>> i2 happening during kernel boot:
>>> (...)
>>> [1]:
>>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/?id=543cea9accd9804307541cb93d3ed7ec94b07237
>>
>> Do you have any idea what could be the reason for the issue introduced
>> by your above commit? James Clarke has guess that it might be GFP_DMA32
>> which isn't being set properly anymore for the affected machines.
>>
>> Do you think we could test a kernel which just sets the flag unconditionally
>> to see whether this is the problem that causes the issues on these machines?
>
> Just as a heads-up: This issue has magically fixed itself and a current kernel
> with some additional minor fixes applied boots fine on these machines again [1].

Thanks for he pointer, I already noticed your email to the debian-ia64
list some minutes ago. That's great news! :-)

If time allows today I might give it a try in my rx2800 i2, which ATM
just sits a meter away from me, but I'm still testing kernels on one of
my V245 machines.

Cheers,
Frank
