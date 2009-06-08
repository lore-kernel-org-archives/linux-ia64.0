From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 08 Jun 2009 16:33:31 +0000
Subject: RE: [PATCH 2/6] headers_check fix: ia64, fpswa.h
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3A89196D0@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1244118232.5172.26.camel@ht.satnam>
 <1244118476.5172.29.camel@ht.satnam> <1244118599.5172.31.camel@ht.satnam>
 <20090604202212.GD13892@uranus.ravnborg.org>
In-Reply-To: <20090604202212.GD13892@uranus.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sam Ravnborg <sam@ravnborg.org>, Jaswinder Singh Rajput <jaswinder@kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

> Tony - is this file really used from userspace.
> Looking at the definitions I think not.
>
> I not then the real fix is to unexport it.

Sam,

FPSWA should be completely invisible to user space.  You are correct that the
right fix is to unexport it.

-Tony
