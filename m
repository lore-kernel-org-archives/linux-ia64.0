From: Andrew Morton <akpm@osdl.org>
Date: Tue, 20 Jan 2004 17:00:04 +0000
Subject: Re: [patch] 2.6.1-mm5 compile do not use shared extable code for
Message-Id: <20040120090004.48995f2a.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <E1Aiuv7-0001cS-00@jaguar.mkp.net>
In-Reply-To: <E1Aiuv7-0001cS-00@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@trained-monkey.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, paulus@samba.org

Jes Sorensen <jes@trained-monkey.org> wrote:
>
> The new sort_extable and shares search_extable code doesn't work on
>  ia64.

hm, OK.  It would be nice if ia64 could use the generic code at some stage,
of course.

One wonders why the linker dragged lib/extable.c in at all.  Or does it fail at
compile time?


