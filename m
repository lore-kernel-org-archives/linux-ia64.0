From: Christian Hildner <christian.hildner@hob.de>
Date: Tue, 08 Feb 2005 07:51:32 +0000
Subject: Re: Kernel 2.4.21 gives kernel panic at boot time
Message-Id: <42086F84.70803@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050207061424.58043.qmail@web51110.mail.yahoo.com>
In-Reply-To: <20050207061424.58043.qmail@web51110.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

baswaraj kasture schrieb:

>Thanks Christian, It worked for me.
>But (just for curacity), i didn't understood why it
>worked when i put scsi driver + mpt into the kernel  ?
>What is the problem with initrd ?
>
One thing in the make chain went wrong. Maybe you didn't make clean, or 
the config changed, or there were modules from earlier build found or ...

Christian

