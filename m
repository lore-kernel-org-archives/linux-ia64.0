From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 05 Oct 2004 15:50:46 +0000
Subject: Re: [PATCH] 2.6 SGI Altix I/O code reorganization
Message-Id: <20041005165046.A19870@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410042157.i94Lv7UC104750@fsgi900.americas.sgi.com>
In-Reply-To: <200410042157.i94Lv7UC104750@fsgi900.americas.sgi.com>; from pfg@sgi.com on Mon, Oct 04, 2004 at 04:57:06PM -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>
Cc: tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Also is there any chance you can move the additional rrb allocation for
the qlogic adapters into the prom so the driver doesn't have to bother
with it?  That way the whole SN_SAL_IOIF_RRB_ALLOC could go away.

