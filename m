From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Wed, 25 Jul 2001 15:29:29 +0000
Subject: Re: [Linux-ia64] Big problems with 2.4.7
Message-Id: <marc-linux-ia64-105590693005913@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005908@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005908@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Alex,

thanks for helping.

>    Ok, perhaps you can disregard my suspicion about the I/O port base,

I just tried that. As you just said, it doesn't help.
The printk output is also lost because it comes so early, and there's
a lot more stuff to follow ...

My firmware version string is S460AC4a.86B.0083.B.0106070029.

I am going to try your patch next.

Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113




