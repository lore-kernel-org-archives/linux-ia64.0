From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 18 Oct 2007 16:02:42 +0000
Subject: Re: [PATCH] ptrace RSE bug
Message-Id: <20071018160242.GA19432@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Just as a little notice, we now have the arch_ptrace_attach that
allows switching to the generic ptrace once the RSE bits are
settled.  It would be nice if the people working on this area
could do that conversion aswell.

