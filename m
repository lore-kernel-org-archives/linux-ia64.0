From: Khalid Aziz <khalid@fc.hp.com>
Date: Fri, 12 Jul 2002 20:46:16 +0000
Subject: Re: [Linux-ia64] [PATCH] make xconfig broken in ia64-020622
Message-Id: <marc-linux-ia64-105590701905776@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905745@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905745@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> 
> 
> If nobody wants to fix this problem, perhaps what we should do is
> change "make xconfig" so it just prints a message telling the user to
> do "make menuconfig" instead.  Other suggestions (and particular patches)
> are welcome...

It might not be a bad idea to do this anyway until xconfig is fixed. If
xconfig never gets fixed, the message to use menuconfig will stay in
permanently.

-- 
Khalid

==================================
Khalid Aziz                                   Linux Systems Division
(970)898-9214                                        Hewlett-Packard
khalid@fc.hp.com                                    Fort Collins, CO

