From: Johannes Erdfelt <jerdfelt@valinux.com>
Date: Thu, 15 Jun 2000 18:48:42 +0000
Subject: Re: [Linux-ia64] Disable VGA on motherboard ?
Message-Id: <marc-linux-ia64-105590678205148@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205147@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205147@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jun 15, 2000, Hiram Clawson, 831-427-7519 <hiramc@sco.COM> wrote:
> 
> Has anyone successfully turned off the motherboard
> VGA graphics system and used a plug in video board ?
> I have set the BIOS setup option to "Absent" for
> on-board VGA, but it continues to be used.
> This is a server version of the SDV.

We've done this with the Lion without any problems. We didn't need to
configure anything in the BIOS either.

I do think you need to place the video card in a specific set of slots.
I'll check on that.

JE



