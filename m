From: Matt_Domsch@Dell.com
Date: Wed, 13 Mar 2002 18:52:31 +0000
Subject: RE: [Linux-ia64] gcc/binutils bug building parted?
Message-Id: <marc-linux-ia64-105590701905260@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905246@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905246@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> typedef unsigned char guid_t[16];
> #define EFI_GUID(a,b,c,b0,b1,b2,b3,b4,b5,b6,b7)		

I meant to do this in the kernel's fs/partition/efi.[ch] files too, but
never got around to it...  Back on the TODO list.

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ lists.us.dell.com
#1 US Linux Server provider for 2001!

