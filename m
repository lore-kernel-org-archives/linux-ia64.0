From: Keith Owens <kaos@ocs.com.au>
Date: Sat, 10 Nov 2001 04:59:31 +0000
Subject: Re: [Linux-ia64] adding new network device driver
Message-Id: <marc-linux-ia64-105590698805464@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805461@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805461@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 9 Nov 2001 16:08:06 -0800 (PST), 
Gururaj Ananthateerta <gururaj@cup.hp.com> wrote:
>When I boot with new kernel my driver probe routine is not entered. 
>Is there anyplace I need to inform the kernel about the existence 
>of the new driver.

linux/Documentation/DocBook/kernel-hacking.tmpl, __initcall and friends.


