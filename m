From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 24 Jun 2008 17:56:19 +0000
Subject: RE: [PATCH 3/14] arch/ia64: Eliminate NULL test and memset after
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3062D2476@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0806241021360.26777@ask.diku.dk>
 <57C9024A16AD2D4C97DC78E552063EA3062D2438@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA3062D2438@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Julia Lawall <julia@diku.dk>, "akinobu.mita@gmail.com" <akinobu.mita@gmail.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>

> In addition the current alloc_bootmem() is a macro that uses __alloc_bootmem
> which most defintely can return NULL.

        ...
        panic("Out of memory");
        return NULL;
}

Oops ... that "panic" call before the "return NULL" makes the
above statement totally wrong.

-Tony
