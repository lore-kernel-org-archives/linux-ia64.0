From: Michael Madore <mmadore@turbolinux.com>
Date: Wed, 16 Jan 2002 19:13:58 +0000
Subject: Re: [Linux-ia64] PXE Boot
Message-Id: <marc-linux-ia64-105590698805853@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805846@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805846@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Where can I get the source for aftpd?

Mike

Egan Ford wrote:
> 
> I cannot tell you what the problem is, but can tell you what I do:
> 
> Here is my DHCP entry (I still use DHCP v2):
> 
>         subnet 199.88.179.0 netmask 255.255.255.0 {
>                 default-lease-time              -1;
>                 option routers                  199.88.179.1;
>                 option subnet-mask              255.255.255.0;
>                 option nis-domain                       "sensenet";
>                 option domain-name              "sense.net";
>                 option domain-name-servers      199.88.179.22;
>                 option time-offset              -7;
> 
>                 host node8 {
>                         hardware ethernet 00:03:47:13:83:3F;
>                         fixed-address 199.88.179.208;
>                         filename "/tftpboot/elilo.efi";
>                         next-server 199.88.179.22;
>                 }
>         }
> 
> I use atftpd as my tftpd server.  I have tested and used elilo 2.5 and 3.x
> with no problems.

