From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 24 Mar 2003 21:57:07 +0000
Subject: Re: [Linux-ia64] [TRIVIAL PATCH] Cross-compile fix
Message-Id: <marc-linux-ia64-105590723705307@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705294@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705294@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 23 Mar 2003 20:11:25 +0100 (CET), Wolfgang Mauerer <wolfgang@top.mynetix.de> said:

  Wolfgang> Hello,
  Wolfgang> the attached patch (against bk-current) fixes a cross 
  Wolfgang> compilation problem by using the target specific objdump 
  Wolfgang> tool instead of the host specific one.

Looks good to me.  Applied.

Thanks,

	--david

