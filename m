From: Petr Tesarik <ptesarik@suse.cz>
Date: Thu, 22 May 2008 12:12:47 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a
Message-Id: <1211458368.5610.36.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	 <1211446045.5610.33.camel@elijah.suse.cz>
	 <3877989d0805220216o5add20ddye2a1fde98a0c1e69@mail.gmail.com>
	 <20080522111826.BB90326FA24@magilla.localdomain>
In-Reply-To: <20080522111826.BB90326FA24@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland McGrath <roland@redhat.com>
Cc: Luming Yu <luming.yu@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Thu, 2008-05-22 at 04:18 -0700, Roland McGrath wrote:
> I really cannot figure out from anything you've said what the failure mode
> is or how you think it should be affected.

At least you should be able to see the related bug report at:

https://bugzilla.redhat.com/show_bug.cgi?idD6200

I'm getting Access Denied. :(

Petr Tesarik

