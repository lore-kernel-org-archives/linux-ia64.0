From: Helge Deller <deller@gmx.de>
Date: Wed, 20 Sep 2017 17:53:49 +0000
Subject: Re: [RFC][PATCH v2 7/7] checkpatch: add pF/pf deprecation warning
Message-Id: <ddf9b54b-34d9-c1e2-e34f-a1cc055b8cf7@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170920162910.32053-1-sergey.senozhatsky@gmail.com>
 <20170920162910.32053-8-sergey.senozhatsky@gmail.com>
 <1505929138.12311.5.camel@perches.com>
In-Reply-To: <1505929138.12311.5.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, James Bottomley <jejb@parisc-linux.org>
Cc: Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@canonical.com>

On 20.09.2017 19:38, Joe Perches wrote:
> On Thu, 2017-09-21 at 01:29 +0900, Sergey Senozhatsky wrote:
>> We deprecated '%pF/%pf' printk specifiers, since '%pS/%ps' is now smart
>> enough to handle function pointer dereference on platforms where such
>> dereference is required.
>>
>> checkpatch warning example:
>>
>> WARNING: Use '%pS/%ps' instead. This pointer extension was deprecated: '%pF'
> 
> If this series is accepted,  I think this message
> is unclear and would prefer something like:

Is it worth to mention, that it's still needed in older kernels?
Just in case some patch get's backported.

Helge
