From: Keith Owens <kaos@sgi.com>
Date: Sun, 29 Aug 2004 06:39:34 +0000
Subject: Re: Latest Altix I/O code reorganization code
Message-Id: <28819.1093761574@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Fri, 27 Aug 2004 17:21:31 +0100."
             <20040827172131.A473@infradead.org> 
References: <412F4EC9.7050003@sgi.com>
In-Reply-To: <412F4EC9.7050003@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: Patrick Gefre <pfg@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 27 Aug 2004 17:21:31 +0100, 
Christoph Hellwig <hch@infradead.org> wrote:
>all files: lots of missing statics, try running
>http://samba.org/ftp/unpacked/junkcode/findstatic.pl over the compiled code.

ftp://ftp.ocs.com.au/pub/namespace.pl does a more rigorous check for
symbols that can be static.  namespace.pl knows about the special
kernel symbols, linkage and EXPORT_SYMBOL().

