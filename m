From: "Chris Hyser" <chrish@fc.hp.com>
Date: Thu, 18 May 2000 18:11:20 +0000
Subject: RE: [Linux-ia64] How do I set variables in efishell?
Message-Id: <marc-linux-ia64-105590678205093@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205073@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205073@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi All,

> -----Original Message-----
> From: linux-ia64-admin@linuxia64.org
> [mailto:linux-ia64-admin@linuxia64.org]On Behalf Of Christoph Rohland
> Sent: Tuesday, May 09, 2000 3:02 AM
> To: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] How do I set variables in efishell?
>
>
> Hi all,
>
> I still do not know how to set variables in efishell to switch the
> console to my serial device.
>
> I actually know that I have to set the variables ConIn and ConOut. But
> I am prettty confused by any documentation I can find about actually
> setting these variables.
>
> Any help appreciated

Has anybody figured this out yet? Specifically, there is a "set" command in
the EFI shell, but the difficulty seems to be figuring out the device path
to actually set the variables to. Then of course this early firmware may end
up ignoring them anyway. Thoughts?

---
Best Regards
Chris Hyser
Hewlett-Packard



