From: Christoph Hellwig <hch@caldera.de>
Date: Thu, 25 Oct 2001 06:44:51 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.13)
Message-Id: <marc-linux-ia64-105590698805393@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 24, 2001 at 09:30:42PM -0700, David Mosberger wrote:
> 	- half-hearted attempt add supporting reading of "default LDT entry" in ia32
> 	  modify_ldt() syscall; someone who understands what this is supposed to do
> 	  should take a look at this...

This is just needed for Xenix/286 binary emulation - I doubt we want to run
x286emul on ia64 anytime soon 8)

	Christoph

-- 
Of course it doesn't work. We've performed a software upgrade.

