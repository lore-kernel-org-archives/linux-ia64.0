From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 09 Nov 2006 13:19:04 +0000
Subject: Re: elilo.efi causing Kernel Panic
Message-Id: <20061109131903.GM16952@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061109124221.GL16952@parisc-linux.org>
In-Reply-To: <20061109124221.GL16952@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 09, 2006 at 06:40:59PM +0530, Karthik Gopalakrishnan wrote:
> When I booted from the original elilo.efi binary, the console log was
> a bit different. I have listed it below. My efi binary seems to have
> detected some RAM Disk when this one doesn't. Hope this helps.

Yep, this is a known bug in some versions of elilo.  3.6 should have
this fixed ... if not, let us know.
