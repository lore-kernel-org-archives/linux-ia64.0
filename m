From: Jens Axboe <axboe@kernel.dk>
Date: Tue, 17 Nov 2020 15:06:30 +0000
Subject: Re: [PATCH] sh: add support for TIF_NOTIFY_SIGNAL
Message-Id: <1047f3e5-4599-c34f-3176-9f41d2e1246b@kernel.dk>
List-Id: <linux-ia64.vger.kernel.org>
References: <5fcc82b4-89ae-3bca-10ab-6ad933565cee@kernel.dk>
In-Reply-To: <5fcc82b4-89ae-3bca-10ab-6ad933565cee@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-sh@vger.kernel.org

On 11/16/20 10:26 PM, John Paul Adrian Glaubitz wrote:
> Hi Jens!
> 
> On 11/9/20 3:14 PM, Jens Axboe wrote:
>>> Sorry for the delay. I'm busy at the moment and my SH board is currently
>>> building the Perl 5.32 package for Debian. Will try to test your patches
>>> by tomorrow, also ia64.
>>
>> Thanks, both would be appreciated! Just CC'ed you on the updated patch
>> for sh.
> 
> Is this still relevant for testing? I'm ready to test now, much later than
> I thought, sorry.
> 
> I'm going to build Linus' latest kernel for my SH and IA64 machines now
> and then I can test additional patches on top of it.

Thanks, would definitely still appreciate testing. You can just run
linux-next if you want, it's got everything in there. Or apply the
separate patches to -git, either approach is fine.

-- 
Jens Axboe
