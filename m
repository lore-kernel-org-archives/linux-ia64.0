From: "Ross Ridge" <ross@sitraka.com>
Date: Mon, 06 Nov 2000 15:51:18 +0000
Subject: Re: [Linux-ia64] RE: Out of memory panic on boot...
Message-Id: <marc-linux-ia64-105590678205658@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205657@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205657@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ken Hill writes:
> sounds like you copied the kernel to /boot/efi using the copy
> command instead of using cat.

Just out of curiousity does anyone know why using "cp" rather than
"cat" would be a problem?  I can't find anything in the archives for
this mailing list explaining the problem.  My only guess is some sort
of bug involving sparse files.

                              Ross Ridge



