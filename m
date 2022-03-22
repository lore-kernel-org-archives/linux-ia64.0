From: Randy Dunlap <rdunlap@infradead.org>
Date: Tue, 22 Mar 2022 01:41:49 +0000
Subject: Re: [PATCH] Docs: admin/kernel-parameters: edit a few boot options
Message-Id: <ffe0183c-7e48-2ac7-9c69-ca87d98c442a@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220321012216.23724-1-rdunlap@infradead.org>
 <87ils6hl1z.fsf@mpe.ellerman.id.au>
In-Reply-To: <87ils6hl1z.fsf@mpe.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>, linux-kernel@vger.kernel.org
Cc: Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, linux-s390@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, "Rafael J. Wysocki" <rafael@kernel.org>, Pavel Machek <pavel@ucw.cz>, Len Brown <lenb@kernel.org>, linux-pm@vger.kernel.org, linux-acpi@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org



On 3/21/22 17:45, Michael Ellerman wrote:
> Randy Dunlap <rdunlap@infradead.org> writes:
>> Clean up some of admin-guide/kernel-parameters.txt:
>>
>> a. "smt" should be "smt=" (S390)
>> b. add "smt-enabled" for POWERPC
> 
> I'd rather you didn't. It's not well tested and we ignore it entirely on
> some platforms because it causes bugs. Eventually I'd like to remove it.
> 
> If we ever get time we'd want to support the generic `nosmt` argument
> instead.

No problem. Thanks for replying.

-- 
~Randy
