From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 02 Oct 2001 05:50:42 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.10)
Message-Id: <marc-linux-ia64-105590698805287@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

2.4.10-ia64-010924 patches drivers/acpi/Makefile to add driver.o to a
list of objects.  That is no longer required, Linus's tree already has
the required code a couple of lines below.


