From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 02 Oct 2001 05:20:56 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.10)
Message-Id: <marc-linux-ia64-105590698805285@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

2.4.10-ia64-010924 incorrectly patches include/asm-alpha/processor.h
and include/asm-i386/processor.h, partially duplicating code that is
already in Linus's tree.  Completely delete those sections of the
2.4.10-ia64-010924 patch.


