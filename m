From: Randy Dunlap <rdunlap@infradead.org>
Date: Tue, 22 Mar 2022 19:36:52 +0000
Subject: Re: [PATCH] Docs: admin/kernel-parameters: edit a few boot options
Message-Id: <adfeb8bb-50b3-7ff3-a55f-19fc23cd1121@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220321012216.23724-1-rdunlap@infradead.org>
 <CAJZ5v0jBFOWZZrGuBb0GyJa3rKRwSYXrMFOtGu8jLnQ+OPtXHw@mail.gmail.com>
In-Reply-To: <CAJZ5v0jBFOWZZrGuBb0GyJa3rKRwSYXrMFOtGu8jLnQ+OPtXHw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, linux-s390@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-ia64@vger.kernel.org, Pavel Machek <pavel@ucw.cz>, Len Brown <lenb@kernel.org>, Linux PM <linux-pm@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>



On 3/22/22 10:41, Rafael J. Wysocki wrote:
> On Mon, Mar 21, 2022 at 2:22 AM Randy Dunlap <rdunlap@infradead.org> wrote:
>> Clean up some of admin-guide/kernel-parameters.txt:
>>
>> a. "smt" should be "smt=" (S390)
>> b. add "smt-enabled" for POWERPC
>> c. Sparc supports the vdso= boot option
>> d. make the tp_printk options (2) formatting similar to other options
>>    by adding spacing
>> e. add "trace_clock=" with a reference to Documentation/trace/ftrace.rst
>> f. use [IA-64] as documented instead of [ia64]
>> g. fix formatting and text for test_suspend> This ->
> 
>> h. fix formatting for swapaccount>> i. fix formatting and grammar for video.brightness_switch_enabled> -> and the last one are fine with me, but I suppose that there will be a v2?

Yes, there will be a v2.

thanks.

-- 
~Randy
