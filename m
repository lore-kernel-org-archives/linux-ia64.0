From: Matt_Domsch@Dell.com
Date: Thu, 14 Feb 2002 19:05:15 +0000
Subject: RE: [Linux-ia64] [PATCH] linux/fs/partitions/efi.c error handling
Message-Id: <marc-linux-ia64-105590701905096@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698806044@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698806044@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I got random pointer dereference problems, and was apparently having
> data structures freed out from under them.  Turns out the
> find_valid_gpt() was freeing data structures more than once and
> passing back pointers to freed structures.  Patch below.

Mia culpa.  Pass the brown paper bag.  Thanks for the fix.
-Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions www.dell.com/linux
#1 US Linux Server provider with 24.5% (IDC Dec 2001)
#2 Worldwide Linux Server provider with 18.2% (IDC Dec 2001)

