From: Sam Ravnborg <sam@ravnborg.org>
Date: Mon, 25 Aug 2003 19:08:40 +0000
Subject: Re: [PATCH] ia64/lib/Makefile: use call-if-changed
Message-Id: <marc-linux-ia64-106183855212801@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106183721811204@msgid-missing>
In-Reply-To: <marc-linux-ia64-106183721811204@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 25, 2003 at 07:42:09PM +0100, Matthew Wilcox wrote:
> 
> Sam, how does this look?

Good - and you included FORCE which is a typical mistake to forget.
An additional advantage obtained using 'if_changed_dep' is that kbuild will
check dependencies - thats only asm/asmmacro.h - but it is worth it.

	Sam
