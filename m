From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 09 Apr 2017 08:27:52 +0000
Subject: Re: [PATCH v3] ia64: fix module loading for gcc-5.4
Message-Id: <79cc2afd-1655-c276-a53f-2e2202a7e0ee@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <to=<20170408081449.4872-1-slyfox@gentoo.org>
 <20170408195318.18080-1-slyfox@gentoo.org>
In-Reply-To: <20170408195318.18080-1-slyfox@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Sergei Trofimovich <slyfox@gentoo.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Fenghua Yu <fenghua.yu@intel.com>, "H . J . Lu" <hjl.tools@gmail.com>, Tony Luck <tony.luck@intel.com>

> Starting from gcc-5.4+ gcc generates MLX

How do you think about to omit the plus character?


> instructions in more cases to refer local
> symbols:

I wonder about your choice of a line length limit here.


> That caused ia64 module loader to choke
> on such instructions:
>     fuse: invalid slot number 1 for IMM64

Why does it matter to check such a value?


> … That limitation was fixed in linux by

Would it be nicer to write “in corresponding source code by the”?


> Change since v2: checkpatched, fixed typos by found by Markus Elfring

Does this version information contain an unwanted word repetition?
How does it fit to the identifier “v3” in the commit subject?

Regards,
Markus
