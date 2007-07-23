From: Jes Sorensen <jes@sgi.com>
Date: Mon, 23 Jul 2007 16:32:22 +0000
Subject: Re: Linus' tree broken?
Message-Id: <yq0ejizgjxl.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <46A4B026.9030307@sgi.com>
In-Reply-To: <46A4B026.9030307@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:

>> Have anyone else had seen issues with the Linus git tree failing to
>> boot? I'm trying a pull as of this morning and it seems to hang
>> when it's brining up the ethernet devices.
>> 
>> It's not locking up, just the boot scripts never continues -
>> happens both on SLES10 and FC7 roots :(
>> 
>> Just wanted to check before spending real time on it.

Tony> Pulled Linus' tree (the -rc1 commit is at the head) and it built
Tony> and booted on my tiger.  Only new strange stuff in the dmesg is
Tony> a lot of

Strange!

I heard from John Keller that he had problems too. What kind of
userland are you running? I've seen hanging around udev.

Cheers,
Jes
