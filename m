From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 03 May 2006 18:48:37 +0000
Subject: Re: strcpy returns NULL pointer and not destination pointer
Message-Id: <20060503184837.GC9609@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060503133806.GC19859@localhost>
In-Reply-To: <20060503133806.GC19859@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 03, 2006 at 11:46:07AM -0700, Chen, Kenneth W wrote:
> - * 	0 if success, or number of byte NOT copied if error occurred.
> + *	for memcpy:    retrun dest

typo

