From: Sam Ravnborg <sam@ravnborg.org>
Date: Thu, 06 Dec 2007 22:28:36 +0000
Subject: Re: [patch 2/3] ia64: don't assume that unwcheck.py is executable
Message-Id: <20071206222836.GA25209@uranus.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200712052232.lB5MWE3W028394@imap1.linux-foundation.org>
In-Reply-To: <200712052232.lB5MWE3W028394@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Dec 06, 2007 at 02:05:15PM -0800, Luck, Tony wrote:
> > What was the exact reason switching to phython and can we do the same in perl?
> 
> It was a shell script (using awk) before it was pythonised. The
> motivation was correct functionality when cross-building on a
> 32-bit host.  Here's the commit:
> 
>  http://tinyurl.com/28hmoc

If you read the comments in the phyton file is says:
+# Based on a shell/awk script originally written by Harish Patil,
+# which was converted to Perl by Matthew Chapman, which was converted
+# to Python by David Mosberger.

So somewhere a perl variant has existed.

	Sam
