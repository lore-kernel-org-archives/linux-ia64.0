From: Matt_Domsch@Dell.com
Date: Tue, 13 Aug 2002 22:38:11 +0000
Subject: [Linux-ia64] move asm-ia64/efi.h to linux/efi.h ?
Message-Id: <marc-linux-ia64-105590701905936@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David, any further thoughts on moving include/asm-ia64/efi.h to linux/efi.h?
Now that EFI GUID Partition Tables are part of the stock 2.4 and 2.5 kernel
series, and can be (and will be!) used on x86 platforms too, several people
have commented on l-k this week that it doesn't make sense to keep it in
asm-ia64.  I agree.  There's also no ia64-specific code in there.

I'd be happy to work up a patch to move it if there was a chance it would be
accepted and submitted to Marcelo and Linus.

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer, Lead Engineer, Architect
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
#1 US Linux Server provider for 2001 and Q1/2002! (IDC May 2002)




