From: Keith Owens <kaos@sgi.com>
Date: Fri, 06 Aug 2004 13:51:54 +0000
Subject: Re: Altix I/O code reorganization
Message-Id: <8831.1091800314@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Fri, 06 Aug 2004 14:18:36 +0100."
             <20040806141836.A9854@infradead.org> 
References: <200408042014.i74KE8fD141211@fsgi900.americas.sgi.com>
In-Reply-To: <200408042014.i74KE8fD141211@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: Pat Gefre <pfg@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 6 Aug 2004 14:18:36 +0100, 
Christoph Hellwig <hch@infradead.org> wrote:
>008-kdb-support-funtions:
>  kdb isn't in mainline, please add the two files to the kdb patch instead

No.  We have had this discussion before - kdb is an extensible
debugger.  Subsystems can add their own kdb commands to decode their
own data.  Those extensions to kdb belong in the subsystem code, not in
the main kdb patch.

