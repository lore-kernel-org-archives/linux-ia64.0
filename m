From: Jay Lan <jlan@sgi.com>
Date: Wed, 31 Jan 2007 18:09:57 +0000
Subject: Re: [Fastboot] [PATCH] kexec: Avoid migration of already disabled
Message-Id: <45C0DB75.20709@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <45C005C1.5010606@sgi.com>
In-Reply-To: <45C005C1.5010606@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Magnus Damm wrote:
> Hi Nan hai,
> 
> On 1/31/07, Zou, Nanhai <nanhai.zou@intel.com> wrote:
>> > On 1/31/07, Jay Lan <jlan@sgi.com> wrote:
>> > > Magnus Damm wrote:
>> > > > kexec: Avoid migration of already disabled irqs (ia64)
>> > > >
>> > > > This patch fixes up ia64 kexec support for HP rx2620 hardware.
>> It does this
>> > > > by skipping migration of already disabled irqs. This is most
>> likely a problem
>> > > > on other ia64 platforms as well, but I've only tested this on
>> one machine
>> > > > so far.
>> > >
>> > > I have not seen this problem on SN systems.
>> >
>> > Ok, thanks. Let me give you more details.
>> >
>> > When I perform "kexec -e" the following output appears on my serial
>> > console (with my patch applied).
>>
>>  This patch is correct I think. I assume you will also see this bug
>> when trying to offline a CPU by echo 0 >
>> /sys/devices/system/cpu/cpuX/online
> 
> You are right, I can trigger the bug that way too.
> And the bug goes away with the patch. Excellent!

I tried on a 2p SN system with both '-l' followed by '-e' and also
Nan-hai's trigger command. Neither triggered the problem. But, on
the other hand, the system worked fine with your patch also. :)

Thanks,
 - jay

> 
>> However it will not be triggered in crash dump case which has been
>> tested heavily on different kind of platforms. We do not migrate IRQ
>> at the time of crash. I guess that is why Jay has never seen it on SN
>> platforms.
> 
> Booting into a crash kernel does not seem to work on this ia64 box
> unfortunately. I'm about to investigate why, but I thought trying and
> fixing kexec was a good first step.
> 
> Thanks for the help!
> 
> / magnus

