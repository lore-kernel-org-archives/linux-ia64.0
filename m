From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 06 Aug 2004 13:55:28 +0000
Subject: Re: Altix I/O code reorganization
Message-Id: <20040806145528.A10251@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040806141836.A9854@infradead.org> <8831.1091800314@ocs3.ocs.com.au>
In-Reply-To: <8831.1091800314@ocs3.ocs.com.au>; from kaos@sgi.com on Fri, Aug 06, 2004 at 11:51:54PM +1000
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos@sgi.com>
Cc: Pat Gefre <pfg@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Aug 06, 2004 at 11:51:54PM +1000, Keith Owens wrote:
> No.  We have had this discussion before - kdb is an extensible
> debugger.  Subsystems can add their own kdb commands to decode their
> own data.  Those extensions to kdb belong in the subsystem code, not in
> the main kdb patch.

They do not belong into mainline.  kdb isn't in mainline and we shouldn't
carry code for it around.  I don't care whether you want it in the kdb patch
or whatether it's in a separate one.
