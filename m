From: Robin Holt <holt@sgi.com>
Date: Thu, 22 Jul 2004 19:40:50 +0000
Subject: Re: Altix I/O code re-org
Message-Id: <20040722194050.GA797@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407221514.i6MFEVag084696@fsgi900.americas.sgi.com> <200407221357.53404.jbarnes@engr.sgi.com> <20040722192003.GA617@lnx-holt.americas.sgi.com>
In-Reply-To: <20040722192003.GA617@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: Jesse Barnes <jbarnes@engr.sgi.com>, Pat Gefre <pfg@sgi.com>, linux-ia64@vger.kernel.org, hch@infradead.org, linux-kernel@vger.kernel.org

Pat,

I have a set of patches that cleanly applies against the
http://linux.bkbits.net/linux-2.5 bitkeeper tree using quilt.  They are
not available for the rest of the world yet.  Could you move them from
~holt/ioif to the project's ftp directory on oss.sgi.com?

Thanks,
Robin

PS:  I found a few small problems with the bte code and will soon have
another patch that fixes that up.  Specifically, there were changes
made to bte_error.c and pda.h that are undone by your patch.
