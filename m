From: Alexei Gerasimov <alex@netbynet.ru>
Date: Mon, 10 Dec 2007 19:11:14 +0000
Subject: Re: Linux on Intel "Big Sur"
Message-Id: <475DB7BE.5080309@netbynet.ru>
List-Id: <linux-ia64.vger.kernel.org>
References: <475C2CF3.9010206@netbynet.ru>
In-Reply-To: <475C2CF3.9010206@netbynet.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn Helgaas wrote:
> I've only used the HP i2000 version, and even that's been a long time,
> but my guess is that the firmware upgrade would be safe, and that the
> appropriate HP-UX version would probably run on it.
>   
I've discovered a small detail about updates: the firmware update seems
to be safe, but the BIOS update (to the version 1.30) available from the
HP website is marked as for CPU's with C2 stepping. According to my
CPUID, my Itanium's are C0 stepping, therefore an update to the version
dedicated for CPU's with different stepping might be fatal. Personally,
I don't know what stepping is, thus cannot be sure to make any
conclusions. What do you think about this?

Alex.
