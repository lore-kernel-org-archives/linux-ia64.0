From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 09 Apr 2017 09:02:43 +0000
Subject: Re: ia64: fix module loading for gcc-5.4
Message-Id: <bc2dbb55-54b3-e62e-a54f-aa1bbbc3aa5f@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <to=<20170408081449.4872-1-slyfox@gentoo.org>
 <20170408195318.18080-1-slyfox@gentoo.org>
 <79cc2afd-1655-c276-a53f-2e2202a7e0ee@users.sourceforge.net>
 <20170409095121.5f0b6a1e@sf>
In-Reply-To: <20170409095121.5f0b6a1e@sf>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Trofimovich <slyfox@gentoo.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Fenghua Yu <fenghua.yu@intel.com>, "H . J . Lu" <hjl.tools@gmail.com>, Tony Luck <tony.luck@intel.com>

>>> That caused ia64 module loader to choke
>>> on such instructions:
>>>     fuse: invalid slot number 1 for IMM64  
>>
>> Why does it matter to check such a value?
> 
> I'm not sure I follow the question. Is your question about
> linux kernel relocation code handler, gcc or ia64 instruction format?

I am just curious if this source code could also work without
the mentioned check.
Would it make sense to check more than two values there?

Regards,
Markus
