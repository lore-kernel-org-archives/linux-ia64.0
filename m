From: Keith Owens <kaos@sgi.com>
Date: Sun, 29 Aug 2004 07:22:32 +0000
Subject: Re: Latest Altix I/O code reorganization code
Message-Id: <30024.1093764152@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Sun, 29 Aug 2004 09:16:35 +0200."
             <20040829071635.GB7325@mars.ravnborg.org> 
References: <412F4EC9.7050003@sgi.com>
In-Reply-To: <412F4EC9.7050003@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Christoph Hellwig <hch@infradead.org>, Patrick Gefre <pfg@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, 29 Aug 2004 09:16:35 +0200, 
Sam Ravnborg <sam@ravnborg.org> wrote:
>On Sun, Aug 29, 2004 at 04:39:34PM +1000, Keith Owens wrote:
>> On Fri, 27 Aug 2004 17:21:31 +0100, 
>> Christoph Hellwig <hch@infradead.org> wrote:
>> >all files: lots of missing statics, try running
>> >http://samba.org/ftp/unpacked/junkcode/findstatic.pl over the compiled code.
>> 
>> ftp://ftp.ocs.com.au/pub/namespace.pl does a more rigorous check for
>> symbols that can be static.  namespace.pl knows about the special
>> kernel symbols, linkage and EXPORT_SYMBOL().
>
>Should we add it to the support scripts in the kernel?
>Something like: 
>
>make checknamespace

Funny about that ... I was making a patch to send to you and akpm when
your mail arrived.

