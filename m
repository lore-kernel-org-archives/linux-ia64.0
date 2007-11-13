From: Kyle McMartin <kyle@mcmartin.ca>
Date: Tue, 13 Nov 2007 15:20:49 +0000
Subject: Re: [patch 1/1] ia64: export copy_page() to modules
Message-Id: <20071113152049.GA23691@fattire.cabal.ca>
List-Id: <linux-ia64.vger.kernel.org>
References: <200711130929.lAD9Tmmh003824@imap1.linux-foundation.org>
In-Reply-To: <200711130929.lAD9Tmmh003824@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Nov 13, 2007 at 01:22:51AM -0800, akpm@linux-foundation.org wrote:
> To do this we need to move the copy_page() functions out of lib.a and into
> built-in.a, and create a silly little C file to add the EXPORT_SYMBOL().
> 

The usual thing to do for an export for an assembly file is to put it
into $arch_ksyms.c

Cheers,
	Kyle

> Maybe there are better ways...
> 
> Cc: Sam Ravnborg <sam@ravnborg.org>
> Cc: "Luck, Tony" <tony.luck@intel.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
