From: Matt Domsch <Matt_Domsch@dell.com>
Date: Thu, 16 Oct 2003 19:53:36 +0000
Subject: Re: BUG 2.4.23-pre6 megaraid2 fails to build
Message-Id: <marc-linux-ia64-106633487525851@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106632918018841@msgid-missing>
In-Reply-To: <marc-linux-ia64-106632918018841@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> FYI, In case anyone cares about megaraid2, it fails to build for ia64
> from bjorns linux-ia64-2.4 bk tree. I've got too many other things
> to chase this now.

I've sent Marcelo the fix for this, LSI forgot to include the "use the 
io_request_lock" patch when they submitted it.

Looks fixed in BK-current.

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com


