From: Guenter Roeck <linux@roeck-us.net>
Date: Thu, 16 Feb 2023 19:17:55 +0000
Subject: Re: [RFC PATCH 0/5] Retire IA64/Itanium support
Message-Id: <3f91da52-619a-89a2-da96-bf04e8ae3e48@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230215100008.2565237-1-ardb@kernel.org>
In-Reply-To: <20230215100008.2565237-1-ardb@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 2/16/23 10:32, Ard Biesheuvel wrote:
> On Thu, 16 Feb 2023 at 18:43, Pedro Miguel Justo <pmsjt@texair.net> wrote:
>>
>> Hi Ard.
>>
>> John is not the "only remaining user". I also reported the problem. I am sorry I don't update the kernel every month. Yes there might have been more than 30 days between updates.
>>
> 
> Thanks for the report.
> 
> Apologies if that sounded a bit callous but it does help get some
> clarity regarding the ia64 situation. Essentially, we have a very
> small number of downstream users but no dedicated developers or
> maintainers. That is still not a great situation.
> 
>> I'd prefer if we don't remove the Itanium McKinley+ support but I'll understand if it must.
>>
> 
> If you are invested in keeping Itanium alive, how much effort would
> you be willing to spend yourself on testing and reviewing Itanium
> changes?

It isn't just that. Trying to build ia64:allmodconfig with gcc 11.2
fails due to build warning(s) which are now errors, and the same
build with gcc 11.3 or later (and binutils 2.32 or later) fails
completely with
     Error: Register number out of range 0..1
and similar all over the place. So there isn't just code bitrot,
there is also compiler and/or binutils bitrot.

Guenter
