From: "Hiram Clawson, 831-427-7519" <hiramc@sco.COM>
Date: Thu, 15 Jun 2000 20:33:50 +0000
Subject: Re: [Linux-ia64] Disable VGA on motherboard ?
Message-Id: <marc-linux-ia64-105590678205151@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205147@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205147@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks for the idea JE.  This was the problem, the video card
has to be in slot one nearest the existing video connectors.
It just works when placed there, no BIOS adjustment needed.

--Hiram - hiramc@sco.com

 Date: Thu, 15 Jun 2000 11:48:42 -0700
 From: Johannes Erdfelt <jerdfelt@valinux.com>
 To: "Hiram Clawson, 831-427-7519" <hiramc@sco.com>
 Cc: linux-ia64@linuxia64.org
 Subject: Re: [Linux-ia64] Disable VGA on motherboard ?
 
 We've done this with the Lion without any problems. We didn't need to
 configure anything in the BIOS either.
 
 I do think you need to place the video card in a specific set of slots.
 I'll check on that.
 
 JE
 
 


