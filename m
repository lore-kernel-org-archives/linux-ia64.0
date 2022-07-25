From: Ben Dooks <ben.dooks@codethink.co.uk>
Date: Mon, 25 Jul 2022 20:48:28 +0000
Subject: Re: [PATCH] profile: setup_profiling_timer() is moslty not implemented
Message-Id: <a5b079bb-64ab-092d-27d4-d32d0d35afcb@codethink.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220721195509.418205-1-ben-linux@fluff.org>
 <20220725123948.f16674b10022404814161d4a@linux-foundation.org>
In-Reply-To: <20220725123948.f16674b10022404814161d4a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Ben Dooks <ben-linux@fluff.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-riscv@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, linux-parisc@vger.kernel.org, openrisc@lists.librecores.org, linux-ia64@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-csky@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-snps-arc@lists.infradead.org, linux-alpha@vger.kernel.org

On 25/07/2022 20:39, Andrew Morton wrote:
> On Thu, 21 Jul 2022 20:55:09 +0100 Ben Dooks <ben-linux@fluff.org> wrote:
> 
>> The setup_profiling_timer() is mostly un-implemented by many
>> architectures. In many places it isn't guarded by CONFIG_PROFILE
>> which is needed for it to be used. Make it a weak symbol in
>> kernel/profile.c and remove the 'return -EINVAL' implementations
>> from the kenrel.
>>
>> There are a couple of architectures which do return 0 from
>> the setup_profiling_timer() function but they don't seem to
>> do anything else with it. To keep the /proc compatibility for
>> now, leave these for a future update or removal.
>>
>> On ARM, this fixes the following sparse warning:
>> arch/arm/kernel/smp.c:793:5: warning: symbol 'setup_profiling_timer' was not declared. Should it be static?
> 
> I'll grab this.
> 
> We have had some problems with weak functions lately.  See
> 
> https://lore.kernel.org/all/87ee0q7b92.fsf@email.froward.int.ebiederm.org/T/#u
> 
> Hopefully that was a rare corner case.

Great, thanks.

-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius

https://www.codethink.co.uk/privacy.html
