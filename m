From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 22 Jul 2004 19:42:31 +0000
Subject: Re: Altix I/O code re-org
Message-Id: <20040722194231.GA16991@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407221514.i6MFEVag084696@fsgi900.americas.sgi.com> <200407221357.53404.jbarnes@engr.sgi.com> <20040722192003.GA617@lnx-holt.americas.sgi.com> <20040722194050.GA797@lnx-holt.americas.sgi.com>
In-Reply-To: <20040722194050.GA797@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: Jesse Barnes <jbarnes@engr.sgi.com>, Pat Gefre <pfg@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

> PS:  I found a few small problems with the bte code and will soon have
> another patch that fixes that up.  Specifically, there were changes
> made to bte_error.c and pda.h that are undone by your patch.

apropos bte, could you please merge bte_error.c into bte.c - there's no
external callers of functions in bte_error.c except in bte.c

